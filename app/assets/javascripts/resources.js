/**
 * Used in add and edit view.
 */
var ResourceForm = {

    init: function() {
        $(document).on('PSAPFormSectionAdded', function() {
            ResourceForm.attachEventListeners();

            // this is necessary per http://getbootstrap.com/javascript/#scrollspy
            $('[data-spy="scroll"]').each(function () {
                $(this).scrollspy('refresh')
            });
        }).trigger('PSAPFormSectionAdded');

        ResourceForm.initSuggestions();
        ResourceForm.updateDependentQuestions();
        ResourceForm.updateProgress();

        $('button.save').on('click', function() { $('form').submit(); });

        // hide all of the sections except Basic Info
        ResourceForm.hideSections();

        if ($('body#edit_resource').length) {
            ResourceForm.initInitialSelections();
        }
    },

    attachEventListeners: function() {
        $('input[name="format_type"]').on('change', function() {
            ResourceForm.selectFormatType();
        });

        $('button.save').on('click', function(event) {
            if ($('form#new_resource').length) {
                $('form#new_resource').submit();
            } else if ($('form#edit_resource').length) {
                $('form#edit_resource').submit();
            }
        });

        $('select.date_type').on('change', function(event) {
            switch (parseInt(this.value)) {
                case 0: // single
                    $(this).nextAll('div.date:first').show();
                    $(this).nextAll('div.begin_date:first').hide();
                    $(this).nextAll('div.end_date:first').hide();
                    break;
                default: // bulk or inclusive/span
                    $(this).nextAll('div.date:first').hide();
                    $(this).nextAll('div.begin_date:first').show();
                    $(this).nextAll('div.end_date:first').show();
                    break;
            }
            $('input.year').trigger('change');
            $('input.month').trigger('change');
            $('input.day').trigger('change');
        }).trigger('change');

        $('input.year').on('change keyup', function(event) {
            if ($(this).val().length < 1) {
                $(this).closest('.input-group').find('input.month').prop('disabled', true);
                $(this).closest('.input-group').find('input.day').prop('disabled', true);
            } else {
                $(this).closest('.input-group').find('input.month').prop('disabled', false);
            }
        }).trigger('keyup');

        $('input.month').on('change keyup', function(event) {
            $(this).closest('.input-group').find('input.day').prop('disabled',
                ($(this).val().length < 1));
        }).trigger('keyup');

        $(document).on('PSAPAssessmentQuestionsAdded', function() {
            $('.assessment_question input, .assessment_question select').
                on('change', function() {
                ResourceForm.updateDependentQuestions();
                ResourceForm.updateProgress();
                // TODO: check for dependent questions
            });
            ResourceForm.showSections();
            $('body').scrollspy({ target: '#sections' });
        });
    },

    initInitialSelections: function() {
        var onFormatSelected = function() {
            // select the question response options
            $('input[name="selected_option_ids"]').each(function() {
                var selected_id = $(this).val();
                $('[data-type="option"]').each(function() {
                    var form_option_id = $(this).val();
                    if (form_option_id == selected_id) {
                        if ($(this).prop('tagName') == 'SELECT') {
                            $(this).val(form_option_id);
                        } else {
                            $(this).attr('checked', true);
                        }
                    }
                });
            });
        };

        var onFormatCategorySelected = function() {
            $('input[name="selected_format_ids"]').each(function() {
                var id = $(this).val();
                $('select[name="resource[format_id]"] option').each(function() {
                    if ($(this).val() == id) {
                        ResourceForm.selectFormat(id, onFormatSelected);
                    }
                });
            });
        };

        var onFormatTypeSelected = function() {
            $('input[name="selected_format_ids"]').each(function() {
                var id = $(this).val();
                $('select[name="resource[format_id]"] option').each(function() {
                    if ($(this).val() == id) {
                        ResourceForm.selectFormatCategory(id,
                            onFormatCategorySelected);
                    }
                });
            });
        };

        ResourceForm.selectFormatType(
            $('input[name="selected_format_type"]').val(),
            onFormatTypeSelected);
    },

    initSuggestions: function() {
        var institution_url = $('input[name="institution_url"]').val();
        $('input#resource_name').typeahead({
            name: 'names',
            prefetch: institution_url + '/resources/names.json',
            limit: 10
        });
        $('input.resource_subject').typeahead({
            name: 'subjects',
            prefetch: institution_url + '/resources/subjects.json',
            limit: 10
        });

        // fix incompatibilities with bootstrap
        $('.typeahead').parent().css('display', '');
        $('.tt-hint').addClass('form-control');

        $(document).on('PSAPFormSectionAdded', function() {
            ResourceForm.initSuggestions();
        });
    },

    appendSelectToNode: function(node) {
        var select = $('<select>').attr('name', 'resource[format_id]').
            attr('class', 'form-control');
        select.hide();
        node.append(select);
        var prompt = $('<option value=\"\">Select...</option>');
        select.append(prompt);
        return select;
    },

    clearAssessmentQuestions: function() {
        $('div.assessment_question').remove();
        ResourceForm.updateProgress();
    },

    // Transforms an assessment question into HTML for the
    // assessment form.
    htmlForQuestion: function(object, question_index) {
        var control = '';

        switch (object['question_type']) { // corresponds to the AssessmentQuestionType constants
            case 0: // radio
                for (key in object['assessment_question_options']) {
                    var option = object['assessment_question_options'][key];
                    control += '<div class="radio">' +
                            '<label>' +
                                '<input type="radio" ' +
                                    'name="resource[assessment_question_responses][' + question_index + ']" ' +
                                    'data-type="option" ' +
                                    'data-option-score="' + option['value'] + '" data-option-id="' +
                                    option['id'] + '" value="' + option['id'] + '"> ' +
                                option['name'] +
                            '</label>' +
                        '</div>';
                }
                break;
            case 1: // select
                control += '<select class="form-control" data-type="option" ' +
                            'name="resource[assessment_question_responses][' + question_index + ']">';
                for (key in object['assessment_question_options']) {
                    var option = object['assessment_question_options'][key];
                    control += '<option value="' + option['id'] + '" data-option-score="' +
                            option['value'] + '" data-option-id="' + option['id'] + '">' +
                            option['name'] +
                        '</option>';
                }
                control += '</select>';
                break;
            case 2: // checkbox
                for (key in object['assessment_question_options']) {
                    var option = object['assessment_question_options'][key];
                    control += '<div class="checkbox">' +
                            '<label>' +
                                '<input type="checkbox" ' +
                                    'name="resource[assessment_question_responses][' + question_index + ']" ' +
                                    'data-type="option" ' +
                                    'data-option-score="' + option['value'] + '" data-option-id="' +
                                    option['id'] + '" value="' + option['id'] + '"> ' +
                                    option['name'] +
                            '</label>' +
                        '</div>';
                }
                break;
        }

        return '<div class="assessment_question">' +
                '<hr>' +
                '<div class="row depth-0">' +
                    '<div class="col-sm-11">' +
                        '<h3>' + object['name'] + '</h3>' +
                    '</div>' +
                    '<div class="col-sm-1" style="text-align:right">' +
                        '<button type="button" class="btn btn-default help hovertip-fire" ' +
                            'data-container="body" data-toggle="popover" ' +
                            'data-placement="left" data-html="true" ' +
                            'data-content="' + object['help_text'].replace(/"/g, "&quot;").
                            replace("\n", "<br><br>") + '">? ' +
                        '</button>' +
                    '</div>' +
                '</div>' +
                '<div class="row depth-0">' +
                    '<div class="col-sm-12 question">' +
                        control +
                    '</div>' +
                '</div>' +
            '</div>';
    },

    hideSections: function() {
        $('div#sections').hide();
        $('div.section').each(function() {
            if ($(this).attr('id') != 'basic_info') {
                $(this).hide();
            }
        });
    },

    populateSelect: function(select, url, onCompleteCallback) {
        // remove all options except "Select..."
        select.find('*').not(':first').remove();
        $.getJSON(url, function (data) {
            if (data.length == 0) {
                select.remove();
            } else {
                select.prev().attr('name', 'noop');
            }

            var any_subtypes = false;
            $.each(data, function (i, object) {
                if (object['format_subtype']) {
                    any_subtypes = true;
                }
            });
            $.each(data, function (i, object) {
                var option = $('<option>').attr('value',
                    object['id']).text(object['name']);
                if (any_subtypes) {
                    var optgroup = $('optgroup#format-subtype-' +
                        object['format_subtype']);
                    if (optgroup.length < 1) {
                        optgroup = $('<optgroup id="format-subtype-' +
                            object['format_subtype'] + '" label="' +
                            object['readable_format_subtype'] + '"></optgroup>');
                        select.append(optgroup);
                    }
                    optgroup.append(option);
                } else {
                    select.append(option);
                }
            });
            (select.find('option').length < 2) ?
                select.hide() : select.show();

            if (onCompleteCallback) {
                onCompleteCallback();
            }
        });
    },

    selectFormat: function(id, onCompleteCallback) {
        ResourceForm.clearAssessmentQuestions();
        ResourceForm.hideSections();
        if (id) {
            $('select[name="resource[format_id]"]').val(id);

            var url = $('input[name="root-url"]').val() +
                'formats/' + id + '/assessment_questions';
            $.getJSON(url, function (data) {
                $.each(data, function (i, object) {
                    $('div[data-id="' + object['assessment_section_id'] + '"] div.section-questions').
                        append(ResourceForm.htmlForQuestion(object, i));
                });
                if (data.length > 0) {
                    ResourceForm.showSections();
                    $(document).trigger('PSAPAssessmentQuestionsAdded');
                } else {
                    ResourceForm.hideSections();
                }
                ResourceForm.updateProgress();

                if (onCompleteCallback) {
                    onCompleteCallback();
                }
            });
        } else {
            ResourceForm.hideSections();
        }
    },

    selectFormatCategory: function(id, onCompleteCallback) {
        $('select[name="resource[format_id]"] option').each(function() {
            if ($(this).val() == id) {
                $(this).parent().val(id);

                var childSelect = ResourceForm.appendSelectToNode(
                    $(this).parent().parent());
                var url = $('input[name="root-url"]').val() +
                    '/format-types/' +
                    $('input[name="format_type"]:checked').val() +
                    '/formats?parent_id=' + $(this).val();
                ResourceForm.populateSelect(childSelect, url,
                    onCompleteCallback);
            }
        });
    },

    // Format type is one of the radio buttons: A/V, Photo/Image...
    selectFormatType: function(id, onCompleteCallback) {
        if (id) {
            $('input[name="format_type"]').each(function() {
                if ($(this).val() == id) {
                    $(this).attr('checked', true);
                }
            });
        }

        ResourceForm.clearAssessmentQuestions();
        ResourceForm.hideSections();

        // destroy all selects
        $('div.format').find('select').remove();

        var select = ResourceForm.appendSelectToNode($('div.format'));
        var onSelectChanged = function() {
            // destroy all selects after the changed select
            $(this).nextAll('select').remove();
            // create a child select
            var childSelect = ResourceForm.appendSelectToNode(
                $(this).parent());
            var url = $('input[name="root-url"]').val() +
                '/format-types/' +
                $('input[name="format_type"]:checked').val() +
                '/formats?parent_id=' + $(this).val();
            ResourceForm.populateSelect(childSelect, url);
            childSelect.on('change', onSelectChanged);
            if ($(this).attr('name') == 'noop') {
                ResourceForm.selectFormatCategory($(this).val());
            } else {
                ResourceForm.selectFormat($(this).val());
            }
        };
        select.on('change', onSelectChanged);

        var url = $('input[name="root-url"]').val() + '/format-types/' +
            $('input[name="format_type"]:checked').val() + '/formats';
        ResourceForm.populateSelect(select, url, onCompleteCallback);
    },

    showSections: function() {
        $('div#sections').show();
        $('div.section').fadeIn();
    },

    updateDependentQuestions: function() {
        $('div.assessment_question').each(function() {
            var show = true;
            var dependent_option_id = parseInt($(this).attr('data-dependent-option-id'));
            if (dependent_option_id > -1) {
                if (!$('input[data-option-id="' + dependent_option_id + '"]:checked').length
                    && !$('input[data-option-id="' + dependent_option_id + '"]:selected').length) {
                    show = false;
                }
            }
            if (show) {
                $(this).show();
            } else {
                $(this).hide();
            }
        });
    },

    updateProgress: function() {
        var questions = $('.assessment_question');
        var numQuestions = questions.length;
        var numAnsweredQuestions = 0;
        questions.each(function() {
            var numChecked = $(this).find(
                'input[type="radio"]:checked, input[type="checkbox"]:checked').length;
            if (numChecked > 0 || ($(this).find('select').val() !== undefined
                && $(this).find('select').val().length > 0)) {
                numAnsweredQuestions++;
            }
        });

        $('.total-assessment-question-count').text(numQuestions);
        $('.complete-assessment-question-count').text(numAnsweredQuestions);
        $('div.progress-bar.psap-progress').attr('style',
                'width:' + numAnsweredQuestions / numQuestions * 100 + '%');

        // update question counts per-section
        var total = 0;
        $('div.section').each(function() {
            var count = $(this).find('.assessment_question').length;
            $('.nav li[data-section-id="' + $(this).data('id') +
                '"] .assessment-question-count').text(count);
            total += count;
        });

        // Update score bar
        //
        // Formula (from SRS): TODO: this is broken
        //
        // climate control 70% + emergency preparedness 30% =
        // environment (location)
        //
        // format (40%) + environment (location) (10%) + storage/container (5%)
        // + use/access (5%) + condition (40%) = total

        var score = 0;
        var weight_elements = $('.question input[name="weight"]');

        weight_elements.each(function() {
            var weight = $(this).val();

            var input_elem = $(this).parent().find(
                'input[type="radio"]:checked, input[type="checkbox"]:checked, option:selected');
            var response_value = input_elem.attr('data-option-score');

            if (response_value !== undefined) {
                score += (parseFloat(response_value) * parseFloat(weight))
                    / weight_elements.length;
            }
        });

        $('div.progress-bar.score').attr('style', 'width:' + score * 100 + '%');
    }

};

var ready = function() {
    if ($('body#show_resource').length) {
        // vertically center modal panels
        $('.modal').on('show.bs.modal', function() {
            $(this).css('display', 'block');
            var $dialog = $(this).find(".modal-dialog");
            var offset = ($(window).height() - $dialog.height()) / 2;
            // Center modal vertically in window
            $dialog.css("margin-top", offset);
        });

        // show the export notification panel after clicking an export option
        $('a.export').on('click', function() {
            var filename = $(this).attr('data-filename');
            var format = $(this).text();
            setTimeout(function() {
                var alert = $('div#export_notification');
                alert.find('#filename').text(filename);
                alert.find('.format').text(format);
                alert.modal();
            }, 100);
        });
    } else if ($('body#new_resource').length
        || $('body#edit_resource').length) {

        // override bootstrap nav-pills behavior
        $('ul.nav-pills a').on('click', function() {
            window.location.href = $(this).attr('href');
        });

        $('#sections').affix({ // TODO: broken on narrow screens and glitchy on short screens
            offset: {
                top: 220
            }
        });

        $(document).bind('affix.bs.affix', function() {
            //$('#sections').width($('.tab-pane.active').offset().left + 'px');
        });

        ResourceForm.init();
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);
// TODO: destroy event listeners

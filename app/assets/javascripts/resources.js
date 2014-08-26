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
        ResourceForm.initDependentSelects();
        ResourceForm.updateDependentQuestions();
        ResourceForm.updateProgress();

        $('button.save').on('click', function(event) {
            $('div.tab-pane.active form').submit();
        });

        // hide all of the sections except Basic Info
        $('div.section').each(function() {
            if ($(this).attr('id') != 'basic_info') {
                $(this).hide();
            }
        });
    },

    attachEventListeners: function() {
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

        // Format type is one of the radio buttons: A/V, Photo/Image...
        $(document).on('PSAPResourceFormatTypeChanged', function() {
            ResourceForm.clearAssessmentQuestions();
        });

        // Populates the form with assessment questions. Triggered
        // when the resource format is changed.
        $(document).on('PSAPResourceFormatChanged', function() {
            ResourceForm.clearAssessmentQuestions();
            var format_id = $('select[name="resource[format_id]"]').val();
            if (format_id) {
                var url = $('input[name="root-url"]').val() +
                    'formats/' + format_id + '/assessment_questions';
                $.getJSON(url, function (data) {
                    $.each(data, function (i, object) {
                        $('div[data-id="' + object['assessment_section_id'] + '"] form').
                            append(ResourceForm.htmlForQuestion(object));
                    });
                    if (data.length > 0) {
                        $(document).trigger('PSAPAssessmentQuestionsAdded');
                    }
                    ResourceForm.updateProgress();
                });
            }
        });

        $(document).on('PSAPAssessmentQuestionsAdded', function() {
            $('.assessment_question input, .assessment_question select').
                on('change', function() {
                ResourceForm.updateDependentQuestions();
                ResourceForm.updateProgress();
                // TODO: check for dependent questions
            });
            $('div.section').show();
            $('div#sections').show();
        });
    },

    initDependentSelects: function() {
        var appendSelectToNode = function(node) {
            var select = $('<select>').attr('name', 'resource[format_id]').
                attr('class', 'form-control');
            select.hide();
            node.append(select);
            var prompt = $('<option value=\"\">').text('Select...');
            select.append(prompt);
            return select;
        };

        var populateSelect = function(select, url) {
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
                if (select.attr('name') == 'resource[format_id]') {
                    select.on('change', function() {
                        $(document).trigger('PSAPResourceFormatChanged');
                    });
                }
            });
        };

        $('input[name="format_type"]').on('change', function() {
            $(document).trigger('PSAPResourceFormatTypeChanged');

            // destroy all selects
            $(this).parent().nextAll('select').remove();

            var select = appendSelectToNode($(this).parent().parent());

            var url = $('input[name="root-url"]').val() +
                '/format-types/' + $(this).val() + '/formats';
            populateSelect(select, url);

            var onSelectChanged = function() {
                // destroy all selects after the changed select
                $(this).nextAll('select').remove();
                // create a child select
                var childSelect = appendSelectToNode($(this).parent());
                var url = $('input[name="root-url"]').val() +
                    '/format-types/' +
                    $('input[name="format_type"]:checked').val() +
                    '/formats?parent_id=' + $(this).val();
                populateSelect(childSelect, url);
                childSelect.on('change', onSelectChanged);
            };
            select.on('change', onSelectChanged);
        });
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

    clearAssessmentQuestions: function() {
        $('div.assessment_question').remove();
        ResourceForm.updateProgress();
    },

    // Transforms an assessment question into HTML for the
    // assessment form.
    htmlForQuestion: function(object) {
        var control = '';

        switch (object['question_type']) { // corresponds to the AssessmentQuestionType constants
            case 0: // radio
                for (key in object['assessment_question_options']) {
                    var option = object['assessment_question_options'][key];
                    control += '<label>' +
                            '<input type="radio" ' + // TODO: class="form-control"
                                'name="resource[assessment_question_responses_attributes][#{response.id}][assessment_question_option_id]" ' +
                                'data-option-score="' + option['value'] + '" data-option-id="' +
                                option['id'] +
                                '"> ' +
                            option['name'] +
                        '</label>' +
                        '<br>';
                }
                break;
            case 1: // select
                control += '<label>' +
                        '<select name="resource[assessment_question_responses_attributes][#{response.id}][assessment_question_option_id]">';
                for (key in object['assessment_question_options']) {
                    var option = object['assessment_question_options'][key];
                    control += '<option value="' + option['id'] + '" data-option-score="' +
                        option['value'] + '" data-option-id="' + option['id'] + '">' +
                            option['name']
                        + '</option>';
                }
                control += '</label>';
                break;
            case 2: // checkbox
                for (key in object['assessment_question_options']) {
                    var option = object['assessment_question_options'][key];
                    control += '<label>' +
                        '<input type="checkbox" ' +
                        'name="resource[assessment_question_responses_attributes][#{response.id}][assessment_question_option_id]" ' +
                        'data-option-score="' + option['value'] + '" data-option-id="' +
                        option['id'] +
                        '"> ' +
                        option['name'] +
                        '</label>' +
                        '<br>';
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
        //
        //  (question 1 weight * question 1 value
        // + question 2 weight * question 2 value
        // + question 2a weight * question 2a value)
        // / number of top-level questions

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

        $('body').scrollspy({ target: '#sections' });

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

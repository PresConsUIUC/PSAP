/**
 * Used in add and edit view.
 */
var ResourceForm = {

    addFormatSelect: function(parent_format_id, onCompleteCallback) {
        var newSelect = $('<select>').attr('name', 'resource[format_id]').
            attr('class', 'form-control');
        newSelect.hide();
        $('div.format').append(newSelect);
        var prompt = $('<option value=\"\">Select...</option>');
        newSelect.append(prompt);

        newSelect.on('change', function() {
            // destroy all selects after the changed select
            $(this).nextAll('select').remove();
            // create a child select
            ResourceForm.addFormatSelect($(this).val(), onCompleteCallback);
        });

        var contents_url = $('input[name="root-url"]').val() +
            '/format-classes/' + $('input[name="format_class"]:checked').val() +
            '/formats';
        if (parent_format_id) {
            contents_url += '?parent_id=' + parent_format_id;
        }

        $.getJSON(contents_url, function(data) {
            if (data.length == 0) {
                newSelect.remove();
            } else {
                newSelect.prev().attr('name', 'noop');
            }

            $.each(data, function(i, object) {
                var option = $('<option data-score="' + object['score'] + '">').
                    attr('value', object['id']).
                    text(object['name']);
                newSelect.append(option);
            });
            (newSelect.find('option').length < 2) ?
                newSelect.hide() : newSelect.show();

            // if the last select has been added
            newSelect.on('change', function() {
                ResourceForm.selectFormat($(this).val(), null);
            });

            if (onCompleteCallback) {
                onCompleteCallback(newSelect);
            }
        });
    },

    attachEventListeners: function() {
        $('input[name="format_class"]').on('change', function() {
            ResourceForm.selectFormatClass($(this).val());
            ResourceForm.addFormatSelect(null);
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
    },

    clearAssessmentQuestions: function() {
        $('div.assessment_question').remove();
        ResourceForm.updateProgress();
    },

    hideSections: function() {
        $('div#sections').hide();
        $('div.section').each(function() {
            if ($(this).attr('id') != 'basic_info') {
                $(this).hide();
            }
        });
    },

    init: function() {
        $(document).on('PSAPFormFieldAdded', function() {
            ResourceForm.attachEventListeners();

            // Adding a form section will change the page length, necessitating
            // a refresh of the scrollspy.
            $('[data-spy="scroll"]').each(function () {
                $(this).scrollspy('refresh');
            });
        }).trigger('PSAPFormFieldAdded');

        ResourceForm.initSuggestions();

        $('button.save').on('click', function() { $('form').submit(); });

        // hide all of the sections except Basic Info
        ResourceForm.hideSections();

        if ($('body#edit_resource').length) {
            ResourceForm.initInitialSelections();
        }
    },

    initInitialSelections: function() {
        ResourceForm.selectFormatClass(
            $('input[name="selected_format_class"]').val());

        var selected_format_ids = $('input[name="selected_format_ids"]').map(function() {
            return $(this).val();
        }).toArray().reverse();

        var onSelectAdded = function(select) {
            // set the select's default value
            selected_format_ids.forEach(function(id) {
                var options = select.find('option[value="' + id + '"]');
                options.each(function() {
                    if ($(this).val() == id) {
                        $(this).prop('selected', true);
                    }
                });
            });

            // if the last select has been added
            if (select.val() == selected_format_ids[selected_format_ids.length - 1]) {
                ResourceForm.selectFormat(select.val(), null);

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
                ResourceForm.updateProgress();
            }
        };

        ResourceForm.addFormatSelect(null, onSelectAdded); // top-level formats
        selected_format_ids.forEach(function(id) {
            ResourceForm.addFormatSelect(id, onSelectAdded);
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

        $(document).on('PSAPFormFieldAdded', function() {
            ResourceForm.initSuggestions();
        });
    },

    insertQuestionAfter: function(questionNode, afterNode) {
        $(questionNode).hide();
        afterNode.after(questionNode);
        $(questionNode).fadeIn();
    },

    insertQuestionIn: function(questionNode, parentNode) {
        parentNode.append(questionNode);
    },

    // Transforms an assessment question into HTML for the assessment form.
    nodeForQuestion: function(object, question_index) {
        var control = '';

        switch (object['question_type']) { // corresponds to the AssessmentQuestionType constants
            case 0: // radio
                for (var key in object['assessment_question_options']) {
                    var option = object['assessment_question_options'][key];
                    if (option['value']) { // TODO: why is option['value'] ever undefined?
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
                }
                break;
            case 1: // checkbox
                for (var key in object['assessment_question_options']) {
                    var option = object['assessment_question_options'][key];
                    if (option['value']) { // TODO: why is option['value'] ever undefined?
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
                }
                break;
        }

        return $.parseHTML('<div class="assessment_question" data-id="' +
            object['id'] + '" data-weight="' + object['weight'] + '">' +
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
                    '<div class="col-sm-12">' +
                        control +
                    '</div>' +
                '</div>' +
            '</div>');
    },

    selectFormat: function(format_id, onCompleteCallback) {
        ResourceForm.clearAssessmentQuestions();
        ResourceForm.hideSections();
        if (!format_id) {
            return;
        }

        $('select[name="resource[format_id]"]').val(format_id);

        var questions_url = $('input[name="root-url"]').val() +
            'formats/' + format_id + '/assessment-questions';
        $.getJSON(questions_url, function (data) {
            $.each(data, function (i, object) {
                ResourceForm.insertQuestionIn(
                    ResourceForm.nodeForQuestion(object, i),
                    $('div[data-id="' + object['assessment_section_id'] + '"] div.section-questions'));
            });
            if (data.length > 0) {
                var onOptionChanged = function() {
                    // check for dependent questions
                    var selected_option_id = $(this).val();
                    var question_elem = $(this).closest('div.assessment_question');
                    var qid = question_elem.data('id');
                    var child_questions_url = $('input[name="root-url"]').val() +
                        'formats/' + format_id + '/assessment-questions?parent_id=' + qid;
                    $.getJSON(child_questions_url, function(data) {
                        $.each(data, function (i, object) {
                            var child_question_elem =
                                $('div.assessment_question[data-id=' + object['id'] + ']');
                            var add = false;
                            $.each(object['enabling_assessment_question_options'], function (i, opt) {
                                // TODO: add data-depth attribute
                                if (opt['id'] == selected_option_id) {
                                    add = true;
                                }
                            });
                            if (add && child_question_elem.length < 1) {
                                ResourceForm.insertQuestionAfter(
                                    ResourceForm.nodeForQuestion(object, i),
                                    question_elem)
                            } else {
                                child_question_elem.remove();
                            }
                        });

                        $('.assessment_question input, .assessment_question select').
                            off('change').on('change', onOptionChanged);
                        $('body').scrollspy('refresh');
                    });

                    ResourceForm.updateProgress();
                };
                $('.assessment_question input, .assessment_question select').
                    on('change', onOptionChanged);

                ResourceForm.showSections();
                $('body').scrollspy({ target: '#sections' });
            }
            ResourceForm.updateProgress();

            if (onCompleteCallback) {
                onCompleteCallback();
            }
        });
    },

    // Format class is one of the radio buttons: A/V, Photo/Image...
    selectFormatClass: function(id) {
        ResourceForm.clearAssessmentQuestions();
        ResourceForm.hideSections();
        // destroy all selects
        $('div.format').find('select').remove();
        // select the format class
        $('input[name="format_class"][value="' + id + '"]').attr('checked', true);
    },

    selectedFormatScore: function() {
        return parseFloat($('select[name="resource[format_id]"] option:selected').
            data('score'));
    },

    showSections: function() {
        $('div#sections').show();
        $('div.section').fadeIn();
    },

    updateProgress: function() {
        var questions = $('.assessment_question');
        var numQuestions = questions.length;

        $('.total-assessment-question-count').text(numQuestions);

        // update question counts per-section
        $('div.section').each(function() {
            var count = $(this).find('.assessment_question').length;
            $('.nav li[data-section-id="' + $(this).data('id') +
                '"] .assessment-question-count').text(count);
        });

        // Update score bar
        // https://github.com/PresConsUIUC/PSAP/wiki/Scoring
        var resource_score = 0;
        var format_score = ResourceForm.selectedFormatScore();
        if (format_score) {
            var section_scores = [];
            $('.section-questions').each(function () {
                var question_scores = [];
                var question_weights = [];
                var weighted_scores = [];

                $(this).find('.assessment_question').each(function () {
                    // radios and checkboxes are handled differently. Radios
                    // have the score of the selected radio. Checkboxes have
                    // a score of 1 - (sum of checked checkboxes).
                    var selected_radio = $(this).find('input[type="radio"]:checked');
                    if (selected_radio.length) {
                        // and its score
                        var response_value = selected_radio.data('option-score');
                        if (response_value) {
                            question_scores.push(response_value);
                            var question_weight = parseFloat($(this).data('weight'));
                            question_weights.push(question_weight);
                        }
                    } else { // get the checked checkboxes
                        var checked_checkboxes = $(this).find(
                            'input[type="checkbox"]:checked');
                        if (checked_checkboxes.length > 0) {
                            var response_value = 1;
                            checked_checkboxes.each(function () {
                                response_value -= $(this).data('option-score');
                            });
                            question_scores.push(response_value);
                            var question_weight = parseFloat($(this).data('weight'));
                            question_weights.push(question_weight);
                        }
                    }
                });

                var total_weight = question_weights.sum();
                var section_weight = $(this).closest('.section').data('weight');
                var score = 0;
                if (question_scores.length > 0) {
                    for (var i = 0; i < question_scores.length; i++) {
                        weighted_scores[i] = question_scores[i] * question_weights[i];
                    }
                    score = (parseFloat(weighted_scores.sum()) / total_weight) *
                        section_weight;
                }
                section_scores.push(score);
            });

            var assessment_score = section_scores.sum();
            var location_score = 1; // TODO: this is a placeholder
            resource_score = 0.4 * format_score + 0.1 * location_score +
                assessment_score;
            console.log(format_score + ' format + ' + assessment_score + ' assessment + ' +
                location_score + ' location (placeholder) = ' + resource_score + ' resource');
        }
        // TODO: include format vectors
        var score_bar = $('div.progress-bar.score');
        score_bar.css('width', resource_score * 100 + '%');
        score_bar.attr('aria-valuenow', resource_score);
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
            offset: { top: 220 }
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

/**
 * Used in add and edit view for locations and institutions. Resource
 * assessment uses different code, in resources.js.
 */
var AssessmentForm = {

    attachEventListeners: function() {
        $('button.save').on('click', function(event) {
            $('form.psap-assessment').submit();
        });
    },

    clearAssessmentQuestions: function() {
        PSAP.Popover.closeAll();
        $('.assessment_question').remove();
        AssessmentForm.updateProgress();
    },

    init: function() {
        $(document).on('PSAPFormFieldAdded', function() {
            AssessmentForm.attachEventListeners();

            // Adding a form section will change the page length, necessitating
            // a refresh of the scrollspy.
            $('[data-spy="scroll"]').each(function () {
                $(this).scrollspy('refresh');
            });
        }).trigger('PSAPFormFieldAdded');

        $('button.save').on('click', function() { $('form').submit(); });

        if ($('body#edit_location').length) {
            AssessmentForm.setInitialSelections();
        }

        // populate assessment questions
        var questions_url = $('input[name="root-url"]').val() +
            'locations/1/assessment-questions';
        $.getJSON(questions_url, function (data) {
            $.each(data, function (i, object) {
                AssessmentForm.insertQuestionIn(
                    AssessmentForm.nodeForQuestion(object, i),
                    $('div[data-id="' + object['assessment_section_id'] + '"] div.section-questions'));
            });
            if (data.length > 0) {
                var onOptionChanged = function() {
                    // check for dependent (child) questions
                    var selected_option_id = $(this).val();
                    var question_elem = $(this).closest('div.assessment_question');
                    var qid = question_elem.data('id');
                    var child_questions_url = $('input[name="root-url"]').val() +
                        'locations/1/assessment-questions?parent_id=' + qid;
                    $.getJSON(child_questions_url, function(data) {
                        $.each(data, function (i, object) {
                            var child_question_elem =
                                $('div.assessment_question[data-id=' + object['id'] + ']');
                            var add = false;
                            $.each(object['enabling_assessment_question_options'], function (i, opt) {
                                if (opt['id'] == selected_option_id) {
                                    add = true;
                                }
                            });
                            if (add) {
                                if (child_question_elem.length < 1) {
                                    var depth = 0;
                                    if (question_elem) {
                                        depth = question_elem.data('depth') + 1;
                                    }
                                    AssessmentForm.insertQuestionAfter(
                                        AssessmentForm.nodeForQuestion(object, i, depth),
                                        question_elem)
                                }
                            } else {
                                child_question_elem.remove();
                            }
                        });

                        $('.assessment_question input, .assessment_question select').
                            off('change').on('change', onOptionChanged);
                        $('[data-spy="scroll"]').each(function () {
                            $(this).scrollspy('refresh');
                        });
                    });

                    AssessmentForm.updateProgress();
                };
                $('.assessment_question input, .assessment_question select').
                    on('change', onOptionChanged);

                $('body').scrollspy({ target: '#sections' });
            }
            AssessmentForm.updateProgress();
        });
    },

    insertQuestionAfter: function(questionNode, afterNode) {
        $(questionNode).hide();
        afterNode.after(questionNode);
        $(questionNode).fadeIn();
        PSAP.Popover.refresh();
    },

    insertQuestionIn: function(questionNode, parentNode) {
        parentNode.append(questionNode);
        PSAP.Popover.refresh();
    },

    // Transforms an assessment question into HTML for the assessment form.
    nodeForQuestion: function(object, question_index, depth) {
        if (!depth) {
            depth = 0;
        }
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

        return $.parseHTML('<div class="assessment_question depth-' + depth +
            '" data-id="' + object['id'] + '" data-depth="' + depth +
            '" data-weight="' + object['weight'] + '">' +
            '<hr>' +
            '<div class="row">' +
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
            '<div class="row">' +
            '<div class="col-sm-12">' +
            control +
            '</div>' +
            '</div>' +
            '</div>');
    },

    setInitialSelections: function() {
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
        AssessmentForm.updateProgress();
    },

    updateProgress: function() {
        // update question counts per-section
        $('div.section').each(function() {
            var count = $(this).find('.assessment_question').length;
            $('.nav li[data-section-id="' + $(this).data('id') +
                '"] .assessment-question-count').text(count);
        });
    }

};

var ready = function() {
    if ($('body#new_location').length
        || $('body#edit_location').length) {
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

        AssessmentForm.init();
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);
// TODO: destroy event listeners

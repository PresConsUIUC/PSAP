/**
 * Used in assess-location, assess-institution, and assess-resource view.
 */
var AssessmentForm = {

    entity: null,

    /**
     * @param entity 'location', 'institution', or 'resource'
     */
    init: function(entity) {
        AssessmentForm.entity = entity;

        $(document).on('PSAPAssessmentQuestionsAdded', function() {
            $('[data-spy="scroll"]').each(function () {
                $(this).scrollspy('refresh');
            });
        });

        AssessmentForm.showAssessmentQuestions(
            AssessmentForm.setInitialSelections);
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

    /**
     * Transforms an assessment question into HTML for the assessment form.
     *
     * @param object JSON AssessmentQuestion object
     * @param question_index
     * @param depth
     * @returns jQuery node
     */
    nodeForQuestion: function(object, question_index, depth) {
        if (!depth) {
            depth = 0;
        }
        var control = '';
        var root_url = $('input[name="root_url"]').val();

        switch (object['question_type']) { // corresponds to the AssessmentQuestionType constants
            case 0: // radio
                for (var key in object['assessment_question_options']) {
                    var option = object['assessment_question_options'][key];
                    if (option['value']) { // TODO: why is option['value'] ever undefined?
                        control += '<div class="radio-inline">' +
                                '<label>' +
                                    '<input type="radio" ' +
                                    'name="' + AssessmentForm.entity + '[assessment_question_responses][' + question_index + ']" ' +
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
                        control += '<div class="checkbox-inline">' +
                                '<label>' +
                                    '<input type="checkbox" ' +
                                    'name="' + AssessmentForm.entity + '[assessment_question_responses][' + question_index + ']" ' +
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

        var adv_help_link = '';
        if (object['advanced_help_page']) {
            adv_help_link = '<br><br><a href="' + root_url + '/help/' + object['advanced_help_page'] + '#' +
                object['advanced_help_anchor'].replace(/#/g, '') + '" target="_blank">More information&hellip;</a>';
            adv_help_link = adv_help_link.replace(/"/g, "'");
        }

        return $.parseHTML('<div class="assessment_question depth-' + depth +
            '" data-id="' + object['id'] + '" data-depth="' + depth +
            '" data-weight="' + object['weight'] + '">' +
                '<hr>' +
                '<div class="row">' +
                    '<div class="col-sm-10">' +
                        '<p class="question">' + object['name'] + '</p>' +
                    '</div>' +
                    '<div class="col-sm-2" style="text-align:right">' +
                        '<button type="button" class="btn btn-default help hovertip-fire" ' +
                        'data-container="body" data-toggle="popover" ' +
                        'data-placement="left" data-html="true" ' +
                        'data-content="' + object['help_text'].replace(/"/g, "&quot;").
                        replace("\n", "<br><br>") + adv_help_link + '">?' +
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
        $('input[name="selected_option_ids"]').each(function() {
            var selected_id = $(this).val();
            $('[data-type="option"]').each(function() {
                if ($(this).val() == selected_id) {
                    $(this).prop('checked', true);
                }
            });
        });
    },

    showAssessmentQuestions: function(onCompleteCallback) {
        var root_url = $('input[name="root_url"]').val();
        var questions_url;
        switch (AssessmentForm.entity) {
            case 'location':
                // all locations have the same set of assessment questions
                questions_url = root_url + 'locations/1/assessment-questions';
                break;
            case 'institution':
                // all institutions have the same set of assessment questions
                questions_url = root_url + 'institutions/1/assessment-questions';
                break;
            case 'resource':
                var format_id = $('input[name="format_id"]').val();
                questions_url = root_url + 'formats/' + format_id +
                '/assessment-questions';
                break;
        }

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
                    var question_elem = $(this).closest('.assessment_question');
                    var qid = question_elem.data('id');
                    var child_questions_url;
                    switch (AssessmentForm.entity) {
                        case 'location':
                            child_questions_url = root_url +
                            'locations/1/assessment-questions?parent_id=' + qid;
                            break;
                        case 'institution':
                            child_questions_url = root_url +
                            'institutions/1/assessment-questions?parent_id=' + qid;
                            break;
                        case 'resource':
                            child_questions_url = root_url + 'formats/' +
                                format_id + '/assessment-questions?parent_id=' + qid;
                            break;
                    }
                    $.getJSON(child_questions_url, function(data) {
                        $.each(data, function (i, object) {
                            var child_question_elem =
                                $('.assessment_question[data-id=' + object['id'] + ']');
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
                        $('.assessment_question input').off('change').
                            on('change', onOptionChanged);
                        $(document).trigger('PSAPAssessmentQuestionsAdded');
                    });

                    AssessmentForm.updateQuestionCounts();
                };
                $('.assessment_question input').on('change', onOptionChanged);
            }
            AssessmentForm.updateQuestionCounts();

            if (onCompleteCallback) {
                onCompleteCallback();
            }
            $(document).trigger('PSAPAssessmentQuestionsAdded');
        });
    },

    updateQuestionCounts: function() {
        // update question counts per-section
        $('div.section').each(function() {
            var count = $(this).find('.assessment_question').length;
            $('.nav li[data-section-id="' + $(this).data('id') +
                '"] .assessment-question-count').text(count);
        });
    }

};

var ready = function() {
    if ($('body#assess_institution').length) {
        AssessmentForm.init('institution');
    } else if ($('body#assess_resource').length) {
        AssessmentForm.init('resource');
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);
// TODO: destroy event listeners

/**
 * Used in the institution, location, and resource assessment views.
 *
 * @param entity 'location', 'institution', or 'resource'
 */
var AssessmentForm = function(entity) {

    var _entity = entity;
    var _question_node_index = 0;

    /**
     * Called at the end of the AssessmentForm definition
     */
    var construct = function() {
        $(document).on('PSAPAssessmentQuestionsAdded', function() {
            $('[data-spy="scroll"]').each(function () {
                $(this).scrollspy('refresh');
            });
        });
        showAssessmentQuestions();
    };

    var insertQuestionAfter = function(questionNode, afterNode) {
        $(questionNode).hide();
        afterNode.after(questionNode);
        setInitialSelection(questionNode);
        $(questionNode).fadeIn();
        PSAP.Popover.refresh();
    };

    var insertQuestionIn = function(questionNode, parentNode) {
        parentNode.append(questionNode);
        setInitialSelection(questionNode);
        PSAP.Popover.refresh();
    };

    /**
     * Transforms an assessment question into HTML for the assessment form.
     *
     * @param object JSON AssessmentQuestion object
     * @param depth
     * @returns jQuery node
     */
    var nodeForQuestion = function(object, depth) {
        if (!depth) {
            depth = 0;
        }
        var control = '';
        var root_url = $('input[name="root_url"]').val();

        switch (object['question_type']) { // corresponds to the AssessmentQuestionType constants
            case 0: // radio
                for (var key in object['assessment_question_options']) {
                    var option = object['assessment_question_options'][key];
                    if (!option['value']) {
                        option['value'] = '0';
                    }
                    control += '<div class="radio-inline">' +
                            '<label>' +
                                '<input type="radio" ' +
                                'name="' + _entity + '[assessment_question_responses][' + _question_node_index + ']" ' +
                                'data-type="option" ' +
                                'data-option-score="' + option['value'] + '" data-option-id="' +
                                option['id'] + '" value="' + option['id'] + '"> ' +
                                option['name'] +
                            '</label>' +
                        '</div>';
                }
                break;
            case 1: // checkbox
                for (var key in object['assessment_question_options']) {
                    var option = object['assessment_question_options'][key];
                    if (!option['value']) {
                        option['value'] = '0';
                    }
                    control += '<div class="checkbox-inline">' +
                            '<label>' +
                                '<input type="checkbox" ' +
                                'name="' + _entity + '[assessment_question_responses][' + _question_node_index + ']" ' +
                                'data-type="option" ' +
                                'data-option-score="' + option['value'] + '" data-option-id="' +
                                option['id'] + '" value="' + option['id'] + '"> ' +
                                option['name'] +
                            '</label>' +
                        '</div>';
                }
                break;
        }

        var adv_help_link = '';
        if (object['advanced_help_page']) {
            adv_help_link = '<br><br><a href="' + root_url + '/help/' +
                object['advanced_help_page'] + '#' +
                object['advanced_help_anchor'].replace(/#/g, '') +
                '" target="_blank">More information&hellip;</a>';
            adv_help_link = adv_help_link.replace(/"/g, "'");
        }

        _question_node_index++;

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
    };

    /**
     * @param parent_qid Optional parent QID
     * @returns string
     */
    var questionsUrl = function(parent_qid) {
        var root_url = $('input[name="root_url"]').val();
        switch (_entity) {
            case 'location':
                if (parent_qid) {
                    return root_url +
                        'locations/1/assessment-questions?parent_id=' +
                        parent_qid;
                }
                // all locations have the same set of assessment questions
                return root_url + 'locations/1/assessment-questions';
                break;
            case 'institution':
                if (parent_qid) {
                    return root_url +
                        'institutions/1/assessment-questions?parent_id=' +
                        parent_qid;
                }
                // all institutions have the same set of assessment questions
                return root_url + 'institutions/1/assessment-questions';
                break;
            case 'resource':
                var format_id = $('input[name="format_id"]').val();
                if (parent_qid) {
                    return root_url + 'formats/' +
                        format_id + '/assessment-questions?parent_id=' +
                        parent_qid;
                }
                return root_url + 'formats/' + format_id +
                    '/assessment-questions';
                break;
        }
    };

    var setInitialSelection = function(questionNode) {
        $('input[name="selected_option_ids"]').each(function() {
            var selected_id = $(this).val();
            $(questionNode).find('[data-type="option"]').each(function() {
                if (selected_id == $(this).val()) {
                    $(this).prop('checked', true);
                }
            });
        });
    };

    var showAssessmentQuestions = function() {
        $.getJSON(questionsUrl(null), function (data) {
            // insert top-level questions into their corresponding section
            $.each(data, function (i, object) {
                insertQuestionIn(
                    nodeForQuestion(object),
                    $('div[data-id="' + object['assessment_section_id'] + '"] div.section-questions'));
            });
            if (data.length) {
                var onOptionChanged = function() {
                    // check for dependent (child) questions
                    var selected_option_id = $(this).val();
                    var question_elem = $(this).closest('.assessment_question');
                    var qid = question_elem.data('id');
                    var child_questions_url = questionsUrl(qid);
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
                                    insertQuestionAfter(
                                        nodeForQuestion(object, depth),
                                        question_elem)
                                }
                            } else {
                                child_question_elem.remove();
                            }
                        });
                        $('.assessment_question [data-type="option"]').
                            off('change').on('change', onOptionChanged);
                        $(document).trigger('PSAPAssessmentQuestionsAdded');
                    });
                };
                $('.assessment_question [data-type="option"]').
                    on('change', onOptionChanged).trigger('change');
                /* TODO: get this to work: https://github.com/PresConsUIUC/PSAP/issues/242
                // make assessment question options toggle no matter where clicked
                $('.assessment_question .radio-inline').on('click', function() {
                    var radio = $(this).find('input[type="radio"]');
                    radio.prop('checked', !radio.prop('checked'));
                    return false;
                });
                */
            }

            $(document).trigger('PSAPAssessmentQuestionsAdded');
        });
    };

    construct();

};

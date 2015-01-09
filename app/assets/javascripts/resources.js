/**
 * Used in add and edit view.
 */
var ResourceForm = {

    // lazy-loaded by formats()
    formats_json: null,
    // lazy-loaded by formatInkMediaTypes()
    format_ink_media_types_json: null,
    // lazy_loaded by formatSupportTypes()
    format_support_types_json: null,

    /**
     * @param parent_format Format object
     * @param onCompleteCallback
     */
    addFormatSelect: function(parent_format, onCompleteCallback) {
        var format_class_id = $('input[name="format_class"]:checked').val();
        if (ResourceForm.shouldShowFormatVectorMenus()) {
            return;
        }

        var ROOT_URL = $('input[name="root-url"]').val();

        var new_select = $('<select></select>').
            attr('name', 'resource[format_id]').
            attr('class', 'form-control');
        var prompt = $('<option value="">Select&hellip;</option>');
        new_select.append(prompt);

        // add help button (href will be populated in selectFormat())
        var help_button = $('<a>?</a>').attr('href', '').
            attr('class', 'btn btn-default help').attr('target', '_blank').
            hide();

        var group = $('<div class="form-inline"></div>').hide();
        group.append(new_select).append(help_button);
        $('div.format').append(group);

        new_select.on('change', function() {
            // destroy all selects after the changed select
            $(this).parent().nextAll('div.form-inline').remove();
            // create a child select
            ResourceForm.addFormatSelect(ResourceForm.format($(this).val()),
                onCompleteCallback);
        });

        var contents_url = ROOT_URL + '/format-classes/' + format_class_id +
            '/formats';
        if (parent_format) {
            contents_url += '?parent_id=' + parent_format['id'];
        }

        $.getJSON(contents_url, function(data) {
            if (data.length == 0) {
                ResourceForm.showSections();
                group.remove();
            } else {
                group.prev().find('select').attr('name', 'noop');
            }

            $.each(data, function(i, object) {
                var option = $('<option data-help-page="' + object['format_id_guide_page'] + '" ' +
                    'data-help-anchor="' + object['format_id_guide_anchor'] + '" ' +
                    'data-score="' + object['score'] + '">').
                    attr('value', object['id']).
                    text(object['name']);
                new_select.append(option);
            });
            (new_select.find('option').length < 2) ? group.hide() : group.show();

            new_select.on('change', function() {
                var format = ResourceForm.format($(this).val());
                ResourceForm.selectFormat(format, null);
            });

            if (onCompleteCallback) {
                onCompleteCallback(new_select);
            }
        });
    },

    attachEventListeners: function() {
        // conditionally show/hide assessment type depending on whether the
        // resource is a collection
        $('input[name="resource[resource_type]"]').on('change', function() {
            var assessment_type_group = $('#psap-assessment-type-group');
            if ($('input[name="resource[resource_type]"]:checked').val() == '0') { // collection
                assessment_type_group.show();
            } else {
                assessment_type_group.hide();
            }
        }).trigger('change');

        $('input[name="format_class"]').on('change', function() {
            ResourceForm.selectFormatClass($(this).val());
            ResourceForm.addFormatSelect();
        });

        $('button.save').on('click', function(event) {
            $('form.psap-assessment').submit();
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
        PSAP.Popover.closeAll();
        $('.assessment_question').remove();
        ResourceForm.updateProgress();
    },

    format: function(id) {
        var formats = ResourceForm.formats();
        for (var i = 0; i < formats.length; i++) {
            if (formats[i]['id'] == id) {
                return formats[i];
            }
        }
        return null;
    },

    formatByFID: function(fid) {
        var formats = ResourceForm.formats();
        for (var i = 0; i < formats.length; i++) {
            if (formats[i]['fid'] == fid) {
                return formats[i];
            }
        }
        return null;
    },

    formats: function() {
        if (!ResourceForm.formats_json) {
            ResourceForm.formats_json = $.parseJSON(
                $('input[name="formats_json"]').val());
        }
        return ResourceForm.formats_json;
    },

    formatInkMediaTypes: function() {
        if (!ResourceForm.format_ink_media_types_json) {
            ResourceForm.format_ink_media_types_json = $.parseJSON(
                $('input[name="format_ink_media_types_json"]').val());
        }
        return ResourceForm.format_ink_media_types_json;
    },

    formatSupportTypes: function() {
        if (!ResourceForm.format_support_types_json) {
            ResourceForm.format_support_types_json = $.parseJSON(
                $('input[name="format_support_types_json"]').val());
        }
        return ResourceForm.format_support_types_json;
    },

    hideFormatVectorMenus: function() {
        $('.format-vectors').remove();
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
            ResourceForm.setInitialSelections();
        }
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

        var adv_help_link = '';
        if (object['advanced_help_page']) {
            adv_help_link = '<br><br><a href="/help/' + object['advanced_help_page'] + '#' +
                object['advanced_help_anchor'] + '" target="_blank">More information&hellip;</a>';
            adv_help_link = adv_help_link.replace(/"/g, "'");
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
                            replace("\n", "<br><br>") + adv_help_link + '">? ' +
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

    /**
     * @param format Format object (from ResourceForm.format())
     * @param onCompleteCallback Function
     */
    selectFormat: function(format, onCompleteCallback) {
        ResourceForm.clearAssessmentQuestions();
        ResourceForm.hideSections();
        if (!format) {
            return;
        }

        // if the format is Paper-Unbound --> Original Document or Paper-Bound,
        // show the ink/media type and support menus
        if (format['fid'] == 159 || format['fid'] == 160) {
            $('div.format').append(
                '<input type="hidden" name="resource[format_id]" value="' + format['id'] + '">');
            ResourceForm.showFormatVectorMenus();
        } else {
            ResourceForm.hideFormatVectorMenus();
        }

        var select = $('select[name="resource[format_id]"]');
        select.val(format['id']);

        var root_url = $('input[name="root-url"]').val();
        var help_page = select.find(':selected').data('help-page');
        help_page = help_page ? help_page : '';
        var help_anchor = select.find(':selected').data('help-anchor');
        help_anchor = help_anchor ? '#' + help_anchor : '';
        select.filter(':first').next('a').attr('href',
                root_url + 'format-id-guide/' + help_page + help_anchor).show();

        ResourceForm.showAssessmentQuestions(format, onCompleteCallback);
    },

    /**
     * Format class is one of the radio buttons: A/V, Photo/Image...
     *
     * @param id Format class ID
     */
    selectFormatClass: function(id) {
        ResourceForm.clearAssessmentQuestions();
        ResourceForm.hideSections();
        // destroy all selects
        $('div.format .form-inline').remove();
        // select the format class
        $('input[name="format_class"][value="' + id + '"]').attr('checked', true);

        if (id == 3) { // 3 == bound paper
            ResourceForm.showFormatVectorMenus();
            // if the format is bound paper, provide the format ID in a hidden
            // input instead of a select menu.
            var format = ResourceForm.formatByFID(160);
            ResourceForm.selectFormat(format, function() {
                ResourceForm.showSections();
            });
        } else {
            $('input[name="resource[format_id]"]').remove();
        }
    },

    setInitialSelections: function() {
        var format_class_id = $('input[name="selected_format_class"]').val();
        ResourceForm.selectFormatClass(format_class_id);

        var selected_format_ids = $('input[name="selected_format_ids"]').map(function() {
            return $(this).val();
        }).toArray().reverse();
        var selected_format_fids = $('input[name="selected_format_fids"]').map(function() {
            return parseInt($(this).val());
        }).toArray();

        var is_original_document = (selected_format_fids.indexOf(159) > -1);
        var is_bound_paper = (format_class_id == 3);

        if (ResourceForm.shouldShowFormatVectorMenus()) {
            ResourceForm.showFormatVectorMenus();
        }

        var setInitialFormatVectorSelections = function() {
            $('[name="resource[format_ink_media_type_id]"]').val(
                $('input[name="selected_format_ink_media_type_id"]').val());
            $('[name="resource[format_support_type_id]"]').val(
                $('input[name="selected_format_support_type_id"]').val());
        }

        if (is_bound_paper) {
            setInitialFormatVectorSelections();
        } else {
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
                    var format = ResourceForm.format(select.val());
                    ResourceForm.selectFormat(format, null);

                    if (is_original_document) {
                        setInitialFormatVectorSelections();
                    }

                    $(document).on('PSAPAssessmentQuestionsAdded', function() {
                        // select the question response options
                        $('input[name="selected_option_ids"]').each(function() {
                            var selected_id = $(this).val();
                            $('[data-type="option"]').each(function() {
                                if ($(this).val() == selected_id) {
                                    $(this).prop('checked', true);
                                }
                            });
                        });
                        ResourceForm.updateProgress();
                    });
                    ResourceForm.updateProgress();
                }
            };

            ResourceForm.addFormatSelect(null, onSelectAdded); // top-level formats
            var clone = selected_format_ids.slice();
            clone.shift();
            clone.forEach(function(id) {
                ResourceForm.addFormatSelect(ResourceForm.format(id), onSelectAdded);
            });
        }
    },

    shouldShowFormatVectorMenus: function() {
        // if format class is Bound Paper or format is Unbound Paper -->
        // Original Document
        return ($('input[name="format_class"]:checked').val() == 3 ||
        $('[name="resource[format_id]"]').val() == 159);
    },

    showAssessmentQuestions: function(format, onCompleteCallback) {
        var root_url = $('input[name="root-url"]').val();
        var questions_url = root_url + 'formats/' + format['id'] +
            '/assessment-questions';
        $.getJSON(questions_url, function (data) {
            $.each(data, function (i, object) {
                ResourceForm.insertQuestionIn(
                    ResourceForm.nodeForQuestion(object, i),
                    $('div[data-id="' + object['assessment_section_id'] +
                    '"] div.section-questions'));
            });
            if (data.length > 0) {
                var onOptionChanged = function() {
                    // check for dependent (child) questions
                    var selected_option_id = $(this).val();
                    var question_elem = $(this).closest('.assessment_question');
                    var qid = question_elem.data('id');
                    var child_questions_url = root_url + 'formats/' +
                        format['id'] + '/assessment-questions?parent_id=' + qid;
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
                                    ResourceForm.insertQuestionAfter(
                                        ResourceForm.nodeForQuestion(object, i, depth),
                                        question_elem);
                                }
                            } else {
                                child_question_elem.remove();
                            }
                        });

                        $('.assessment_question input').off('change').
                            on('change', onOptionChanged);
                        $('[data-spy="scroll"]').each(function () {
                            $(this).scrollspy('refresh');
                        })
                    });

                    ResourceForm.updateProgress();
                };
                $('.assessment_question input').on('change', onOptionChanged);

                $('body').scrollspy({ target: '#sections' });
            }
            ResourceForm.updateProgress();

            if (onCompleteCallback) {
                onCompleteCallback();
            }
            $('body').trigger('PSAPAssessmentQuestionsAdded');
        });
    },

    showFormatVectorMenus: function() {
        ResourceForm.hideFormatVectorMenus();

        var ink_select = $('<select></select>').
            attr('id', 'resource[format_ink_media_type_id]').
            attr('name', 'resource[format_ink_media_type_id]').
            attr('class', 'form-control').
            append($('<option value="">Select&hellip;</option>'));
        $.each(ResourceForm.formatInkMediaTypes(), function(i, obj) {
            ink_select.append($('<option data-score="' + obj['score'] + '">').
                attr('value', obj['id']).text(obj['name']));
        });

        var ink_container = $('<div class="form-inline"></div>');
        ink_container.append('<label for="resource[format_ink_media_type_id]">Ink/Media Type: </label>');
        ink_container.append(ink_select);

        var support_select = $('<select></select>').
            attr('id', 'resource[format_support_type_id]').
            attr('name', 'resource[format_support_type_id]').
            attr('class', 'form-control').
            append($('<option value="">Select&hellip;</option>'));
        $.each(ResourceForm.formatSupportTypes(), function(i, obj) {
            support_select.append($('<option data-score="' + obj['score'] + '">').
                attr('value', obj['id']).text(obj['name']));
        });

        var support_container = $('<div class="form-inline"></div>');
        support_container.append('<label for="resource[format_ink_media_type_id]">Support Type: </label>');
        support_container.append(support_select);

        var group = $('<div class="format-vectors"></div>');
        group.append(ink_container).append(support_container);
        $('div.format').append(group);
    },

    showSections: function() {
        $('div#sections').show();
        $('div.section').fadeIn();
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
    if ($('body#show_resource').length) {
        // vertically center modal panels
        $('.modal').on('show.bs.modal', function() {
            $(this).css('display', 'block');
            var $dialog = $(this).find(".modal-dialog");
            var offset = ($(window).height() - $dialog.height()) / 2;
            // Center modal vertically in window
            $dialog.css("margin-top", offset);
        });
    } else if ($('body#new_resource').length ||
        $('body#edit_resource').length) {
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

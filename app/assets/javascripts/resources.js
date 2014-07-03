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

        $('#sections').affix({ // TODO: broken on narrow screens and glitchy on short screens
            offset: {
                top: 220
            }
        });

        $(document).bind('affix.bs.affix', function() {
            //$('#sections').width($('.tab-pane.active').offset().left + 'px');
        });

        var ResourceForm = {

            init: function() {
                $(document).on('PSAPFormSectionAdded', function() {
                    ResourceForm.attachEventListeners();
                }).trigger('PSAPFormSectionAdded');

                ResourceForm.initSuggestions();
                ResourceForm.initDependentSelects();
                ResourceForm.updateDependentQuestions();
                ResourceForm.updateProgress();
                ResourceForm.updateScoreBar();

                $('button.save').on('click', function(event) {
                    $('div.tab-pane.active form').submit();
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

                $('.question input, .question select').on('change',
                    function(event) {
                        ResourceForm.updateDependentQuestions();
                        ResourceForm.updateProgress();
                        ResourceForm.updateScoreBar();
                    }).trigger('change');
            },

            initDependentSelects: function() {
                var appendSelectToNode = function(node) {
                    var select = $('<select>').attr('name', 'resource[format_id]').
                        attr('class', 'form-control');
                    select.hide();
                    node.append(select);
                    var prompt = $('<option value=\"\">').text('Select...');
                    select.append(prompt);
                    select.prev().attr('name', 'noop');
                    return select;
                };

                var populateSelect = function(select, url) {
                    // remove all options except "Select..."
                    select.find('*').not(':first').remove();
                    $.getJSON(url, function (data) {
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
                    });
                };

                $('input[name="format_type"]').on('change', function() {
                    // destroy all selects
                    $(this).parent().nextAll('select').remove();

                    var select = appendSelectToNode($(this).parent().parent());

                    var url = '/format-types/' + $(this).val() + '/formats'; // TODO: root url
                    populateSelect(select, url);

                    var onSelectChanged = function() {
                        // destroy all selects after the changed select
                        $(this).nextAll('select').remove();
                        // create a child select
                        var childSelect = appendSelectToNode($(this).parent());
                        var url = '/format-types/' +
                            $('input[name="format_type"]:checked').val() +
                            '/formats?parent_id=' + $(this).val(); // TODO: root url
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

            updateScoreBar: function() {
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
            },

            updateProgress: function() {
                var numQuestions = $('.question').length;
                var numAnsweredQuestions = 0;
                $('.question').each(function() {
                    var numChecked = $(this).find(
                        'input[type="radio"]:checked, input[type="checkbox"]:checked').length;
                    if (numChecked > 0 || ($(this).find('select').val() !== undefined
                        && $(this).find('select').val().length > 0)) {
                        numAnsweredQuestions++;
                    }
                });
                $('.question_response_count').text(numAnsweredQuestions);
                //$('div.progress-bar.psap-progress').attr('style',
                //        'width:' + numAnsweredQuestions / numQuestions * 100 + '%');
            }

        };

        ResourceForm.init();
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

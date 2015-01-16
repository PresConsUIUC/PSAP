var ResourceEditForm = {

    // lazy-loaded by formats()
    formats_json: null,
    // lazy-loaded by formatInkMediaTypes()
    format_ink_media_types_json: null,
    // lazy_loaded by formatSupportTypes()
    format_support_types_json: null,

    /**
     * @param parentFormat Format object
     * @param onCompleteCallback
     */
    addFormatSelect: function(parentFormat, onCompleteCallback) {
        var format_class_id = $('input[name="format_class"]:checked').val();
        if (ResourceEditForm.shouldShowFormatVectorMenus()) {
            return;
        }

        var ROOT_URL = $('input[name="root-url"]').val();

        var depth = $('div.format select').length;

        var new_select = $('<select></select>').
            attr('name', 'resource[format_id]').
            attr('class', 'form-control input-md');
        var prompt = $('<option value="">Select&hellip;</option>');
        new_select.append(prompt);

        // add help button (href will be populated in selectFormat())
        var help_button = $('<a>?</a>').attr('href', '').
            attr('class', 'btn btn-default help').attr('target', '_blank').
            hide();

        var group = $('<div class="form-inline depth-' + depth + '"></div>').hide();
        group.append(new_select).append(help_button);
        $('div.format').append(group);

        new_select.on('change', function() {
            // destroy all selects after the changed select
            $(this).parent().nextAll('div.form-inline').remove();
            // create a child select
            ResourceEditForm.addFormatSelect(
                ResourceEditForm.format($(this).val()),
                onCompleteCallback);
        });

        var contents_url = ROOT_URL + '/format-classes/' + format_class_id +
            '/formats';
        if (parentFormat) {
            contents_url += '?parent_id=' + parentFormat['id'];
        }

        $.getJSON(contents_url, function(data) {
            if (data.length == 0) {
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
                var format = ResourceEditForm.format($(this).val());
                ResourceEditForm.selectFormat(format, null);
            });

            if (onCompleteCallback) {
                onCompleteCallback(new_select);
            }
        });
    },

    attachEventListeners: function() {
        // if the resource is an item, hide the format; otherwise, show it
        var format_div = $('div.format');
        $('input[name="resource[resource_type]"]').on('change', function() {
            if ($(this).filter(':checked').val() == 1) { // 1 == item
                format_div.show();
            } else {
                format_div.hide();
            }
        }).trigger('change');

        $('input[name="format_class"]').on('change', function() {
            ResourceEditForm.selectFormatClass($(this).val());
            ResourceEditForm.addFormatSelect();
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

    format: function(id) {
        var formats = ResourceEditForm.formats();
        for (var i = 0; i < formats.length; i++) {
            if (formats[i]['id'] == id) {
                return formats[i];
            }
        }
        return null;
    },

    formatByFID: function(fid) {
        var formats = ResourceEditForm.formats();
        for (var i = 0; i < formats.length; i++) {
            if (formats[i]['fid'] == fid) {
                return formats[i];
            }
        }
        return null;
    },

    formats: function() {
        if (!ResourceEditForm.formats_json) {
            ResourceEditForm.formats_json = $.parseJSON(
                $('input[name="formats_json"]').val());
        }
        return ResourceEditForm.formats_json;
    },

    formatInkMediaTypes: function() {
        if (!ResourceEditForm.format_ink_media_types_json) {
            ResourceEditForm.format_ink_media_types_json = $.parseJSON(
                $('input[name="format_ink_media_types_json"]').val());
        }
        return ResourceEditForm.format_ink_media_types_json;
    },

    formatSupportTypes: function() {
        if (!ResourceEditForm.format_support_types_json) {
            ResourceEditForm.format_support_types_json = $.parseJSON(
                $('input[name="format_support_types_json"]').val());
        }
        return ResourceEditForm.format_support_types_json;
    },

    hideFormatVectorMenus: function() {
        $('.format-vectors').remove();
    },

    init: function() {
        $(document).on('PSAPFormFieldAdded', function() {
            ResourceEditForm.attachEventListeners();
        }).trigger('PSAPFormFieldAdded');

        ResourceEditForm.initSuggestions();

        if ($('body#edit_resource').length) {
            ResourceEditForm.setInitialSelections();
        }
    },

    initSuggestions: function() {
        $('input#resource_name, input.resource_subject').typeahead('destroy');

        var institution_url = $('input[name="institution_url"]').val();

        var names = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            limit: 10,
            prefetch: {
                url: institution_url + '/resources/names.json',
                filter: function(list) {
                    return $.map(list, function(item) { return { name: item }; });
                }
            }
        });
        names.initialize();

        var subjects = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            limit: 10,
            prefetch: {
                url: institution_url + '/resources/subjects.json',
                filter: function(list) {
                    return $.map(list, function(item) { return { name: item }; });
                }
            }
        });
        subjects.initialize();

        $('input#resource_name').typeahead(null, {
            name: 'names',
            displayKey: 'name',
            source: names.ttAdapter()
        });
        $('input.resource_subject').typeahead(null, {
            name: 'subjects',
            displayKey: 'name',
            source: subjects.ttAdapter()
        });

        // fix bugs/incompatibilities with bootstrap
        $('.typeahead').parent().css('display', '');
        $('.tt-hint').addClass('form-control');
        $('input.form-control.typeahead').css('background-color', 'white'); // fix text fields in wells

        $(document).on('PSAPFormFieldAdded', function() {
            ResourceEditForm.initSuggestions();
        });
    },

    /**
     * @param format Format object (from ResourceEditForm.format())
     * @param onCompleteCallback Function
     */
    selectFormat: function(format, onCompleteCallback) {
        if (!format) {
            return;
        }

        // if the format is Paper-Unbound --> Original Document or Paper-Bound,
        // show the ink/media type and support menus
        if (format['fid'] == 159 || format['fid'] == 160) {
            $('div.format').append(
                '<input type="hidden" name="resource[format_id]" value="' + format['id'] + '">');
            ResourceEditForm.showFormatVectorMenus();
        } else {
            ResourceEditForm.hideFormatVectorMenus();
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
    },

    /**
     * Format class is one of the radio buttons: A/V, Photo/Image...
     *
     * @param id Format class ID
     */
    selectFormatClass: function(id) {
        // destroy all selects
        $('div.format .form-inline').remove();
        // select the format class
        $('input[name="format_class"][value="' + id + '"]').attr('checked', true);

        if (id == 3) { // 3 == bound paper
            ResourceEditForm.showFormatVectorMenus();
        } else {
            $('input[name="resource[format_id]"]').remove();
        }
    },

    setInitialSelections: function() {
        var format_class_id = $('input[name="selected_format_class"]').val();
        ResourceEditForm.selectFormatClass(format_class_id);

        var selected_format_ids = $('input[name="selected_format_ids"]').map(function() {
            return $(this).val();
        }).toArray().reverse();
        var selected_format_fids = $('input[name="selected_format_fids"]').map(function() {
            return parseInt($(this).val());
        }).toArray();

        var is_original_document = (selected_format_fids.indexOf(159) > -1);
        var is_bound_paper = (format_class_id == 3);

        if (ResourceEditForm.shouldShowFormatVectorMenus()) {
            ResourceEditForm.showFormatVectorMenus();
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
                    var format = ResourceEditForm.format(select.val());
                    ResourceEditForm.selectFormat(format, null);
                    if (is_original_document) {
                        setInitialFormatVectorSelections();
                    }
                }
            };

            var clone = selected_format_ids.slice();
            clone.shift();
            clone.forEach(function(id) {
                ResourceEditForm.addFormatSelect(ResourceEditForm.format(id), onSelectAdded);
            });
        }
    },

    shouldShowFormatVectorMenus: function() {
        // if format class is Bound Paper or format is Unbound Paper -->
        // Original Document
        return ($('input[name="format_class"]:checked').val() == 3 ||
        $('[name="resource[format_id]"]').val() == 159);
    },

    showFormatVectorMenus: function() {
        ResourceEditForm.hideFormatVectorMenus();

        var ink_select = $('<select></select>').
            attr('id', 'resource[format_ink_media_type_id]').
            attr('name', 'resource[format_ink_media_type_id]').
            attr('class', 'form-control input-md').
            append($('<option value="">Select&hellip;</option>'));
        $.each(ResourceEditForm.formatInkMediaTypes(), function(i, obj) {
            ink_select.append($('<option data-score="' + obj['score'] + '">').
                attr('value', obj['id']).text(obj['name']));
        });

        var ink_container = $('<div class="form-inline"></div>');
        ink_container.append('<label for="resource[format_ink_media_type_id]">Ink/Media Type: </label>');
        ink_container.append(ink_select);

        var support_select = $('<select></select>').
            attr('id', 'resource[format_support_type_id]').
            attr('name', 'resource[format_support_type_id]').
            attr('class', 'form-control input-md').
            append($('<option value="">Select&hellip;</option>'));
        $.each(ResourceEditForm.formatSupportTypes(), function(i, obj) {
            support_select.append($('<option data-score="' + obj['score'] + '">').
                attr('value', obj['id']).text(obj['name']));
        });

        var support_container = $('<div class="form-inline"></div>');
        support_container.append('<label for="resource[format_ink_media_type_id]">Support Type: </label>');
        support_container.append(support_select);

        var group = $('<div class="format-vectors"></div>');
        group.append(ink_container).append(support_container);
        $('div.format').append(group);
    }

};

var ready = function() {
    if ($('body#new_resource').length || $('body#edit_resource').length) {
        ResourceEditForm.init();
    } else if ($('body#assess_resource').length) {
        // handled by AssessmentForm in assessments.js
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

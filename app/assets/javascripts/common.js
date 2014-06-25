var ready = function() {
    // if using a retina display, loop through all <img> tags and, if they have
    // a "data-has-retina" attribute, replace the "[filename].[ext]" in their
    // "src" attribute with "[filename]@2x.[ext]"
    if (window.devicePixelRatio > 1) {
        $('img').each(function() {
            if ($(this).attr('data-has-retina')) {
                var parts = $(this).attr('src').split('.');
                parts[parts.length - 2] = parts[parts.length - 2] + '@2x';
                $(this).attr('src', parts.join('.'));
            }
        });
    }

    // Pagination links
    $('.pagination a').attr('data-remote', 'true');

    // enable bootstrap popovers
    $('button[data-toggle="popover"]').popover({ html: true });
    // close popovers on outside clicks
    $('body').on('click', function(e) {
        if ($(e.target).data('toggle') !== 'popover'
            && $(e.target).parents('.popover.in').length === 0) {
            $('[data-toggle="popover"]').popover('hide');
        }
    });

    // Entity live-search forms
    $('.entity_search').submit(function() {
        $.get(this.action, $(this).serialize(), null, 'script');
        $(this).nextAll('input').addClass('active');
        return false;
    });
    $('.entity_search input').on('keyup', function() {
        $.get($('.entity_search').attr('action'),
            $('.entity_search').serialize(), null, 'script');
        $(this).addClass('active');
        return false;
    });

    // Show the modal progress view after submitting an ajax form
    $(document).on('submit', 'form[data-remote="true"]', function() {
        var view = $('#modal_progress_view');
        view.height($(document).height());
        view.show();
    });

    updateResultsCount();

    // Fade out flash messages after a delay. This will work only with
    // server-rendered flash messages; the same thing is done with ajax-
    // rendered flash messages in ajax.js.
    /*
     setTimeout(function() {
     $('div.alert-dismissable').fadeOut(1000);
     }, 5000);
     */

    // Used by the Bootstrap 3 tab bar
    // http://getbootstrap.com/javascript/#tabs
    $('ul.nav-tabs a, ul.nav-pills a').click(function(e) {
        e.preventDefault();
        $(this).tab('show');
    });

    // Show the glossary, bibliography, help, etc. in a modal panel instead of
    // a new page
    $('a.modal_view').on('click', function() {
        $('#appModal').modal('show');

        $.get($(this).attr('data-open'), function(data) {
            var content = $(data).find('div#page_content');
            $('div.modal-body').html(content.html());
            $('#appModalTitle').text($('div.modal-body h1:first').text());
            $('div.modal-body h1').remove();
        });
        return false;
    });

    Form.enableDynamicNestedEntities();
};

/**
 * Updates the results count text. Called on document ready and in index.js.erb
 * files on ajax load.
 */
function updateResultsCount() {
    var query_input = $('.entity_search input[name="q"]');
    if (query_input.length) {
        var query_length = query_input.val().length;
        var count_elem = $('input[name="results_count"]');
        if (count_elem.length) {
            var count = count_elem.val();
            $('.entity_count').text(count + ' '
                + ((query_length > 0) ? ((count == 1) ? 'match' : 'matches') : 'total'));
        }
    }
}

var Form = {

    TYPE_URL: 0,

    enableDynamicNestedEntities: function() {
        var updateIndexes = function() {
            $('.addable_removable').each(function() {
                $(this).find('.addable_removable_input_group input[type="hidden"].index').each(function(index) {
                    $(this).val(index);
                });
            });
        };

        // enable certain form elements to be dynamically added and removed, as
        // in the case of a nested form with a 1..n relationship to its child
        // object(s).
        $('.addable_removable button.remove').on('click', function() {
            // Instead of removing it from the DOM, hide it and set its
            // "_destroy" key to 1, so Rails knows to destroy its corresponding
            // model.
            var group = $(this).closest('.addable_removable_input_group');
            group.hide();
            group.find('input[type="hidden"].destroy').val(1);

            updateIndexes();
        });

        $('.addable_removable button.add').on('click', function() {
            // prohibit adding more than 10 fields
            if ($(this).closest('.addable_removable')
                .children('.addable_removable_input_group').length >= 10) {
                return;
            }

            // clone the last input group and insert the clone into the DOM
            // div input groups
            var group = $(this).prevAll('.addable_removable_input_group:first');
            if (!group.length) {
                // table input groups
                group = $(this).prevAll('table:first').find('tr:last');
            }
            var cloned_group = group.clone(true);
            group.after(cloned_group);
            cloned_group.show();

            // find all of its input elements
            cloned_group.find('input, select, textarea').each(function() {
                // update the element's indexes within the form, for rails
                var index = parseInt($(this).attr('id').match(/\d+/)[0]);
                $(this).attr('id',
                    $(this).attr('id').replace(index, index + 1));
                $(this).attr('name',
                    $(this).attr('name').replace(index, index + 1));

                // reset its value
                if ($(this).is('select')) {
                    $(this).val(
                        $(this).parent().prev().find('select:first').val());
                } else if (!$(this).is('input[type="hidden"]')) {
                    $(this).val(null);
                } else if ($(this).is('input[type="hidden"].destroy')) {
                    $(this).val(0);
                }
            });

            updateIndexes();
            $(document).trigger('PSAPFormSectionAdded');
        });

        updateIndexes();
    },

    validate: function(field_id, min_length, max_length, type) {
        var elem = $('#' + field_id);
        elem.parent('div').removeClass('has-success');
        elem.parent('div').removeClass('has-error');
        elem.next('span').removeClass('glyphicon-ok');
        elem.next('span').removeClass('glyphicon-remove');

        var passValidation = function(elem) {
            elem.parent('div').addClass('has-success');
            elem.next('span').addClass('glyphicon-ok');
        };

        var failValidation = function(elem) {
            elem.parent('div').addClass('has-error');
            elem.next('span').addClass('glyphicon-remove');
        };

        passValidation(elem);

        var value = elem.val().trim();

        if (min_length > 0 && max_length > 0) {
            if (value.length >= min_length && value.length <= max_length) {
                passValidation(elem);
            } else {
                failValidation(elem);
            }
        } else if (type == Form.TYPE_URL) {
            // very crude checks here, but good enough
            if (value.substring(0, 7) == 'http://' && value.length > 7
                || value.substring(0, 8) == 'https://' && value.length > 8) {
                passValidation(elem);
            } else {
                failValidation(elem);
            }
        }
    }

};

$(document).ready(ready);
$(document).on('page:load', ready);

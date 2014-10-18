Array.prototype.sum = function () {
    var total = 0;
    var i = this.length;

    while (i--) {
        total += this[i];
    }
    return total;
};

var ready = function() {
    // lazy-load images that have a data-original attribute
    $('img[data-original]').each(function() {
        // provided by vendor/assets/javascripts/jquery.lazyload.js
        $(this).lazyload({ effect: 'fadeIn' });
    });

    // if using a retina display, loop through all <img> tags and, if they have
    // a "data-has-retina" attribute, replace the "[filename].[ext]" in their
    // "src" attribute with "[filename]@2x.[ext]"
    if (window.devicePixelRatio > 1) {
        $('img').each(function() {
            if ($(this).data('has-retina')) {
                var parts = $(this).attr('src').split('.');
                parts[parts.length - 2] += '@2x';
                $(this).attr('src', parts.join('.'));
            }
        });
    }

    // Pagination links
    $('.pagination a').attr('data-remote', 'true');

    Popover.refresh();

    // Entity live-search forms
    $('.psap-live-search').submit(function() {
        $.get(this.action, $(this).serialize(), null, 'script');
        $(this).nextAll('input').addClass('active');
        return false;
    });
    var input_timer;
    $('.psap-live-search input').on('keyup', function() {
        clearTimeout(input_timer);
        var msec = 800; // wait this long after user has stopped typing
        var forms = $('.psap-live-search');
        var input = $(this);
        input_timer = setTimeout(function() {
            $.get(forms.attr('action'), forms.serialize(), null, 'script');
            return false;
        }, msec);
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

    var checkboxes = $('input[type="checkbox"]');

    function refreshCheckboxUI() {
        var all_checked = checkboxes.filter(':checked').length == checkboxes.length;
        var none_checked = checkboxes.filter(':checked').length == 0;

        $('button.psap-move-checked').prop('disabled', none_checked);
        if (all_checked) {
            $('.psap-check-all').prop('disabled', true);
            $('.psap-uncheck-all').prop('disabled', false);
        } else if (none_checked) {
            $('.psap-check-all').prop('disabled', false);
            $('.psap-uncheck-all').prop('disabled', true);
        } else {
            $('.psap-check-all').prop('disabled', false);
            $('.psap-uncheck-all').prop('disabled', false);
        }
    }

    // hook up "check/uncheck all" buttons
    $('.psap-check-all').on('click', function() {
        checkboxes.each(function() {
            $(this).prop('checked', true);
        });
        refreshCheckboxUI();
        checkboxes.trigger('change');
    });
    $('.psap-uncheck-all').on('click', function() {
        checkboxes.each(function() {
            $(this).prop('checked', false);
        });
        refreshCheckboxUI();
        checkboxes.trigger('change');
    });

    // conditionally enable the "move checked" button depending on whether
    // any checkboxes are checked
    checkboxes.on('change', function() {
        refreshCheckboxUI();
    }).trigger('change');

    Form.enableDynamicNestedEntities();

    // Enable smooth scrolling when clicking anchors.
    var top_padding = $('nav.navbar.navbar-default').height() + 10;
    var $root = $('html, body');
    $('a').click(function () {
        var href = $.attr(this, 'href');
        $root.animate({
            scrollTop: $(href).offset().top - top_padding
        }, 500, function () {
            window.location.hash = href;
        });
        return false;
    });
};

/**
 * Updates the results count text. Called on document ready and in index.js.erb
 * files on ajax load.
 */
function updateResultsCount() {
    var query_input = $('.psap-live-search input[name="q"]');
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
                if (typeof($(this).attr('id')) !== 'undefined') {
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
                }
            });

            updateIndexes();
            $(document).trigger('PSAPFormFieldAdded');
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

var Popover = {

    closeAll: function() {
        $('[data-toggle="popover"]').popover('hide');
    },

    refresh: function() {
        $('button[data-toggle="popover"]').popover({ html: true });
        // close popovers on outside clicks
        $('body').on('click', function(e) {
            $('[data-toggle=popover]').each(function () {
                // hide any open popovers when anywhere else in the body is clicked
                if (!$(this).is(e.target) && $(this).has(e.target).length === 0
                    && $('.popover').has(e.target).length === 0) {
                    $(this).popover('hide');
                }
            });
        });

        // open & close popovers on hover-in & out
        var should_open = true;
        $('label').on('mouseover', function() {
            should_open = true;
            var label = $(this);
            setTimeout(function() {
                if (should_open) {
                    label.next('[data-toggle="popover"]').popover('show');
                }
            }, 1000);
        });
        $('label').on('mouseout', function() {
            should_open = false;
            $(this).next('[data-toggle="popover"]').popover('hide');
        });
    }

};

$(document).ready(ready);
$(document).on('page:load', ready);

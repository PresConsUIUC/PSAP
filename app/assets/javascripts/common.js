var ready = function() {
    PSAP.init();
};

var PSAP = {

    Flash: {

        FADE_OUT_DELAY: 10000,

        /**
         * @param text
         * @param type Value of the X-Psap-Message-Type header
         * @return void
         */
        set: function(text, type) {
            var bootstrapClass;
            switch (type) {
                case 'success':
                    bootstrapClass = 'alert-success';
                    break;
                case 'error':
                    bootstrapClass = 'alert-danger';
                    break;
                case 'alert':
                    bootstrapClass = 'alert-block';
                    break;
                default:
                    bootstrapClass = 'alert-info';
                    break;
            }

            // remove any existing messages
            $('div.alert').remove();

            // construct the message
            var flash = $('<div class="alert ' + bootstrapClass + '"></div>');
            var button = $('<button type="button" class="close"' +
            ' data-dismiss="alert" aria-hidden="true">&times;</button>');
            flash.append(button);
            button.after(text);

            // append the flash to the DOM
            var edit_panel = $('.psap-edit-panel');
            if (edit_panel.length && edit_panel.hasClass('in')) {
                edit_panel.find('.modal-body').prepend(flash);
            } else {
                $('div.container header, div.container-fluid header').after(flash);
            }

            // make it disappear after a delay
            setTimeout(function() {
                flash.fadeOut();
            }, PSAP.Flash.FADE_OUT_DELAY);
        }

    },

    Form: {

        TYPE_URL: 0,

        enableDynamicNestedEntities: function() {
            var updateIndexes = function() {
                $('.psap-addable-removable').each(function() {
                    $(this).find('.psap-addable-removable-input-group').each(function(index) {
                        // find all of its input elements
                        $(this).find('input, select, textarea').each(function() {
                            // update the element's indexes
                            if (typeof($(this).attr('id')) !== 'undefined') {
                                var currentIndex = parseInt($(this).attr('id').
                                    match(/\d+/)[0]);
                                $(this).attr('id',
                                    $(this).attr('id').replace(currentIndex, index));
                                $(this).attr('name',
                                    $(this).attr('name').replace(currentIndex, index));
                            }
                        });
                    });
                });
            };
            updateIndexes();

            // enable certain form elements to be dynamically added and removed, as
            // in the case of a nested form with a 1..n relationship to its child
            // object(s).
            $('.psap-addable-removable button.remove').on('click', function() {
                // Instead of removing it from the DOM, hide it and set its
                // "_destroy" key to 1, so Rails knows to destroy its corresponding
                // model.
                var group = $(this).closest('.psap-addable-removable-input-group');
                group.hide();
                group.find('input[type="hidden"].destroy').val(1);
            });

            $('.psap-addable-removable button.add').on('click', function() {
                // prohibit adding more than 10 fields
                if ($(this).closest('.psap-addable-removable')
                    .children('.psap-addable-removable-input-group').length >= 10) {
                    return;
                }

                // clone the last input group and insert the clone into the DOM
                // div input groups
                var group = $(this).prevAll('.psap-addable-removable-input-group:first');
                if (!group.length) {
                    // table input groups
                    group = $(this).prevAll('table:first').find('tr:last');
                }
                var cloned_group = group.clone(true);
                group.after(cloned_group);
                cloned_group.show();

                cloned_group.find('input, select, textarea').each(function() {
                    // update the element's indexes within the form, for rails
                    if (typeof($(this).attr('id')) !== 'undefined') {
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
        },

        /**
         * Initializes a form. Called automatically by PSAP.init() but can be
         * called again when a form is added dynamically.
         */
        init: function() {
            PSAP.Form.enableDynamicNestedEntities();
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

            if (min_length > 0) {
                if (value.length >= min_length) {
                    passValidation(elem);
                } else {
                    failValidation(elem);
                }
            }
            if (max_length > 0) {
                if (value.length <= max_length) {
                    passValidation(elem);
                } else {
                    failValidation(elem);
                }
            }
            if (type == PSAP.Form.TYPE_URL) {
                // very crude checks here, but good enough
                if (value.substring(0, 7) == 'http://' && value.length > 7
                    || value.substring(0, 8) == 'https://' && value.length > 8) {
                    passValidation(elem);
                } else {
                    failValidation(elem);
                }
            }
        }

    },

    /**
     * Application-level initialization.
     */
    init: function() {
        // lazy-load images that have a data-original attribute
        $('img[data-original]').each(function() {
            // provided by vendor/assets/javascripts/jquery.lazyload.js
            $(this).lazyload();
        });

        // Pagination links
        $('.pagination a').attr('data-remote', 'true');

        PSAP.Popover.refresh();

        // Entity live-search forms
        $('.psap-live-search').submit(function() {
            $.get(this.action, $(this).serialize(), null, 'script');
            $(this).nextAll('input').addClass('active');
            return false;
        });
        var input_timer;
        $('.psap-live-search input').on('keyup', function() {
            var input = $(this);
            input.addClass('active');

            clearTimeout(input_timer);
            var msec = 800; // wait this long after user has stopped typing
            var forms = $('.psap-live-search');
            input_timer = setTimeout(function() {
                $.get(forms.attr('action'),
                    forms.serialize(),
                    function() { input.removeClass('active'); },
                    'script');
                return false;
            }, msec);
            return false;
        });

        // Show the modal progress view after submitting an ajax form
        $(document).on('submit', 'form[data-remote="true"]', function() {
            var view = $('#psap-ajax-shade');
            view.height($(document).height());
            view.show();
        });

        PSAP.updateResultsCount();

        // Show the glossary, bibliography, help, etc. in a modal panel instead of
        // a new page
        $('a.psap-modal-view').on('click', function() {
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

        /**
         * Refreshes "check/uncheck all" checkboxes.
         */
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

        PSAP.Form.init();

        // show the export notification panel after clicking an export option
        $('.psap-export').on('click', function() {
            var filename = $(this).attr('data-filename');
            var format = $(this).attr('data-format');
            setTimeout(function() {
                var alert = $('div#psap-export-notification');
                alert.find('.psap-filename').text(filename);
                alert.find('.psap-format').text(format);
                alert.modal();
            }, 100);
        });

        // set up affixed left menu with scrollspy
        var affixed = $('#psap-affixed-menu');
        if (affixed.length) {
            var body = $('body');
            if (body.width() > 600) {
                var navbar = $('nav.navbar.navbar-default');
                affixed.width(affixed.parent().width());
                affixed.affix({
                    offset: {
                        top: affixed.offset().top - navbar.height() - 15
                    }
                });
                body.scrollspy({
                    target: '#psap-affixed-menu',
                    offset: navbar.height() + 15
                });
            }
        }

        // Panels with the "psap-inner-scrolling" class should be limited to
        // window height and their body made scrollable.
        $('.psap-inner-scrolling').on('show.bs.modal', function (e) {
            var body = $(e.target).find('.modal-body');
            body.css('overflow', 'scroll');
            body.css('max-height', $(window).height() * 0.7);
        });

        // make flash messages disappear after a delay
        if ($('div.alert').length) {
            setTimeout(function () {
                $('div.alert').fadeOut();
            }, PSAP.Flash.FADE_OUT_DELAY);
        }

        PSAP.smoothAnchorScroll(0);
    },

    Panel: {

        /**
         * Loads HTML content for a panel and restructures its DOM
         * appropriately.
         *
         * @param panel_selector jQuery selector
         * @param template_url URL of panel HTML content
         * @param on_content_loaded_fn Function
         */
        initRemote: function(panel_selector, template_url, on_content_loaded_fn) {
            var panel = $(panel_selector);
            panel.on('show.bs.modal', function (e) {
                $.get(template_url, function (data) {
                    var body = panel.find('.modal-body');
                    body.html(data);
                    // if the body contains a form, move its opening tag into the
                    // .modal-content div and its submit buttons into a new
                    // .modal-footer div so that the panel will be both more
                    // structurally correct, and work with the
                    // .psap-inner-scrolling class
                    var form = body.find('form');
                    if (form.length) {
                        var container = panel.find('.modal-content');
                        container.prepend(form);
                        body.append(form.children());
                        var header = panel.find('.modal-header');
                        if (!panel.find('.modal-footer').length) {
                            var footer = $('<div class="modal-footer"></div>');
                            footer.append(
                                body.find('[data-dismiss="modal"], input[type="submit"]'));
                            form.prepend(footer);
                        } else {
                            body.find('[data-dismiss="modal"], input[type="submit"]').remove();
                        }
                        form.prepend(body);
                        form.prepend(header);
                    }

                    if (on_content_loaded_fn) {
                        on_content_loaded_fn();
                    }
                });
            });
        }

    },

    Popover: {

        closeAll: function() {
            $('[data-toggle="popover"]').popover('hide');
        },

        refresh: function() {
            var popover_buttons = $('[data-toggle="popover"]');
            popover_buttons.popover({ html: true });
            // close popovers on outside clicks
            $('body').on('click', function(e) {
                popover_buttons.each(function () {
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
            }).on('mouseout', function() {
                should_open = false;
                $(this).next('[data-toggle="popover"]').popover('hide');
            });
        }

    },

    /**
     * Enables smooth scrolling to anchors. This is called by PSAP.init() to
     * take effect globally, but is safe to call again to use a different
     * offset.
     *
     * @param offset Integer
     */
    smoothAnchorScroll: function(offset) {
        if (!offset && offset !== 0) {
            offset = 0;
        }
        var top_padding = $('nav.navbar.navbar-default').height() + 10 + offset;
        var root = $('html, body');

        var anchors = $('a[href^="#"]');
        anchors.off('click').on('click', function(e) {
            // avoid interfering with other Bootstrap components
            if ($(this).data('toggle') == 'collapse' ||
                $(this).data('toggle') == 'tab') {
                return;
            }
            e.preventDefault();

            var target = this.hash;
            root.stop().animate({
                'scrollTop': $(target).offset().top - top_padding
            }, 500, 'swing', function () {
                window.location.hash = target;
            });
        });
    },

    /**
     * Updates the results count text. Called on document ready and in index.js.erb
     * files on ajax load.
     */
    updateResultsCount: function() {
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

};

$(document).ready(ready);
$(document).on('page:load', ready);

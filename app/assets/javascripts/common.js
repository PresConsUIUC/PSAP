$(document).ready(function() {
    // Sorting and pagination links
    // These don't work yet
    //$('#formats th a, .pagination a').live('click', function() {
    /*$(document).on('click', '.pagination a', function() {
        $.getScript(this.href);
        return false;
    });*/

    // Entity live-search forms
    $('.entity_search').submit(function() {
        $.get(this.action, $(this).serialize(), null, 'script');
        return false;
    });
    $('.entity_search input').on('keyup', function() {
        $.get($('.entity_search').attr('action'),
            $('.entity_search').serialize(), null, 'script');
        return false;
    });

    function adjustNavBar() {
        var navBar = $('nav.navbar');
        // Unfix the nav bar from the top on small screens; otherwise it will fill
        // way too much of the screen.
        if ($(window).width() < 500 || $(window).height() < 500) {
            navBar.removeClass('navbar-fixed-top');
            $('body').css('padding-top', '0px');
        } else {
            navBar.addClass('navbar-fixed-top');
            $('body').css('padding-top', '50px');
        }
    }

    $(window).on('resize', function() {
        adjustNavBar();
    });

    adjustNavBar();

    var multiPageView = new FauxMultiPageView();
    multiPageView.init();
    $('.entity_menu a').on('click', function() {
        multiPageView.openView($(this).attr('data-open'));
        return false;
    });

    // Fade out flash messages after a delay. This will work only with
    // server-rendered flash messages; the same thing is done with ajax-
    // rendered flash messages in ajax.js.
    setTimeout(function() {
        $('div.alert').fadeOut(1000);
    }, 5000);

    // Used by the Bootstrap 3 tab bar
    // http://getbootstrap.com/javascript/#tabs
    $('ul.nav-tabs a').click(function(e) {
        e.preventDefault();
        $(this).tab('show');
    });

    // Show the glossary & bibliography in a modal panel instead of a new page
    $('a.modal_view').on('click', function() {
        $('#appModal').modal('show');

        $.get($(this).attr('data-open'), function(data) {
            var content = $(data).find('div#page_content');

            $('div.modal-body').html(content.html());
            $('#appModalTitle').text($('div.modal-body h1').text());
            $('div.modal-body h1').remove();
        });
        return false;
    });
});

/**
 * Enables a menu that uses JavaScript to show/hide different views.
 * See users/edit.html.erb and users/show.html.erb for markup examples.
 * @constructor
 */
function FauxMultiPageView() {
    // Retain references to the views' DOM trees so they won't be garbage-
    // collected when they have been temporarily removed from the DOM. Keyed
    // by ID of the root element.
    var form_views = {};

    var self = this;

    this.init = function() {
        var i = 0;
        $('.form_view').each(function() {
            form_views[$(this).attr('id')] = $(this);
            if (i > 0) {
                $(this).remove();
            }
            i++;
        });
        var first_li = $('.entity_menu li:first');
        first_li.addClass('active');


        var first_view = first_li.children('a:first').attr('data-open');
        if (first_view) {
            self.openView(first_view);
        }
    };

    this.openView = function(view_id) {
        if ($('#' + view_id).is(':visible')) { // nothing to do
            return;
        }

        var FADE_DURATION = 100;

        $('.entity_menu li').removeClass('active');
        $('.entity_menu a[data-open="' + view_id + '"]').parent()
            .addClass('active');

        $('.form_view').remove();
        var view = form_views[view_id];
        view.hide();
        $('.entity_menu').parent().append(view);
        view.show();
    };

}

var Form = {

    TYPE_URL: 0,

    validate: function(field_id, min_length, max_length, type) {
        var elem = $('#' + field_id);
        elem.parent('div').removeClass('has-success');
        elem.parent('div').removeClass('has-error');
        elem.next('span').removeClass('glyphicon-ok');
        elem.next('span').removeClass('glyphicon-remove');

        function passValidation(elem) {
            elem.parent('div').addClass('has-success');
            elem.next('span').addClass('glyphicon-ok');
        }

        function failValidation(elem) {
            elem.parent('div').addClass('has-error');
            elem.next('span').addClass('glyphicon-remove');
        }

        passValidation(elem);

        var value = elem.val().trim();
        if (min_length > 0 && max_length > 0) {
            if (value.length >= min_length && value.length <= max_length) {
                passValidation(elem);
            } else {
                failValidation(elem);
            }
        }
        if (type == Form.TYPE_URL) {
            // very crude checks here, but good enough, as the server will
            // detect invalid URLs
            if (value.substring(0, 7) == 'http://' && value.length > 7
                || value.substring(0, 8) == 'https://' && value.length > 8) {
                passValidation(elem);
            } else {
                failValidation(elem);
            }
        }
    }

}

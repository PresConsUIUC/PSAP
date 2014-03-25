$(document).ready(function() {
    var multiPageView = new FauxMultiPageView();
    multiPageView.init();

    // Code for the user registration, edit, and show forms.
    if ($('#new_user') || $('.edit_user') || $('#show_user')) {
        $('.entity_menu a').on('click', function() {
            multiPageView.openView($(this).attr('data-open'));
            UserForm.attachPasswordEventListeners();
            return false;
        });
        UserForm.attachPasswordEventListeners();
    }
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

    this.init = function() {
        var i = 0;
        $('.form_view').each(function() {
            form_views[$(this).attr('id')] = $(this);
            if (i > 0) {
                $(this).remove();
            }
            i++;
        });
        $('.entity_menu li:first').addClass('active');
    };

    this.openView = function(view_id) {
        if ($('#' + view_id).is(':visible')) { // nothing to do
            return;
        }

        var FADE_DURATION = 100;

        $('.entity_menu li').removeClass('active');
        $('.entity_menu a[data-open="' + view_id + '"]').parent()
            .addClass('active');

        $('.form_view').fadeOut(FADE_DURATION, function() {
            $(this).remove();

            var view = form_views[view_id];
            view.hide();
            $('.entity_menu').parent().append(view);
            view.fadeIn();
        });
    };

}

var UserForm = {

    attachPasswordEventListeners: function() {
        $('input#user_password').bind('keyup input paste', function() {
            UserForm.refreshPasswordStatus();
            UserForm.refreshPasswordConfirmationStatus();
        });
        $('input#user_password_confirmation').bind('keyup input paste', function() {
            UserForm.refreshPasswordConfirmationStatus();
        });
    },

    refreshPasswordStatus: function() {
        var MIN_LENGTH = 6;

        // Update the password feedback text
        var value = $('input#user_password').val();
        var message = '';

        $('div.progress-bar').attr('aria-valuenow', value.length / MIN_LENGTH);
        $('div.progress-bar').width(((value.length / MIN_LENGTH) * 100) + '%');

        if (value.length > 5) {
            $('div.progress-bar').removeClass('progress-bar-warning');
            $('div.progress-bar').addClass('progress-bar-success');
        } else {
            $('div.progress-bar').addClass('progress-bar-warning');
            $('div.progress-bar').removeClass('progress-bar-success');
        }

        if (value.length == 5) {
            message = 'Needs 1 more character.';
        } else if (value.length < MIN_LENGTH) {
            message = 'Needs ' + (MIN_LENGTH - value.length) + ' more characters.';
        }
        //$('#password_status').text(message);
    },

    refreshPasswordConfirmationStatus: function() {
        var value = $('input#user_password').val();
        var confirmation_value = $('input#user_password_confirmation').val();
        var status_p = $('p#password_confirmation_status');
        var message = '';

        if (value == confirmation_value) {
            status_p.addClass('text-success');
            status_p.removeClass('text-warning');
        } else {
            message = 'Passwords don\'t match.';
            status_p.addClass('text-warning');
            status_p.removeClass('text-success');
        }

        status_p.text(message);
    }

};
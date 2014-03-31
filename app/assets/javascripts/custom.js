$(document).ready(function() {
    var multiPageView = new FauxMultiPageView();
    multiPageView.init();

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

    // Code for the user registration, edit, and show forms.
    if ($('#new_user') || $('.edit_user') || $('#show_user')) {
        $('.entity_menu a').on('click', function() {
            multiPageView.openView($(this).attr('data-open'));
            UserForm.attachEventListeners();
            return false;
        });
        UserForm.attachEventListeners();
    }

    // Code for the dashboard "find my institution" modal panel.
    // #find_institution_panel will only appear when the user is not
    // affiliated with an institution (which will only be immediately after
    // they have created an account).
    if ($('#find_institution_panel')) {
        Dashboard.showFindInstitutionPanel();
    }
});

function attachEventListeners() {
    UserForm.attachEventListeners();
}

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

        $('.form_view').fadeOut(FADE_DURATION, function() {
            $(this).remove();

            var view = form_views[view_id];
            view.hide();
            $('.entity_menu').parent().append(view);
            view.fadeIn();

            attachEventListeners();
        });
    };

}

var Dashboard = {

    showFindInstitutionPanel: function() {
        $('#find_institution_panel').modal('show');

        $('#find_institution_button').on('click', function() {

        });
    }

};

var UserForm = {

    attachEventListeners: function() {
        $('input#user_first_name').bind('keyup input paste', function() {
            UserForm.validateFirstName();
        });
        $('input#user_last_name').bind('keyup input paste', function() {
            UserForm.validateLastName();
        });
        $('input#user_email').bind('keyup input paste', function() {
            UserForm.validateEmail();
        });
        $('input#user_username').bind('keyup input paste', function() {
            UserForm.validateUsername();
        });
        $('input#user_password').bind('keyup input paste', function() {
            UserForm.validatePassword();
            UserForm.validatePasswordConfirmation();
        });
        $('input#user_password_confirmation').bind('keyup input paste', function() {
            UserForm.validatePasswordConfirmation();
        });
    },

    validateFirstName: function() {
        var input = $('input#user_first_name');
        input.parent('div').removeClass('has-success');
        input.parent('div').removeClass('has-error');
        input.next('span').removeClass('glyphicon-ok');
        input.next('span').removeClass('glyphicon-remove');

        var value = input.val().trim();
        if (value.length && value.length <= 255) {
            input.parent('div').addClass('has-success');
            input.next('span').addClass('glyphicon-ok');
        } else {
            input.parent('div').addClass('has-error');
            input.next('span').addClass('glyphicon-remove');
        }
    },

    validateLastName: function() {
        var input = $('input#user_last_name');
        input.parent('div').removeClass('has-success');
        input.parent('div').removeClass('has-error');
        input.next('span').removeClass('glyphicon-ok');
        input.next('span').removeClass('glyphicon-remove');

        var value = input.val().trim();
        if (value.length && value.length <= 255) {
            input.parent('div').addClass('has-success');
            input.next('span').addClass('glyphicon-ok');
        } else {
            input.parent('div').addClass('has-error');
            input.next('span').addClass('glyphicon-remove');
        }
    },

    validateEmail: function() {
        var input = $('input#user_email');
        input.parent('div').removeClass('has-success');
        input.parent('div').removeClass('has-error');
        input.next('span').removeClass('glyphicon-ok');
        input.next('span').removeClass('glyphicon-remove');

        var value = input.val().trim();

        // Far from perfect, but forces the user to at least put in the effort
        // to make it look real.
        var regex = /\S+@\S+\.\S+/;

        if (regex.test(value)) {
            input.parent('div').addClass('has-success');
            input.next('span').addClass('glyphicon-ok');
        } else {
            input.parent('div').addClass('has-error');
            input.next('span').addClass('glyphicon-remove');
        }
    },

    validateUsername: function() {
        var msg_element = $('p#username_status');

        var username = $('input#user_username').val().trim();
        if (!username) {
            msg_element.text('');
            msg_element.removeClass('text-success');
            msg_element.removeClass('text-danger');
            msg_element.parent('div').removeClass('has-success');
            msg_element.parent('div').removeClass('has-error');
            msg_element.prev('span').removeClass('glyphicon-ok');
            msg_element.prev('span').removeClass('glyphicon-remove');
            return;
        }

        // window.pageURL is set in users/new.html.erb
        var url = window.pageURL + 'users/' + username + '/exists';

        $.ajax(url, {
            type: 'GET',
            data: null,
            statusCode: {
                200: function(response) {
                    msg_element.removeClass('text-success');
                    msg_element.addClass('text-danger');
                    msg_element.text('Username is in use.');

                    msg_element.parent('div').removeClass('has-success');
                    msg_element.parent('div').addClass('has-error');

                    msg_element.prev('span').removeClass('glyphicon-ok');
                    msg_element.prev('span').addClass('glyphicon-remove');
                },
                404: function(response) {
                    msg_element.addClass('text-success');
                    msg_element.removeClass('text-danger');
                    msg_element.text('');

                    msg_element.parent('div').addClass('has-success');
                    msg_element.parent('div').removeClass('has-error');

                    msg_element.prev('span').addClass('glyphicon-ok');
                    msg_element.prev('span').removeClass('glyphicon-remove');
                }
            },
            success: function() {
            }
        });
    },

    validatePassword: function() {
        var MIN_LENGTH = 6;

        var input = $('input#user_password');
        input.parent('div').removeClass('has-success');
        input.parent('div').removeClass('has-error');
        input.next('span').removeClass('glyphicon-ok');
        input.next('span').removeClass('glyphicon-remove');

        var value = input.val();

        var progress_bar = $('div.progress-bar');
        progress_bar.attr('aria-valuenow', value.length / MIN_LENGTH);
        progress_bar.width(((value.length / MIN_LENGTH) * 100) + '%');

        if (value.length > 5) {
            input.parent('div').addClass('has-success');
            input.next('span').addClass('glyphicon-ok');
            progress_bar.removeClass('progress-bar-warning');
            progress_bar.addClass('progress-bar-success');
        } else {
            input.parent('div').addClass('has-error');
            input.next('span').addClass('glyphicon-remove');
            progress_bar.addClass('progress-bar-warning');
            progress_bar.removeClass('progress-bar-success');
        }
    },

    validatePasswordConfirmation: function() {
        var input = $('input#user_password_confirmation');
        input.parent('div').removeClass('has-success');
        input.parent('div').removeClass('has-error');
        input.next('span').removeClass('glyphicon-ok');
        input.next('span').removeClass('glyphicon-remove');

        var value = $('input#user_password').val();
        var confirmation_value = input.val();
        var status_p = $('p#password_confirmation_status');
        var message = '';

        if (value == confirmation_value && value.length > 0) {
            input.parent('div').addClass('has-success');
            input.next('span').addClass('glyphicon-ok');
            status_p.addClass('text-success');
            status_p.removeClass('text-danger');
        } else {
            input.parent('div').addClass('has-error');
            input.next('span').addClass('glyphicon-remove');
            message = 'Passwords don\'t match.';
            status_p.addClass('text-danger');
            status_p.removeClass('text-success');
        }

        status_p.text(message);
    }

};
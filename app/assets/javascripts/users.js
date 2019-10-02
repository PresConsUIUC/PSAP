var ready = function() {
    // Code for the user registration, edit, and show forms.
    if ($('#new_user').length || $('.edit_user').length || $('#show_user').length) {
        $('.entity_menu a').on('click', function() {
            UserForm.attachEventListeners();
            return false;
        });
        UserForm.attachEventListeners();

        // initialize create-institution panel
        PSAP.Panel.initRemote(
            '#psap-create-panel',
            $('input[name="new_institution_url"]').val(),
            function () {
                PSAP.Form.init();
            }
        );
    }
};

var UserForm = {

    attachEventListeners: function() {
        $('input#user_first_name').bind('keyup input paste', function() {
            PSAP.Form.validate('user_first_name', 1, 255);
        });
        $('input#user_last_name').bind('keyup input paste', function() {
            PSAP.Form.validate('user_last_name', 1, 255);
        });
        $('input#user_email').bind('keyup input paste', function() {
            UserForm.validateEmail();
        });
        $('input#user_username').bind('keyup input paste', function() {
            UserForm.validateUsername();
        });
        $('textarea#user_about').bind('keyup input paste', function() {
            PSAP.Form.validate('user_about', 1, 0);
        });
        $('input#user_password').bind('keyup input paste', function() {
            UserForm.validatePassword();
            UserForm.validatePasswordConfirmation();
        });
        $('input#user_password_confirmation').bind('keyup input paste', function() {
            UserForm.validatePasswordConfirmation();
        });

        if ($('meta[name="request-method"]').attr('content') == 'POST') {
            $('input#user_first_name, input#user_last_name, ' +
            'input#user_email, input#user_about, input#user_username, ' +
            'input#user_password').trigger('paste');
        }
    },

    validateEmail: function() {
        var input = $('input#user_email');
        input.parent('div').removeClass('has-success');
        input.parent('div').removeClass('has-error');
        input.next('span').removeClass('glyphicon-ok');
        input.next('span').removeClass('glyphicon-remove');

        var value = input.val().trim();

        // not perfect, but forces the user to at least put in some effort
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

        var url = $('[name="root_url"]').val() + '/users/' + username + '/exists';

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
            success: function() {}
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

$(document).ready(ready);
$(document).on('page:load', ready);

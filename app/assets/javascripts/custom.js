$(document).ready(function() {
    // Code for the user registration & user edit forms.
    if ($('form#new_user') || $('form.edit_user')) {
        $('input#user_password').bind('keyup input paste', function() {
            UserForm.refreshPasswordStatus();
            UserForm.refreshPasswordConfirmationStatus();
        });
        $('input#user_password_confirmation').bind('keyup input paste', function() {
            UserForm.refreshPasswordConfirmationStatus();
        });
    }
});

var UserForm = {

    refreshPasswordStatus: function() {
        // Update the password feedback text
        var value = $('input#user_password').val();
        var message = '';

        if (value.length == 5) {
            message = 'Needs 1 more character.';
        } else if (value.length < 6) {
            message = 'Needs ' + (6 - value.length) + ' more characters.';
        }
        $('p#password_status').text(message)
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
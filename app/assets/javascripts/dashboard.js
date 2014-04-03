$(document).ready(function() {

    // Code for the dashboard "welcome to PSAP" modal panel. This will only
    // appear when the user is not affiliated with an institution (which will
    // be immediately after they have created an account).
    if ($('body#dashboard').length && $('#welcome_panel').length) {
        // This cookie is set in SessionsController when the user is not
        // affiliated with an institution.
        if ($.cookie('show_welcome_panel')) {
            $('#welcome_panel').modal('show');
            $.removeCookie('show_welcome_panel');
        }
    }

});

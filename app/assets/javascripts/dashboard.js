var ready = function() {
    // Code for the dashboard "welcome to PSAP" modal panel. This will only
    // appear when the user is not affiliated with an institution (which will
    // be immediately after they have created an account).
    if ($('body#dashboard_welcome').length) {
        // This cookie is set in SessionsController when the user has signed
        // in for the first time.
        if ($.cookie('first_signin')) {
            $('#psap-welcome-panel').modal('show');
        }

        // after the user has closed the welcome panel, we want to nag them
        // about taking the pre-usage survey.
        $('#psap-welcome-panel').on('hidden.bs.modal', function(e) {
            setTimeout(function() {
                $('#psap-pre-survey-panel').modal('show');
            }, 800);
        })
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

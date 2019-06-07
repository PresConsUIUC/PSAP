var ready = function() {
    // Code for the dashboard "welcome to PSAP" modal panel. This will only
    // appear when the user is not affiliated with an institution (which will
    // be immediately after they have created an account).
    if ($('body#dashboard_welcome').length) {
        // This cookie is set in SessionsController when the user has signed
        // in for the first time.
        if (Cookies.get('first_signin')) {
            $('#psap-welcome-panel').modal('show');
            Cookies.remove('first_signin'); // prevent it from being shown again
        }

        $('#psap-welcome-panel').on('hide.bs.modal', function(e) {
            $(this).find('video').get(0).pause();
        });

        // after the user has closed the welcome panel, we want to nag them
        // about taking the pre-usage survey.
        $('#psap-welcome-panel').on('hidden.bs.modal', function(e) {
            setTimeout(function() {
                $('#psap-pre-survey-panel').modal('show');
            }, 700);
        })

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

$(document).ready(ready);
$(document).on('page:load', ready);

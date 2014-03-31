$(document).ready(function() {
    // Code for the dashboard "find my institution" modal panel.
    // #find_institution_panel will only appear when the user is not
    // affiliated with an institution (which will only be immediately after
    // they have created an account).
    if ($('body#dashboard') && $('#find_institution_panel')) {
        $('#find_institution_panel').modal('show');
    }
});

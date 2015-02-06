var LocationEditForm = function() {

    this.init = function() {
        // Load the edit panel content via ajax when it appears
        var location_url = $('input[name="location_url"]').val();
        $('#psap-edit-panel').on('show.bs.modal', function (e) {
            $.get(location_url + '/edit', function(data) {
                $(e.target).find('.modal-body').html(data);
                PSAP.Form.init();
            });
        });
    };

};

var ready = function() {
    if ($('body#new_location').length || $('body#show_location').length) {
        new LocationEditForm().init();
    } else if ($('body#assess_location').length) {
        // handled by AssessmentForm in assessments.js
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

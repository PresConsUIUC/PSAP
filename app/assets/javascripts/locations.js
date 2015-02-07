var LocationAssessForm = function() {

    this.init = function() {
        // Load the edit panel content via ajax when it appears
        var location_url = $('input[name="location_url"]').val();
        $('#psap-assess-panel').on('show.bs.modal', function (e) {
            $.get(location_url + '/assess', function(data) {
                $(e.target).find('.modal-body').html(data);
                //PSAP.Form.init();
                AssessmentForm.init('location');
            });
        });
    };

};

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

var ResourceCreateForm = function() {

    this.init = function() {
        // Load the edit panel content via ajax when it appears
        var new_resource_url = $('input[name="new_resource_url"]').val();
        $('#psap-create-panel').on('show.bs.modal', function (e) {
            $.get(new_resource_url, function(data) {
                $(e.target).find('.modal-body').html(data);
                new ResourceEditForm().init(); // resources.js
            });
        });
    };

};

var ready = function() {
    if ($('body#show_location').length) {
        new LocationEditForm().init();
        new LocationAssessForm().init();
        new ResourceCreateForm().init();
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

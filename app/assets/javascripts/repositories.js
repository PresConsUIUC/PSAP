var LocationCreateForm = function() {

    this.init = function() {
        // Load the edit panel content via ajax when it appears
        var new_location_url = $('input[name="new_location_url"]').val();
        $('#psap-create-panel').on('show.bs.modal', function (e) {
            $.get(new_location_url, function(data) {
                $(e.target).find('.modal-body').html(data);
                PSAP.Form.init();
            });
        });
    };

};

var RepositoryEditForm = function() {

    this.init = function() {
        // Load the edit panel content via ajax when it appears
        var repository_url = $('input[name="repository_url"]').val();
        $('#psap-edit-panel').on('show.bs.modal', function (e) {
            $.get(repository_url + '/edit', function(data) {
                $(e.target).find('.modal-body').html(data);
                PSAP.Form.init();
            });
        });
    };

};

var ready = function() {
    if ($('body#new_repository').length || $('body#show_repository').length) {
        new RepositoryEditForm().init();
        new LocationCreateForm().init();
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

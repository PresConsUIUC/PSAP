var ready = function() {
    if ($('body#show_repository').length) {
        // initialize repository-edit panel
        PSAP.Panel.initRemote(
            '#psap-edit-panel',
            $('input[name="repository_url"]').val() + '/edit',
            function () {
                PSAP.Form.init();
            }
        );

        // initialize location-create panel
        PSAP.Panel.initRemote(
            '#psap-create-panel',
            $('input[name="new_location_url"]').val(),
            function () {
                PSAP.Form.init();
            }
        );
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

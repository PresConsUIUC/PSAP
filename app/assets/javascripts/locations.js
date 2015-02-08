var ready = function() {
    if ($('body#show_location').length) {
        // initialize edit panel
        PSAP.Panel.initRemote(
            '#psap-edit-panel',
            $('input[name="location_url"]').val() + '/edit',
            function () {
                PSAP.Form.init();
            }
        );

        // initialize assess panel
        PSAP.Panel.initRemote(
            '#psap-assess-panel',
            $('input[name="location_url"]').val() + '/assess',
            function () {
                new AssessmentForm().init('location'); // assessments.js
            }
        );

        // initialize resource-create panel
        PSAP.Panel.initRemote(
            '#psap-create-panel',
            $('input[name="new_resource_url"]').val(),
            function () {
                new ResourceEditForm().init(); // resources.js
            }
        );
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

var ready = function() {
    if ($('body#show_institution').length) {
        // initialize create-repository panel
        PSAP.Panel.initRemote(
            '#psap-create-panel',
            $('input[name="new_repository_url"]').val(),
            function () {
                PSAP.Form.init();
            }
        );
        
        // initialize edit-institution panel
        PSAP.Panel.initRemote(
            '#psap-edit-panel',
            $('input[name="institution_url"]').val() + '/edit',
            function () {
                PSAP.Form.init();
            }
        );

        // initialize assess-institution panel
        PSAP.Panel.initRemote(
            '#psap-assess-panel',
            $('input[name="institution_url"]').val() + '/assess',
            function () {
                new AssessmentForm('institution');
            }
        );
    }
    if ($('body#institutions').length) {
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

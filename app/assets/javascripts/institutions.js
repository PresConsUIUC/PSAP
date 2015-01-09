var ready = function() {
    if ($('body#show_institution')) {
        ShowInstitutionForm.attachEventListeners();
    }
};

var ShowInstitutionForm = {
    attachEventListeners: function() {
        var form = $('.psap-search');
        var all_elements = form.find('textarea, input, select, button');

        $('.psap-clear').on('click', function() {
            all_elements.prop('disabled', true);
            form.submit();
        });

        // resource type
        $('[name="resource_type"]').on('change', function() {
            if ($(this).filter(':checked').val() == '1') { // 1 = item
                $('#format_id').prop('disabled', false);
                $('[name="assessed"]').prop('disabled', false);
            } else {
                $('#format_id').prop('disabled', true);
                $('[name="assessed"]').prop('disabled', true);
            }
        }).filter(':checked').trigger('change');

        // assessed
        $('[name="assessed"]').on('change', function() {
            if ($(this).filter(':checked').val() == '1') {
                $('#score, #score_direction').prop('disabled', false);
            } else {
                $('#score, #score_direction').prop('disabled', true);
            }
        }).filter(':checked').trigger('change');
    }

};

$(document).ready(ready);
$(document).on('page:load', ready);

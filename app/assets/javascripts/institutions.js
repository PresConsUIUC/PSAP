var ready = function() {
    if ($('body#new_institution')) {
        EditInstitutionForm.attachEventListeners();
    }

    if ($('body#show_institution')) {
        ShowInstitutionForm.attachEventListeners();
    }
};

var EditInstitutionForm = {

    attachEventListeners: function() {
        $('input#institution_name').bind('keyup input paste', function() {
            PSAP.Form.validate('institution_name', 1, 255);
        });
        $('input#institution_url').bind('keyup input paste', function() {
            PSAP.Form.validate('institution_url', 0, 0, Form.TYPE_URL);
        });
        $('input#institution_address1').bind('keyup input paste', function() {
            PSAP.Form.validate('institution_address1', 1, 255);
        });
        $('input#institution_address2').bind('keyup input paste', function() {
            PSAP.Form.validate('institution_address2', 1, 255);
        });
        $('input#institution_city').bind('keyup input paste', function() {
            PSAP.Form.validate('institution_city', 1, 255);
        });
        $('input#institution_state').bind('keyup input paste', function() {
            PSAP.Form.validate('institution_state', 1, 255);
        });
        $('input#institution_postal_code').bind('keyup input paste', function() {
            PSAP.Form.validate('institution_postal_code', 1, 255);
        });
        $('#country').bind('change', function() {
            PSAP.Form.validate('institution_country', 1, 255);
        });
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

var ready = function() {
    if ($('body#new_institution')) {
        InstitutionForm.attachEventListeners();
    }
};

var InstitutionForm = {

    attachEventListeners: function() {
        $('input#institution_name').bind('keyup input paste', function() {
            Form.validate('institution_name', 1, 255);
        });
        $('input#institution_url').bind('keyup input paste', function() {
            Form.validate('institution_url', 0, 0, Form.TYPE_URL);
        });
        $('input#institution_address1').bind('keyup input paste', function() {
            Form.validate('institution_address1', 1, 255);
        });
        $('input#institution_address2').bind('keyup input paste', function() {
            Form.validate('institution_address2', 1, 255);
        });
        $('input#institution_city').bind('keyup input paste', function() {
            Form.validate('institution_city', 1, 255);
        });
        $('input#institution_state').bind('keyup input paste', function() {
            Form.validate('institution_state', 1, 255);
        });
        $('input#institution_postal_code').bind('keyup input paste', function() {
            Form.validate('institution_postal_code', 1, 255);
        });
        $('#country').bind('change', function() {
            Form.validate('institution_country', 1, 255);
        });
    }

};

$(document).ready(ready);
$(document).on('page:load', ready);

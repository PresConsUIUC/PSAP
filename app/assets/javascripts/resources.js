$(document).ready(function() {
    if ($('body#new_resource') || $('body#edit_resource')) {
        ResourceForm.attachEventListeners();
    }
});

var ResourceForm = {

    attachEventListeners: function() {
        $('#resource_date_type').on('change', function(event) {
            switch (parseInt(this.value)) {
                case 0: // single
                    $('input#resource_year').parent().show();
                    $('input#resource_begin_year').val(null);
                    $('input#resource_begin_year').parent().hide();
                    $('input#resource_end_year').val(null);
                    $('input#resource_end_year').parent().hide();
                    break;
                case 1: // bulk
                    $('input#resource_year').val(null);
                    $('input#resource_year').parent().hide();
                    $('input#resource_begin_year').parent().show();
                    $('input#resource_end_year').parent().show();
                    break;
                case 2: // inclusive/span
                    $('input#resource_year').val(null);
                    $('input#resource_year').parent().hide();
                    $('input#resource_begin_year').parent().show();
                    $('input#resource_end_year').parent().show();
                    break;
            }
        });
    }

};

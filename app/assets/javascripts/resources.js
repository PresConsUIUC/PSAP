$(document).ready(function() {
    if ($('body#new_resource') || $('body#edit_resource')) {
        ResourceForm.init();
    }
});

var ResourceForm = {

    init: function() {
        ResourceForm.attachEventListeners();
    },

    attachEventListeners: function() {
        $('select.date_type').on('change', function(event) {
            switch (parseInt(this.value)) {
                case 0: // single
                    $(this).nextAll('div.date:first').show()
                    $(this).nextAll('div.begin_date:first').hide()
                    $(this).nextAll('div.end_date:first').hide()
                    break;
                default: // bulk or inclusive/span
                    $(this).nextAll('div.date:first').hide()
                    $(this).nextAll('div.begin_date:first').show()
                    $(this).nextAll('div.end_date:first').show()
                    break;
            }
        }).trigger('change');
    }

};

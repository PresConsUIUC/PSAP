var ready = function() {
    if ($('body#format_id_guide').length) {
        $('table').addClass('table').addClass('table-striped');
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

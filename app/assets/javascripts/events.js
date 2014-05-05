$(document).ready(function() {
    if ($('body#events').length) {
        $('.level_button').on('click', function () {
            $('.level_button').removeClass('btn-info');
            $('.level_button').removeClass('btn-warning');
            $('.level_button').removeClass('btn-danger');
            $('.level_button').addClass('btn-default');
            $(this).removeClass('btn-default');

            var level = $(this).attr('data-level');
            if (level > 4) {
                $(this).addClass('btn-info');
            } else if (level > 2) {
                $(this).addClass('btn-warning');
            } else {
                $(this).addClass('btn-danger');
            }
        });
    }
});

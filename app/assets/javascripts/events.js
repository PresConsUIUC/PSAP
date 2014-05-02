$(document).ready(function() {
    if ($('body#events').length) {
        $('.level_button').on('click', function () {
            $.get($(this).attr('href'), null, null, 'script');
            return false;
        });
    }
});

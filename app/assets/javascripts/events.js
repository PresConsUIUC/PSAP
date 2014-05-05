$(document).ready(function() {
    if ($('body#events').length) {
        var updateFeedLink = function() {
            var new_url = document.createElement('a');
            new_url.href = $('.event_feed_link:first').attr('href');
            var new_level = $('.level_button.active').attr('data-level');
            new_url.search = 'level=' + new_level;
            $('.event_feed_link:first').attr('href', new_url);

            $('input[name="level"]').val(new_level);
        };

        $('.level_button').on('click', function () {
            // update level button classes
            $('.level_button').removeClass('active');
            $('.level_button').removeClass('btn-info');
            $('.level_button').removeClass('btn-warning');
            $('.level_button').removeClass('btn-danger');
            $('.level_button').addClass('btn-default');
            $(this).removeClass('btn-default');
            $(this).addClass('active');

            var level = $(this).attr('data-level');
            if (level > 4) {
                $(this).addClass('btn-info');
            } else if (level > 2) {
                $(this).addClass('btn-warning');
            } else {
                $(this).addClass('btn-danger');
            }

            updateFeedLink();
        });

        updateFeedLink();
    }
});

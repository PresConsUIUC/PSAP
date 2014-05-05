$(document).ready(function() {
    if ($('body#events').length) {
        var updateFeedLink = function() {
            var new_url = document.createElement('a');
            new_url.href = $('.feed_link:first').attr('href');

            new_url = updateQueryStringParameter(new_url.toString(), 'level',
                $('.level_button.active').attr('data-level'));

            $('.feed_link:first').attr('href', new_url);

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

        function updateQueryStringParameter(uri, key, value) {
            var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
            var separator = uri.indexOf('?') !== -1 ? "&" : "?";
            if (uri.match(re)) {
                return uri.replace(re, '$1' + key + "=" + value + '$2');
            }
            else {
                return uri + separator + key + "=" + value;
            }
        }
    }
});

var ready = function() {
    if ($('body#events').length) {
        var Events = {

            initEventListeners: function() {
                $('.level_button').on('click', function () {
                    Events.updateLevelButtons($(this));
                });
            },

            updateFeedLink: function() {
                var new_url = document.createElement('a');
                new_url.href = $('.psap-feed-link:first').attr('href');

                var new_level = $('.level_button.active').attr('data-level');
                new_url = updateQueryStringParameter(new_url.toString(), 'level',
                    new_level);

                $('.psap-feed-link:first').attr('href', new_url);

                $('input[name="level"]').val(new_level);

                function updateQueryStringParameter(uri, key, value) {
                    var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
                    var separator = uri.indexOf('?') !== -1 ? "&" : "?";
                    if (uri.match(re)) {
                        return uri.replace(re, '$1' + key + "=" + value + '$2');
                    }
                    return uri + separator + key + "=" + value;
                }
            },

            updateLevelButtons: function(selected_button) {
                $('.level_button').
                    removeClass('active btn-info btn-warning btn-danger').
                    addClass('btn-default');
                selected_button.removeClass('btn-default').addClass('active');

                var level = selected_button.attr('data-level');
                if (level > 4) {
                    selected_button.addClass('btn-info');
                } else if (level > 2) {
                    selected_button.addClass('btn-warning');
                } else {
                    selected_button.addClass('btn-danger');
                }
            }
        };

        Events.initEventListeners();
        Events.updateFeedLink();

        $(document).ajaxComplete(function(event, request, options) {
            var level = $('input[name="level"]').val();
            var button = $('.level_button[data-level="' + level + '"]');
            Events.updateLevelButtons(button);
        });
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

var ready = function() {
    if ($('body#format_id_guide').length) {
        var all_formats_link = $('a[href="#all_formats"]');
        var showAllSections = function() {
            $('div.tab-content div').addClass('active');
        };
        if (all_formats_link.parent().hasClass('active')) {
            showAllSections();
        }
        all_formats_link.on('click', showAllSections);

    } else if ($('body#format_id_guide_categories').length) {
        $('table').addClass('table').addClass('table-striped');

        // http://fancyapps.com/fancybox/#examples
        $(".fancybox").fancybox({
            parent: 'body', // required for turbolinks compatibility
            beforeShow : function() {
                var alt = this.element.find('img').attr('alt');
                this.inner.find('img').attr('alt', alt);

                var caption = this.element.find('img').data('caption');
                this.title = caption;
            },
            helpers : {
                title: {
                    type: 'outside'
                }
            }
        });

        // smooth scroll to anchor locations when clicking links in TOC
        var $root = $('html, body');
        $('a').click(function() {
            var href = $.attr(this, 'href');
            $root.animate({
                scrollTop: $(href).offset().top - 60
            }, 500, function () {
                window.location.hash = href;
            });
            return false;
        });
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

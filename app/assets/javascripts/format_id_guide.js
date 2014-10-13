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
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

var ready = function() {
    if ($('body#format_id_guide').length) {
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

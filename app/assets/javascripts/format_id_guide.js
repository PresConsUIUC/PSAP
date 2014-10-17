var ready = function() {
    if ($('body#format_id_guide').length) {
        $('body').scrollspy({
            target: '#sections',
            offset: $('nav.navbar.navbar-default').height() + 15
        });

        $('#sections').affix({
            offset: { top: 160 }
        });
    } else if ($('body#format_id_guide_page').length) {
        // dynamically add some needed classes
        $('table').addClass('table').addClass('table-striped');

        // move the header
        $('div#page_content div.col-sm-9:first').append(
            $('div#page_content h1:first'));

        // set up fancybox
        $('div#page_content img').each(function() {
            $(this).wrap('<a class="fancybox" href="' + $(this).data('lightbox-src') + '"></a>');
        });

        // http://fancyapps.com/fancybox/#examples
        $(".fancybox").fancybox({
            parent: 'body', // required for turbolinks compatibility
            beforeShow : function() {
                var alt = this.element.find('img').attr('alt');
                this.inner.find('img').attr('alt', alt);

                //$('div.fancybox-wrap').removeClass('fancybox-type-inline').
                //    addClass('fancybox-type-image');
                //this.inner.css('overflow', 'visible');
                //this.inner.find('img').addClass('fancybox-image');

                var caption = this.element.next('figcaption').html();
                //$('div.fancybox-skin').append('<div class="fancybox-title">' + caption + '</div>');
                this.title = caption;
            },
            afterClose: function() {
                $(".fancybox").show();
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

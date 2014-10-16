var ready = function() {
    if ($('body#format_id_guide').length) {
        $('body').scrollspy({ target: '#sections' });

        $('#sections').affix({
            offset: { top: 160 }
        });
    } else if ($('body#format_id_guide_categories').length) {
        // dynamically add some needed classes
        $('table').addClass('table').addClass('table-striped');
        $('div#page_content img').each(function() {
            $(this).wrap('<a class="fancybox" href="' + $(this).attr('src') + '"></a>');
        });

        // move the header
        $('div#page_content').find('div.col-sm-9:first').append(
            $('div#page_content h1:first'));

        // http://fancyapps.com/fancybox/#examples
        $(".fancybox").fancybox({
            parent: 'body', // required for turbolinks compatibility
            beforeShow : function() {
                var alt = this.element.find('img').attr('alt');
                this.inner.find('img').attr('alt', alt);

                var caption = this.element.next('figcaption').html();
                this.title = caption;
            },
            helpers : {
                title: {
                    type: 'outside'
                }
            }
        });
    }

    // smooth scroll to anchor locations when clicking links in TOC
    var $root = $('html, body');
    $('a').click(function() {
        var href = $.attr(this, 'href');
        $root.animate({
            scrollTop: $(href).offset().top //- 60
        }, 500, function () {
            window.location.hash = href;
        });
        return false;
    });
};

$(document).ready(ready);
$(document).on('page:load', ready);

var ready = function() {
    if ($('body#format_id_guide').length) {
        smoothAnchorScroll(0); // defined in common.js

        $('body').scrollspy({
            target: '#sections',
            offset: $('nav.navbar.navbar-default').height() + 15
        });

        if ($('body').width() > 600) {
            $('#sections').affix({
                offset: { top: 160 }
            });
        }
    } else if ($('body#format_id_guide_page').length) {
        smoothAnchorScroll(0); // defined in common.js

        // dynamically add some needed classes
        $('table').addClass('table').addClass('table-striped');

        // move the header
        $('div#page_content div.col-sm-9:first').append(
            $('div#page_content h1:first'));

        // initialize Magnific Popup
        $('div#page_content img').each(function() {
            $(this).wrap('<a class="magnific" href="' + $(this).data('lightbox-src') + '"></a>');
        });

        $('a.magnific').magnificPopup({
            type: 'image',
            mainClass: 'mfp-with-zoom',
            closeOnContentClick: true,
            alignTop: false,
            showCloseBtn: false,
            image: {
                titleSrc: function(item) {
                    return item.el.next('figcaption').html();
                },
                verticalFit: true,
                cursor: null
            },
            retina: {
                ratio: 2
            },
            zoom: {
                enabled: true,
                duration: 300,
                easing: 'ease-in-out' // CSS transition easing function
            },
            callbacks: {
                resize: function() {
                    // without this, the title will be pushed below the viewport
                    var img = this.content.find('img');
                    img.css('max-height', parseFloat(img.css('max-height')) * 0.94);
                }
            }
        });
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

var ready = function() {
    if ($('body#format_id_guide_page').length || $('body#help_page').length) {
        // dynamically add some needed classes
        $('table').addClass('table table-striped');
        var page_content = $('div#page_content');
        page_content.find('img').addClass('img-thumbnail gallery-item');

        // move the header
        page_content.find('div.col-sm-8:first').append(
            page_content.find('h1:first'));

        // initialize Magnific Popup
        page_content.find('img').each(function() {
            var lightbox_src = (window.devicePixelRatio > 1) ?
                $(this).data('retina-lightbox-src') :
                $(this).data('lightbox-src');
            $(this).wrap('<a class="magnific" href="' + lightbox_src + '"></a>');
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
            gallery: {
                enabled: true,
                navigateByImgClick: false
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

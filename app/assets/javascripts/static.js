var ready = function() {
    if ($('#glossary').length) {
        $('body').scrollspy({
            target: '#psap-glossary-letter-links',
            offset: $('nav.navbar.navbar-default').height() + 210
        });

        $('#psap-glossary-letter-links').affix({
            offset: { top: 220 }
        });

        smoothAnchorScroll(96); // defined in common.js
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

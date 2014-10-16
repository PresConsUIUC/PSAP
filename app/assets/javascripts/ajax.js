$(document).ajaxStart(function(event, request, options) {
    $('form.psap-live-search input').removeClass('active');
});

/**
 Displays a flash message based on the contents of the X-Message and
 X-Message-Type headers.
 */
$(document).ajaxComplete(function(event, request, options) {
    $('form.psap-live-search input').removeClass('active');

    $('#modal_progress_view').hide();

    // These headers are set by an ApplicationController after_filter, to
    // support ajax requests.
    var msg = request.getResponseHeader('X-Message');
    if (msg) {
        // remove any existing messages
        $('div.alert').remove();

        // determine which CSS class to use for the message
        var type = request.getResponseHeader('X-Message-Type');
        var bootstrapClass;
        switch (type) {
            case 'success':
                bootstrapClass = 'alert-success';
                break;
            case 'error':
                bootstrapClass = 'alert-danger';
                break;
            case 'alert':
                bootstrapClass = 'alert-block';
                break;
            default:
                bootstrapClass = 'alert-info';
                break;
        }

        // construct the message
        var flash = $('<div class="alert ' + bootstrapClass + '"></div>');
        var button = $('<button type="button" class="close"' +
            ' data-dismiss="alert" aria-hidden="true">&times;</button>');
        flash.append(button);
        button.after(msg);

        // append it to the DOM
        $('div.container header, div.container-fluid header').after(flash);

        // fade it out after a delay
        //setTimeout(function() {
        //    $('div.alert').fadeOut(1000);
        //}, 5000);
    }
});

$(document).ajaxError(function(event, request) {
    var msg = request.getResponseHeader('X-Message');
    if (msg) {
        alert(msg);
    }
});

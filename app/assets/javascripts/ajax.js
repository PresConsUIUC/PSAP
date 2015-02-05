/**
 Displays a flash message based on the contents of the X-Message and
 X-Message-Type headers.
 */
$(document).ajaxComplete(function(event, request, options) {
    $('#psap-ajax-shade').hide();

    // These headers are set by an ApplicationController after_filter, to
    // support ajax requests.
    var msg = request.getResponseHeader('X-Psap-Message');
    console.log('ajaxComplete: X-Psap-Message header: ' + msg);
    if (msg) {
        // remove any existing messages
        $('div.alert').remove();

        // determine which CSS class to use for the message
        var type = request.getResponseHeader('X-Psap-Message-Type');
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
    }
});

$(document).ajaxSuccess(function(event, request) {
    console.log('ajaxSuccess');

    var edit_panel = $('#psap-edit-panel');
    var action = request.getResponseHeader('X-Psap-Action');
    // if the action was successful, close the panel so we can display the flash
    if (action == 'success') {
        if (edit_panel.length) {
            if (edit_panel.hasClass('in')) {
                edit_panel.modal('hide');
            }
        }
    } else if (action == 'error') {
        edit_panel.animate({ scrollTop: 0 }, 'fast');
    }
});

$(document).ajaxError(function(event, request) {
    console.log('ajaxError');
});

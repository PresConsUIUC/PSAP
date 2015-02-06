// The X-Psap-Message and X-Psap-Message-Type headers are set by an
// ApplicationController after_filter to support ajax requests.
// X-Psap-Result is an other header that, if set, can contain "success" or
// "error", indicating the result of a form submission.

$(document).ajaxComplete(function(event, request, options) {
    $('#psap-ajax-shade').hide();
});

$(document).ajaxSuccess(function(event, request) {
    var result = request.getResponseHeader('X-Psap-Result');
    var edit_panel = $('.psap-edit-panel.in');

    if (result && edit_panel.length) {
        if (result == 'success') {
            edit_panel.modal('hide');
        } else if (result == 'error') {
            edit_panel.animate({ scrollTop: 0 }, 'fast');
        }
        var message = request.getResponseHeader('X-Psap-Message');
        var message_type = request.getResponseHeader('X-Psap-Message-Type');
        if (message && message_type) {
            PSAP.Flash.set(message, message_type);
        }
    }
});

$(document).ajaxError(function(event, request) {
    console.log('ajaxError');
});

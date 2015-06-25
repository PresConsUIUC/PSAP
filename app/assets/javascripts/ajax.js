// The X-Psap-Message and X-Psap-Message-Type headers are set by an
// ApplicationController after_filter to support ajax requests.
// X-Psap-Result is an other header that, if set, can contain "success" or
// "error", indicating the result of a form submission.

$(document).ajaxComplete(function(event, request, options) {
    $('#psap-ajax-shade').hide();
});

$(document).ajaxSuccess(function(event, request) {
    var result_type = request.getResponseHeader('X-Psap-Message-Type');
    var edit_panel = $('.psap-edit-panel.in');

    if (result_type && (edit_panel.length || $('body#edit_user').length)) {
        if (result_type == 'success') {
            edit_panel.modal('hide');
        } else if (result_type == 'error') {
            edit_panel.find('.modal-body').animate({ scrollTop: 0 }, 'fast');
        }
        var message = request.getResponseHeader('X-Psap-Message');
        if (message && result_type) {
            PSAP.Flash.set(message, result_type);
        }
    }
});

$(document).ajaxError(function(event, request) {
    console.log('ajaxError');
});

$(document).ajaxError(function(event, request) {
    console.log('Error: X-Message header: ' +
        request.getResponseHeader('X-Message'));
});

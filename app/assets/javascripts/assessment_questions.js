$(document).ready(function() {
    if ($('body#new_assessment_question').length
        || $('body#edit_assessment_question').length) {

        $('select[data-option-dependent=true]').each(function() {
            var observer_dom_id = $(this).attr('id');
            var observed_dom_id = $(this).data('option-observed');
            var url_mask = $(this).data('option-url');
            var key_method = $(this).data('option-key-method');
            var value_method = $(this).data('option-value-method');
            var prompt = $(this).has('option[value=]').size() ?
                $(this).find('option[value=]') :
                $('<option value=\"\">').text('Select a specialization');
            var regexp = /:[0-9a-zA-Z_]+:/g;
            var observer = $('select#' + observer_dom_id);
            var observed = $('#' + observed_dom_id);

            if (!observer.val() && observed.size() > 1) {
                observer.attr('disabled', true);
            }
            observed.on('change', function() {
                //observer.empty().append(prompt);
                observer.empty();
                if (observed.val()) {
                    url = url_mask.replace(regexp, observed.val());
                    $.getJSON(url, function (data) {
                        $.each(data, function (i, object) {
                            observer.append($('<option>').attr('value',
                                object[key_method]).text(object[value_method]));
                            observer.attr('disabled', false);
                        });
                    });
                }
            });
        });
    }
});

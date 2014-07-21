var ready = function() {
    if ($('body#show_location')) {
        var checkboxes = $('input[name="resources[]"]');

        function refreshCheckboxUI() {
            var all_checked = checkboxes.filter(':checked').length == checkboxes.length;
            var none_checked = checkboxes.filter(':checked').length == 0;

            $('button.psap-move-checked').prop('disabled', none_checked);
            if (all_checked) {
                $('.psap-check-all').prop('disabled', true);
                $('.psap-uncheck-all').prop('disabled', false);
            } else if (none_checked) {
                $('.psap-check-all').prop('disabled', false);
                $('.psap-uncheck-all').prop('disabled', true);
            } else {
                $('.psap-check-all').prop('disabled', false);
                $('.psap-uncheck-all').prop('disabled', false);
            }
        }

        // hook up "check/uncheck all" buttons
        $('.psap-check-all').on('click', function() {
            checkboxes.each(function() {
                $(this).prop('checked', true);
            });
            refreshCheckboxUI();
            checkboxes.trigger('change');
        });
        $('.psap-uncheck-all').on('click', function() {
            checkboxes.each(function() {
                $(this).prop('checked', false);
            });
            refreshCheckboxUI();
            checkboxes.trigger('change');
        });

        // conditionally enable the "move checked" button depending on whether
        // any checkboxes are checked
        checkboxes.on('change', function() {
            refreshCheckboxUI();
        }).trigger('change');
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

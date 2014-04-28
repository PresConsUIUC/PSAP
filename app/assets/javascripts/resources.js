$(document).ready(function() {
    if ($('body#new_resource') || $('body#edit_resource')) {
        ResourceForm.init();
    }
});

var ResourceForm = {

    init: function() {
        ResourceForm.attachEventListeners();
        ResourceForm.updateProgressBar();
        ResourceForm.updateScoreBar();
    },

    attachEventListeners: function() {
        $('select.date_type').on('change', function(event) {
            switch (parseInt(this.value)) {
                case 0: // single
                    $(this).nextAll('div.date:first').show();
                    $(this).nextAll('div.begin_date:first').hide();
                    $(this).nextAll('div.end_date:first').hide();
                    break;
                default: // bulk or inclusive/span
                    $(this).nextAll('div.date:first').hide();
                    $(this).nextAll('div.begin_date:first').show();
                    $(this).nextAll('div.end_date:first').show();
                    break;
            }
        }).trigger('change');

        $('input.year').on('keyup', function(event) {
            if ($(this).val().length < 1) {
                $(this).parent().parent().find('input.month').prop('disabled', true);
                $(this).parent().parent().find('input.day').prop('disabled', true);
            } else {
                $(this).parent().parent().find('input.month').prop('disabled', false);
            }
        }).trigger('keyup');

        $('input.month').on('keyup', function(event) {
            if ($(this).val().length < 1) {
                $(this).parent().parent().find('input.day').prop('disabled', true);
            } else {
                $(this).parent().parent().find('input.day').prop('disabled', false);
            }
        }).trigger('keyup');

        $('.question input, .question select').on('change', function(event) {
            ResourceForm.updateProgressBar();
            ResourceForm.updateScoreBar();
        });
    },

    updateScoreBar: function() {
    },

    updateProgressBar: function() {
        var numQuestions = $('.question').length;
        var numAnsweredQuestions = 0;
        $('.question').each(function() {
            var numChecked = $(this).find('input:checked').length;
            if (numChecked > 0 || $(this).find('select').val() !== undefined) {
                numAnsweredQuestions++;
            }
        });
        $('div.progress-bar.psap-progress').attr('style',
                'width:' + numAnsweredQuestions / numQuestions * 100 + '%');
    }

};

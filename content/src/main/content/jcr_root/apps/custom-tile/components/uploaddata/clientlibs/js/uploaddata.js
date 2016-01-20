;(function (window, $, _, undefined) {
    'use strict';

    //---------------------------------------------------------------------------

    var ui = $(window).adaptTo("foundation-ui");
    var uploadFormRel = '.custom-tile-upload-form';
    var uploaderRel = uploadFormRel + ' .coral-Form-field[name=articledata]';
    var showFileNameClass = 'custom-tile-upload-file';
    var ticker;

    $(document).on("foundation-contentloaded" + uploadFormRel, function() {
        var uploadForm = $(uploadFormRel);
        if (uploadForm.length > 0) {

            uploadForm.off("submit" + uploadFormRel)
                .on("submit" + uploadFormRel, handleSubmit);

            uploadForm.closest('coral-Dialog').off("show" + uploadFormRel)
                .on("show" + uploadFormRel, reset);

            var fileUploader = $(uploaderRel);
            fileUploader.off('change' + uploadFormRel)
                .on('change' + uploadFormRel, function(event) {
                    var filename = $(event.currentTarget).find('input').val();
                    if (filename.indexOf('/') > 0) {
                        filename = filename.substring(filename.lastIndexOf('/') + 1);
                    }
                    if (filename.indexOf('\\') > 0) {
                        filename = filename.substring(filename.lastIndexOf('\\') + 1);
                    }

                    var uploadForm = $(uploadFormRel);
                    showFileName(filename, uploadForm);
                });

        }
    });

    function handleFoundationFormSubmitted(success, xhr) {
        reset();
    }

    function handleSubmit(event) {
        var showFile = $('.' + showFileNameClass);
        var filename = showFile.find('span').last().html();
        var title = Granite.I18n.get("Uploading"),
            msg = Granite.I18n.get("Uploading data file: " + filename);
        var uploadForm = $(uploadFormRel);

        ticker = ui.waitTicker(title, msg);

        uploadForm.off("foundation-form-submitted" + uploadFormRel)
            .on("foundation-form-submitted" + uploadFormRel, handleFoundationFormSubmitted);
    }

    function showFileName(filename, uploadForm) {
        var showFile = $('.' + showFileNameClass);
        if (showFile.length == 0) {
            showFile = $('<div class=' + showFileNameClass + '>');
            uploadForm.append(showFile);
        }
        showFile.html('<span>' + Granite.I18n.get('File') + ':</span><span>' + encodeURIComponent(filename) + '</span>');
    }

    function reset() {
        if (ticker) {
            ticker.clear();
        }
        var uploadForm = $(uploadFormRel);

        uploadForm.find(':input[type=file]').val('');
        uploadForm.find('.' + showFileNameClass).remove();
        var fileUpload = uploadForm.find('.coral3-FileUpload').data('fileUpload');
        if (fileUpload) {
            fileUpload.uploadQueue = $.makeArray();
        }
    }
    
}(window, Granite.$, _));

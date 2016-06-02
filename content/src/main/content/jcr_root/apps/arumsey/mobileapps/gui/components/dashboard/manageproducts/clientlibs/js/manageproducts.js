;(function(window, document, Granite, $) {
    'use strict';

    var ns = '.cq-apps-CardDashboard-ManageProducts';
    var relImportFromCommerce = 'form#displayImportFromCommerceModal';
    var relUpdate = 'form#displayUploadProductModal';
    var ui = $(window).adaptTo('foundation-ui');

    var waitTicker = null;

    $(document).off('foundation-contentloaded' + ns)
        .on('foundation-contentloaded' + ns, function() {
            $(relUpdate).off('foundation-form-submitted' + ns)
                .on('foundation-form-submitted' + ns, function(e, success, xhr) {
                    handleFoundationFormSubmitted(success, xhr, $(relUpdate));
                    e.preventDefault();
                    return false;
                });
            $(relImportFromCommerce).off('foundation-form-submitted' + ns)
                .on('foundation-form-submitted' + ns, function(e, success, xhr) {
                    handleFoundationFormSubmitted(success, xhr, $(relImportFromCommerce));
                    e.preventDefault();
                    return false;
                });
            $(relImportFromCommerce).find('button[type=submit]').off('click' + ns)
                .on('click' + ns, function(e) {
                    setModalToWaiting(e, Granite.I18n.get('Import'));
                });
            $(relUpdate).find('button[type=submit]').off('click' + ns)
                .on('click' + ns, function(e) {
                    setModalToWaiting(e, Granite.I18n.get('Update'));
                });
        });

    /**
     * Handle the response from the creation form submit
     * @param success
     * @param xhr
     * @param $form
     */
    function handleFoundationFormSubmitted(success, xhr, $form) {
        var errorMsg;
        try {
            var jsonResponse = JSON.parse(xhr.responseText);
            errorMsg = jsonResponse.error;
        } catch(err) {
            // json parse failed.  That's ok.
        }

        // Dismiss prompt modal if it is still visible.
        if ($form.is(':visible')) {
            $form.modal('hide');
        }
        // Dismiss the wait ticker, or the general wait overlay
        if (waitTicker) {
            waitTicker.clear();
            waitTicker = null;
        } else {
        ui.clearWait();
        }

        if (errorMsg != undefined ) {
            ui.alert(Granite.I18n.get('Error'), errorMsg, 'error');
        } else if (!success) {
            var message = '';
            if (xhr.responseText.indexOf('<title>') > 0) {
                message = xhr.responseText.substr(xhr.responseText.indexOf('<title>') + 7);
                message = message.substr(0, message.lastIndexOf('</title>'));
            } else {
                var $html = $(xhr.responseText);
                message = $html.find('.foundation-form-response-status-message').next().html();
            }

            if (message.length == 0) {
                message = Granite.I18n.get('Unexpected Error.');
                message += '<br /><br />' + Granite.I18n.get('Details: ') + xhr.statusText + ': ' + xhr.status;
            }
            ui.alert(Granite.I18n.get('Error'), message, 'error');
        } else {
            ui.notify(Granite.I18n.get('Success'),
                Granite.I18n.get('{0}: Successfully Executed', $form.find('.coral-Modal-title').text(), 'modal title'),
                'success');
            $(document).trigger("products-reloaded");
        }
    }

    function setModalToWaiting(clickEvent, action) {
        // Give user feed back that the action is executing.
        waitTicker = ui.waitTicker(action, Granite.I18n.get('Please wait while the {0} executes.', action, '"update" or "import", already translated'));

        // Hide the prompt modal.
        var modal = $(clickEvent.currentTarget).closest('form');
        modal.modal('hide');
    }

})(window, document, Granite, Granite.$);


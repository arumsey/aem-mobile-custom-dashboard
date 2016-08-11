/*
 * ADOBE CONFIDENTIAL
 * __________________
 *
 *  Copyright 2014 Adobe Systems Incorporated
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 */

(function($, window, undefined) {

    var ns = '.cq-apps-content-clickable-row';
    var actionRel = '.cq-apps-CardDashboard-Content .cq-apps-DashboardTable tr.cq-apps-clickable-row';

    $(document).off('foundation-contentloaded' + ns)
        .on('foundation-contentloaded' + ns, function() {
            $(actionRel).off('click' + ns)
                .on('click' + ns, function(event) {
                    var contentName = $(this).data("href-tabname");
                    if (!contentName) {
                        contentName = 'appcontent';
                    }
                    window.open($(this).data("href"), contentName);
                });
        });

}(Granite.$, window));

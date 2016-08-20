(function() {
    'use strict';

    var emptySpan,
        rel = ".cq-apps-CardDashboard-Content.custom";

    Coral.register( {
        name: 'arStatus',
        tagName: 'ar-status',
        className: 'ar-status',
        properties: {
            'emptyText': {
                'default': false,
                reflectAttribute: true,
                sync: function() {
                    if (this.empty) {
                        this._render();
                    }
                }
            }
        },

        _initialize: function() {
            var self = this;

            Coral.commons.addResizeListener($(rel).get(0), function() {
                self._render();
            });

            $(document).on("status-reloaded", function() {
                self._loadStatus();
            });

            this._loadStatus();

            if (this.emptyText && emptyTextEl === undefined) {
                emptySpan = document.createElement("span");
                var emptyTextEl = document.createTextNode(this.emptyText);
                emptySpan.appendChild(emptyTextEl);
                emptySpan.style.display = 'none';
                this.appendChild(emptySpan);
            }
        },

        _render: function() {
            if (!emptySpan) {
                return;
            }

            if (this._isEmpty()) {
                emptySpan.style.display = 'block';
            } else {
                emptySpan.style.display = 'none';

                var d = cloudViz.donut({
                    width: '100%',
                    height: 350,
                    data: this._json,
                    colors: ['rgb(255, 91, 64)', 'rgb(121, 169, 255)', 'rgb(167, 204, 77)', 'rgb(70,130,180)', 'rgb(135,206,250)'],
                    parent: this,
                });
                d.render();
            }
        },

        _isEmpty: function() {
            this._json == undefined;
        },


        _loadStatus: function() {
            var self = this;
            var url = $(rel).find(".cq-apps-CardDashboard-body").data("feedHref");
            if (!url) {
                return
            }
            $.ajax({
                'url': Granite.HTTP.externalize(url),
                'dataType': 'json',
                'success': function (data) {

                    var pkgCount = 0,
                        pagesPkgs = 0,
                        pendingCount = 0,
                        pagesCount = 0,
                        assetsCount = 0;
                    for (var pkg in data) {
                        pkgCount++;
                        if( ! data.hasOwnProperty(pkg) ) {
                            continue;
                        }
                        if ("pages" == data[pkg].type) {
                            pagesPkgs++;
                            pagesCount += data[pkg].childResourceCount;
                        } else {
                            assetsCount += data[pkg].childResourceCount;
                        }
                        if (data[pkg].hasPendingChanges) {
                            pendingCount++;
                        }
                    }

                    self._json = {
                        'y': [pagesPkgs, pkgCount-pagesPkgs, pagesCount, assetsCount],
                        'x': ["Content Packages", "App Packages", "Pages", "Assets"],
                        'series': ["Content Packages", "Content Packages", "Resources", "Resources"]
                    };

                    self._render();
                }
            });
        }

    });

}());
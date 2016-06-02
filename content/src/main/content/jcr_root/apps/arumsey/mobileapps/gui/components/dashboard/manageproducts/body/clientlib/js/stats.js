(function() {
    'use strict';

    var emptySpan;

    Coral.register( {
        name: 'WeProducts',
        tagName: 'we-product',
        className: 'we-product',
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

            Coral.commons.addResizeListener($('.cq-apps-CardDashboard-ManageProducts').get(0), function() {
                self._render();
            });

            $(document).on("products-reloaded", function() {
                self._loadProducts();
            });

            this._loadProducts();

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


        _loadProducts: function() {
            var self = this;
            $.ajax({
                'url': Granite.HTTP.externalize('/content/mobileapps/we-healthcare-sales.wehealth.status.json'),
                'dataType': 'json',
                'success': function (data) {
                    var content_needsimport= data['products.inapp.not'];
                    var content_needsupdate= data['products.inapp.outofdate'];
                    var content_uptodate= data['products.inapp.uptodate'];

                    var state_uploaded = data['products.included.uploaded'];
                    var state_needsupload = data['products.included.needsupload'];

                    self._json = {
                        'y': [content_needsimport, content_needsupdate, content_uptodate, state_uploaded, state_needsupload],
                        'x': ["Missing from App ", "In App : Out of date", "In App: Up to date", "In Mobile On-Demand", "Missing from Mobile On-Demand"],
                        'series': ["Products in Commerce", "Products in Commerce", "Products in Commerce", "Products in Mobile On-Demand", "Products in Mobile On-Demand"]
                    };

                    self._render();
                }
            });
        }

    });

}());
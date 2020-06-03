import Product from "../models/product"
import _ from "underscore"

var ProductView = Backbone.View.extend({
  model: Product,
  template: _.template($("#product_view_template").html()),
  tagName: 'tr',
  render: function(){
    this.$el.html(this.template(this.model.toJSON()));
    return this;
  }
});

export default ProductView

import Group from "../models/group"
import Products from "../collections/products"
import ProductView from "../views/product_view"
import _ from "underscore"

var GroupView = Backbone.View.extend({
  model: Group,
  template: _.template($("#group_view_template").html()),
  renderProducts: function(){
    let products = new Products(this.model.get("products"));
    products.each( (product) => {
      let view = new ProductView({model: product});
      this.$el.find(".products").append(view.render().$el);
    });
  },
  render: function(){
    this.$el.html(this.template(this.model.toJSON()));
    this.renderProducts();
    return this;
  }
});

export default GroupView

import Product from "../models/product"

var Products = Backbone.Collection.extend({
  model: Product,
  url: "/products",
});

export default Products

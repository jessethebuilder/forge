import Menu from "../models/menu"

var Menus = Backbone.Collection.extend({
  url: '/menus',
  model: Menu
});

export default Menus

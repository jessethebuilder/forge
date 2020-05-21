import Menu from "../models/menu"
import _ from "underscore"

var MenuView = Backbone.View.extend({
  model: Menu,
  el: "#menu",
  template: _.template($("#menu_view_template").html()),
  initialize: function(){

  },
  render: function(){
    this.$el.html(this.template({menu: this.model}));
    return this;
  }
});

export default MenuView

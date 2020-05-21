import Menus from "../collections/menus"
import MenuView from "./menu_view"
import _ from "underscore"

var MenusView = Backbone.View.extend({
  collection: Menus,
  template: _.template($("#menus_view_template").html()),
  el: "#menus",
  initialize: function(){

  },
  events: {
    // "click .menu_picker" : "renderMenu"
  },
  renderMenu: function(menu_id){
    let menu = this.collection.find(menu_id);
    if(typeof menu === "undefined"){
      menu = this.collection.models[0];
    }

    let menu_view = new MenuView({model: menu});
    menu_view.render();
  },
  render: function(){
    console.log("Rendering MenusView");
    this.$el.html(this.template({menus: this.collection}));
    return this;
  }
});

export default MenusView

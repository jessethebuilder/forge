var MenusRouter = Backbone.Router.extend({
  routes: {
    "" : "showMenu",
    ":menu_id" : "showMenu"
  },
  showMenu: function(){
    let menu_id = window.location.hash.substr(1);
    this.view.renderMenu(menu_id);
  }
});

export default MenusRouter

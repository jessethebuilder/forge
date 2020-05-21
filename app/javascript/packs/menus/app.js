import MenusRouter from "./router"
import Menus from "./collections/menus"
import MenusView from "./views/menus_view"

class MenusApp{
  start(data){
    let menus = new Menus(data);
    let view = new MenusView({collection: menus})
    view.render();

    let router = new MenusRouter;
    router.view = view;
    Backbone.history.start();
  }
}

export default MenusApp

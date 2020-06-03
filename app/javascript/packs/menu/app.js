import Menu from "./models/menu"
import MenuView from "./views/menu_view"

class MenuApp{
  start(menu_data){
    let menu = new Menu(menu_data);
    let view = new MenuView({model: menu})
    view.render();
  }
}

export default MenuApp

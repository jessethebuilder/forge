import Menu from "../models/menu"
import Group from "../models/group"
import Groups from "../collections/groups"
import GroupView from "../views/group_view"
import _ from "underscore"

var MenuView = Backbone.View.extend({
  model: Menu,
  el: "#menu",
  template: _.template($("#menu_view_template").html()),
  initialize: function(){
  },
  events: {
    "change .menu_field" : "updateModel",
    "change [name=name]" : "render"
  },
  updateModel: function(event){
    let target = $(event.target);
    let attribute = target.attr("name");
    let value = target.val();
    let new_attributes = {};
    new_attributes[attribute] = value;
    this.model.set(new_attributes);
    this.model.save();
  },
  renderGroups: function(){
    let groups = new Groups(this.model.get("groups"));

    groups.each((group) => {
      let view = new GroupView({model: group});
      this.$el.find("#groups").append(view.render().$el);
    });
  },
  render: function(){
    this.$el.html(this.template(this.model.toJSON()));
    this.renderGroups();
    return this;
  }
});

export default MenuView

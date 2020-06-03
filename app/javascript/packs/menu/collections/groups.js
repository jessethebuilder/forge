import Group from "../models/group"

var Groups = Backbone.Collection.extend({
  model: Group,
  url: "/groups",
});

export default Groups

window.setupActivators = function(selector, model_name, plural_model_name){
  // This is very similar to logic in menus_groups_and_products. DRY!!!!!!!!!
  if(typeof pluralize_model_name === 'undefined'){
    // If no plural name is defined, just assume it is an "s"
    plural_model_name = model_name + "s";
  }

  $(selector).find(".activator").change(function(event){
    // When an .activator changes, get closest element with a data-id attriubte,
    // that id value, and the state of the elment, which is put into a Hash and
    // sent, via Ajax, to the relevant Record's update route.
    let target = $(event.target);
    let row = target.closest("[data-id]");
    let id = row.data("id");
    let is_active = target.is(":checked");
    let data = {};
    data[model_name] = {active: is_active};

    $.ajax({
      method: "PATCH",
      url: `${plural_model_name}/${id}.json`,
      data: data,
      success: function(){
        if(is_active){
          row.addClass("active").removeClass("inactive");
        } else {
          row.addClass("inactive").removeClass("active");
        }
      }
    });
  });
}

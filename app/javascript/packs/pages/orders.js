window.clearInanactiveOrders = function(){
  $('.inactive').each(function(){
    let row = $(this).closest('tr');
    row.hide(250, function(){ row.detach() });
  });
}

function setupOrderActivators(){
  // This is very similar to logic in menus_groups_and_products. DRY!
  $(".activator").change(function(event){
    let target = $(event.target);
    let row = target.closest('tr');
    let id = row.data("id");
    let url = "/orders/" + id + ".json";

    $.ajax({
      method: "PATCH",
      url: url,
      data: {
        order: {
          active: target.is(':checked')
        }
      },
      success: function(){
        row.addClass('inactive')
      }
    });
  });
}

$(document).on('turbolinks:load', function(){
  setupOrderActivators();
})

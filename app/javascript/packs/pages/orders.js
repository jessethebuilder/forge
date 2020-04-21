window.clearInactiveOrders = function(){
  $(".inactive").each(function(){
    let row = $(this).closest("tr");
    row.hide(250, function(){ row.detach() });
  });
}

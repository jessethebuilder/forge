function setupRecordSorter(){
  // When drag-and-drop reording ends, reorder all enclosed groups.
  $(".sortable tbody").sortable({
    axis: "y",
    handle: ".sorter",
    deactivate: function(event) {
      let target = $(event.target);
      let table = target.closest("table");
      let sortable_type = table.data("sortable-type");

      table.find("tbody tr").each(function(i, element){
        let data = {}
        data[sortable_type] = {order: i}
        let id = $(element).data("id")

        let url = "/" + sortable_type + "s/" + id + ".json";
        $.ajax({
          method: "PATCH",
          url: url,
          data: data
        });
      });
    }
  });
}

function setupRecordActivators(){
  // When an active checkbox is clicked, set the Record's active attribute.
  $(".stortable .active").change(function(event){
    let target = $(event.target);
    let table = target.closest("table");
    let sortable_type = table.data("sortable-type");
    let id = target.closest('tr').data("id");
    let url = "/" + sortable_type + "s/" + id + ".json";
    let data = {};
    data[sortable_type] = {active: target.is(':checked')}

    $.ajax({
      method: "PATCH",
      url: url,
      data: data
    });
  });
}

function setupRecordTable(){
  setupRecordSorter();
  setupRecordActivators();
}

$(document).on("turbolinks:load", function(){
  setupRecordTable();
});

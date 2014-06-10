$("#btn_add_position").click(function(){

  var positions = [];

  try {
    positions = $.parseJSON($("#hdd_positions").val());
  } catch (e) {
    if($("#hdd_positions").val()!="")
    {
      console.error("Parsing error:", e);
      return;
    }
  }
  
  positions.push({id:"", title:$("#positions_title").val(),description:$("#positions_description").val()});
  $("#hdd_positions").val(JSON.stringify(positions));


  $("#lbl_position_title").text("<%=t(:title).capitalize%>: " + $("#positions_title").val());
  $("#lbl_position_description").text("<%=t(:description).capitalize%>: " + $("#positions_description").val());
  $element = $("#position_list_item").clone().removeAttr("hidden").removeAttr("id");
  $element.find("#lbl_position_title").removeAttr("id");
  $element.find("#hdd_position_index").val(positions.length -1);
  $element.find("#btn_remove_position").bind("click",function(event){
  
    var positions = [];
    var index;

    try {
      positions = $.parseJSON($("#hdd_positions").val());
      index = parseInt($(event.target).closest(".panel-footer").find("#hdd_position_index").val());

      if(isNaN(index))
        throw new error("index is not a valid integer");
    } catch (e) {
        console.error("Parsing error:", e);
        return;
    }
    
      positions.splice(index, 1);
      $("#hdd_positions").val(JSON.stringify(positions));
    
    
    $(event.target).parents(".panel").remove();
  });

  $("#positions_list").append($element);
  $("#positions_title").val("");
  $("#positions_description").val("");
});
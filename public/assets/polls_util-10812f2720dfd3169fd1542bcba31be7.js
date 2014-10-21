$("#btn_add_option").click(function(){

  var options = [];

  try {
    options = $.parseJSON($("#hdd_options").val());
  } catch (e) {
    if($("#hdd_options").val()!="")
    {
      console.error("Parsing error:", e);
      return;
    }
  }
  
  options.push($("#txt_option").val());
  $("#hdd_options").val(JSON.stringify(options));

  $("#lbl_options_list_item").text($("#txt_option").val());
  $element = $("#options_list_item").clone().removeAttr("id");
  $element.find("#lbl_options_list_item").removeAttr("id");
  $element.find("#hdd_option_index").val(options.length -1);
  $element.find("#btn_remove_option").bind("click",function(event){

    var options = [];
    var index;

    try {
      options = $.parseJSON($("#hdd_options").val());
      index = parseInt($(event.target).closest(".list-group-item").find("#hdd_option_index").val());

      if(isNaN(index))
        throw new error("index is not a valid integer");
    } catch (e) {
        console.error("Parsing error:", e);
        return;
    }
      options.splice(index, 1);
      $("#hdd_options").val(JSON.stringify(options));
    
    
    $(event.target).parents(".list-group-item").remove();

    $(".hdd_option_index").each(function(){
        aux_index = parseInt($(this).val());
          if(aux_index > index)
          $(this).val(aux_index-1);
        });
  });

  $("#options_list").append($element);
  $("#txt_option").val("");
});

$(".btn_remove_option").click(function(event){

    var options = [];
    var index;

    try {
      options = $.parseJSON($("#hdd_options").val());
      index = parseInt($(event.target).closest(".list-group-item").find("#hdd_option_index").val());
      if(isNaN(index))
        throw new error("index is not a valid integer");
    } catch (e) {
        console.error("Parsing error:", e);
        return;
    }
    
    options.splice(index, 1);
    $("#hdd_options").val(JSON.stringify(options));
    
    $(event.target).parents(".list-group-item").remove();
   
    $(".hdd_option_index").each(function(){
        aux_index = parseInt($(this).val());
          if(aux_index > index)
          $(this).val(aux_index-1);
        });

  });

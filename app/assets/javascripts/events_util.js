  $(document).ready(function(){
    var preview = $(".title_photoheader");
    var uploadImage = $('.upload-preview img')

    $("#event_picture").change(function(event){
      var input = $(event.currentTarget);
      var file = input[0].files[0];
      var reader = new FileReader();

      reader.onload = function(e){
         image_base64 = e.target.result;
         preview.css("background-image", 'url("' + image_base64 + '")');
         
         uploadImage.attr("src", image_base64);
         uploadImage.attr("class", "event_image");
      };
      reader.readAsDataURL(file);
    });
  });

  $("#btn_add_volunteer").click(function(){

  var volunteers = [];

  try {
    volunteers = $.parseJSON($("#hdd_volunteers").val());
  } catch (e) {
    if($("#hdd_volunteers").val()!="")
    {
      console.error("Parsing error:", e);
      return;
    }
  }
  
  var volunteer = null;
  volunteer = {position_title: $("#txt_volunteer_position").val(), description: $("#txt_volunteer_description").val()};

  volunteers.push(volunteer);
  $("#hdd_volunteers").val(JSON.stringify(volunteers));

  $("#lbl_volunteers_position").text($("#txt_volunteer_position").val());
  $("#lbl_volunteers_description").text($("#txt_volunteer_description").val());
  $element = $("#volunteers_list_item").clone().removeAttr("id");
  $element.find("#lbl_volunteers_position").removeAttr("id");
  $element.find("#lbl_volunteers_description").removeAttr("id");
  $element.find("#hdd_volunteer_index").val(volunteers.length -1);
  $element.find("#btn_remove_volunteer").bind("click",function(event){

    var volunteers = [];
    var index;

    try {
      volunteers = $.parseJSON($("#hdd_volunteers").val());
      index = parseInt($(event.target).closest(".list-group-item").find("#hdd_volunteer_index").val());

      if(isNaN(index))
        throw new error("index is not a valid integer");
    } catch (e) {
        console.error("Parsing error:", e);
        return;
    }
      volunteers.splice(index, 1);
      $("#hdd_volunteers").val(JSON.stringify(volunteers));
    
    
    $(event.target).parents(".list-group-item").remove();

    $(".hdd_volunteer_index").each(function(){
        aux_index = parseInt($(this).val());
          if(aux_index > index)
          $(this).val(aux_index-1);
        });
  });

  $("#volunteers_list").append($element);
  $("#txt_volunteer_position").val("");
  $("#txt_volunteer_description").val("");
});

$(".btn_remove_volunteer").click(function(event){

    var volunteers = [];
    var index;

    try {
      volunteers = $.parseJSON($("#hdd_volunteers").val());
      index = parseInt($(event.target).closest(".list-group-item").find("#hdd_volunteer_index").val());
      if(isNaN(index))
        throw new error("index is not a valid integer");
    } catch (e) {
        console.error("Parsing error:", e);
        return;
    }
    
    volunteers.splice(index, 1);
    $("#hdd_volunteers").val(JSON.stringify(volunteers));
    
    $(event.target).parents(".list-group-item").remove();
   
    $(".hdd_volunteer_index").each(function(){
        aux_index = parseInt($(this).val());
          if(aux_index > index)
          $(this).val(aux_index-1);
        });

  });


$(document).ready(function(){
    var preview = $(".upload-preview img");

    $("#candidate_photos").change(function(event){
       var input = $(event.currentTarget);
       var file = input[0].files[0];
       var reader = new FileReader();
       reader.onload = function(e){
           image_base64 = e.target.result;
           preview.attr("src", image_base64);
           preview.attr("class", "photo_image");
       };
       reader.readAsDataURL(file);
    });
    $("#slPositions").change(function(){
      var selected_position=$(this).val();
      if(selected_position == '0')
        $('#hdd_position_id').val('');
      else
        $('#hdd_position_id').val(selected_position);
    });
  });
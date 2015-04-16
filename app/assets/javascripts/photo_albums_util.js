$(document).ready(function(){
    var preview1 = $(".upload-preview1 img");
    var preview2 = $(".upload-preview2 img");

    $("#photo_album_thumbnail").change(function(event){
       var input = $(event.currentTarget);
       var file = input[0].files[0];
       var reader = new FileReader();
       reader.onload = function(e){
           image_base64 = e.target.result;
           preview1.attr("src", image_base64);
           preview1.attr("class", "photo_album_thumbnail");
       };
       reader.readAsDataURL(file);
    });
    $("#photo_album_picture").change(function(event){
       var input = $(event.currentTarget);
       var file = input[0].files[0];
       var reader = new FileReader();
       reader.onload = function(e){
           image_base64 = e.target.result;
           preview2.attr("src", image_base64);
           preview2.attr("class", "photo_album_image");
       };
       reader.readAsDataURL(file);
    });
  });
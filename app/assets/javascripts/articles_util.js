  $(document).ready(function(){
    var preview = $(".upload-preview img");

    $("#article_picture").change(function(event){
       var input = $(event.currentTarget);
       var file = input[0].files[0];
       var reader = new FileReader();
       reader.onload = function(e){
           image_base64 = e.target.result;
           preview.attr("src", image_base64);
           preview.attr("class", "article_image");
       };
       reader.readAsDataURL(file);
    });
    //$('.delete_question_control').unbind('click');
    //$('.cancel_delete_control').unbind('click');
    $('.delete_question_control').click(function(e){
      $(this).parent().parent().find('.delete_confirmation_form').toggleClass('show');
      e.preventDefault();
      });
    $('.cancel_delete_control').click(function(e){
      $(this).parent().removeClass('show');
      e.preventDefault();
    });
  });
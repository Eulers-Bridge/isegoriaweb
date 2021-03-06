  $(document).ready(function(){
    // var preview = $(".upload-preview img");
    var preview = $(".title_photoheader");
    var uploadImage = $('.upload-preview img')

    $("#article_picture").change(function(event){
       var input = $(event.currentTarget);
       var file = input[0].files[0];
       var reader = new FileReader();
       reader.onload = function(e){
          image_base64 = e.target.result;
          preview.css("background-image", 'url("' + image_base64 + '")');
          
          uploadImage.attr("src", image_base64);
          uploadImage.attr("class", "article_image");
       };
       reader.readAsDataURL(file);
    });

    $('.body').keyup(function(event){
      var bodyInput = $(event.currentTarget);
      var currentVal = bodyInput.val();
      var words = currentVal.split(' ').length;
      $('.body-wc').text(words);
    })
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
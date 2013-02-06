$(document).ready(function(){

  $.ajax({ // Amazon
      type: 'PUT',
      dataType: "json",
      success: function(data, textStatus, jqXHR){
        console.log(data);
      }
    });
  
});
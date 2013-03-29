$(document).ready(function(){

  var schoolSlug = $('h2.school-name').attr('data-slug')
  $.cookie('school',schoolSlug);

  $('#try-button').on({
    click: function(){
      $.cookie('try',true) 
    }
  });

});

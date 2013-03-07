$(document).ready(function(){
  $('#try-button').on({
    click: function(){
      $.cookie('try',true, { expires: 1 }) 
    }
  });
})

// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # Schools

$(document).ready(function(){

  // $('.school-row').hover(function(){
  //  var color = $(this).attr('data-secondary-color');
  //  $(this).css('color',color);
  // },
  // function(){
  //  var color = $(this).attr('data-primary-color');
  //  $(this).css('color',color);
  // });

  var recursiveFade = function(elementArray,fadeSpeed,delay,callback){
    fadeSpeed = fadeSpeed || 500;
    delay = delay || 0;
    callback = callback || $.noop;
    var fadeMeIn = function(i){
      i = i || 0
      $(elementArray[i]).fadeIn(fadeSpeed,function(){
        if( i < (elementArray.length - 1) ){ 
          setTimeout(function(){
            fadeMeIn(i + 1); 
          },delay);
        } else {
          setTimeout(function(){
            callback(); 
          },delay);
        }
      });
    };
    fadeMeIn();
  };


  if( $.cookie('try') ){
    $('#paper-box-index,#tell-me-more,#schools-index-box').show()
  } else {
    $('#paper-box-index').fadeIn(1000,function(){
      $('#teach-me,#readyStart').fadeIn(500);
      recursiveFade($('.demo-column'),500,700,function(){
        $('#curiousDemo,#skepticalAbout').fadeIn(500);
      });
      $('#try-button').on({
        click: function(){
          // Tranistion in the go-time
          $('#teach-me,.actions-div').fadeOut(function(){
            $('#schools-index-box').fadeIn();
          });
        }
      });
    });
  }

  $('h1.logo').arctext({ radius: 2000 });
});
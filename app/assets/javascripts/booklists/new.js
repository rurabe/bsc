// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//


$(document).ready(function(){
  // [----------------------------------------===== #NEW =====----------------------------------------]
  
  // [----------=====About Tab=====----------]

    $('#about-handle').on({
      click: function(){
        if(!this.isOpen){
          $('.logo-inner').animate({'margin-top': '-350px'});
          $('.about-info').slideToggle();
          $(this).fadeOut(200,function(){
            $(this).text("OK, I got it!").fadeIn();
            $('#about-handle').parent().append(
              "<a href='/about'><button class='btn btn-danger faq-button'>Tell me more</button></a>"
            ).hide().fadeIn(500);
          });

          // Do it on load
          resizeExplanationDivs();
          // And do it each time the window resizes
          $(window).resize(resizeExplanationDivs);
          this.isOpen = true
        } else {
          $('.logo-inner').animate({'margin-top': '-250px'});
          $('.about-info').slideToggle();
          $('.faq-button').fadeOut(200,function(){$(this).remove()});
          $(this).fadeOut(200,function(){
            $(this).text("Wait, what's this about again?").fadeIn();
            $('#aboutlink').remove();
          });
          this.isOpen = false
        }
      }
    });

  // [----------=====Loading Modal=====----------]

    $('#loadingModal').modal({
      backdrop: 'static',
      keyboard: false,
      show: false
    });

    $('#login-button').click(function(){
      $('#icon-carousel').carousel({
        interval: 2500,
        pause: "false"
      }).carousel('cycle');
      $('#loadingModal').modal('show');
    });

  // [----------=====Keep the divs the same size =====----------]

    var resizeExplanationDivs = function(){
      $('p.about-explanation').map(function(){$(this).removeAttr("style")});
      var sizes = $('p.about-explanation').map(function(){ return $(this).height() }).get();
      var maxSize = Math.max.apply(null,sizes);
      $('p.about-explanation').map(function(){$(this).height(maxSize)});
    };

  // [----------=====     INIT      =====----------] 

    $('#paper-box').fadeIn(1500);
  
});
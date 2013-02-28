$(document).ready(function(){
  // [----------------------------------------===== #NEW =====----------------------------------------]
  
  

    $('#paper-box').hide().fadeIn(1000,function(){
      $('.teach-me').fadeIn(500)
    });

    $('#try').on({
      click: function(){
        $('.teach-me').fadeOut(function(){
          $('.go-time').fadeIn();
        })
      }
    })

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

  
});
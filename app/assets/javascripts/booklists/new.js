$(document).ready(function(){
  // [----------------------------------------===== #NEW =====----------------------------------------]

    var recursiveFade = function(elementArray,fadeSpeed,delay){
      fadeSpeed = fadeSpeed || 500;
      delay = delay || 0
      var fadeMeIn = function(i){
        i = i || 0
        $(elementArray[i]).fadeIn(fadeSpeed,function(){
          if( i < (elementArray.length - 1) ){ 
            setTimeout(function(){
              fadeMeIn(i + 1); 
            },delay);
          }
        });
      };
      fadeMeIn();
    };
    // so first the paper comes in
    $('#paper-box').fadeIn(1000,function(){
      // then the demo box and button fade in
      $('#teach-me').fadeIn(500);
            $('#tell-me-more').fadeIn(500);
      recursiveFade($('.demo-column'),500,500);

    });

    $('#try').on({
      click: function(){
        $('#teach-me').fadeOut(function(){
          $('#go-time').fadeIn();
        })
      }
    })
        $('h1.logo').arctext({ radius: 2000 });

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
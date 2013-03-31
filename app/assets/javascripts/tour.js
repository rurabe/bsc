$(document).ready(function(){
  var tourCreator = function(){
    return {
      setBackground: function(){
        $('body').append('<div id="tourScreen" class="tour-background"></div>')
        $('#tourScreen').animate({opacity: 0.8},200)
      },
      removeBackground: function(){
        $('#tourScreen').fadeOut(200,function(){
          $(this).remove();
        });
        this.unlockBackground();
      },
      lockBackground: function(){
        $('body').css({overflow: 'hidden'});
      },
      unlockBackground: function(){
        $('body').css({overflow: ''});
      },
      start: function(){
        if( !$('#tourScreen')[1] ){ this.setBackground(); }
        var tour = this
        var stepOne = {
          $el: $('.price-used .book-button-outer').first(),
          call: function(){
            $('html,body').animate({ scrollTop: 0 },200)
            tour.lockBackground();
            this.arrow = $('#tourOne .tour-arrow').clone().appendTo('#tourScreen').show().hide();
            var arrow1CSS = this.$el.offset()
            arrow1CSS.top -= 155;
            arrow1CSS.left -= 50;
            this.arrow.offset( arrow1CSS ).fadeIn();

            this.description = $('#tourOne .tour-description').clone().appendTo('#tourScreen').hide();
            var desc1CSS = arrow1CSS;
            desc1CSS.left -= 100;
            desc1CSS.top -= 30;
            this.description.offset(desc1CSS).fadeIn();

            this.$el.css({'z-index': 20})

            this.next = $('<a href="#" class="tour-next"><span>Next &gt;&gt;</span></a>').appendTo('#tourScreen').hide();
            var nextCSS = {
              left: this.description.offset().left + this.description.width() - this.next.width(),
              top: this.description.offset().top + this.description.height() + 10
            }

            this.next.offset( nextCSS ).fadeIn().one({
              click: function(){
                stepOne.cleanup();
                stepTwo.call()
              }
            })
          },
          cleanup: function(){
            this.arrow.remove();
            this.description.remove();
            this.next.remove();
            this.$el.css({'z-index': ""});
          }
        };
        

        // Step 2

        var stepTwo = {
          $el: $('#checkout-button'),
          call: function(){
            var step = this

            tour.unlockBackground();

            $('html,body').animate({
              scrollTop: ($('#checkout-button').offset().top )
            },{
              duration: 200,
              complete: function(){

                tour.lockBackground();

                step.arrow = $('#tourTwo .tour-arrow').clone().appendTo('#tourScreen').hide();
                var arrow2CSS = step.$el.offset()
                arrow2CSS.top -= 25;
                arrow2CSS.left -= 150;
                step.arrow.offset( arrow2CSS ).fadeIn();


                step.description = $('#tourTwo .tour-description').clone().appendTo('#tourScreen').hide();
                var desc2CSS = arrow2CSS
                desc2CSS.top += 10;
                desc2CSS.left -= 300;
                step.description.offset(desc2CSS).fadeIn();


                step.$el.css({'z-index': 20});

                step.next = $('<a href="#" class="tour-next"><span>Get started!</span></a>').appendTo('#tourScreen').hide();
                var next2CSS = desc2CSS
                next2CSS.left += (step.description.width() - step.next.width());
                next2CSS.top += 10 + step.description.height();
                step.next.offset( next2CSS ).fadeIn().one({
                  click: function(){
                    stepTwo.cleanup();
                    tour.end();
                  }
                })

                setTimeout(function(){
                  stepTwo.cleanup();
                  tour.end();
                },10000)

              }
            });
          },
          cleanup: function(){
            this.arrow.remove();
            this.description.remove();
            this.$el.css({'z-index': ""});
          }
        }


        setTimeout(function(){
          stepOne.call();
        },500)
      
      },
      end: function(){
        this.removeBackground();
        $('html,body').animate({ scrollTop: 0 },200)
      }
    }
  }
  bscTour = tourCreator();
});

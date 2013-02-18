var createOffersHandle = function(offerGroup){
  var $el = offerGroup.$el.find('.book-button-handle');
  var $wrapper = $el.find('.handle-content');
  var $wireline = $el.siblings('.wireline')

  var arrows = function(direction){
    return '<i class="icon-double-angle-' + direction + '"></i>'
  };

  var labelChanger = function(off,on){
    $el.off('mouseenter').off('mouseleave')
    $el.on({
      mouseenter: function(e){
        if(!this.isOn){
          changeContent(on);
          $(this).animate({
            'width': '65%',
            'color': 'white',
            'background-color': 'black'
          },100);
          this.isOn = true
        }
      },
      mouseleave: function(e){
        changeContent(off)
        $(this).animate({
          'width': '50%',
          'color': 'black',
          'background-color': 'white'
        },100);
        this.isOn = false
      }
    });
  };

  var setClickOpener = function(){
    $el.on({
      click: open
    });
  };

  var isOpen
  var open = function(time){
    time = time || 500
    var height = offerGroup.offersBox.open() + $el.outerHeight();
    $wireline.animate({'height': height},time);
    labelChanger(arrows('up'),'hide');
    $el.off('click')
    $el.on({
      click: close
    });
    isOpen = true;
  };

  var close = function(time){
    if(isOpen){
      time = time || 500
      offerGroup.offersBox.close()
      $wireline.animate({'height': '0px'},time);
      labelChanger(arrows('down'),"more options");
      $el.off('click')
      $el.on({
        click: open
      });
    }
    isOpen = false;
  };

  returnObject = {
    $el: $el,
    offerGroup: offerGroup,
    open: open,
    close: close
  };

  var changeContent = function(content){
    $wrapper.fadeOut(50,function(){
      $wrapper.empty().append('<span class="handle-content">' + content + '</span>').fadeIn(50);
    });
  };

  labelChanger(arrows('down'),"more options");
  setClickOpener();


  return returnObject;
};
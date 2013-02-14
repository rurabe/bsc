var createOffersHandle = function(offerGroup){
  var $el = offerGroup.$el.find('.book-button-handle');
  var wrapper = $el.find('.book-button-handle-inner')
  var arrows = '<i class="icon-double-angle-down"></i>'

  var changeContent = function(content,callbackOut,callbackIn){
    callbackIn = callbackIn || $.noop;
    callbackOut = callbackOut || $.noop;
    wrapper.fadeOut(50,function(){
      callbackIn.call();
      wrapper.html(content).fadeIn(50,function(){
        callbackOut.call();
      });
    });
  };

  var setLabelChanger = function(){
    $el.mouseenter(function(){
      changeContent("more options",function(){
        $el.mouseleave(function(){
          changeContent(arrows);
          $el.animate({'width': '50%',
                       'color': 'black',
                       'background-color': 'white'},100);
        });
      });
      $el.animate({'width': '70%',
                   'color': 'white',
                   'background-color': 'black'},100);
    });
  };



  returnObject = {
    $el: $el
  };

  setLabelChanger();

  return returnObject;
};
var createOfferRow = function(offer,offersBox){
  var $box = offersBox.$el
  var $el
  var offerGroup = offer.offerGroup

  var create = function(){
    this.$el = $el = addDomElement();
    offer.setOfferRow(returnObject);
    if(offer.status === "Available"){
      setMouseOverHandler();
      setClickHandler();
    }
    if( offer.isSelected() ){
      $el.addClass('selected')
    }
  };

  var select = function(){
    $el.removeClass('deselected').addClass('selected')
  }

  var deselect = function(){
    $el.removeClass('selected').addClass('deselected');
  };

  var addDomElement = function(){
    return $box.append(offer.offerHtml()).children().last();
  }

  var setMouseOverHandler = function(){
    $el.on({
      mouseenter: function(e){
        $(this).addClass("active");
      },
      mouseleave: function(e){
        $(this).removeClass("active").addClass('inactive');
      },
    });
  };

  var setClickHandler = function(){
    $el.on({
      click: function(e){
        e.stopPropagation();
        if( !$(e.target).hasClass('link-safe') ){
          offer.select();
        }
      }
    });
  };

  returnObject = {
    $el: $el,
    offer: offer,
    offersBox: offersBox,
    create: create,
    select: select,
    deselect: deselect
  }

  returnObject.create();
  return returnObject
};
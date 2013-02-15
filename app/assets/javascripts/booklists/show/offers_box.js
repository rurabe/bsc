var createOffersBox = function(offerGroup){
  var $el = undefined;
  var $bookRow = offerGroup.book.$el.find('.book-row-inner');
  

  var offerRow = '<div class="offer-row <%= offer.vendorCode %>"><%= offer.priceHtml() %></div>';


  var open = function(){
    this.$el = $el = formDomElement();
    appendOffers();
    var height = $el.outerHeight() + parseInt( $el.css('margin-top') );
    $el.slideDown();
    return height;
  };

  var close = function(){
    $el.slideUp(function(){
      $(this).remove()
    })
  };

  returnObject = {
    $el: $el,
    open: open,
    close: close
  };


  var formDomElement = function(){
    var css = { 'margin-right': margin() }
    return $('<div class="offer-box"></div>').appendTo($bookRow).hide().css(css)
  }

  var margin = function(){
    var cell = offerGroup.$el
    var row = offerGroup.book.$el
    var x = cell.offset().left - row.offset().left
    var cellWidth = cell.outerWidth()
    var rowWidth = row.innerWidth()
    var margin = 15
    return rowWidth - (x + cellWidth/2) + margin + "px"
  }

  var appendOffers = function(){
    _.each(offerGroup.sortedOffers(),function(offer){
      $el.append(_.template(offerRow,{offer: offer}));
    });
  }


  return returnObject;
};
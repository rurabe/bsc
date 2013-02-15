var createOfferGroup = function(book,category){
  var $el = book.$el.find('.price-'+category)
  var $contentContainer = $el.find('.book-button-inner')
  var offers = [];


  var bestOffer = function(){
    var valid = validOffers();
    var found = foundOffers();
    if( valid.length > 0 ){
      return _.min(valid,function(offer){
        return parseFloat(offer.price);
      });
    } else if( found.length > 0 ){
      return _.find(found,function(offer){
        return offer.status != "Not found"
      });
    } else {
      offers[0]
    }
  };

  var otherOffers = function(){
    return _.difference(offers,bestOffer());
  };

  var sortedOffers = function(){
    valid = validOffers();
    invalid = _.difference(offers,valid)

    var result = _.map([valid,invalid],function(collection){
      return _.sortBy(collection,function(offer){
        return offer.price || offer.status;
      });
    });

    return _.flatten(result)
  }

  // Public methods
  var addOffer = function(json){
    offers.push( createOffer(this,json) );
    displayOffer();
  }

  var displayOffer = function(){
    var best = this.bestOffer = bestOffer() || {priceHtml: function(){return "Not Found"}}
    changeContent('<span class="price-content">'+ best.priceHtml() +'</span>',function(){
      if(best.status === "Available"){ $contentContainer.addClass(best.vendorCode) }
    });
    
  }

  var returnObject = {
    $el: $el,
    book: book,
    category: category,
    offers: offers,
    addOffer: addOffer,
    displayOffer: displayOffer,
    otherOffers: otherOffers,
    sortedOffers: sortedOffers
  };

  var changeContent = function(content,funcOut,funcIn){
    funcOut = funcOut || $.noop
    funcIn = funcIn || $.noop
    $contentContainer.fadeOut(function(){
      funcOut.call();
      $contentContainer.html(content).fadeIn(function(){
        funcIn.call();
      });
    });
  };

  var validOffers = function(){
    return _.filter(offers,function(offer){
      return parseFloat(offer.price)
    });
  };

  var foundOffers = function(){
    return _.filter(offers,function(offer){
      return offer.status != "Not found"
    });
  }

  var offersBox = createOffersBox(returnObject);
  _.extend(returnObject,{offersBox: offersBox})
  var offersHandle = createOffersHandle(returnObject);
  _.extend(returnObject,{offersHandle: offersHandle})
  
  return returnObject;
}
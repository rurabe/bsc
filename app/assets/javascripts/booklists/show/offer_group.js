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

  // Public methods
  var addOffer = function(json){
    offers.push( createOffer(this,json) );
  }

  var displayOffer = function(){
    changeContent('<span>'+ bestOffer().priceHtml() +'</span>');
  }

  var returnObject = {
    $el: $el,
    book: book,
    category: category,
    offers: offers,
    addOffer: addOffer,
    displayOffer: displayOffer,
    otherOffers: otherOffers
  };

  var changeContent = function(content){
    $contentContainer.fadeOut(function(){
      $contentContainer.html(content).fadeIn();
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

  var offersHandle = createOffersHandle(returnObject);

  _.extend(returnObject,{offersHandle: offersHandle})

  return returnObject;
}
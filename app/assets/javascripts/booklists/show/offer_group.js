var createOfferGroup = function(book,category){
  var $el = book.$el.find('.price-'+category)
  var $contentContainer = $el.find('.book-button-inner')
  var offers = [];
  var displayOffer

  var selected = false;
  var select = function(offer){
    $el.addClass('selected');
    book.reportSelected(this);
    selected = true;
  };

  var deselect = function(){
    $el.removeClass('selected').addClass('deselected');
    if(selectedOffer()){ selectedOffer().deselect(); }
    selected = false;
  };

  var isSelected = function(){
    return selected;
  };

  var reportSelected = function(offer){
    deselectSiblingOffers(offer);
    returnObject.select();
    offersHandle.close();
    updateDiv();
  };

  var selectedOffer = function(){
    return _.find(offers,function(offer){
      return offer.isSelected();
    });
  };

  var bestOffer = function(){
    return sortedOffers('valid')[0];
  };

  var sortedOffers = function(subset){
    var queue = []
    if( !subset || subset === "valid" ){ queue.push(validOffers()); }
    if( !subset || subset === "invalid" ){ queue.push(_.difference(offers,validOffers())); }

    var result = _.map(queue,function(collection){
      return _.sortBy(collection,function(offer){
        return parseFloat(offer.price) || offer.status;
      });
    });
    return _.flatten(result)
  }

  var validOffers = function(){
    return _.filter(offers,function(offer){
      return parseFloat(offer.price)
    });
  };

  var foundOffers = function(){
    return _.filter(offers,function(offer){
      return offer.status != "Not found";
    });
  };

  var defaultOffer = function(){
    return bestOffer() || offers[0] || { priceHtml: function(){return "Not found"} }
  };

  var addOffer = function(json){
    offers.push( createOffer(this,json) );
    updateDiv();
  };

  var updateDiv = function(funcIn,funcOut){
    funcOut = funcOut || $.noop;
    funcIn = funcIn || $.noop;

    var newDisplayOffer = selectedOffer() || bestOffer() || defaultOffer();

    if(displayOffer != newDisplayOffer){
      displayOffer = newDisplayOffer;
      changeContent('<span class="price-content">'+ newDisplayOffer.priceHtml() +'</span>',function(){
        if(newDisplayOffer.status === "Available"){ 
          updateClasses(newDisplayOffer); 
          makeSelectable();
        }
        funcIn.call();
      },funcOut); 
    }
  };

  // For adding vendor styling to book buttons
  var updateClasses = function(offer){
    $contentContainer.removeClass();
    $contentContainer.addClass('book-button-inner ' + offer.vendorCode);
  };

  var makeSelectable = function(){
    $el.addClass('selectable');
    setClickHandler();
  };

  var changeContent = function(content,funcOut,funcIn){
    funcOut = funcOut || $.noop
    funcIn = funcIn || $.noop
    $contentContainer.fadeOut(200,function(){
      funcOut.call();
      $contentContainer.html(content).fadeIn(200,function(){
        funcIn.call();
      });
    });
  };

  var deselectSiblingOffers = function(offer){
    var siblings = _.difference(offers,offer)
    _.each(siblings,function(offer){ offer.deselect(); })
  }

  var toggleSelect = function(){
    if(selected){
      returnObject.deselect();
    } else {
      displayOffer.select();
    }
  };

  var setClickHandler = function(){
    $contentContainer.on({
      click: function(e){
        toggleSelect();
      }
    });
  };


  var returnObject = {
    $el: $el,
    book: book,
    category: category,
    offers: offers,
    addOffer: addOffer,
    updateDiv: updateDiv,
    sortedOffers: sortedOffers,
    validOffers: validOffers,
    foundOffers: foundOffers,
    selectedOffer: selectedOffer,
    select: select,
    deselect: deselect,
    isSelected: isSelected,
    reportSelected: reportSelected
  };

  var offersBox = createOffersBox(returnObject);
  _.extend(returnObject,{offersBox: offersBox})
  var offersHandle = createOffersHandle(returnObject);
  _.extend(returnObject,{offersHandle: offersHandle})
  
  return returnObject;
}
var createBook = function(el){
  var $el = $(el);
  var ean = $el.attr('data-ean');
  var offerGroups = [];

  // Public methods
  var addOffers = function(offers){
    if( !_.isArray(offers) ){ offers = [offers] }
    var book = this
    _.each(offers,function(offer){
      var offerGroup = _.find(book.offerGroups,function(group){ 
        return group.category === offer.condition;
      });
      offerGroup.addOffer(offer);
    });
  };

  var reportSelected = function(offerGroup){
    var siblings = _.difference(offerGroups,offerGroup)
    _.each(siblings,function(offerGroup){ offerGroup.deselect(); });
  }

  // Public attributes
  var returnObject = {
    el: el,
    $el: $el,
    ean: ean,
    offerGroups: offerGroups,
    addOffers: addOffers,
    reportSelected: reportSelected
  }

  // Private methods
  var createOfferGroups = function(book){
    _.each(['new','used'],function(category,index){
      offerGroups.push( createOfferGroup(book,category) );
    });
  };

  // Control
  createOfferGroups(returnObject);

  return returnObject;
};

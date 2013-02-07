$(document).ready(function(){
  var offerGroupCategories = ['new','used']

  $.ajax({
      type: 'PUT',
      dataType: "json",
      success: function(data, textStatus, jqXHR){
        booklist.importData(data);
        booklist.displayAllOffers();
      }
    });

  booklist = {
    books: [],
    find: function(ean){
      return _.find(this.books,function(book){
        return book.ean === ean
      });
    },
    importData: function(data){
      var booklist = this;
      _.each(data,function(bookOffers){
        var book = booklist.find(bookOffers.ean);
        book.addOffers(bookOffers.offers_attributes);
      })
    },
    displayAllOffers: function(){
      _.each(this.books,function(book){
        book.displayOffers();
      });
    }
  }

  // Book contructor //
  var createBook = function(tr){
    var ean = $(tr).attr('data-ean')
    // A place to hold offerGroups
    var offerGroups = [];


    // Create offerGroups for each newly minted book obj
    _.each(offerGroupCategories,function(category,index){
      offerGroups.push(createOfferGroup(tr,category))
    })


    return{
      tr: tr,
      ean: ean,
      offerGroups: offerGroups,
      addOffers: function(offers){
        var book = this;
        _.each(offers,function(offer,index){
          var offerGroup = _.find(book.offerGroups,function(group){ 
            return group.category === offer.condition 
          });
          offerGroup.offers.push(createOffer(offer));
        });
      },
      displayOffers: function(){
        _.each(this.offerGroups,function(group){
          group.displayOffer();
        });
      }
    }
  };

  // Offer group constructor //
  var createOfferGroup = function(tr,category){
    var td = $(tr).children('.offer-' + category);
    var offers = [];
    var status = undefined;

    var bestOffer = function(){
      var allOffers = validOffers();
      if(allOffers.length === 0){
        return null;
      } else {
        return _.min(allOffers,function(offer){
          return parseInt(offer.price);
        });
      }
    };

    var validOffers = function(){
      return _.filter(offers,function(offer){
        return parseInt(offer.price)
      });
    };

    var foundOffers = function(){
      return _.filter(offers,function(offer){
        return offer.vendorBookId
      });
    };

    var validateStatus = function(){
      if( _.isEmpty(foundOffers()) ){
        return "Not found"
      } else if( _.isEmpty(validOffers()) ){
        return "Sold out"
      } else {
        return "Available"
      }
    };

    var changeContent = function(content){
      var wrapper = $(td).children('span.offer-price');
      wrapper.fadeOut(function(){
        wrapper.html(content).fadeIn();
      });
    };

    return {
      td: td,
      category: category,
      status: status,
      offers: offers,
      addOffer: function(json){
        offers.push(createOffer(json));
      },
      displayOffer: function(){
        this.status = validateStatus();
        var offer = bestOffer();
        if(offer){
          changeContent(offer.toHTML());
        } else {
          changeContent(this.status);
        }
      }
    }
  };
  
  // Offer constructor //
  var createOffer = function(json){

    return {
      availability:       json.availability,
      comments:           json.comments,
      condition:          json.condition,
      detailedCondition:  json.detailed_condition,
      price:              json.price,
      shippingTime:       json.shipping_time,
      vendor:             json.vendor,
      vendorBookId:       json.vendor_book_id,
      vendorOfferId:      json.vendor_offer_id,
      toHTML: function(){
        return "$" + parseFloat(this.price,10).toFixed(2);
      }
     }
  };

  $('.book-row').each(function(){
    booklist.books.push(createBook(this));
  });




});
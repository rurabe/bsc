$(document).ready(function(){
  var offerGroupCategories = ['new','used']

  // $.ajax({
  //     type: 'PUT',
  //     dataType: "json",
  //     success: function(data, textStatus, jqXHR){
  //       booklist.importData(data);
  //       booklist.displayAllOffers();
  //     }
  //   });

  booklist = {
    books: [],
    menus: [],
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
    },
    newMenu: function(offerGroup){
      var menu = createOffersMenu(offerGroup)
      this.menus.push(menu);
      return menu
    },
  }

  // Book contructor //
  var createBook = function(tr){
    var ean = $(tr).attr('data-ean')
    // A place to hold offerGroups
    var offerGroups = [];


    // Create offerGroups for each newly minted book obj
    _.each(['new','used'],function(category,index){
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
    var $handle = $(tr).next('tr').find('.handle-' + category)
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
        return parseFloat(offer.price)
      });
    };

    var validateStatus = function(){
      if( checkOfferStatus("Available") ){
        return "Available"
      } else if( checkOfferStatus("Sold out") ){
        return "Sold out"
      } else {
        return "Not found"
      }
    };

    var checkOfferStatus = function(status){
      return !_.isEmpty(
        _.filter(offers,function(offer){
          return offer.status === status
        })
      );
    };

    var changeCellContent = function(content){
      var wrapper = $(td).children('div.offer-div')
      var contentContainer = wrapper.children('div.offer-div-inner');
      wrapper.fadeOut(function(){
        contentContainer.remove()
        $(wrapper).prepend(content).fadeIn();
      });
    };




    var returnObject = {
      td: td,
      handle: $handle,
      category: category,
      status: status,
      offers: offers,
      selectedOffer: {},
      bestOffer: function(){
        return bestOffer();
      },
      addOffer: function(json){
        offers.push(createOffer(json));
      },
      displayOffer: function(){
        this.status = validateStatus();
        this.selectedOffer = bestOffer();
        if(this.selectedOffer){
          changeCellContent(this.selectedOffer.toPriceHTML());
        } else {
          changeCellContent('<div class="offer-div-inner">' + this.status + '</div>');
        }
      },
      otherOffers: function(){
        return _.difference(offers,this.selectedOffer)
      }
    }

    var menu = booklist.newMenu(returnObject);
    
    return returnObject
  };
  
  // Offer constructor //
  var createOffer = function(json){

    var determineStatus = function(){
      if(!vendorBookId){
        return "Not found"
      } else if(!price){
        return "Sold out"
      } else {
        return "Available" }
    };

    var availability =      json.availability;
    var comments =          json.comments;
    var condition =         json.condition;
    var detailedCondition = json.detailed_condition;
    var price =             json.price;
    var shippingTime =      json.shipping_time;
    var vendor =            json.vendor;
    var vendorBookId =      json.vendor_book_id;
    var vendorOfferId =     json.vendor_offer_id;
    var status =            determineStatus();

    var formattedPrice = function(){
      return "$" + parseFloat(price,10).toFixed(2);
    }

    var vendorCode = function(){
      codes = {
        'Amazon': 'amazon',
        'Barnes and Noble': 'bn',
        'Bookstore': 'bookstore'
      }
      return codes[vendor]
    }

    return {
      status:             status,
      availability:       availability,
      comments:           comments,
      condition:          condition,
      detailedCondition:  detailedCondition,
      price:              price,
      shippingTime:       shippingTime,
      vendor:             vendor,
      vendorBookId:       vendorBookId,
      vendorOfferId:      vendorOfferId,
      toPriceHTML: function(){
        if(status === "Available"){
          return '<div class="offer-div-inner '+vendorCode()+'">'+ formattedPrice(); + "</div>"
        } else {
          return '<div class="offer-div-inner">'+ status; +'</div>'
        }
      },
      toFullHTML: function(){
        return '<div class="menu-item ' + vendorCode() + '">'+ vendor +" - " +formattedPrice()+ " - " + this.shippingTime +'</div>'
      }
     }
  };

  createOffersMenu = function(offerGroup){
    var $handle = offerGroup.handle;
    var $container = undefined

    // var setClickHandler = function(block){
    //   $handle.click(function(){
    //     $handle.off();
    //     block.call();
    //   });
    // };

    var open = function(){
      $handle.trigger("handleOpen",$handle)
      var $tr = $handle.parents('tr')
      $container = $('<tr class="more-offers-container"><td colspan="4"></td></tr>').insertBefore($tr).hide().slideDown();
    };

    var close = function(e,handle){
      if( $container ){
        $container.slideUp()
      }
    };

    $handle.on("click",open);

    $(document).on("handleOpen",close)

    return {
      offerGroup: offerGroup,
      open: function(){
        open();
        this.status = "open"
      },
      close: function(){
        close();
        this.status = "closed"
      }
    }
    
  };

  // Let's make books right away
  $('.book-row').each(function(){
    booklist.books.push(createBook(this));
  });




});
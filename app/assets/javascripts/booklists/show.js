$(document).ready(function(){


  var vendors = ['bookstore','amazon','bn'];

//-------UTILS-----------------------------------------------------------//

  var setActiveButton = function($element){
    $element.on({
      mouseenter: function(e){
        $(this).addClass("active");
      },
      mouseleave: function(e){
        $(this).removeClass("active").addClass('inactive');
      },
    });
  }; 


//--------BOOKLIST--------BOOKLIST--------BOOKLIST--------BOOKLIST-------//
  BOOKSUPPLYCO = function(){
    var books = [];

    var addBooks = function(){
      $('.book-row-outer').each(function(){
        books.push( createBook(this) );
      });
    };

    var importData = function(data){
      _.each(data,function(bookData){
        var book = find(bookData.ean);
        book.addOffers(bookData.offers_attributes);
      });
    }

    var find = function(ean){
      return _.find(books,function(book){
        return book.ean === ean
      });
    };

    var updateData = function(){
      var received = []
      _.each(vendors,function(vendor){
        $.ajax({
          url: window.location.pathname + '/books/' + vendor,
          dataType: "json",
          success: function(data, textStatus, jqXHR){
            importData(data);
          },
          complete: function(){
            received.push(vendor);
            if(received.length === vendors.length){
              $('.loading').fadeOut('slow',function(){ $(this).remove(); });
            }
          }
        });
      });
    };

    var checkoutData = function(){

      var selectedOffers = function(){
        return _.reduce(books,function(memo,book){
          if( book.selectedOffer() ){ memo.push( book.selectedOffer() ); }
          return memo;
        },[]);
      };


      var checkoutOffers = function(vendor){
        return _.filter(selectedOffers(),function(offer){
          return offer.vendor === vendor || offer.vendorCode === vendor;
        });
      };

      var vendorCheckoutData = function(vendor){
        return _.map( checkoutOffers(vendor), function(offer){
          return {
            vendor: offer.vendor,
            ean: offer.ean,
            condition: offer.condition,
            vendor_offer_id: offer.vendorOfferId,
            vendor_book_id: offer.vendorBookId,
            price: offer.price
          };
        });
      };

      var vendorData = function(vendor){
        return {
          vendor: vendor,
          school: $('h2.school-name').attr('data-slug'),
          books:  vendorCheckoutData(vendor) 
        };
      };

      var checkoutVendors = function(){
        return _.unique(_.map(selectedOffers(),function(offer){
          return offer.vendor
        }));
      };

      return _.map(checkoutVendors(),function(vendor){
        // For rails, check to make sure server interprets correctly if refactoring
        return $.param( vendorData(vendor) ).replace(/\%5B\d\%5D/g,"%5B%5D");
      });
    };

    var booklistId = function(){
      return window.location.pathname.replace("/","")
    };

    var setCheckoutButton = function(){

      var windows = [];
      var openWindow = function(name){
        var x = 0;
        var y = (windows.length)*150;
        var newWindow = window.open('',name,'height=650,width=1000' );
        newWindow.moveTo(x,y);
        windows.push(newWindow);
        return newWindow
      };      

      var sendToCart = function(params,name){
        var form = document.createElement('form');
        form.target = name
        form.method = 'POST'
        form.action = booklistId() + "/carts?" + params
        var newWindow = openWindow(name)
        if(newWindow){ form.submit(); } else {
          console.log("popup blocked")
        }
      };

      $('#checkout-button').on({
        click: function(){
          _.map(checkoutData(),function(vendorData,i){
            sendToCart(vendorData,'books ' + i);
          });
        }
      });
    };

    returnObject = {
      books: books,
      addBooks: addBooks,
      importData: importData,
      checkoutData: checkoutData,
      find: find
    };

    updateData();
    setCheckoutButton();
    return returnObject
  }();

// -------BOOK-------BOOK-------BOOK-------BOOK-------BOOK-------BOOK-------//
  var createBook = function(el){
    var $el = $(el);
    var ean = $el.attr('data-ean');
    var offerGroups = [];

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

    var selectedOffer = function(){
      return _.reduce(offerGroups,function(memo,offerGroup){
        return offerGroup.selectedOffer() ? offerGroup.selectedOffer() : memo;
      },undefined);
    };

    var createOfferGroups = function(book){
      _.each(['new','used'],function(category,index){
        offerGroups.push( createOfferGroup(book,category) );
      });
    };

    var returnObject = {
      el: el,
      $el: $el,
      ean: ean,
      offerGroups: offerGroups,
      addOffers: addOffers,
      reportSelected: reportSelected,
      selectedOffer: selectedOffer
    }

    createOfferGroups(returnObject);
    return returnObject;
  };

//-------OFFERGROUP-------OFFERGROUP-------OFFERGROUP-------OFFERGROUP-------//
  var createOfferGroup = function(book,category){
    var $el = book.$el.find('.price-'+category)
    var $outerContainer = $el.find('.book-button-outer')
    var $vendorTag = $el.find('.vendor-tag')
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
      var newOffer = createOffer(this,json);
      offers.push( newOffer );
      updateDiv();
    };

    var updateDiv = function(funcIn,funcOut){
      funcOut = funcOut || $.noop;
      funcIn = funcIn || $.noop;

      var newDisplayOffer = selectedOffer() || bestOffer() || defaultOffer();

      if(displayOffer != newDisplayOffer){
        displayOffer = newDisplayOffer;
        changeContent('<span class="price-content">'+ newDisplayOffer.priceHtml() +'</span>',function(){
          updateClasses(newDisplayOffer)
          if(newDisplayOffer.status === "Available"){  
            makeSelectable();
            setActiveButton($outerContainer);
          }
          funcIn.call();
        },funcOut); 
      }
    };

    // For adding vendor styling to book buttons
    var updateClasses = function(offer){
      $vendorTag.removeClass();
      $vendorTag.addClass('vendor-tag ' + offer.vendorCode);
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

    var isClickable = false
    var makeSelectable = function(){
      $el.addClass('selectable');
      if(!isClickable){ setClickHandler(); }
    };

    var setClickHandler = function(){
      $contentContainer.on({
        click: function(e){
          toggleSelect();
        }
      });
      isClickable = true;
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
  };

//-------OFFER-------OFFER-------OFFER-------OFFER-------OFFER-------OFFER-------//
  var createOffer = function(offerGroup,json){
    var availability =      json.availability;
    var comments =          json.comments;
    var condition =         json.condition;
    var detailedCondition = json.detailed_condition;
    var price =             json.price;
    var shippingTime =      json.shipping_time;
    var vendor =            json.vendor;
    var link =              json.link;
    var vendorBookId =      json.vendor_book_id;
    var vendorOfferId =     json.vendor_offer_id;
    var status
    var $el
    var offerRow

    var status = function(){
      if(!vendorBookId){
        return "Not found"
      } else if(!price){
        return "Sold out"
      } else if( availability === "Not available" ){
        return "Not available"
      } else {
        return "Available"
      }
    }();

    var formattedPrice = function(){
      if(price){
        return "$" + parseFloat(price,10).toFixed(2);
      }
    }();

    var vendorCode = function(){
      codes = {
        'Amazon': "amazon",
        'Barnes and Noble': 'bn'}

      if( vendor.match(/bookstore/i) ){ var bookstore = "bookstore" }
      return codes[vendor] || bookstore
    }();

    var schoolAmazonTag = function(){
      var slug = $('h2.school-name').attr('data-slug');
      return 'bsc-' + slug + '-20'
    }();

    var vendorLink = function(){
      var links = {
        amazon: {
          'new': "http://www.amazon.com/gp/offer-listing/" + vendorBookId + "?condition=new&tag=" + schoolAmazonTag,
          'used': "http://www.amazon.com/gp/offer-listing/" + vendorBookId + "?condition=used&tag=" + schoolAmazonTag
        },
        bn: {
          'new': "http://click.linksynergy.com/deeplink?mid=36889&id=BF/ADxwv1Mc&murl=http%3A%2F%2Fwww.barnesandnoble.com%2Fean%2F" + vendorBookId,
          'used': "http://click.linksynergy.com/deeplink?mid=36889&id=BF/ADxwv1Mc&murl=http%3A%2F%2Fwww.barnesandnoble.com%2Flisting%2F" + vendorBookId
        },
        bookstore: {
          'new': link,
          'used': link
        } 

      };
      return link || links[vendorCode][condition];
    }();

    var priceHtml = function(){
      return formattedPrice || status;
    };

    var setDetailedCondition = function(){
      if(status === "Available" && !detailedCondition){
        detailedCondition = condition.substr(0,1).toUpperCase() + condition.substr(1)
      }
    }();

    var alternateComments = function(){
      if(status != "Not found"){
        return 'See <a href="'+ vendorLink +'" class="link-safe" target="_blank">link</a>.';
      }
    };

    var setOfferRow = function(offerRow){
      offerRow = this.offerRow = offerRow;
    };

    var selected = false
    var select = function(report){
      selected = true;
      offerGroup.reportSelected( this );
      if(returnObject.offerRow){ returnObject.offerRow.select(); }
    };

    var deselect = function(){
      selected = false;
      if(returnObject.offerRow){ returnObject.offerRow.deselect(); }
    }

    var isSelected = function(){
      return selected
    };


    var returnObject = {
      offerGroup:         offerGroup,
      availability:       availability,
      comments:           comments,
      condition:          condition,
      detailedCondition:  detailedCondition,
      ean:                offerGroup.book.ean,
      price:              price,
      formattedPrice:     formattedPrice,
      shippingTime:       shippingTime,
      vendor:             vendor,
      vendorBookId:       vendorBookId,
      vendorOfferId:      vendorOfferId,
      offerGroup:         offerGroup,
      status:             status,
      priceHtml:          priceHtml,
      vendorCode:         vendorCode,
      offerRowTemplate:   offerRowTemplate,
      vendorLink:         vendorLink,
      alternateComments:  alternateComments,
      offerRow:           offerRow,
      setOfferRow:        setOfferRow,
      select:             select,
      deselect:           deselect,
      isSelected:         isSelected
    };

    var offerRowTemplate = '\
      <div class="offer-row-outer">\
        <div class="offer-row <%= offer.vendorCode %>">\
          <div class="offer-column-link">\
            <% if(offer.vendorBookId){ %>\
              <a href="<%= offer.vendorLink %>" class="link-safe" target="_blank">\
                <i class="icon-link link-safe"></i>\
              </a>\
            <% } %>\
          </div>\
          <div class="offer-column-left">\
            <div class="offer-price">\
              <span class"offer-price-content"><%= offer.priceHtml() %></span>\
            </div>\
            <span class="offer-vendor"><%= offer.vendor %></span>\
          </div>\
          <div class="offer-column-right">\
            <div class="offer-column-row">\
              <% if(offer.detailedCondition){ %>\
                Condition: <span class="offer-detailed-condition"><%= offer.detailedCondition %></span>\
              <% } %>\
              <span class="offer-shipping-time"><%= offer.shippingTime %></span>\
            </div>\
            <div class="offer-column-row offer-comments-row">\
              <span class="offer-comments"><%= offer.comments || offer.alternateComments() %></span>\
            </div>\
          </div>\
        </div>\
      </div>\
    ';

    var offerHtml = function(){
      return _.template(offerRowTemplate,{offer: returnObject})
    };

    _.extend(returnObject,{offerHtml: offerHtml});


    return returnObject;
  };

//-------OFFERSHANDLE-------OFFERSHANDLE-------OFFERSHANDLE-------OFFERSHANDLE----------//
  var createOffersHandle = function(offerGroup){
    var $el = offerGroup.$el.find('.book-button-handle');
    var $wrapper = $el.find('.handle-content');
    var $wireline = $el.siblings('.wireline')

    var arrows = function(direction){
      return '<i class="icon-caret-' + direction + '"></i>'
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
        $el.trigger('mouseleave')
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

//---------OFFERSBOX---------OFFERSBOX---------OFFERSBOX---------OFFERSBOX---------//
  var createOffersBox = function(offerGroup){
    var $el
    var $bookRow = offerGroup.book.$el.find('.book-row-inner');
    var offerRows = []
    
    var open = function(){
      this.$el = $el = formDomElement();
      appendOffers(this);
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
      close: close,
      offerRows: offerRows
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

    var appendOffers = function(offersBox){
      _.each(offerGroup.sortedOffers(),function(offer){
        offerRows.push(createOfferRow(offer,offersBox));
      });
    }

    return returnObject;
  };

//-------OFFERROW-------OFFERROW-------OFFERROW-------OFFERROW-------OFFERROW-------//
  
  var createOfferRow = function(offer,offersBox){
    var $box = offersBox.$el
    var $el
    var $elInner
    var offerGroup = offer.offerGroup

    var createWithBox = function(){
      this.$el = $el = addDomElement();
      this.$elInner = $elInner = $el.find('.offer-row')
      offer.setOfferRow(returnObject);
      setEventHandlers();
    };

    var addToExistingBox = function(){
      this.$el = $el = addDomElement();
      setEventHandlers();
    };

    var select = function(){
      $elInner.removeClass('deselected').addClass('selected')
    }

    var deselect = function(){
      $elInner.removeClass('selected').addClass('deselected');
    };

    var addDomElement = function(){
      return $box.append(offer.offerHtml()).children().last();
    }

    var setEventHandlers = function(){
      if(offer.status === "Available"){
        setActiveButton($elInner);
        setClickHandler();
      }
      if( offer.isSelected() ){
        $elInner.addClass('selected')
      }
    };

    var setClickHandler = function(){
      $elInner.on({
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
      $elInner: $elInner,
      offer: offer,
      offersBox: offersBox,
      select: select,
      deselect: deselect
    }

    createWithBox();
    
    return returnObject
  };

//--------INIT--------INIT--------INIT--------INIT--------INIT--------INIT--------//

  BOOKSUPPLYCO.addBooks();
  bscTour.start();

});
var createOffer = function(offerGroup,json){
  var availability =      json.availability;
  var comments =          json.comments;
  var condition =         json.condition;
  var detailedCondition = json.detailed_condition;
  var price =             json.price;
  var shippingTime =      json.shipping_time;
  var vendor =            json.vendor;
  var vendorBookId =      json.vendor_book_id;
  var vendorOfferId =     json.vendor_offer_id;
  var status

  var status = function(){
    if(!vendorBookId){
      return "Not Found"
    } else if(!price){
      return "Sold out"
    } else {
      return "Available"
    }
  }();

  var formattedPrice = function(){
    if(price){
      return "$" + parseFloat(price,10).toFixed(2);
    }
  }

  var schoolAmazonTag = function(){
    var slug = $('h2.school-name').attr('data-slug');
    return 'bsc-' + slug + '-20'
  };

  var formattedPrice = formattedPrice();
  var vendorCode = function(){
    codes = {
      'Amazon': "amazon",
      'Barnes and Noble': 'bn' }
    return codes[vendor]
  }

  var vendorLink = function(){
    var links = {
      amazon: {
        'new': "https://www.amazon.com/dp/" + vendorBookId + "?tag=" + schoolAmazonTag(),
        'used': "http://www.amazon.com/gp/offer-listing/" + vendorBookId + "?tag=" + schoolAmazonTag()
      },
      bn: {
        'new': "http://click.linksynergy.com/deeplink?mid=36889&id=BF/ADxwv1Mc&murl=http%3A%2F%2Fwww.barnesandnoble.com%2Fean%2F" + vendorBookId,
        'used': "http://click.linksynergy.com/deeplink?mid=36889&id=BF/ADxwv1Mc&murl=http%3A%2F%2Fwww.barnesandnoble.com%2Flisting%2F" + vendorBookId
      } 
    };
    return links[vendorCode()][condition];
  }()

  var priceHtml = function(){
    return formattedPrice || status;
  };

  var setDetailedCondition = function(){
    if(status === "Available" && !detailedCondition){
      detailedCondition = condition.substr(0,1).toUpperCase() + condition.substr(1)
    }
  }();


  var returnObject = {
    offerGroup:         offerGroup,
    availability:       availability,
    comments:           comments,
    condition:          condition,
    detailedCondition:  detailedCondition,
    price:              price,
    formattedPrice:     formattedPrice,
    shippingTime:       shippingTime,
    vendor:             vendor,
    vendorBookId:       vendorBookId,
    vendorOfferId:      vendorOfferId,
    offerGroup:         offerGroup,
    status:             status,
    priceHtml:          priceHtml,
    vendorCode:         vendorCode(),
    offerRowTemplate:   offerRowTemplate,
    vendorLink:         vendorLink
  };

  var offerRowTemplate = '\
    <div class="offer-row <%= offer.vendorCode %>">\
      <div class="offer-column-link">\
        <% if(offer.vendorBookId){ %>\
          <a href="<%= offer.vendorLink %>" target="_blank">\
            <i class="icon-link"></i>\
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
          <span class="offer-comments"><%= offer.comments %></span>\
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
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

  var determineStatus = function(){
    if(!vendorBookId){
      return "Not Found"
    } else if(!price){
      return "Sold out"
    } else {
      return "Available"
    }
  };

  var formattedPrice = function(){
    if(price){
      return "$" + parseFloat(price,10).toFixed(2);
    }
  }

  var status = determineStatus();
  var formattedPrice = formattedPrice();
  var vendorCode = function(){
    codes = {
      'Amazon': "amazon",
      'Barnes and Noble': 'bn' }
    return codes[vendor]
  }

  var priceHtml = function(){
    return formattedPrice || status;
  };

  var offerHtml = function(){

  };

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
    offerHtml:          offerHtml,
    vendorCode:         vendorCode()
  };

  return returnObject;
};
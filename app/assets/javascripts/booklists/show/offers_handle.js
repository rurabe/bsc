var createOffersHandle = function(offerGroup){
  var $el = offerGroup.$el.find('.book-button-handle');
  var wrapper = $el.find('.handle-content');

  var moreOptions = '<span class="handle-content">more options</span>'
  var arrows = '<i class="icon-double-angle-down"></i>'
  var setLabelChanger = function(){
    $el.mouseenter(function(e){
      e.stopPropagation();
      changeContent(moreOptions);
      $(this).animate({'width': '70%',
                       'color': 'white',
                       'background-color': 'black'},50);
    }).mouseleave(function(e){
      e.stopPropagation();
      changeContent(arrows);
      $(this).animate({'width': '50%',
                       'color': 'black',
                       'background-color': 'white'},50);
    });
  };

  var $bookRow = offerGroup.book.$el
  var offerRow = '<div class="span5 offer-row"><%= offer.formattedPrice %></div>'
  var setClickOpener = function(){
    $el.click(function(){
      _.each(offerGroup.offers,function(offer){
        $bookRow.append(_.template(offerRow,{offer: offer}));
      });
    })
  }

  returnObject = {
    $el: $el,
    offerGroup: offerGroup
  };
  var changeContent = function(content){
    wrapper.fadeOut(50,function(){
      wrapper.html(content).fadeIn(50);
    });
  };

  setLabelChanger();
  setClickOpener();


  return returnObject;
};
BOOKSUPPLYCO = function(){
  var books = []

  var addBook = function(el){
    this.books.push( createBook(el) );
  }

  var importData = function(data){
    _.each(data,function(bookData){
      var book = find(bookData.ean);
      book.addOffers(bookData.offers_attributes);
    });
  }

  var updateData = function(){
    $.ajax({
      type: 'PUT',
      dataType: "json",
      success: function(data, textStatus, jqXHR){
        importData(data);
      }
    });
  }

  var selectedOffers = function(){
    return _.reduce(books,function(memo,book){
      if( book.selectedOffer() ){ memo.push( book.selectedOffer() ); }
      return memo;
    },[]);
  };

  var checkoutData = function(vendor){
    return _.filter(selectedOffers(),function(offer){
      return offer.vendor === vendor || offer.vendorCode === vendor;
    });
  };

  returnObject = {
    books: books,
    addBook: addBook,
    importData: importData,
    selectedOffers: selectedOffers,
    checkoutData: checkoutData
  };

  var find = function(ean){
    return _.find(books,function(book){
      return book.ean === ean
    });
  };

  updateData();

  return returnObject
}();
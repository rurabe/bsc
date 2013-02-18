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

  returnObject = {
    books: books,
    addBook: addBook,
    importData: importData
  };

  var find = function(ean){
    return _.find(books,function(book){
      return book.ean === ean
    });
  };

  updateData();

  return returnObject
}();
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require ./show/top.js
//= require ./show/booklist.js
//= require ./show/book.js
//= require ./show/offer_group.js
//= require ./show/offer.js
//= require ./show/offers_handle.js
//= require ./show/offers_box.js
//= require ./show/offer_row.js

  var createBooks = function(){
    $('.book-row-outer').each(function(){
      BOOKSUPPLYCO.addBook(this);
    })
  }();

});
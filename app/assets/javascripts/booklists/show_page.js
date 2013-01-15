$(document).ready(function(){

	// BOOKSUPPLYCO is the master object, accessible from the gloabal scope.
	// Only public methods should be exposed in this object, but all JS
	// activity should be contained within this object
	BOOKSUPPLYCO = function(){
// [----------------------------------------===== #Private Methods =====----------------------------------------]
		var initialize = function(){
			// Ajax requests for the book prices, returns JSON which is imported by 
			// the global object.
			$.each(['amazon','bn','bn-used'],function(i,vendor){
				$.ajax({ // Amazon
					type: 'PUT',
					dataType: "json",
					data: {vendor: vendor},
					success: function(data, textStatus, jqXHR){
						BOOKSUPPLYCO.importData(data);
					},
					error: function(jqXHR, textStatus, errorThrown){
						$(".book-amazon").each(function(){
							// Fade out the loading divs
							$(this).children(".loading")
										 .fadeOut(function(){
								$(this).parent().html('<span class="label">Error</span>').hide().fadeIn();
								console.log(errorThrown);
							});
						})
					}
				});
			});

			// Sets behavior for the checkout button
			$('#checkout-button').click(function(){
				if( bnTarget = priceDivsHeartShapedBox.bnCheckoutData() ){
					var bnBooks = window.open(bnTarget,'amazonBooks','height=650,width=800');
				}
				if( amazonTarget = priceDivsHeartShapedBox.amazonCheckoutData() ){
					var amazonBooks = window.open(amazonTarget,'bnBooks','height=650,width=800');
					if ( bnTarget ){
						amazonBooks.moveTo(0,200);
					}
				}
				if( !amazonTarget && !bnTarget ){
					// Action if no books are selected
				}
			});

	    $('th.amazon').popover(
	      { html: true,
	        title: "<span class='close' id='offerClose'>&times;</span><h4>Hot Deal!</h4>",
	        content: "<p>Amazon is offering <b>students</b> a <a href='http://www.amazon.com/gp/student/signup/info?ie=UTF8&refcust=HR7XOWUQOG6SMYEDL5FJBQACTU&ref_type=generic' target='_blank'> free trial of Amazon Prime.</a> Sign up <a href='http://www.amazon.com/gp/student/signup/info?ie=UTF8&refcust=HR7XOWUQOG6SMYEDL5FJBQACTU&ref_type=generic' target='_blank'>here</a> before you select your books and get free 2-day shipping on your books from Amazon!</p>",
	        placement: 'top',
	        trigger: 'manual'
	      }
	    );

	    $('th.amazon').tooltip({
	    	title: "Hot Deal!",
	    	trigger: 'manual'
	    })

	    var whyPopoverContent = "\
	    	<p>When we can't find a book, it's usually for one of the following reasons:</p>\
	    	<ul>\
	    		<li>\
	    			Your school does not have that class' books in the system,\
	    		</li>\
	    		<li>\
	    			Your teacher hasn't chosen what books are required,\
	    		</li>\
	    		<li>\
	    			This is a lab or discussion section; the books are listed under the lecture, or\
	    		</li>\
	    		<li>\
	    			No books are required! Yay!\
	    		</li>\
	    	</ul>\
	    	<p>If you think we're wrong and it's an error on our part, let us know on Facebook.</p>"

	    $('.no-books-why').popover({
	    	html: true,
	    	content: whyPopoverContent,
	    	title: "<h4>No Books?</h4>",
	    	trigger: 'hover'
	    })


			// Set handlers for link/express switch
			$('#simple').change(function(){
				priceDivsHeartShapedBox.makeSimple();
			});
			$('#express').change(function(){
				priceDivsHeartShapedBox.makeExpress();
			});	

			// Replaces loading divs with Not Found after 20 secs
			setTimeout(function(){
				$('.loading').fadeOut(function(){
					$(this).replaceWith('<span class="label">Not Found</span>').hide().fadeIn()
				})
			},20000);
		}();	


		// Pulls the school slug from the school subhead. This is the way the 
		// backend communicates which school is set @school.
		var schoolAmazonTag = function(){
			var slug = $('h2.school-name').attr('data-slug');
			return 'bsc-' + slug + '-20'
		};

		var showAmazonOffer = function(){
			$('th.amazon').popover('show').tooltip('hide');
			$('#offerClose').click(function(){
				hideAmazonOffer();
			});
		};

		var hideAmazonOffer = function(){
			$('th.amazon').popover('hide').tooltip('show');
			$('div.tooltip.fade').click(function(){
	    	showAmazonOffer();
	  	});
		};

		// Defines the tour object and starts the tour.
		var takeTour = function(){
			// Start the tour
			$('#tour').joyride({
				tipLocation: 'top',
				postStepCallback: function(){
					var that = this;
					setTimeout(function(){
						if( $('.joyride-tip-guide[data-index=1]').is(':visible') ){
						// Then it is on step 2
							setTimeout(function(){
								$('.first')[0].click();
							},1200);
							setTimeout(function(){
								$('.first~.book-query')[0].click();
							},2400);
							setTimeout(function(){
								$('.first')[0].click();
							},3600);
							setTimeout(function(){
								$('.first')[0].click();
							},4800);
						}
					},100);
				},
				postRideCallback: function(){
					$('#tour-button').fadeIn();
					$('#tour-button').on('click',function(){ takeTour(); });
					showAmazonOffer();
				}
			});

			// Set cookie
			$.cookie('booksupplyco_tour','taken', { expires: 90 });
		};

		var checkTour = function(){
			// Checks for the tour taken cookie, and starts the tour or sets the button
			if (!$.cookie('booksupplyco_tour')){
				$('#tour-button').hide().off();
				takeTour();
			}else{
				$('#tour-button').on('click',function(){ takeTour(); });
				showAmazonOffer();
			};
		}();

		$('div.tooltip.fade').click(function(){
	    $('th.amazon').popover('show').tooltip('hide');
	  });
		
		// Constructor for priceDiv objects
		// params = {vendor,vendorId,price,condition, }
		var priceDiv = function(params){

			// Instance variables

			var condition 	= params.condition;
			var ean					= params.ean;
			var price 			= params.price;
			var vendor 			= params.vendor;
			var parentEan		= params.parent_ean;
			var $div 				= $('#book-row-' + (parentEan||ean) + ' .' + vendor + '-' + condition);

			// Function to determine if the item is sold out or not found
			var setPrice = function(){
				if ( ean === null ){ price = "Not found" }
				else if ( price == null ){ price = "Sold out" }
			}();

			// Function to format prices => $ 123,456.78
			var showPrice = function(number){
				return "$" + Number(number).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
			};

			// Function to change the html contents of the div 
			var changeContent = function(html,callback){
				callback = callback || $.noop;
				$div.children()
						.fadeOut(function(){
							$div.html('<span class="priceDiv-content">' + html + '</span>')
						 		 	.hide()
								 	.fadeIn();
							callback();
						});					
			};

			// Function to wrap content in a label span
			var makeLabel = function(content){
				return '<span class="label">' + content + '</span>'
			}

			// Function to make the behavior of the div toggleable for Express
			var makeToggleable = function(){
				$div.addClass("selectable");
				$div.click(function(){
					$(this).toggleClass("selected");
					$(this).siblings(".selected").removeClass("selected");
				});
			};

			// Set the handlers for the express buttons
			var setCheckoutLinkHandler = function(){
				$div.click(function(){
					var amazonBooks = priceDivsHeartShapedBox.amazonCheckoutData();
					var bnBooks = priceDivsHeartShapedBox.bnCheckoutData();
					if( amazonBooks && bnBooks ){
						$('.checkout-text-prefix').show()
						$('.checkout-text-amazon').show()
						$('.checkout-text-connector').show()
						$('.checkout-text-bn').show()
					}else if( amazonBooks ){
						$('.checkout-text-prefix').show()
						$('.checkout-text-amazon').show()
						$('.checkout-text-connector').hide()
						$('.checkout-text-bn').hide()
					}else if( bnBooks ){
						$('.checkout-text-prefix').show()
						$('.checkout-text-amazon').hide()
						$('.checkout-text-connector').hide()
						$('.checkout-text-bn').show()
					}else if ( !amazonBooks && !bnBooks ){
						$('.checkout-text-prefix').hide()
						$('.checkout-text-amazon').hide()
						$('.checkout-text-connector').hide()
						$('.checkout-text-bn').hide()
					}
				});
			};

			// Describes the characteristics of a non sold out express div
			var expressPrice = function(){
				makeToggleable();
				$div.addClass("selectable")
				changeContent(showPrice(price),function(){
					$div.removeClass("simple")
				});
				setCheckoutLinkHandler();
			}

			// Describes the characteristics of a sold out express div
			var expressSoldOut = function(){
				changeContent(makeLabel(price),function(){
					$div.removeClass("simple")
				});
			}

			// Describes the characteristics of a sold out simple div
			var simpleSoldOut = function(){
					changeContent(
						makeLabel(price)
					);
				}

			var vendorMethods = {
			 	amazon: {
					vendor: "amazon",
					asin: params.asin,
					newLink: function(){
						return "https://www.amazon.com/dp/" + this.asin + "?tag=" + schoolAmazonTag();
					},
					usedLink: function(){
						return "http://www.amazon.com/gp/offer-listing/" + this.asin + "?tag=" + schoolAmazonTag();
					}
				},
				bn: {
					vendor: "bn",
					productCode: function(){
						if(this.condition === "new") { return "BK" }
						else if (this.condition === "used") { return "MP" }
					},
					newLink: function(){
						return "http://click.linksynergy.com/deeplink?mid=36889&id=BF/ADxwv1Mc&murl=http%3A%2F%2Fwww.barnesandnoble.com%2Fean%2F" + this.ean
					},
					usedLink: function(){
						return "http://click.linksynergy.com/deeplink?mid=36889&id=BF/ADxwv1Mc&murl=http%3A%2F%2Fwww.barnesandnoble.com%2Flisting%2F" + this.ean
					}
				}
			};

			// PRICEDIV PUBLIC METHODS
			var thisDiv = $.extend(
				{},
				vendorMethods[vendor],
				{
					condition: 	condition,
					ean: 				ean,
					div: 				$div,

					toSimpleDiv: function(){
						$div.off();
						$div.addClass("simple");
						$div.removeClass("selectable");
						if (price === "Sold out" || price === "Not found"){
							simpleSoldOut();
						} else {
							this.simplePrice();
						}
					},

					toExpressDiv: function(){
						if (price === "Sold out" || price === "Not found"){
							expressSoldOut();
						} else {
							expressPrice();
						}
					},
					// Describes the characteristics of a non sold out simple div
					simplePrice: function(){
						changeContent(
							'<a href=' + this.link() + ' target="_blank">' +
								 showPrice(price)
							+ '</a>'
						);
					},
					// Switch to give you
					link: function(){
						if (ean){
							if (condition === "new") {
								return this.newLink();
							} else {
								return this.usedLink();
							}
						}
					}
				}
			);
				
				priceDivsHeartShapedBox.divs.push(thisDiv);
				thisDiv.toExpressDiv();
				return thisDiv
			};

			var priceDivsHeartShapedBox = {
				divs: [],
				makeSimple: function(filter){
					$.each(this.divs,function(){
						this.toSimpleDiv();
					});
					$("#checkout-button").slideUp();
				},
				makeExpress: function(filter){
					$.each(this.divs,function(){
						this.toExpressDiv();
					});
					$("#checkout-button").slideDown();
				},
				selectByClass: function(){
					var that = this
					var args = Array.prototype.slice.call(arguments)
					return args.reduce(function(subset,className){
						return $.map(subset,function(e){
							if(e.div.attr('class').match(className)){
								return e;
							}
						});
					}, that.divs);
				},
				// Make more general. Maybe select by class as a 2nd - infinity arguments
				getIds: function(collection){
					return collection.map(function(i){
						return i.ean;
					});
				},
				amazonCheckoutData: function(){
					var amazonBooks = this.selectByClass('book-amazon','selected');
					if( amazonBooks.length != 0 ){
						var conditionString = "cart[books][][condition]=";
						var eanString = "cart[books][][ean]=";
						var associateTag = "&cart[tag]=" + schoolAmazonTag();
						var bookData = amazonBooks.map(function(book){
							return conditionString + book.condition + "&" + eanString + book.ean;
						});

						return window.location.pathname + "/carts?" + bookData.join("&") + associateTag
					}
				},
				bnCheckoutData: function(){
					var bnBooks = this.selectByClass("book-bn","selected")
					if( bnBooks.length != 0 ) {
						var paramsString = bnBooks.reduce(function(a,e,i){
								a.push( "ean" + (i+1) + "=" + e.ean + "&productcode" + (i+1) + "=" + e.productCode() + "&qty" + (i+1) + "=1" );
								return a
						},[]).join("&");

						return "http://cart4.barnesandnoble.com/op/request.aspx?" + paramsString + "&stage=fullCart&uiaction=multAddMoreToCart"
					}
				}
			}

	// [----------------------------------------===== #Public Methods =====----------------------------------------]

		return {
			importData: function(data){
				if( Object.prototype.toString.call(data) === '[object Object]' ) {
				  priceDiv(data);
				}
				else if( Object.prototype.toString.call(data) === '[object Array]' ) {
					$.each(data,function(index,priceDivData){
						priceDiv(priceDivData);
					});
				}
			}
		}
	}();
});
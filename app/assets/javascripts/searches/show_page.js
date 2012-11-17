$(document).ready(function(){

	(BOOKSUPPLYCO = function(){

		var takeTour = function(){
			console.log("tour!!!")
			// Start the tour
			$('#tour').joyride({
				tipLocation: 'top',
				postRideCallback: function(){
					$('#tour-button').fadeIn();
					$('#tour-button').on('click',function(){ takeTour(); })
				}
			});

			$.cookie('boooksupplyco_tour','taken', {
				expires: 90
			});
		}

		if (!$.cookie('boooksupplyco_tour')){
			$('#tour-button').hide().off()
			takeTour();
		}else{
			$('#tour-button').on('click',function(){ takeTour(); })
		}

	$.ajax({ // Amazon
			type: 'PUT',
			dataType: "json",
			data: {vendor: "amazon"},
			success: function(data, textStatus, jqXHR){
				$.each(data,function(){
					BOOKSUPPLYCO.importData(this);
				});
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

		$.ajax({ // Barnes and Noble
			type: 'PUT',
			dataType: "json",
			data: {vendor: "bn"},
			success: function(data, textStatus, jqXHR){
				var a = this;
				$.each(data,function(){
					BOOKSUPPLYCO.importData(this)
				});
			},
			error: function(jqXHR, textStatus, errorThrown){
				$(".book-bn").each(function(){
					// Fade out the loading divs
					$(this).children(".loading")
								 .fadeOut(function(){
						$(this).parent().html('<span class="label">Error</span>').hide().fadeIn();
						console.log(errorThrown);
					});
				})
			}
		});

		$('.bn-used').each(function(){
			var div = this;
			$.ajax({ // Barnes and Noble
				type: 'PUT',
				url: '/books/' + $(div).parent().attr('id').match(/book-row-(\d+)/)[1],
				dataType: "json",
				success: function(data, textStatus, jqXHR){
					BOOKSUPPLYCO.importData(data);			
				},
				error: function(jqXHR, textStatus, errorThrown){
					
						// Fade out the loading divs
					$(this).children(".loading")
								 .fadeOut(function(){
						$(this).parent().html('<span class="label">Error</span>').hide().fadeIn();
						console.log(errorThrown);
					});
				}
			});
		});

		// Set handlers for link/express switch
		$('#simple').change(function(){
			priceDivsHeartShapedBox.makeSimple();
		});
		$('#express').change(function(){
			priceDivsHeartShapedBox.makeExpress();
		});	

		// [----------------------------------------===== #Private Methods =====----------------------------------------]
		setTimeout(function(){
			$('.loading').fadeOut(function(){
				$(this).replaceWith('<span class="label">Not Found</span>').hide().fadeIn()
			})
		},15000)
		
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
					amazonCheckoutBehavior();
					bnCheckoutBehavior();
				});
			};

			// Wrap the amazon button in the UJS link on click
			var amazonCheckoutBehavior = function(){
				var amazonTarget = priceDivsHeartShapedBox.amazonCheckoutData();
					$('a > #checkout-amazon').unwrap();
				if (amazonTarget){
					$('#checkout-amazon').wrap(
						'<a href="' + amazonTarget + '" target="_blank" data-method="post" rel="nofollow"/>'
					);
				}
			};

			// Wrap the bn button in the built link on click
			var bnCheckoutBehavior = function(){
				var bnTarget = priceDivsHeartShapedBox.bnCheckoutData();
					$('a > #checkout-bn').unwrap();
				if (bnTarget) {
					$('#checkout-bn').wrap(
						'<a href="' + bnTarget + '" target="_blank" rel="nofollow"/>'
					);
				}
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
						return "https://www.amazon.com/dp/" + this.asin + "?tag=booksupply-20"
					},
					usedLink: function(){
						return "http://www.amazon.com/gp/offer-listing/" + this.asin + "?tag=booksupply-20"
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



				thisDiv = $.extend(
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

			priceDivsHeartShapedBox = {
				divs: [],
				makeSimple: function(filter){
					$.each(this.divs,function(){
						this.toSimpleDiv();
					});
					$("#checkout-amazon").slideUp();
					$("#checkout-bn").slideUp();
				},
				makeExpress: function(filter){
					$.each(this.divs,function(){
						this.toExpressDiv();
					});
					$("#checkout-amazon").slideDown();
					$("#checkout-bn").slideDown();
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
					var response = {amazon:{}};
					
					var newBooks = this.selectByClass('amazon-new','selected')
					if (newBooks.length != 0) {
						response.amazon.new = this.getIds(newBooks);
					}

					var usedBooks = this.selectByClass('amazon-used','selected')
					if (usedBooks.length != 0) {
						response.amazon.used = this.getIds(usedBooks);
					}

					if ( newBooks.length != 0 || usedBooks.length != 0 ){
						return window.location.pathname + "/carts?" + $.param(response);
					}
				},
				bnCheckoutData: function(){
					var bnBooks = this.selectByClass("book-bn","selected")
					if ( bnBooks.length != 0 ) {
						var paramsString = bnBooks.reduce(function(a,e,i){
								a.push( "ean" + (i+1) + "=" + e.ean + "&productcode" + (i+1) + "=" + e.productCode() + "&qty" + (i+1) + "=1" )
								return a
						},[]).join("&")

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
	}());

});
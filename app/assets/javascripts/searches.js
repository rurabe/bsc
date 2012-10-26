$(document).ready(function(){
	// [----------------------------------------===== #NEW =====----------------------------------------]
	
	// [----------=====About Tab=====----------]

		$('#about-handle').toggle(
			function(){
				var el = $(this)
				$('.logo-inner').animate({'margin-top': '-350px'});
				$('.about-info').slideToggle();
				$(this).fadeOut(200,function(){
					$(this).text("OK, I got it!").fadeIn();
					// $(this).parent().append("<button id='aboutlink' class='btn btn-info'>Learn moretabout</button>");
				});
			},
			function(){
				$('.logo-inner').animate({'margin-top': '-250px'});
				$('.about-info').slideToggle();
				$(this).fadeOut(200,function(){
					$(this).text("Wait, what's this about again?").fadeIn();
					$('#aboutlink').remove()
				});
			}
		);

	// [----------=====Loading Modal=====----------]

		$('#loadingModal').modal({
			backdrop: 'static',
			keyboard: false,
			show: false
		});

		$('#login-button').click(function(){
			$('#icon-carousel').carousel({
				interval: 2500,
				pause: "false"
			}).carousel('cycle')
			$('#loadingModal').modal('show');
		})


	// [----------------------------------------===== #SHOW =====----------------------------------------]

		// [----------===== ** Helper Methods (Async Book Prices) ** =====----------]

			// Constructor for priceDiv objects, which are called in the ajax callback
			var priceDiv = function(div,price,asin,condition){
				return {
					div: div,
					price: 			function(){
												if (price === undefined){
													return this.div.attr('data-price')
												} else if (asin === ""){
													return "Not found"
												} else {
													return price
												}
											}(),
					asin: 			function(){
												if (asin === undefined){
													return this.div.attr('data-asin')
												} else if (asin === ""){
													return null
												} else {
													return asin
												}
											}(),
					condition:	condition || this.div.attr("id").match(/-(\w+)-/)[1],
					changeContent: function(html,callback){
						callback = callback || $.noop;
						var that = this
						that.div.children()
										.fadeOut(function(){
											$(that.div).html(
																	'<span class="priceDiv-content">' + html + '</span>')
														 		 .hide()
																 .fadeIn();
											callback();
										});
						
					},
					toSimpleDiv: function(){
						this.div.off()
						this.div.addClass("simple")
						this.div.removeClass("selectable")
						if (this.price === "Sold out" || this.price === "Not found"){
							this.simpleSoldOut();
						} else {
							this.simplePrice();
						}
					},
					simplePrice: function(){
						this.changeContent(
							'<a href=' + this.link() + ' target="_blank">' +
								 this.price
							+ '</a>'
						);
					},
					simpleSoldOut: function(){
						this.changeContent(
							this.makeLabel(this.price)
						);
					},
					toExpressDiv: function(){
						this.div.addClass("selectable")
						if (this.price === "Sold out" || this.price === "Not found"){
							this.expressSoldOut();
						} else {
							this.expressPrice();
						}
					},
					expressPrice: function(){
						var that = this
						this.makeToggleable();
						this.addDataAttributes();
						this.changeContent(this.price,function(){
							that.div.removeClass("simple")
						});
					},
					expressSoldOut: function(){
						var that = this
						this.addDataAttributes();
						this.changeContent(
							this.makeLabel(this.price),function(){
								that.div.removeClass("simple")
								console.log(that.div)
							}
						)
					},
					addDataAttributes: function(){
						this.div.attr('data-price',this.price)
						this.div.attr('data-asin',this.asin)
					},
					makeToggleable: function(){
						this.div.addClass("selectable");
						this.div.click(function(){
							$(this).toggleClass("selected")
							$(this).siblings(".selected").removeClass("selected")
							resetCheckoutButton();
						});
					},
					makeLinkable: function(content){
						return '<a href=' + this.link() + ' target="_blank">' +
							content
						+ '</a>'
					},
					makeLabel: function(content){
						return '<span class="label">' + content + '</span>'
					},
					link: function(){
						if (this.asin){
							if (this.condition === "new") {
								return this.newLink();
							} else {
								return this.usedLink();
							}
						}
					},
					newLink: function(){
						return "https://www.amazon.com/dp/" + this.asin + "?tag=booksupply-20"
					},
					usedLink: function(){
						return "http://www.amazon.com/gp/offer-listing/" + this.asin + "?tag=booksupply-20"
					}
				}
			};

		var priceDivsHeartShapedBox = {
			divs: [],
			makeSimple: function(){
				$.each(this.divs,function(){
					this.toSimpleDiv();
				});
			},
			makeExpress: function(){
				$.each(this.divs,function(){
					this.toExpressDiv();
				});
			}
		}

	// [----------=====Async Book Prices=====----------]

		$('#simple').change(function(){
			priceDivsHeartShapedBox.makeSimple();
		});
		$('#express').change(function(){
			priceDivsHeartShapedBox.makeExpress();
		});		

		// Format bookstore sold outs as labels on load
		$('span:contains(Sold out)').addClass('label')

		$('.book-row').each(function(){
			var el = this;

			$.ajax({
				type: 'PUT',
				url: 	"/books/" + this.id.match(/\d+/),
				dataType: "json",
				success: function(data, textStatus, jqXHR){
					newDiv 		= $(el).children(".amazon-new");
					newPrice 	= data["new_price"];
					asin 			= data["asin"];

					newPriceDiv = priceDiv(newDiv,newPrice,asin,"new");
					newPriceDiv.toExpressDiv();

					usedDiv		= $(el).children(".amazon-used");
					usedPrice = data["used_price"];

					usedPriceDiv = priceDiv(usedDiv,usedPrice,asin,"used");
					usedPriceDiv.toExpressDiv();

					priceDivsHeartShapedBox.divs.push(newPriceDiv,usedPriceDiv);
				},
				error: function(jqXHR, textStatus, errorThrown){
					$(el).children(".book-query").each(function(){
						// Fade out the loading divs
						$(this).children(".loading")
									 .fadeOut(function(){
							$(this).parent().html('Error').hide().fadeIn();
							console.log(errorThrown);
						});
					})
				}
			});
		});

		// [----------===== ** Helper Methods(Checkout Button) ** =====----------]

			// 
			var createCart = function(){
				$.ajax({
					type: 'POST',
					url: 	window.location.pathname + "/carts",
					data: checkoutData(),
					dataType: "json",
					beforeSend: function(){
						changeCheckoutButton('Loading...');	
					},
					success: function(data, textStatus, jqXHR){
						changeCheckoutButton('<i class="icon-shopping-cart"></i> Go to cart')
						$('#checkout-amazon').wrap('<a href="' + data["link"] + '" target="_blank" />');

					},
					error: function(jqXHR, textStatus, errorThrown){
						console.log("Error: " + errorThrown);
						resetCheckoutButton();
					}
				});
				$('#checkout-amazon').off("click",createCart);
			};

			// Function to return data to the ajax request based on the
			// elements selected by the user.
			var checkoutData = function(){
				// Get the ASINs from the divs
				var getAsins = function(collection){
					return collection.map(function(){
						return $(this).attr('data-asin')
					}).get();
				};
				// return the object
				var response = {
					amazon: {}
				};

				var new_books = getAsins($('.selected.amazon-new'));
				var used_books = getAsins($('.selected.amazon-used'));

				if (new_books.length != 0){
					response.amazon.new = new_books;
				}
				if (used_books.length != 0){
					response.amazon.used = used_books;
				}
				return response;
			};

			// Change the contents of the checkout button. Optional callback for additional actions
			// after the fadeOut completes
			var changeCheckoutButton = function(html,callback){
				callback = callback || $.noop;
				$('#checkout-amazon-text').fadeOut(function(){
					$(this).html(html)
								 .hide()
								 .fadeIn();
					callback();
				});
			};

			// Reset the checkout button, usually after the selection changes.
			var resetCheckoutButton = function(){
				if ($('#checkout-amazon-text').text() != "Checkout"){
					changeCheckoutButton('Checkout');
					$('a > #checkout-amazon').unwrap();
					$('#checkout-amazon').on("click",createCart);
					console.log("reset")
				}
			};

	// [----------=====Checkout Button=====----------]

		// set the behavior of the checkout button

		$('#checkout-amazon').on("click",createCart);

});
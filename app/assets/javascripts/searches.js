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

			// Constructor for priceDiv objects, which are called in the ajax callback using the method .toHtml
			var priceDiv = function(div,price,asin){
				return {
					div: div,
					price: price,
					asin: asin,
					toHtml: function(){
						console.log(this);
						if (this.price === "Sold out"){
							this.soldOutLabel();
						} else {
							this.priceLink();
						}

					},
					priceLink: function(){
						this.makeToggleable();
						this.addAsinToDiv();
						this.addPriceToDiv();
						this.changeContent(this.price);
					},
					soldOutLabel: function(){
						this.addAsinToDiv();
						this.addPriceToDiv();
						this.changeContent('<span class="label">' + this.price + '</span>')
					},
					makeToggleable: function(){
						this.div.addClass("selectable");
						this.div.click(function(){
							$(this).toggleClass("selected")
							$(this).siblings(".selected").removeClass("selected")
							resetCheckoutButton();
						});

					},
					changeContent: function(html){
						this.div.children("span")
										.html(html)
										.hide()
										.fadeIn();
					},
					addAsinToDiv: function(){
						this.div.attr('data-asin',this.asin)
					},
					addPriceToDiv: function(){
						this.div.attr('data-price',this.price)
					}
				}
			};

	// [----------=====Async Book Prices=====----------]
		
		// Format bookstore sold outs as labels on load
		$('span:contains(Sold out)').addClass('label')

		$('.book-row').each(function(){
			var el = this;

			$.ajax({
				type: 'PUT',
				url: 	"/books/" + this.id.match(/\d+/),
				dataType: "json",
				success: function(data, textStatus, jqXHR){
					// Fade out the loading divs
					$(el).children(".amazon-new")
							 .children(".loading")
							 .fadeOut(function(){
							 		priceDiv($(el).children(".amazon-new"),data["new_price"],data["asin"]).toHtml();
							 });
					$(el).children(".amazon-used")
							 .children(".loading")
							 .fadeOut(function(){
							 		priceDiv($(el).children(".amazon-used"),data["used_price"],data["asin"]).toHtml();
							 });
				},
				error: function(jqXHR, textStatus, errorThrown){
					$(el).children(".book-query").each(function(){
						// Fade out the loading divs
						$(this).children(".loading")
									 .fadeOut(function(){
							$(this).parent().html("Error").hide().fadeIn();
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
$(document).ready(function(){
	// #new
	

	// About tab toggle switch

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


	// Modal that pops over during the Mecha process
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


	// #show

	// Fetch Amazon prices
	$('.book-row').each(function(){
		// Regex to pull the object ID from the #ID attribute
		var idFinder = /\d+/;
		var el = this;
		
		$.ajax({
			type: 'PUT',
			url: 	"/books/" + idFinder.exec(this.id),
			dataType: "json",
			success: function(data, textStatus, jqXHR){
				// Select the td's that are updated by ajax
				$(el).children(".book-query").each(function(){
					// Fade out the loading divs
					$(this).children(".loading")
								 .fadeOut(function(){
						// Insert amazon new price
						newDiv = fillDiv($(el).children(".amazon-new"),data["new_price"],data["new_link"]).toHtml()
						usedDiv = fillDiv($(el).children(".amazon-used"),data["used_price"],data["used_link"]).toHtml()
					});
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

	var fillDiv = function(div,price,link){
		return {
			div: div,
			price: price,
			link: link,
			toHtml: function(){
				if (this.price === "Sold out"){
					return this.soldOutLabel();
				} else {
					return this.priceLink();
				}

			},
			priceLink: function(){
				this.makeToggleable();
				this.div.children("span")
								.html(this.price)
								.hide()
								.fadeIn();
			},
			soldOutLabel: function(){
				this.div.children("span")
								.html(
									'<a href=' + this.link +' target="_blank"><span class="label">' + this.price + '</span></a>')
								.hide()
								.fadeIn();
			},
			makeToggleable: function(){
				this.div.addClass("selectable");
				this.div.toggle(
					function(){
						$(this).siblings(".selected").click();
						$(this).addClass("selected");
					},
					function(){
						$(this).removeClass("selected");
					}
				);
			}
		}
	};
	

	// Format bookstore sold outs as labels
	$('span:contains(Sold out)').addClass('label')

	// checkoutData returns an array of selected book objects with id, vendor, and condition
	var checkoutData = function(){
		// Get the DOM nodes
		var selectedBooks = $('.selected').map(function(){
			return $(this).attr('id')
		});
		// function to parse the ids into an array of objects
		var bookParser = function(collection,vendor,condition){
			return collection.map(function(){
				match = this.match(vendor + "-" + condition + "-(\\d+)");
				if (match) {
					return {	book_id: match[1],
										condition: condition,
										vendor: vendor };
				}
			}).get();
		};
		// return the array
		return	bookParser(selectedBooks,"amazon","new").concat(
						bookParser(selectedBooks,"amazon","used"))
	};

	// set the behavior of the checkout button
	$('#checkout-amazon').click(function(){
		$('#checkout-amazon-text').fadeOut(function(){
			$(this).html('Loading...')
						 .hide()
						 .fadeIn();
		});

		$.ajax({
			type: 'POST',
			url: 	window.location.pathname + "/carts",
			data: {cart: {cart_items_attributes: checkoutData()}},
			dataType: "json",
			success: function(data, textStatus, jqXHR){
				$('#checkout-amazon-text').fadeOut(function(){
					$(this).html('<i class="icon-shopping-cart"></i> Go to cart')
						 		 .hide()
						 		 .fadeIn();
					$('#checkout-amazon').wrap('<a href="' + data["link"] + '" target="_blank" />');
				});
			},
			error: function(jqXHR, textStatus, errorThrown){
				console.log("error!")
				console.log(errorThrown);
			}
		});
	});



});
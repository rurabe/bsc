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
			url: 	"/amazonbooks/" + idFinder.exec(this.id),
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


	var checkoutData = function(){

		var selectedBooks = $('.selected').map(function(){
			return $(this).attr('id')
		});

		var bookParser = function(collection,vendor,condition){
			return collection.map(function(){
				match = this.match(vendor + "-" + condition + "-(\\d+)");
				if (match) {
					return match[1];
				}
			}).get();
		};

		return {
			amazon:{
				new:  bookParser(selectedBooks,"amazon","new"),
				used: bookParser(selectedBooks,"amazon","used")
			}
		};
	};

	$('#checkout-amazon').click(function(){
		$.ajax({
			type: 'PUT',
			url: 	"/amazonbooks/300",
			data: checkoutData()
		});
	});



});
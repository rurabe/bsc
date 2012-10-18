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
						$(el).children(".amazon-new")
								 .children("span")
								 .html(makeLink(data["new_price"],data["new_link"]))
								 .hide()
								 .fadeIn();
						// Insert amazon used price 
						$(el).children(".amazon-used")
								 .children("span")
								 .html(makeLink(data["used_price"],data["used_link"]))
								 .hide()
								 .fadeIn();
					});
				})

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
	
	$('span:contains(Sold out)').addClass('label')

	var makeLink = function(price,link){
		if (price === 'Sold out') {
			return '<a href=' + link +' target="_blank"><span class="label">' + price + '</span></a>';
		} else if (price) {
			return '<a href=' + link +' target="_blank">' + price + '</a>';
		} else {
			return price;
		}
	};
});
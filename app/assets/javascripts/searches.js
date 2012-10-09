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
	$('.book-amazon').each(function(){
		// Regex to pull the object ID from the #ID attribute
		idFinder = /\d+/;
		
		$.ajax({
			type: 'PUT',
			url: 	"/amazonbooks/" + idFinder.exec(this.id),
			dataType: "html",
			// Set this to el for reference in the callbacks
			el: this,
			success: function(data, textStatus, jqXHR){
				$(this.el.children).fadeOut(function(){
					el = $(this).parent();
					$(this).remove();
					el.html(data).hide().fadeIn();
				});
			},
			error: function(jqXHR, textStatus, errorThrown){
				$(this.el.children).fadeOut(function(){
					el = $(this).parent();
					$(this).remove();
					el.append("N/A").hide().fadeIn();
					console.log(errorThrown);
				});
			}
		});
	});
});
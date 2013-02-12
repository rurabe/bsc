$(document).ready(function(){
	// [----------------------------------------===== #NEW =====----------------------------------------]
	
	// [----------=====About Tab=====----------]
		var aboutOpen = false
		$('#about-handle').click(
			function(){
				if(aboutOpen){
					$('.logo-inner').animate({'margin-top': '-250px'});
					$('.about-info').slideToggle();
					$('.faq-button').fadeOut();
					$(this).fadeOut(200,function(){
						$(this).text("Wait, what's this about again?").fadeIn();
						$('#aboutlink').remove();
					});
				} else {
					$('.logo-inner').animate({'margin-top': '-350px'});
					$('.about-info').slideToggle();
					$(this).fadeOut(200,function(){
						$(this).text("OK, I got it!").fadeIn();
					});
					$('#about-handle').parent().append(
							"<a href='/about'><button class='btn btn-danger faq-button'>Tell me more</button></a>"
						).hide().fadeIn();
					// Do it on load
					resizeExplanationDivs();
					// And do it each time the window resizes
					$(window).resize(resizeExplanationDivs);
				}
				aboutOpen = !aboutOpen
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
			}).carousel('cycle');
			$('#loadingModal').modal('show');
		})

	// [----------=====Keep the divs the same size =====----------]

	  var resizeExplanationDivs = function(){
	 		$('p.about-explanation').map(function(){$(this).removeAttr("style")});
			var sizes = $('p.about-explanation').map(function(){ return $(this).height() }).get();
			var maxSize = Math.max.apply(null,sizes);
			$('p.about-explanation').map(function(){$(this).height(maxSize)});
		}
	
});
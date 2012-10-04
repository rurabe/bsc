$(document).ready(function(){
	// #new
	$('#loadingModal').modal({
		backdrop: 'static',
		keyboard: false,
		show: false
	});

	$('#login-button').click(function(){
		$('#icon-carousel').carousel('cycle')
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
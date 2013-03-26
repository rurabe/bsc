// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # Schools

$(document).ready(function(){

	$('.school-row').hover(function(){
		var color = $(this).attr('data-secondary-color');
		$(this).css('color',color);
	},
	function(){
		var color = $(this).attr('data-primary-color');
		$(this).css('color',color);
	});

  


});
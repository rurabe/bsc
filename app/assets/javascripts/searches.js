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

		// Format bookstore sold outs as labels on load
		$('span:contains(Sold out)').addClass('label')
	
	// [----------=====Async Book Prices=====----------]
	
		// [----------===== ** Helper Methods (Async Book Prices) ** =====----------]

			// Constructor for priceDiv objects, which are called in the ajax callback
			// params = {vendor,vendorId,price,condition, *link}
			var priceDiv = function(div,params){
				return {
					div: 				div,
					vendor: 		params.vendor,
					vendorId: 	params.vendorId,
					condition:	params.condition,
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
						this.changeContent(this.price,function(){
							that.div.removeClass("simple")
						});
						this.setCheckoutLinkHandler();
					},
					expressSoldOut: function(){
						var that = this
						this.changeContent(this.makeLabel(this.price),function(){
							that.div.removeClass("simple")
						});
					},
					makeToggleable: function(){
						this.div.addClass("selectable");
						this.div.click(function(){
							$(this).toggleClass("selected")
							$(this).siblings(".selected").removeClass("selected")
						});
					},
					setCheckoutLinkHandler: function(){
						var vendor = this.vendor
						this.div.click(function(){
							var amazonTarget = priceDivsHeartShapedBox.checkoutData("amazon")
							$('a > #checkout-amazon').unwrap();
							$('#checkout-amazon').wrap(
								'<a href="' + amazonTarget + '" target="_blank" data-method="post" rel="nofollow"/>'
							);
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
						if (this.vendorId){
							if (this.condition === "new") {
								return this.newLink();
							} else {
								return this.usedLink();
							}
						}
					}
				}
			};

			var amazonPriceDiv = function(div,params){
				var obj = priceDiv(div,params);
				return $.extend(obj,{
					price:	function(){
										if (params.vendorId === ""){ return "Not found" }
										else { return params.price}
									}(),
					newLink: function(){
						return "https://www.amazon.com/dp/" + this.vendorId + "?tag=booksupply-20"
					},
					usedLink: function(){
						return "http://www.amazon.com/gp/offer-listing/" + this.vendorId + "?tag=booksupply-20"
					}
				})
			};

			var bnPriceDiv = function(div,params){
				var obj = priceDiv(div,params);
				return $.extend(obj,{
					price:	function(){
										if (params.link === ""){ return "Not found" }
										else { return params.price}
									}(),
					link: function(){
						return params.link
					}
				})
			};

			priceDivsHeartShapedBox = {
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
				},
				selectByClass: function(){
					var that = this
					var args = Array.prototype.slice.call(arguments)
					return args.reduce(function(prev,curr){
						return $.map(prev,function(i){
							if(i.div.attr('class').match(curr)){
								return i;
							}
						});
					}, that.divs);
				},
				getIds: function(collection){
					return collection.map(function(i){
						return i.vendorId;
					});
				},
				request: function(data){
					return window.location.pathname + "/carts?" + $.param(data)
				},
				checkoutData: function(vendor){
					if (vendor === "amazon"){
						var response = { amazon: {} };
						
						var newBooks = this.selectByClass('amazon-new','selected')
						if (newBooks.length != 0) {
							response.amazon.new = this.getIds(newBooks);
						}

						var usedBooks = this.selectByClass('amazon-used','selected')
						if (usedBooks.length != 0) {
							response.amazon.used = this.getIds(usedBooks);
						}

					}	else if (vendor === "bn"){
						var response = { bn: {} };
						
						var newBooks = this.selectByClass('bn-new','selected')
						if (newBooks.length != 0) {
							response.bn.new = this.getIds(newBooks);
						}

					}

					return this.request(response);
				}
			}

	//[----------===== ** Execution code (Async Book Prices) ** =====----------]
		// Ataches the handler to swtich between simple and express mode
		$('#simple').change(function(){
			priceDivsHeartShapedBox.makeSimple();
		});
		$('#express').change(function(){
			priceDivsHeartShapedBox.makeExpress();
		});		

		// Fires off an ajax request for each book, then builds a price div for each
		$('.book-row').each(function(){
			var el = this;

			$.ajax({
				type: 'PUT',
				url: 	"/books/" + this.id.match(/\d+/),
				dataType: "json",
				success: function(data, textStatus, jqXHR){
					newAmazonDiv	= $(el).children(".amazon-new");
					usedAmazonDiv	= $(el).children(".amazon-used");
					newBnDiv			= $(el).children(".bn-new");

					newAmazonPriceDiv = amazonPriceDiv(newAmazonDiv,data.amazon.new);
					newAmazonPriceDiv.toExpressDiv();

					usedAmazonPriceDiv = amazonPriceDiv(usedAmazonDiv,data.amazon.used);
					usedAmazonPriceDiv.toExpressDiv();

					newBnPriceDiv = bnPriceDiv(newBnDiv,data.bn.new);
					newBnPriceDiv.toSimpleDiv();

					priceDivsHeartShapedBox.divs.push(newAmazonPriceDiv,usedAmazonPriceDiv,newBnPriceDiv);
				},
				error: function(jqXHR, textStatus, errorThrown){
					$(el).children(".book-query").each(function(){
						// Fade out the loading divs
						$(this).children(".loading")
									 .fadeOut(function(){
							$(this).parent().html('<span class="label">Error</span>').hide().fadeIn();
							console.log(errorThrown);
						});
					})
				}
			});
		});

});
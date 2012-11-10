$(document).ready(function(){
	// [----------------------------------------===== #NEW =====----------------------------------------]
	
	// [----------=====About Tab=====----------]

		$('#about-handle').toggle(
			function(){
				var el = $(this);
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
					$('#aboutlink').remove();
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
			}).carousel('cycle');
			$('#loadingModal').modal('show');
		})


	// [----------------------------------------===== #SHOW =====----------------------------------------]

		// Format bookstore sold outs as labels on load
		$('span:contains(Sold out)').addClass('label');

	
	// [----------=====Async Book Prices=====----------]
	
		// [----------===== ** Helper Methods (Async Book Prices) ** =====----------]


			// Function to display prices
			var showPrice = function(number){
				return "$" + Number(number).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
			};

			// Constructor for priceDiv objects, which are called in the ajax callback
			// params = {vendor,vendorId,price,condition, *link}
			var priceDiv = function(params){
				return {
					div: 				params.div,
					vendor: 		params.vendor,
					vendorId: 	params.vendorId,
					condition:	params.condition,
					price:			function(){
												if ( params.vendorId === null ){ return "Not found" }
												else if ( params.price == null ){ return "Sold out" }
												else { return showPrice(params.price) }
											}(),
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
						if (this.price === "Sold out" || this.price === "Not found"){
							this.expressSoldOut();
						} else {
							this.expressPrice();
						}
					},
					expressPrice: function(){
						var that = this
						this.makeToggleable();
						this.div.addClass("selectable")
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
						var that = this
						this.div.click(function(){
							that.amazonCheckoutBehavior();
							that.bnCheckoutBehavior();
						});
					},
					amazonCheckoutBehavior: function(){
						var amazonTarget = priceDivsHeartShapedBox.amazonCheckoutData();
							$('a > #checkout-amazon').unwrap();
						if (amazonTarget){
							$('#checkout-amazon').wrap(
								'<a href="' + amazonTarget + '" target="_blank" data-method="post" rel="nofollow"/>'
							);
						}
					},
					bnCheckoutBehavior: function(){
						var bnTarget = priceDivsHeartShapedBox.bnCheckoutData();
							$('a > #checkout-bn').unwrap();
						if (bnTarget) {
							$('#checkout-bn').wrap(
								'<a href="' + bnTarget + '" target="_blank" rel="nofollow"/>'
							);
						}
					},
					makeLinkable: function(content){
						return '<a href=' + this.link() + ' target="_blank">' +
							content
						+ '</a>'
					},
					makeLabel: function(content){
						return '<span class="label">' + content + '</span>'
					},
					title: function(){
						return this.div.siblings('.book-title').children('span').text()
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

			var amazonPriceDiv = function(params){
				var obj = priceDiv(params);
				var thisDiv = $.extend(obj,{
					asin: params.asin,
					newLink: function(){
						return "https://www.amazon.com/dp/" + this.asin + "?tag=booksupply-20"
					},
					usedLink: function(){
						return "http://www.amazon.com/gp/offer-listing/" + this.asin + "?tag=booksupply-20"
					}
				})
				priceDivsHeartShapedBox.divs.push(thisDiv);
				return thisDiv;
			};

			var bnPriceDiv = function(params){
				var obj = priceDiv(params);
				var thisDiv = $.extend(obj,{
					productCode: function(){
						if(this.condition === "new") { return "BK" }
						else if (this.condition === "used") { return "MP" }
					},
					newLink: function(){
						return "http://click.linksynergy.com/deeplink?mid=36889&id=BF/ADxwv1Mc&murl=http%3A%2F%2Fwww.barnesandnoble.com%2Fean%2F" + this.vendorId
					},
					usedLink: function(){
						return "http://click.linksynergy.com/deeplink?mid=36889&id=BF/ADxwv1Mc&murl=http%3A%2F%2Fwww.barnesandnoble.com%2Flisting%2F" + this.vendorId
					},
					makeCartLinkable: function(content){
						return '<a href="' + this.cartLink() + '" target="_blank">' +
							content + 
						'</a>'
					},


				})
				priceDivsHeartShapedBox.divs.push(thisDiv);
				return thisDiv;
			};

			priceDivsHeartShapedBox = {
				divs: [],
				makeSimple: function(filter){
					$.each(this.selectByClass(filter),function(){
						this.toSimpleDiv();
					});
					$("#checkout-amazon").slideUp();
					$("#checkout-bn").slideUp();
				},
				makeExpress: function(filter){
					$.each(this.selectByClass(filter),function(){
						this.toExpressDiv();
					});
					$("#checkout-amazon").slideDown();
					$("#checkout-bn").slideDown();
				},
				selectByClass: function(){
					var that = this
					var args = Array.prototype.slice.call(arguments)
					return args.reduce(function(subset,className){
						return $.map(subset,function(e){
							if(e.div.attr('class').match(className)){
								return e;
							}
						});
					}, that.divs);
				},
				getIds: function(collection){
					return collection.map(function(i){
						return i.vendorId;
					});
				},
				amazonCheckoutData: function(){
					var response = {amazon:{}};
					
					var newBooks = this.selectByClass('amazon-new','selected')
					if (newBooks.length != 0) {
						response.amazon.new = this.getIds(newBooks);
					}

					var usedBooks = this.selectByClass('amazon-used','selected')
					if (usedBooks.length != 0) {
						response.amazon.used = this.getIds(usedBooks);
					}

					if ( newBooks.length != 0 || usedBooks.length != 0 ){
						return window.location.pathname + "/carts?" + $.param(response);
					}
				},
				bnCheckoutData: function(){
					var bnBooks = this.selectByClass("book-bn","selected")
					if ( bnBooks.length != 0 ) {
						var paramsString = bnBooks.reduce(function(a,e,i){
								a.push( "ean" + (i+1) + "=" + e.vendorId + "&productcode" + (i+1) + "=" + e.productCode() + "&qty" + (i+1) + "=1" )
								return a
						},[]).join("&")

						return "http://cart4.barnesandnoble.com/op/request.aspx?" + paramsString + "&stage=fullCart&uiaction=multAddMoreToCart"
					}
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

		$.ajax({ // Amazon
			type: 'PUT',
			dataType: "json",
			data: {vendor: "amazon"},
			success: function(data, textStatus, jqXHR){
				var a = this;
				$.each(data,function(){
					amazonPriceDiv(a.amazonData(this,"new"));
					amazonPriceDiv(a.amazonData(this,"used"));
				});

				priceDivsHeartShapedBox.makeExpress('book-amazon');
			},
			error: function(jqXHR, textStatus, errorThrown){
				$(".book-amazon").each(function(){
					// Fade out the loading divs
					$(this).children(".loading")
								 .fadeOut(function(){
						$(this).parent().html('<span class="label">Error</span>').hide().fadeIn();
						console.log(errorThrown);
					});
				})
			},
			amazonData: function(data,condition){
				return {
					div: $("#amazon-" + condition + "-" + data.id),
					vendor: "amazon",
					vendorId: data.ean,
					price: data["amazon_" + condition +"_price"],
					condition: condition,
					asin: data.asin
				}
			}
		});

		$.ajax({ // Barnes and Noble
			type: 'PUT',
			dataType: "json",
			data: {vendor: "bn"},
			success: function(data, textStatus, jqXHR){
				var a = this;
				$.each(data,function(){
					bnPriceDiv(a.bnData(this,"new"))
				});

				priceDivsHeartShapedBox.makeExpress('bn-new');
			},
			error: function(jqXHR, textStatus, errorThrown){
				$(".book-bn").each(function(){
					// Fade out the loading divs
					$(this).children(".loading")
								 .fadeOut(function(){
						$(this).parent().html('<span class="label">Error</span>').hide().fadeIn();
						console.log(errorThrown);
					});
				})
			},
			bnData: function(data,condition){
				return {
					div: $("#bn-" + condition + "-" + data.id),
					vendor: "bn",
					vendorId: data.ean,
					price: data["bn_" + condition +"_price"],
					condition: condition
				}
			},
		});

		$('.bn-used').each(function(){
			var div = $(this);
			$.ajax({ // Barnes and Noble
				type: 'PUT',
				url: '/books/' + $(div).attr('id').match(/used-(\d+)/)[1],
				dataType: "json",
				success: function(data, textStatus, jqXHR){
					var priceDiv = bnPriceDiv(this.bnData(data,"used"));
					priceDiv.toExpressDiv();				
				},
				error: function(jqXHR, textStatus, errorThrown){
					
						// Fade out the loading divs
					$(this).children(".loading")
								 .fadeOut(function(){
						$(this).parent().html('<span class="label">Error</span>').hide().fadeIn();
						console.log(errorThrown);
					});
				},
				bnData: function(data,condition){
					return {
						div: div,
						vendor: "bn",
						vendorId: data.bn_used_ean,
						price: data["bn_" + condition +"_price"],
						condition: condition
					}
				},
			});
		});

		
});
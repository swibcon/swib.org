/* programme.js */

$(document).ready(function() {
	$(".conference .abstract p").hide();
	$(".conference .abstract h4 a, .conference .abstract h5 a").addClass("closed");
	$(".programme #col_left .navi + h2").after('<p class="abstract_button show_all"><a href="#" class="closed">show all abstracts</a></p>');

	$('.abstract_header a').click(function(){
		var id = $(this).attr('href');
		$(id).slideToggle("slow");
		$(this).toggleClass("closed");
		return false; //Prevent the browser jump to the link anchor
	});


	$(".abstract_button a").click(function() {
		if($(this).parent("p").hasClass("show_all")) {
			$(".abstract p").show().prev().find("a").removeClass("closed");
			$(this).text("Hide all abstracts").removeClass("closed").parent("p").removeClass("show_all").addClass("hide_all");
		}
		else {
			$(".abstract p").hide().prev().find("a").addClass("closed");
			$(this).text("Show all abstracts").addClass("closed").parent("p").removeClass("hide_all").addClass("show_all");
		}


	});



});



		// $(this).addClass("show").text("show all abstracts").parent("p").removeClass("hide_all").addClass("show_all");
		// $(".conference .abstract p").hide();
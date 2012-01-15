$(document).ready(function(){
	$("#add-new-price").click(function(){
		clone = $(".form-price-wrapper").eq(0).clone()
		clone.find("input").val("");
		clone.appendTo("#form-prices-wrapper");
		return false;
	});
});
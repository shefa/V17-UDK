Graph = function() {
	function init()
	{
		//console.log("im alive");
		//console.log("trying some stuff");
		// TODO move lib in libs folder
		//import 'd3.v3.min.js';  
		//document.getElementsByTagName('body')[0].style.setProperty("color", "white", null);
		import d3 from 'd3'; 
		//d3.select("body").style("color", "white");
		console.log("imported");
		console.log("altering window");
		Meteor.shit = d3;
		//console.log(Meteor.shit);
		//console.log(d3.select("#some_info_block"));
		d3.select("#some_info_block").style("background-color","black");
	}

	return {
		init: init
	};
}();
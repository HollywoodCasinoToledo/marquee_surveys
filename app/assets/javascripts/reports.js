$(document).ready(function() {

	function getColorPallete(answerCount) {
		var uses_rates = $('#colorize_rates').val() == 'true'
		if (uses_rates) {
			switch (answerCount) {
				case 5:
					return ['#35ad05', '#b8e7a5', '#eccf8a', '#ff674c', '#b91c00'];
				case 3:
					return ['#b8e7a5', '#eccf8a', '#ff674c'];
				case 2:
					return ['#b8e7a5', '#ff674c'];
				default:
					return ['#b8e7a5', '#eccf8a', '#ff674c', '#7fa7dd', '#23416b'];
			}
		} else {
			return ['#b8e7a5', '#7fa7dd', '#eccf8a', '#ff674c', '#23416b'];
		}

	}
	

	try {

		var total = document.getElementById('total_responses').innerHTML;

		var goVertical = false;
		if (document.getElementById('responses_data_table').rows.length > 6) {
			goVertical = true;
		}

		function getOverallData() {
			var data = [];
			var table = document.getElementById('responses_data_table');

			var total = 0;
			if (table != undefined) {
				for (i=0; i < table.rows.length; i++) {
					data.push({ 'label' : table.rows[i].cells[0].innerHTML,'value' : (parseInt(table.rows[i].cells[1].innerHTML))});
				}
			}
			formattedData = data;
			return formattedData;
		}

		var overallData = getOverallData();

		if (goVertical) {
			new Morris.Bar({
			  element: 'responses_bar',
			  data: overallData,
				barColors: ['#a5371f'],
				resize: true,
				barSizeRatio: .6,
				hideHover: 'auto',
			  xkey: 'label',
			  ykeys: ['value'],
			  xLabelAngle: 90,
			  labels: ['Votes']
			});
		}
		else {
			new Morris.Bar({
			  element: 'responses_bar',
			  data: overallData,
				barColors: ['#a5371f'],
				resize: true,
				hideHover: 'auto',
				barSizeRatio: .5,
			  xkey: 'label',
			  ykeys: ['value'],
			  labels: ['Votes']
			});
		}

		Morris.Donut({
	  element: 'responses_pie',
	  data: overallData,
	  resize: true,
	  colors: getColorPallete(overallData.length),
	  formatter: function (y, data) { return ((y / total) * 100).toFixed(2) + "%"}
		});

	} catch (ex) {
		console.log('Reporting JS Error:', ex);
	}


	try {

		var goVertical = false;
		if (document.getElementById('responses_date_data_table').rows.length > 8) {
			goVertical = true;
		}

		function votingDateData() {
			var data = [];
			var table = document.getElementById('responses_date_data_table');
			var answer_count = document.getElementById('responses_data_table').rows.length;
			var total = 0;
			if (table != undefined) {
				
				for (i=1; i < table.rows.length; i++) {
					answer_hash = {};
					answer_hash['label'] = table.rows[i].cells[0].innerHTML;
					
					for (j=2; j < answer_count+2; j++) {
						answer_hash[table.rows[0].cells[j].innerHTML] = parseInt(table.rows[i].cells[j].innerHTML);
					}
					data.push(answer_hash);
				}
			}
			formattedData = data;
			return formattedData;
		}

		function getLabels() {
			var labels = [];
			var table = document.getElementById('responses_date_data_table');
			var answer_count = document.getElementById('responses_data_table').rows.length;
			for (j=2; j < answer_count+2; j++) {
				labels.push(table.rows[0].cells[j].innerHTML);
			}
			return labels;
		}


		var labelArray = getLabels();
		if (goVertical) {
			new Morris.Bar({
				  element: 'responses_line',
				  data: votingDateData(),
					barColors: getColorPallete(labelArray.length),
					resize: true,
					stacked: true,
					barSizeRatio: .6,
					hideHover: 'auto',
				  xkey: 'label',
				  ykeys: labelArray,
				  xLabelAngle: 90,
				  labels: labelArray
				});
		}
		else {
			new Morris.Bar({
				  element: 'responses_line',
				  data: votingDateData(),
					barColors: getColorPallete(labelArray.length),
					resize: true,
					stacked: true,
					barSizeRatio: .6,
					hideHover: 'auto',
				  xkey: 'label',
				  ykeys: labelArray,
				  labels: labelArray
				});
		}

	} catch (ex) {
		console.log('Reporting JS Error:', ex);
	}




	
	

});
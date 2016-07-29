$(document).ready(function() {
  var size = $('.carousel .item').size();
  $('.carousel .item').each(function(){

    var next = $(this).next();
    if (!next.length) {
      next = $(this).siblings(':first');
    }
    if (!next.children(':first-child').attr('class').includes('glyphicon')) {
      next.children(':first-child').clone().appendTo($(this));
    } else {
      next = $('.carousel .item').first();
      next.children(':first-child').clone().appendTo($(this));
    }
  
    if (next.next().length > 0) {
        if (!next.next().children(':first-child').attr('class').includes('glyphicon')) {
          next.next().children(':first-child').clone().appendTo($(this));
	} else {
	  next = $('.carousel .item').first();
	  next.next().children(':first-child').clone().appendTo($(this));
	} 
    } 
    else {
	  if (size > 3){
            $(this).siblings(':first').children(':first-child').clone().appendTo($(this));
	  }
    }
  });
});

function multiLineChart(xAxis, users, contributions, redemptions){
  $('#points-chart-container').highcharts({
    chart: {
      type: 'bar'
    },
    title: {
      text: 'CodeCuriosity Usage Trend',
      x: -20 //center
    },
    subtitle: {
      text: 'Last Six Months',
      x: -20
    },
    xAxis: {
      categories: xAxis
    },
    plotOptions: {
      bar: {
        dataLabels: {
          enabled: true
        }
      }
    },
    yAxis: {
      title: {
        text: 'Count'
      },
      plotLines: [{
        value: 0,
        width: 1,
        color: '#808080'
      }]
    },
    tooltip: {
      valueSuffix: ''
    },
    legend: {
      layout: 'horizontal',
      align: 'center',
      verticalAlign: 'bottom',
      borderWidth: 0
    },
    series: [{
      name: 'Users',
      data: users,
      marker: { enabled: false },
      color: '#3C8DBC',
      dataLabels: {color:'#3C8DBC',style: {"color": "contrast", "fontSize": "11px", "fontWeight": "bold", "textShadow": "0" }}
    }, {
      name: 'Contributions',
      data: contributions,
      marker: { enabled: false },
      color: '#00A65A',
      dataLabels: {color:'#00A65A',style: {"color": "contrast", "fontSize": "11px", "fontWeight": "bold", "textShadow": "0" }}
    }, {
      name: 'Redemptions',
      data: redemptions,
      marker: { enabled: false },
      color: '#F39C12',
      tooltip: {
        valuePrefix: '$'
      }, 
      dataLabels: {color:'#F39C12',style: {"color": "contrast", "fontSize": "11px", "fontWeight": "bold", "textShadow": "0" }}
    }] 
  });  
} 

function lineChart(xAxis, trendData, title, subTitle, divId, legendName, lineColor){
  $(divId).highcharts({
    chart: {
      type: 'line'
    },
    title: {
      text: title,
      x: -20 //center
    },
    subtitle: {
      text: subTitle,
      x: -20
    },
    xAxis: {
      categories: xAxis
    },
    plotOptions: {
      line: {
        dataLabels: {
          enabled: false
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
      name: legendName,
      data: trendData,
      marker: { enabled: false },
      color: lineColor,
      dataLabels: {color:'#3C8DBC',style: {"color": "contrast", "fontSize": "11px", "fontWeight": "bold", "textShadow": "0" }}
    }] 
  });  
} 

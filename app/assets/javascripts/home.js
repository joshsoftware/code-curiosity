function userTrendChart(xAxis, commits, activities, points) {
  $('#users-chart-container').highcharts({
    chart: {
      type: 'line'
    },  
    title: {
      text: 'Your Contribution Trend',
      x: -20 //center
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
      name: 'Commits',
      data: commits,
      marker: { enabled: false },
      color: '#00A65A',
      dataLabels: {color:'#00A65A',style: {"color": "contrast", "fontSize": "11px", "fontWeight": "bold", "textShadow": "0" }}
    }, {
      name: 'Activities',
      data: activities,
      marker: { enabled: false },
      color: '#F39C12',
      dataLabels: {color:'#F39C12',style: {"color": "contrast", "fontSize": "11px", "fontWeight": "bold", "textShadow": "0" }}
    }, {
      name: 'Points',
      data: points,
      marker: { enabled: false },
      color: '#00C0EF',
      dataLabels: {color:'#00C0EF',style: {"color": "contrast", "fontSize": "11px", "fontWeight": "bold", "textShadow": "0" }}
    } 
    ]
  });
}
function multiLineChart(xAxis, users, contributions){
  $('#chart-container').highcharts({
    chart: {
      type: 'line'
    },
    title: {
      text: 'CodeCuriosity Impact',
      x: -20 //center
    },
    subtitle: {
      text: 'Linear growth in users has exponential growth in contributions!',
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
    }
    ] 
  });
}

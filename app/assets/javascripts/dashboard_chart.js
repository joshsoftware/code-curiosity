function initDashboardChart(options){
  $('#stats.input-daterange').datepicker({
    format: 'dd/mm/yyyy',
    endDate: new Date()
  });

  $('#chart-container').highcharts({
    chart: {
        type: 'column'
    },
    title: {
        text: options.title 
    },
    xAxis: {
        categories: options.teams 
    },
    yAxis: {
        min: 0,
        title: {
            text: 'Total commits'
        },
        stackLabels: {
            enabled: true,
            style: {
                fontWeight: 'bold',
                color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
            }
        }
    },
    tooltip: {
        headerFormat: '<b>{point.x}</b><br/>',
        pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
    },
    plotOptions: {
        column: {
            stacking: 'normal',
            dataLabels: {
                enabled: true,
                color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white',
                style: {
                    textShadow: '0 0 3px black'
                }
            }
        }
    },
    series: options.series
});
}


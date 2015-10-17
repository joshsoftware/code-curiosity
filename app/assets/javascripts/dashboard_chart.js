function initDashboardChart(options){
  $(options.startDateEle).datepicker({format: 'dd/mm/yyyy', defaultDate: options.startDate});
  $(options.endDateEle).datepicker({format: 'dd/mm/yyyy', defaultDate: options.endDate});

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
        legend: {
            align: 'right',
            x: -30,
            verticalAlign: 'top',
            y: 25,
            floating: true,
            backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
            borderColor: '#CCC',
            borderWidth: 1,
            shadow: false
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


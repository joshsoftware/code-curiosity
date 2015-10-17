function initDashboardChart(options){
  $(options.startDateEle).datepicker({format: 'dd/mm/yyyy', defaultDate: options.startDate});
  $(options.endDateEle).datepicker({format: 'dd/mm/yyyy', defaultDate: options.endDate});

  $(function () { 
    $('#chart-container').highcharts({
      chart: {
        type: 'column',
        inverted: options.inverted
     },
      title: {
       text: options.title
     },
      xAxis: {
        type: 'category',
     },
      yAxis: {
        title: {
        text: 'Commits Count'
       }
     },
     legend: {
       enabled: false
     },
     plotOptions: {
       series: {
         borderWidth: 0,
         dataLabels: {
           enabled: true                  
        }
      }
    },
     series: [{ name: "Commits",
               colorByPoint: true,
               data: options.data
             }]
    });
  });
}

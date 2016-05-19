function showPointsChart(round, points, user_points){
  if(points[points.lenght - 1] != 1){
    points.push(1);
  }

  if(user_points || user_points == 0){
    $.each(points, function(index, value){
      if(value == user_points){
        points[index] = { y: points[index], color: 'red' }
      }
    });
   }

   $('#points-chart-container').highcharts({
        title: {
            text: '' //'Points for ' + round
        },
        xAxis: {
          tickInterval: 1
        },
        yAxis: {
          type: 'logarithmic',
          minorTickInterval: 1,
          min: 1,
          title: {
            enabled: true,
            text: 'Points'
          }
        },
        tooltip: {
            headerFormat: '<b>{series.name}</b><br/>',
            pointFormat: '{point.y} points'
        },
        series: [{
          name: 'Points Distribution',
          data: points,
          pointStart: 1 
        }]
    });
}


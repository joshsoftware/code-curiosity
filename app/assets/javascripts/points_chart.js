function showPointsChart(round, points, user_points){
  points.push(0);

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
          minorTickInterval: 1
        },
        tooltip: {
            headerFormat: '<b>{series.name}</b><br/>',
            pointFormat: '{point.y} points'
        },
        series: [{
          name: 'Points',
          data: points,
          pointStart: 1 
        }]
    });
}


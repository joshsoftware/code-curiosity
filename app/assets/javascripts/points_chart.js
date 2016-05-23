function showPointsChart(round, all_points, user_points){
  var tickInterval = 1;
  var pointGroups = buildPointGroups(all_points);
  var profilePic = $('#profile-pic').attr('src') + '&s=25';

  points = uniqueValues(all_points);
  
  if(points[points.length - 1] != 1){
    points.push(1);
  }

  $.each(points, function(index, value){
    if(value == user_points){
        points[index] = {
          y: points[index], color: 'red', 
          marker: { 
            enabled: true, 
            symbol: 'url('+ profilePic  +')' 
          } 
        }
    }
  });

  if(points.length > 10){
    tickInterval = parseInt(points.length/10);
  }

 $('#points-chart-container').highcharts({
    title: {
      text: '' //'Points for ' + round
    },
    xAxis: {
      tickInterval: tickInterval
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
      formatter: function() {
        return '<b>Points</b>: '+ this.y+ '<br/><b>Users</b>: ' + pointGroups[this.y];
      }
    },
    series: [{
      name: 'Users',
      data: points,
      pointStart: 1,
      marker: { enabled: false }
    }]
  
  });
}

function uniqueValues(array) {
  return $.grep(array, function(el, index) {
    return index === $.inArray(el, array);
  });
}


function buildPointGroups(points){
  var groups = {};

  for(var i = 0, l = points.length; i < l; i++){
    groups[points[i]] = (groups[points[i]] || 0) + 1;
  }

  return groups;
}

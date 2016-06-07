function showPointsChart(round, all_points, user_points){
  var points = uniqueValues(all_points);
  var pointGroups = buildPointGroups(all_points);
  var profilePic = $('#profile-pic').attr('src') + '&s=25';
  var tickInterval = 1;

  $.each(points, function(index, value){
    if(value == user_points){
        points[index] = {
          y: points[index],
          marker: {
            enabled: true,
            symbol: 'url('+ profilePic  +')',
            width: 25,
            height: 25
          }
      }
    }
  });

  $('#points-chart-container').highcharts({
      title: {
        text: ''
      },

      xAxis: {
        tickInterval: tickInterval,
        labels: {
          enabled: false
        }
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
          showInLegend: false,
          pointStart: 1,
          marker: { enabled: false },
          data: points
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

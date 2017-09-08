class SubscriptionsHistory extends React.Component {
  constructor(props) {
    super(props);
    this.state = { subscriptions: [] };
  }

  componentDidMount() {
    $.ajax({
      type: 'GET',
      url: '/subscriptions',
      data: {id: this.props.user_id },
      dataType: 'JSON',
      success: (data) => { this.setState({ subscriptions: data }); },
        error: function(error){ alert('Error!'); },
      beforeSend: function(xhr){ xhr.setRequestHeader('Accept', 'application/vnd.codecuriosity.org; version=1'); }
    });
  }

  render () {
    return (
      <table className="table table-bordered">
        <thead>
          <tr>
            <th className="col-xs-1">#</th>
            <th>Name</th>
            <th className="col-xs-2">Commits</th>
            <th className="col-xs-2">Activities</th>
            <th className="col-xs-2">Points</th>
          </tr>
        </thead>
        <tbody>
          {
            this.state.subscriptions.map(function(subscription, index){
              return <SubscriptionsHistoryRow key={subscription.id} index={index + 1} roundDate={subscription.round_date}
                commits={subscription.commits_count} activities={subscription.activities_count} points={subscription.points}/>
            })
          }
        </tbody>
      </table>
    );
  }
}


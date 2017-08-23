class PointsHistory extends React.Component {
  constructor(props) {
    super(props);
    this.state = { transactions: [] };
  }

  componentDidMount() {
    $.ajax({
      type: 'GET',
      url: '/transactions',
      data: { id: this.props.user_id },
      dataType: 'JSON',
      success: (data) => { this.setState({ transactions: data }); },
        error: function(error){ alert('Error!'); },
      beforeSend: function(xhr){ xhr.setRequestHeader('Accept', 'application/vnd.codecuriosity.org; version=1'); }
    });
  }

  render() {
    var rows = [];
    this.state.transactions.map(function(transaction, index){
      rows.push(<PointsHistoryRow key={transaction.id} show_coupon_code={this.props.show_coupon_code} index={index + 1} points={transaction.points} 
        details={transaction.transaction_type} label={transaction.type} date={transaction.created_at} coupon_code={transaction.coupon_code}
        redeem_request_retailer={transaction.redeem_request_retailer} />);
    }.bind(this));
    return (
      <table className="table table-bordered">
        <thead>
          <tr>
            <th className="col-xs-1">#</th>
            <th className="col-xs-3">Points</th>
            <th>Detail</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          {
            rows
          }
          <tr>
            <td>
              <b>Total</b>
            </td>
            <td colSpan="4">{ this.props.total_points }</td>
          </tr>
        </tbody>
      </table>
    );
  }
}

class PointsHistoryRow extends React.Component {
  render() {
    return (
      <tr>
        <td>{ this.props.index }</td>
        <td>{ "$ " + Math.abs(this.props.amount) }</td>
        <td className="transaction-detail">
          <b>{ this.props.details }</b>{` `}
          <small className={`label ${this.props.label == 'credit' ? 'bg-green' : 'bg-red' }`}>{ this.props.label.toUpperCase() }</small>
          { this.props.show_coupon_code && this.props.coupon_code ? (<h5>Coupon Code:<i>{ this.props.coupon_code }</i></h5>) : (null) }
          { this.props.redeem_request_retailer ? (<small className='label bg-primary'> {this.props.redeem_request_retailer.toUpperCase()} </small>) : (null) }
        </td>
        <td>{ this.props.date }</td>
      </tr>
    );
  }
}

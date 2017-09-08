class SubscriptionsHistoryRow extends React.Component {
  constructor(props) {
    super(props);
  }

  render () {
    return (
      <tr>
        <td>{ this.props.index }</td>
        <td>{ this.props.roundDate }</td>
        <td>{ this.props.commits }</td>
        <td>{ this.props.activities }</td>
        <td>{ this.props.points }</td>
      </tr>
    );
  }
}


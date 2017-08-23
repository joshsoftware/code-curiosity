class UserPointsChart extends React.Component {
  constructor(props) {
    super(props);
  }

  componentDidMount() {
    userTrendChart(this.props.xAxis, this.props.commits, this.props.activities, this.props.points, this.props.username);
  }

  render () {
    return (
      <div className='box-body'>
        <div id='users-chart-container'>
        </div>
      </div>
    );
  }
}


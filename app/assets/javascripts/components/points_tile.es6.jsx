class PointsTile extends React.Component {
  constructor(props){
    super(props);
  }

  render(){
    return (
      <div className={`small-box ${this.props.color}`}>
        <div className="inner">
          <h3>{ this.props.points }</h3>
          <p>{ this.props.title }</p>
        </div>
        <div className="icon">
          <i className={`ion ${this.props.logo}`}></i>
        </div>
        <a className="small-box-footer" href={ this.props.path }>More info
          <i className="fa fa-arrow-circle-right"></i>
        </a>
      </div>
    );
  }
}

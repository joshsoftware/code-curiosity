var CelebrityBox = React.createClass({
  render: function() {
    return (
      <section>
        <div className="callout-info col-xs-12">
          <div className={`callout callout-${this.props.type}`}>
            <button className="close" data-dismiss="callout">×</button>
            { this.props.title ? (<h4> { this.props.title } </h4>) : (null) }
            <p> { this.props.message } </p>
          </div>
        </div>
      </section>
    );
  }
});

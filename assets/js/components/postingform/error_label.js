import React, { PureComponent } from "react";

export default class ErrorLabel extends PureComponent {
  render() {
    const error = (this.props.errors || {})[this.props.for];

    return (
      <label htmlFor={this.props.for}>
        {this.props.children}
        {error && <> <span className="help error">{error}</span></>}
      </label>
    );
  }
}

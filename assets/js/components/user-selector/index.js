import React from "react";

import SingleUserSelector from "./single_user_selector";
import MultiUserSelector from "./multi_user_selector";

export default class UserSelector extends React.Component {
  render() {
    if (this.props.single) {
      return <SingleUserSelector {...this.props} />;
    } else {
      return <MultiUserSelector {...this.props} />;
    }
  }
}

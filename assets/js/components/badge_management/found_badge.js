import React from "react";

import { t } from "../../modules/i18n";

class FoundBadge extends React.Component {
  render() {
    return (
      <li>
        {this.props.badge.name}{" "}
        <button type="button" className="cf-index-btn" onClick={() => this.props.selectBadge(this.props.badge)}>
          {t("select badge")}
        </button>
      </li>
    );
  }
}

export default FoundBadge;

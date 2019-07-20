import React from "react";
import { t } from "../../modules/i18n";

class Badge extends React.Component {
  render() {
    const badge = this.props.badge;
    const nam = `user[badges_users][${this.props.index}]`;

    return (
      <div className="cf-cgroup">
        <input type="hidden" name={`${nam}[active]`} value={badge.active ? "1" : "0"} />
        <input type="hidden" name={`${nam}[badge_id]`} value={badge.badge_id} />
        <input type="hidden" name={`${nam}[user_id]`} value={this.props.userId} />

        <div className="label">{badge.name}</div>
        <label className="check">
          <input type="checkbox" checked={badge.active} onChange={() => this.props.changeActive(badge)} /> {t("active")}{" "}
          <button type="button" onClick={() => this.props.deleteBadge(badge)} className="cf-destructive-index-btn">
            {t("delete")}
          </button>
        </label>
      </div>
    );
  }
}

export default Badge;

import React from "react";
import { t } from "../../modules/i18n";

export default class Tag extends React.Component {
  render() {
    return (
      <li className={this.props.error ? " has-error" : ""}>
        <div className="cf-tag">
          {this.props.tag}

          <button
            type="button"
            className="remove"
            aria-label={t("remove tag {tag}", { tag: this.props.tag })}
            onClick={this.props.onClick}
          >
            <svg width="22" height="14" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg">
              <use xlinkHref="#svg-remove" />
            </svg>
          </button>

          <input type="hidden" name={this.props.name || "message[tags][]"} value={this.props.tag} />
        </div>

        {this.props.error}
      </li>
    );
  }
}

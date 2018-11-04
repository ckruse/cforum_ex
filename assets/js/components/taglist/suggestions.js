import React from "react";
import { CSSTransitionGroup } from "react-transition-group";

import { t } from "../../modules/i18n";

class Suggestions extends React.Component {
  render() {
    return (
      <div className="cf-cgroup">
        <label>{t("tag suggestions")}</label>

        <CSSTransitionGroup
          component="ul"
          className="cf-cgroup cf-form-tagslist cf-tags-list"
          aria-live="polite"
          transitionName="fade-in"
          transitionEnterTimeout={300}
          transitionLeaveTimeout={300}
        >
          {this.props.suggestions.length == 0 && (
            <li>
              <em>{t("no tag suggestions available")}</em>
            </li>
          )}

          {this.props.suggestions.map(tag => (
            <li className="cf-tag" key={tag.tag_id}>
              {tag.tag_name}{" "}
              <button
                type="button"
                className="add"
                aria-label={t("add tag")}
                onClick={() => this.props.onClick(tag.tag_name)}
              >
                <svg width="22" height="14" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg">
                  <use xlinkHref="#svg-check-mark" />
                </svg>
              </button>
            </li>
          ))}
        </CSSTransitionGroup>
      </div>
    );
  }
}

export default Suggestions;

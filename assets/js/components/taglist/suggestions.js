import React from "react";

import { t } from "../../modules/i18n";

export default function Suggestions({ suggestions, onClick }) {
  const svg = (
    <svg width="22" height="14" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg">
      <use xlinkHref="/images/icons.svg#svg-check-mark" />
    </svg>
  );

  return (
    <>
      <h3 className="cf-posting-form-section-header">{t("tag suggestions")}</h3>

      <div className="cf-cgroup">
        <span className="label" id="add-tag-suggestion-help">
          {svg} {t("click to add tag")}
        </span>

        <ul className="cf-cgroup cf-form-tagslist cf-tags-list" aria-live="polite">
          {suggestions.length === 0 && (
            <li key="no-suggestion-found">
              <em>{t("no tag suggestions available")}</em>
            </li>
          )}

          {suggestions.map((tag) => (
            <li className="cf-tag" key={tag.tag_id}>
              {tag.tag_name}
              <button
                type="button"
                className="add"
                aria-labelledby="add-tag-suggestion-help"
                onClick={() => onClick(tag.tag_name)}
              >
                {svg}
              </button>
            </li>
          ))}
        </ul>
      </div>
    </>
  );
}

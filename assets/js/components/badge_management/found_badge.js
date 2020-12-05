import React from "react";

import { t } from "../../modules/i18n";

export default function FoundBadge({ badge, selectBadge }) {
  return (
    <li>
      {badge.name}{" "}
      <button type="button" className="cf-index-btn" onClick={() => selectBadge(badge)}>
        {t("select badge")}
      </button>
    </li>
  );
}

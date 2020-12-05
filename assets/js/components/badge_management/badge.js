import React from "react";
import { t } from "../../modules/i18n";

export default function Badge({ badge, index, userId, changeActive, deleteBadge }) {
  const nam = `user[badges_users][${index}]`;

  return (
    <div className="cf-cgroup">
      <input type="hidden" name={`${nam}[active]`} value={badge.active ? "1" : "0"} />
      <input type="hidden" name={`${nam}[badge_id]`} value={badge.badge_id} />
      <input type="hidden" name={`${nam}[user_id]`} value={userId} />

      <div className="label">{badge.name}</div>
      <label className="check">
        <input type="checkbox" checked={badge.active} onChange={() => changeActive(badge)} /> {t("active")}{" "}
        <button type="button" onClick={() => deleteBadge(badge)} className="cf-destructive-index-btn">
          {t("delete")}
        </button>
      </label>
    </div>
  );
}

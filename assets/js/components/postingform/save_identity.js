import React from "react";
import { t } from "../../modules/i18n";

export default function SaveIdentity(props) {
  return (
    <fieldset>
      <div className="cf-cgroup">
        <label className="checkbox">
          <input
            name="message[save_identity]"
            type="checkbox"
            checked={props.saveIdentity}
            value={true}
            onChange={() => props.onChange(!props.saveIdentity)}
          />{" "}
          {t("save my identity in a cookie")}
        </label>

        <p className="help-text">{t("identity description")}</p>
      </div>
    </fieldset>
  );
}

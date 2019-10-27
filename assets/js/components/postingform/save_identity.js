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

        <p className="help-text">
          Ihre Identität in einem Cookie zu speichern erlaubt es Ihnen, Ihre Beiträge zu editieren. Außerdem müssen Sie
          dann bei neuen Beiträgen nicht mehr die Felder Name, Email und Homepage ausfüllen.
        </p>
      </div>
    </fieldset>
  );
}

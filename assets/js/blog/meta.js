import React, { useState } from "react";
import ErrorLabel from "../components/postingform/meta/error_label";
import { hasErrorClass } from "../components/postingform/meta/utils";
import { t } from "../modules/i18n";

export default function Meta({ subject, email, homepage, thumbnailAlt, errors, onChange }) {
  const [touched, setTouched] = useState({});

  const values = {
    message_subject: subject,
    message_email: email,
    message_homepage: homepage,
    message_thumbnail_alt: thumbnailAlt,
  };

  function setFieldTouched(ev) {
    const name = ev.target.name.replace(/\[/, "_").replace(/\]$/, "");
    setTouched({ ...touched, [name]: true });
  }

  return (
    <fieldset>
      <div className={`cf-cgroup ${hasErrorClass("message_subject", errors, touched, values)}`}>
        <ErrorLabel field="message_subject" errors={errors} values={values} touched={touched}>
          {t("subject")}
        </ErrorLabel>
        <input
          type="text"
          id="message_subject"
          maxLength="250"
          name="message[subject]"
          placeholder={t("e.g. “replace float:left”")}
          value={subject}
          onChange={onChange}
          onBlur={setFieldTouched}
          required
        />
      </div>

      <div className={`cf-cgroup ${hasErrorClass("message_email", errors, touched, values)}`}>
        <ErrorLabel field="message_email" errors={errors} values={values} touched={touched}>
          {t("email")}
        </ErrorLabel>
        <input
          id="message_email"
          maxLength="60"
          name="message[email]"
          type="text"
          value={email}
          onChange={onChange}
          onBlur={setFieldTouched}
        />
        <span className="help">{t("voluntarily, publicly visible")}</span>
      </div>

      <div className={`cf-cgroup ${hasErrorClass("message_homepage", errors, touched, values)}`}>
        <ErrorLabel field="message_homepage" errors={errors} values={values} touched={touched}>
          {t("homepage")}
        </ErrorLabel>
        <input
          id="message_homepage"
          maxLength="250"
          name="message[homepage]"
          placeholder={t("e.g. “http://example.com/”")}
          type="text"
          value={homepage}
          onChange={onChange}
          onBlur={setFieldTouched}
        />
        <span className="help">{t("voluntarily, publicly visible")}</span>
      </div>

      <div className={`cf-cgroup ${hasErrorClass("message_thumbnail", errors, touched, values)}`}>
        <ErrorLabel field="message_thumbnail" errors={errors} values={values} touched={touched}>
          {t("thumbnail")}
        </ErrorLabel>
        <input
          id="message_thumbnail"
          name="message[thumbnail]"
          type="file"
          onChange={onChange}
          onBlur={setFieldTouched}
        />
        <span className="help">{t("optional")}</span>
      </div>

      <div className={`cf-cgroup ${hasErrorClass("message_thumbnail_alt", errors, touched, values)}`}>
        <ErrorLabel field="message_thumbnail_alt" errors={errors} values={values} touched={touched}>
          {t("alt text")}
        </ErrorLabel>
        <input
          id="message_thumbnail_alt"
          maxLength="250"
          name="message[thumbnail_alt]"
          type="text"
          value={thumbnailAlt}
          onChange={onChange}
          onBlur={setFieldTouched}
        />
        <span className="help">{t("voluntarily, publicly visible")}</span>
      </div>
    </fieldset>
  );
}

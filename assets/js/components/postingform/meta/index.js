import React, { useState } from "react";

import { t } from "../../../modules/i18n";
import ErrorLabel from "./error_label";
import { hasMoreThanOneForum, hasErrorClass, showAuthor } from "./utils";

export default function Meta(props) {
  const [touched, setTouched] = useState({});

  const { forumId, subject, author, problematicSite, email, homepage, errors } = props;
  const moreThanOne = hasMoreThanOneForum(props.forumOptions || []);
  const showForumSelect =
    (document.body.dataset.currentForum === "all" || !document.body.dataset.currentForum) && moreThanOne;
  const forumHidden =
    (document.body.dataset.currentForum === "all" || !document.body.dataset.currentForum) && !moreThanOne;

  const values = {
    message_author: author,
    message_email: email,
    message_forum_id: forumId,
    message_homepage: homepage,
    message_problematic_site: problematicSite,
    message_subject: subject,
  };

  function setFieldTouched(ev) {
    const name = ev.target.name.replace(/\[/, "_").replace(/\]$/, "");
    setTouched({ ...touched, [name]: true });
  }

  return (
    <fieldset>
      {showForumSelect && (
        <div className={`cf-cgroup ${hasErrorClass("message_forum_id", errors, touched, values)}`}>
          <ErrorLabel field="message_forum_id" errors={errors} values={values} touched={touched}>
            {t("forum")}
          </ErrorLabel>
          <select
            name="message[forum_id]"
            id="message_forum_id"
            value={forumId}
            onChange={props.onChange}
            onBlur={setFieldTouched}
          >
            {props.forumOptions.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.text}
              </option>
            ))}
          </select>
        </div>
      )}

      {forumHidden && <input type="hidden" name="message[forum_id]" value={props.forumOptions[1].value} />}

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
          onChange={props.onChange}
          onBlur={setFieldTouched}
          required
        />
      </div>

      {showAuthor() && (
        <div className={`cf-cgroup ${hasErrorClass("message_author", errors, touched, values)}`}>
          <ErrorLabel field="message_author" errors={errors} values={values} touched={touched}>
            {t("author")}
          </ErrorLabel>
          <input
            id="message_author"
            maxLength="60"
            name="message[author]"
            type="text"
            value={author}
            onChange={props.onChange}
            onBlur={setFieldTouched}
            required
          />
        </div>
      )}

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
          onChange={props.onChange}
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
          onChange={props.onChange}
          onBlur={setFieldTouched}
        />
        <span className="help">{t("voluntarily, publicly visible")}</span>
      </div>

      {props.withProblematicSite && (
        <div className={`cf-cgroup ${hasErrorClass("message_problematic_site", errors, touched, values)}`}>
          <ErrorLabel field="message_problematic_site" errors={errors} values={values} touched={touched}>
            {t("problematic site")}
          </ErrorLabel>
          <input
            id="message_problematic_site"
            maxLength="250"
            name="message[problematic_site]"
            placeholder={t("e.g. “https://example.com/float-example.html”")}
            type="text"
            value={problematicSite}
            onChange={props.onChange}
            onBlur={setFieldTouched}
          />
          <span className="help">{t("voluntarily, publicly visible")}</span>
        </div>
      )}
    </fieldset>
  );
}

Meta.defaultProps = {
  withProblematicSite: true,
};

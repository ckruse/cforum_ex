import React from "react";
import { t } from "../../modules/i18n";

export default class Meta extends React.PureComponent {
  render() {
    const { subject, author, problematicSite, email, homepage } = this.props;

    return (
      <fieldset>
        <div className="cf-cgroup">
          <label htmlFor="message_subject">{t("subject")}</label>
          <input
            type="text"
            id="message_subject"
            maxLength="250"
            name="message[subject]"
            placeholder={t("e.g. “replace float:left”")}
            defaultValue={subject}
            required
          />
        </div>

        {!window.currentUser && (
          <div className="cf-cgroup ">
            <label htmlFor="message_author">{t("author")}</label>
            <input
              id="message_author"
              maxLength="60"
              name="message[author]"
              type="text"
              defaultValue={author}
              required
            />
          </div>
        )}

        <div className="cf-cgroup ">
          <label htmlFor="message_email">{t("email")}</label>
          <input id="message_email" maxLength="60" name="message[email]" type="text" defaultValue={email} />
          <span className="help">{t("voluntarily, publicly visible")}</span>
        </div>

        <div className="cf-cgroup ">
          <label htmlFor="message_homepage">{t("homepage")}</label>
          <input
            id="message_homepage"
            maxLength="250"
            name="message[homepage]"
            placeholder={t("e.g. “http://example.com/”")}
            type="text"
            defaultValue={homepage}
          />
          <span className="help">{t("voluntarily, publicly visible")}</span>
        </div>

        <div className="cf-cgroup ">
          <label htmlFor="message_problematic_site">{t("problematic site")}</label>
          <input
            id="message_problematic_site"
            maxLength="250"
            name="message[problematic_site]"
            placeholder={t("e.g. “https://example.com/float-example.html”")}
            type="text"
            defaultValue={problematicSite}
          />
          <span className="help">{t("voluntarily, publicly visible")}</span>
        </div>
      </fieldset>
    );
  }
}

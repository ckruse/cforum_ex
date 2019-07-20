import React from "react";
import { t } from "../../modules/i18n";
import ErrorLabel from "./error_label";

export default class Meta extends React.PureComponent {
  hasErrorClass(val) {
    return val ? "has-error" : "";
  }

  render() {
    const { forumId, subject, author, problematicSite, email, homepage, errors } = this.props;
    const showForumSelect = document.body.dataset.currentForum === "all" || !document.body.dataset.currentForum;

    return (
      <fieldset>
        {showForumSelect && (
          <div className={`cf-cgroup ${this.hasErrorClass(errors.message_forum_id)}`}>
            <ErrorLabel for="message_forum_id" errors={errors}>
              {t("forum")}
            </ErrorLabel>
            <select name="message[forum_id]" id="message_forum_id" value={forumId} onChange={this.props.onChange}>
              <option />
              {this.props.forumOptions.map(opt => (
                <option key={opt.value} value={opt.value}>
                  {opt.text}
                </option>
              ))}
            </select>
          </div>
        )}

        <div className={`cf-cgroup ${this.hasErrorClass(errors.message_subject)}`}>
          <ErrorLabel for="message_subject" errors={errors}>
            {t("subject")}
          </ErrorLabel>
          <input
            type="text"
            id="message_subject"
            maxLength="250"
            name="message[subject]"
            placeholder={t("e.g. “replace float:left”")}
            value={subject}
            onChange={this.props.onChange}
            required
          />
        </div>

        {!document.body.dataset.userId && document.cookie.indexOf("cforum_author=") === -1 && (
          <div className={`cf-cgroup ${this.hasErrorClass(errors.message_author)}`}>
            <ErrorLabel for="message_author" errors={errors}>
              {t("author")}
            </ErrorLabel>
            <input
              id="message_author"
              maxLength="60"
              name="message[author]"
              type="text"
              value={author}
              onChange={this.props.onChange}
              required
            />
          </div>
        )}

        <div className={`cf-cgroup ${this.hasErrorClass(errors.message_email)}`}>
          <ErrorLabel for="message_email" errors={errors}>
            {t("email")}
          </ErrorLabel>
          <input
            id="message_email"
            maxLength="60"
            name="message[email]"
            type="text"
            value={email}
            onChange={this.props.onChange}
          />
          <span className="help">{t("voluntarily, publicly visible")}</span>
        </div>

        <div className={`cf-cgroup ${this.hasErrorClass(errors.message_homepage)}`}>
          <ErrorLabel for="message_homepage" errors={errors}>
            {t("homepage")}
          </ErrorLabel>
          <input
            id="message_homepage"
            maxLength="250"
            name="message[homepage]"
            placeholder={t("e.g. “http://example.com/”")}
            type="text"
            value={homepage}
            onChange={this.props.onChange}
          />
          <span className="help">{t("voluntarily, publicly visible")}</span>
        </div>

        <div className={`cf-cgroup ${this.hasErrorClass(errors.message_problematic_site)}`}>
          <ErrorLabel for="message_problematic_site" errors={errors}>
            {t("problematic site")}
          </ErrorLabel>
          <input
            id="message_problematic_site"
            maxLength="250"
            name="message[problematic_site]"
            placeholder={t("e.g. “https://example.com/float-example.html”")}
            type="text"
            value={problematicSite}
            onChange={this.props.onChange}
          />
          <span className="help">{t("voluntarily, publicly visible")}</span>
        </div>
      </fieldset>
    );
  }
}

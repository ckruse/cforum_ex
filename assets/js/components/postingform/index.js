import React from "react";

import CfContentForm from "../contentform";
import { t } from "../../modules/i18n";
import Notes from "./notes";
import Meta from "./meta";

class CfPostingForm extends React.Component {
  constructor(props) {
    super(props);

    this.state = { value: this.props.text };
  }

  render() {
    const { text, subject, author, tags, problematicSite, email, homepage, csrfInfo } = this.props;

    return (
      <>
        <input type="hidden" name={csrfInfo.param} value={csrfInfo.token} />

        <Meta subject={subject} author={author} problematicSite={problematicSite} email={email} homepage={homepage} />

        <div className="cf-content-form">
          <CfContentForm text={text} tags={tags} name="message[content]" />
        </div>

        <Notes />

        <p className="form-actions">
          <button className="cf-primary-btn" type="submit">
            {t("save message")}
          </button>{" "}
          <button className="cf-btn" onClick={this.props.onCancel}>
            {t("cancel")}
          </button>
        </p>
      </>
    );
  }
}

export default CfPostingForm;

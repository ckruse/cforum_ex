import React from "react";
import Modal from "react-modal";

import CfContentForm from "../contentform";
import { t } from "../../modules/i18n";
import Notes from "./notes";
import Meta from "./meta";

class CfPostingForm extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      forumId: this.props.forumId || undefined,
      text: this.props.text,
      subject: this.props.subject || "",
      author: this.props.author || "",
      tags: this.props.tags || "",
      problematicSite: this.props.problematicSite || "",
      email: this.props.email || "",
      homepage: this.props.homepage || "",
      showRestoreDraft: false
    };

    this.resetSaveTimer = this.resetSaveTimer.bind(this);
    this.saveDraft = this.saveDraft.bind(this);
    this.restoreDraft = this.restoreDraft.bind(this);
    this.deleteDraft = this.deleteDraft.bind(this);

    this.updateState = this.updateState.bind(this);
    this.onTextChange = this.onTextChange.bind(this);
    this.onTagChange = this.onTagChange.bind(this);
    this.toggleRestoreDraft = this.toggleRestoreDraft.bind(this);
  }

  updateState(ev) {
    let name = ev.target.name.replace(/message\[([^\]]+)\]/, "$1").replace(/_(.)/, (_, c) => c.toUpperCase());
    this.setState({ [name]: ev.target.value });
    this.resetSaveTimer();
  }

  onTextChange(text) {
    this.setState({ text });
    this.resetSaveTimer();
  }

  onTagChange(tags) {
    this.setState({ tags });
    this.resetSaveTimer();
  }

  restoreDraft() {
    if (!this.props.form) {
      return;
    }

    const key = this.props.form.action;
    const draft = localStorage.getItem(key);

    if (!draft) {
      return;
    }

    const fields = JSON.parse(draft);
    this.setState({
      forumId: fields.forumId || undefined,
      text: fields.text || "",
      subject: fields.subject || "",
      author: fields.author || "",
      tags: fields.tags || "",
      problematicSite: fields.problematicSite || "",
      email: fields.email || "",
      homepage: fields.homepage || "",
      showRestoreDraft: false
    });
  }

  deleteDraft() {
    const key = this.props.form.action;
    localStorage.removeItem(key);
    this.toggleRestoreDraft(false);
  }

  saveDraft() {
    const key = this.props.form.action;
    localStorage.setItem(key, JSON.stringify(this.state));
  }

  resetSaveTimer() {
    if (this.timer) {
      window.clearTimeout(this.timer);
    }

    window.setTimeout(this.saveDraft, 5000);
  }

  componentDidMount() {
    if (this.props.form) {
      const key = this.props.form.action;

      if (localStorage.getItem(key)) {
        this.toggleRestoreDraft();
      }
    }
  }

  toggleRestoreDraft(val = undefined) {
    this.setState(state => ({ showRestoreDraft: val === undefined ? !state.showRestoreDraft : val }));
  }

  render() {
    const { csrfInfo } = this.props;
    const { forumId, text, subject, author, tags, problematicSite, email, homepage } = this.state;

    return (
      <>
        <input type="hidden" name={csrfInfo.param} value={csrfInfo.token} />

        <Meta
          forumId={forumId}
          subject={subject}
          author={author}
          problematicSite={problematicSite}
          email={email}
          homepage={homepage}
          onChange={this.updateState}
          forumOptions={this.props.forumOptions}
        />

        <div className="cf-content-form">
          <CfContentForm
            text={text}
            tags={tags}
            name="message[content]"
            onTextChange={this.onTextChange}
            onTagChange={this.onTagChange}
          />
        </div>

        <Notes />

        <p className="form-actions">
          <button className="cf-primary-btn" type="submit" onClick={this.deleteDraft}>
            {t("save message")}
          </button>{" "}
          <button className="cf-btn" type="button" onClick={this.props.onCancel}>
            {t("cancel")}
          </button>
        </p>

        <Modal
          isOpen={this.state.showRestoreDraft}
          appElement={document.body}
          contentLabel={t("Search user")}
          onRequestClose={this.toggleRestoreDraft}
          closeTimeoutMS={300}
        >
          <h2>{t("There is a saved draft")}</h2>

          <p>{t("There is a saved draft for this post. Do you want to restore it?")}</p>

          <p>
            <button type="button" className="cf-btn" onClick={this.restoreDraft}>
              {t("Yes, restore the draft")}
            </button>{" "}
            <button type="button" className="cf-btn" onClick={this.deleteDraft}>
              {t("No, delete the draft")}
            </button>
          </p>
        </Modal>
      </>
    );
  }
}

export default CfPostingForm;

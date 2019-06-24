import React from "react";
import Modal from "react-modal";

import { t } from "../../modules/i18n";

class LinkModal extends React.Component {
  constructor(props) {
    super(props);

    this.state = { linkText: this.props.linkText, linkTarget: "" };

    this.handleTextKeyPressed = this.handleTextKeyPressed.bind(this);
    this.handleTargetKeyPressed = this.handleTargetKeyPressed.bind(this);
    this.onAfterOpen = this.onAfterOpen.bind(this);
    this.okPressed = this.okPressed.bind(this);
  }

  componentDidUpdate(prevProps) {
    if (prevProps.linkText !== this.props.linkText) {
      this.setState({ linkText: this.props.linkText, linkTarget: "" });
    }
  }

  handleTextKeyPressed(event) {
    this.setState({ linkText: event.target.value });
  }

  handleTargetKeyPressed(event) {
    this.setState({ linkTarget: event.target.value });
  }

  onAfterOpen() {
    if (this.focusElement) {
      this.focusElement.focus();
    }
  }

  okPressed() {
    const { linkText, linkTarget } = this.state;
    this.setState({ linkText: "", linkTarget: "" });

    this.props.onOk(linkText, linkTarget);
  }

  render() {
    return (
      <Modal
        isOpen={this.props.isOpen}
        appElement={document.body}
        contentLabel={t("Add new link")}
        onRequestClose={this.props.onCancel}
        onAfterOpen={this.onAfterOpen}
        closeTimeoutMS={300}
        shouldReturnFocusAfterClose={false}
      >
        <div className="cf-form">
          <div className="cf-cgroup">
            <label htmlFor="add-link-modal-linktext">{t("link description")}</label>
            <input
              ref={ref => (this.focusElement = ref)}
              type="text"
              id="add-link-modal-linktext"
              onChange={this.handleTextKeyPressed}
              value={this.state.linkText}
            />
          </div>

          <div className="cf-cgroup">
            <label htmlFor="add-link-modal-linkurl">{t("link target")}</label>
            <input
              type="text"
              id="add-link-modal-linkurl"
              onChange={this.handleTargetKeyPressed}
              value={this.state.linkTarget}
            />
          </div>

          <button className="cf-primary-btn" type="button" onClick={this.okPressed}>
            {t("add link")}
          </button>
          <button className="cf-btn" type="button" onClick={this.props.onCancel}>
            {t("cancel")}
          </button>
        </div>
      </Modal>
    );
  }
}

export default LinkModal;

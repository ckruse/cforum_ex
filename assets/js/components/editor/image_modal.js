import React from "react";
import Modal from "react-modal";

import { t } from "../../modules/i18n";
import Thumb from "./thumb";
import { isInSizeLimit } from "./helpers";

export default class ImageModal extends React.Component {
  constructor(props) {
    super(props);

    this.state = { desc: "", title: "", file: this.props.file };

    this.handleKeyPressed = this.handleKeyPressed.bind(this);
    this.onAfterOpen = this.onAfterOpen.bind(this);
    this.okPressed = this.okPressed.bind(this);
    this.handleFileChanged = this.handleFileChanged.bind(this);
  }

  componentDidUpdate(prevProps) {
    if (prevProps.file !== this.props.file) {
      this.setState({ file: this.props.file });
    }
  }

  handleKeyPressed(event) {
    this.setState({ [event.target.name]: event.target.value });
  }

  handleFileChanged(ev) {
    const file = ev.target.files[0];

    if (file.type.match(/^image\/(png|jpe?g|gif|svg\+xml)$/) && isInSizeLimit(file)) {
      this.setState({ file });
    }
  }

  onAfterOpen() {
    if (this.focusElementFile) {
      this.focusElementFile.focus();
    } else if (this.focusElement) {
      this.focusElement.focus();
    }
  }

  okPressed() {
    if (this.state.file) {
      this.props.onOk(this.state.file, this.state.desc, this.state.title);
    } else {
      this.props.onCancel();
    }
  }

  render() {
    return (
      <Modal
        isOpen={this.props.isOpen}
        appElement={document.body}
        contentLabel={t("Add new image")}
        onRequestClose={this.props.onCancel}
        onAfterOpen={this.onAfterOpen}
        closeTimeoutMS={300}
        shouldReturnFocusAfterClose={false}
      >
        <div className="cf-form">
          <div className="cf-cgroup">
            <label htmlFor="add-image-modal-file">{t("choose image")}</label>
            <input
              ref={ref => (this.focusElementFile = ref)}
              type="file"
              id="add-image-modal-desc"
              onChange={this.handleFileChanged}
            />
          </div>

          <Thumb file={this.state.file} />

          <div className="cf-cgroup">
            <label htmlFor="add-image-modal-desc">{t("enter image description")}</label>
            <input
              ref={ref => (this.focusElement = ref)}
              type="text"
              id="add-image-modal-desc"
              name="desc"
              onChange={this.handleKeyPressed}
              value={this.state.desc}
            />
          </div>

          <div className="cf-cgroup">
            <label htmlFor="add-image-modal-title">{t("enter image title")}</label>
            <input
              type="text"
              id="add-image-modal-title"
              name="title"
              onChange={this.handleKeyPressed}
              value={this.state.title}
            />
          </div>

          <button className="cf-primary-btn" type="button" onClick={this.okPressed}>
            {t("add image")}
          </button>{" "}
          <button className="cf-btn" type="button" onClick={this.props.onCancel}>
            {t("cancel")}
          </button>
        </div>
      </Modal>
    );
  }
}

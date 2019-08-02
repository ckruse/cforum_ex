import React from "react";

import { t } from "../../modules/i18n";
import ImageModal from "./image_modal";
import { conf } from "../../modules/helpers";
import { alertError } from "../../modules/alerts";

export default class Dropzone extends React.Component {
  constructor(props) {
    super(props);

    this.dragEvents = 0;

    this.state = { dragging: false, file: null, showImageModal: false };
    this.onOk = this.onOk.bind(this);
    this.onCancel = this.onCancel.bind(this);
    this.showImageModal = this.showImageModal.bind(this);
    this.dragEnterListener = this.dragEnterListener.bind(this);
    this.dragLeaveListener = this.dragLeaveListener.bind(this);
    this.dropListener = this.dropListener.bind(this);

    this.ignoreEvents = this.ignoreEvents.bind(this);
    this.dropIgnoreListener = this.dropIgnoreListener.bind(this);
    this.onPaste = this.onPaste.bind(this);
  }

  componentDidMount() {
    window.addEventListener("dragstart", this.ignoreEvents);
    window.addEventListener("dragend", this.ignoreEvents);

    window.addEventListener("dragover", this.ignoreEvents);
    window.addEventListener("drop", this.dropIgnoreListener);

    window.addEventListener("dragenter", this.dragEnterListener);
    window.addEventListener("dragleave", this.dragLeaveListener);

    window.addEventListener("paste", this.onPaste);

    this.dragEvents = 0;
  }

  componentWillUnmount() {
    window.removeEventListener("dragstart", this.ignoreEvents);
    window.removeEventListener("dragend", this.ignoreEvents);

    window.removeEventListener("dragover", this.ignoreEvents);
    window.removeEventListener("drop", this.dropIgnoreListener);

    window.removeEventListener("dragenter", this.dragEnterListener);
    window.removeEventListener("dragleave", this.dragLeaveListener);

    window.removeEventListener("paste", this.onPaste);
  }

  onOk(file, desc, title) {
    console.log(file);
    if (this.isInSizeLimit(file)) {
      this.setState({ showImageModal: false });
      this.props.onDrop(file, desc, title);
    }
  }

  isDraggingFile(ev) {
    return ev.dataTransfer.types.indexOf
      ? ev.dataTransfer.types.indexOf("Files") !== -1
      : ev.dataTransfer.types.contains("Files");
  }

  ignoreEvents(ev, checkedForDraggingFile = false) {
    if (checkedForDraggingFile || this.isDraggingFile(ev)) {
      ev.stopPropagation();
      ev.preventDefault();
    }
  }

  dropIgnoreListener(ev) {
    this.ignoreEvents(ev);
    this.dragEvents = 0;
    this.setState({ dragging: false });
    this.props.onDragStop();
  }

  dragEnterListener(ev) {
    this.dragEvents++;
    this.ignoreEvents(ev);

    if (!this.state.dragging && this.isDraggingFile(ev)) {
      this.setState({ dragging: true });
      this.props.onDragStart();
    }
  }

  dragLeaveListener(ev) {
    this.dragEvents--;
    this.ignoreEvents(ev);

    if (this.dragEvents === 0) {
      this.setState({ dragging: false });
      this.props.onDragStop();
    }
  }

  dropListener(ev) {
    this.ignoreEvents(ev);
    this.dragEvents = 0;
    this.setState({ dragging: false });
    this.props.onDragStop();

    if (ev.dataTransfer.files && ev.dataTransfer.files[0]) {
      const file = ev.dataTransfer.files[0];
      console.log(file);
      if (file.type.match(/^image\/(png|jpe?g|gif|svg\+xml)$/) && this.isInSizeLimit(file)) {
        this.setState({ file, showImageModal: true });
      }
    }
  }

  onPaste(ev) {
    if (ev.clipboardData.items[0].type.match(/^image\//)) {
      this.ignoreEvents(ev, true);

      const file = ev.clipboardData.items[0].getAsFile();

      if (!this.isInSizeLimit(file)) {
        alertError(t("The image you tried to paste exceeds the size limit of {maxSize} mb", { maxSize }));
        return;
      }

      this.setState({ file, showImageModal: true });
    }
  }

  onCancel() {
    this.setState({ showImageModal: false });
  }

  showImageModal() {
    this.setState({ showImageModal: true });
  }

  isInSizeLimit(file) {
    const maxSize = conf("max_image_filesize");

    if (file.size > maxSize * 1024 * 1024) {
      alertError(t("The image you tried to paste exceeds the size limit of {maxSize} mb", { maxSize }));
      return false;
    }

    return true;
  }

  render() {
    return (
      <>
        <div className={`cf-dropzone ${this.state.dragging ? "dragging" : ""}`} onDrop={this.dropListener}>
          <button onClick={this.showImageModal} type="button">
            <span>{t("drop file here or click here to upload")}</span>
          </button>
        </div>

        <ImageModal
          isOpen={this.state.showImageModal}
          file={this.state.file}
          onOk={this.onOk}
          onCancel={this.onCancel}
        />
      </>
    );
  }
}

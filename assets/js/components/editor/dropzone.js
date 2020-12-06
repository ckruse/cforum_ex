import React from "react";

import { t } from "../../modules/i18n";
import ImageModal from "./toolbar/image_modal";
import { alertError } from "../../modules/alerts";
import { isInSizeLimit } from "./helpers";
import { conf } from "../../modules/helpers";

export default class Dropzone extends React.Component {
  state = { dragging: false, file: null, showImageModal: false };
  dragEvents = 0;

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

  onOk = (file, desc, title) => {
    this.setState({ showImageModal: false });

    if (file.type.match(/^image\/(png|jpe?g|gif|svg\+xml)$/) && isInSizeLimit(file)) {
      this.props.onDrop(file, desc, title);
    }
  };

  isDraggingFile = (ev) => {
    return ev.dataTransfer.types.indexOf
      ? ev.dataTransfer.types.indexOf("Files") !== -1
      : ev.dataTransfer.types.contains("Files");
  };

  ignoreEvents = (ev, checkedForDraggingFile = false) => {
    if (checkedForDraggingFile || this.isDraggingFile(ev)) {
      ev.stopPropagation();
      ev.preventDefault();
    }
  };

  dropIgnoreListener = (ev) => {
    this.ignoreEvents(ev);
    this.dragEvents = 0;
    this.setState({ dragging: false });
    this.props.onDragStop();
  };

  dragEnterListener = (ev) => {
    this.dragEvents++;
    this.ignoreEvents(ev);

    if (!this.state.dragging && this.isDraggingFile(ev)) {
      this.setState({ dragging: true });
      this.props.onDragStart();
    }
  };

  dragLeaveListener = (ev) => {
    this.dragEvents--;
    this.ignoreEvents(ev);

    if (this.dragEvents === 0) {
      this.setState({ dragging: false });
      this.props.onDragStop();
    }
  };

  dropListener = (ev) => {
    this.ignoreEvents(ev);
    this.dragEvents = 0;
    this.setState({ dragging: false });
    this.props.onDragStop();

    if (ev.dataTransfer.files && ev.dataTransfer.files[0]) {
      const file = ev.dataTransfer.files[0];
      if (file.type.match(/^image\/(png|jpe?g|gif|svg\+xml)$/) && isInSizeLimit(file)) {
        this.setState({ file, showImageModal: true });
      }
    }
  };

  onPaste = (ev) => {
    if (ev.clipboardData.items[0].type.match(/^image\//)) {
      this.ignoreEvents(ev, true);

      const file = ev.clipboardData.items[0].getAsFile();
      const maxSize = conf("max_image_filesize");

      if (!isInSizeLimit(file)) {
        alertError(t("The image you tried to paste exceeds the size limit of {maxSize} mb", { maxSize }));
        return;
      }

      this.setState({ file, showImageModal: true });
    }
  };

  onCancel = () => {
    this.setState({ showImageModal: false, file: null });
  };

  showImageModal = () => {
    this.setState({ showImageModal: true });
  };

  classes = () => {
    const classes = [];
    if (this.state.dragging) classes.push("dragging");
    if (this.props.loading) classes.push("loading");

    return classes.join(" ");
  };

  render() {
    return (
      <>
        <div className={`cf-dropzone ${this.classes()}`} onDrop={this.dropListener}>
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

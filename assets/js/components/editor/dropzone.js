import React from "react";

import { t } from "../../modules/i18n";
import ImageModal from "./image_modal";

export default class Dropzone extends React.Component {
  constructor(props) {
    super(props);

    this.dragEvents = 0;

    this.state = { dragging: false, file: null, showImageModal: false };
    this.onOk = this.onOk.bind(this);
    this.dragEnterListener = this.dragEnterListener.bind(this);
    this.dragLeaveListener = this.dragLeaveListener.bind(this);
    this.dropListener = this.dropListener.bind(this);

    this.ignoreEvents = this.ignoreEvents.bind(this);
    this.dropIgnoreListener = this.dropIgnoreListener.bind(this);
  }

  componentDidMount() {
    window.addEventListener("dragstart", this.ignoreEvents);
    window.addEventListener("dragend", this.ignoreEvents);

    window.addEventListener("dragover", this.ignoreEvents);
    window.addEventListener("drop", this.dropIgnoreListener);

    window.addEventListener("dragenter", this.dragEnterListener);
    window.addEventListener("dragleave", this.dragLeaveListener);

    this.dragEvents = 0;
  }

  componentWillUnmount() {
    window.removeEventListener("dragstart", this.ignoreEvents);
    window.removeEventListener("dragend", this.ignoreEvents);

    window.removeEventListener("dragover", this.ignoreEvents);
    window.removeEventListener("drop", this.dropIgnoreListener);

    window.removeEventListener("dragenter", this.dragEnterListener);
    window.removeEventListener("dragleave", this.dragLeaveListener);
  }

  onOk(file, desc, title) {
    this.setState({ showImageModal: false });
    this.props.onDrop(file, desc, title);
  }

  ignoreEvents(ev) {
    ev.stopPropagation();
    ev.preventDefault();
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

    const isDraggingFile =
      (ev.dataTransfer.items && ev.dataTransfer.items[0]) ||
      (ev.dataTransfer.types && ev.dataTransfer.types[0] === "Files");

    if (!this.state.dragging && isDraggingFile) {
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
      if (file.type.match(/^image\/(png|jpe?g|gif|svg\+xml)$/)) {
        this.setState({ file, showImageModal: true });
      }
    }
  }

  render() {
    return (
      <div className={`cf-dropzone ${this.state.dragging ? "dragging" : ""}`} onDrop={this.dropListener}>
        <button onClick={this.showImageModal}>
          <span>{t("drop file here or click here to upload")}</span>
        </button>

        <ImageModal isOpen={this.state.showImageModal} file={this.state.file} onOk={this.onOk} />
      </div>
    );
  }
}

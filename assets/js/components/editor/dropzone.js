import React, { useEffect, useRef, useState } from "react";

import { alertError } from "../../modules/alerts";
import { conf } from "../../modules/helpers";
import { t } from "../../modules/i18n";
import { isInSizeLimit } from "./helpers";
import ImageModal from "./toolbar/image_modal";

export const VALID_IMAGE_RX = /^image\/(png|jpe?g|gif|svg\+xml|webp)$/;

export default function Dropzone(props) {
  const [dragging, setDragging] = useState(false);
  const [file, setFile] = useState(null);
  const [showImageModal, setShowImageModal] = useState(false);

  const dragEvents = useRef(0);

  useEffect(
    () => {
      window.addEventListener("dragstart", ignoreEvents);
      window.addEventListener("dragend", ignoreEvents);

      window.addEventListener("dragover", ignoreEvents);
      window.addEventListener("drop", dropIgnoreListener);

      window.addEventListener("dragenter", dragEnterListener);
      window.addEventListener("dragleave", dragLeaveListener);

      window.addEventListener("paste", onPaste);

      return () => {
        window.removeEventListener("dragstart", ignoreEvents);
        window.removeEventListener("dragend", ignoreEvents);

        window.removeEventListener("dragover", ignoreEvents);
        window.removeEventListener("drop", dropIgnoreListener);

        window.removeEventListener("dragenter", dragEnterListener);
        window.removeEventListener("dragleave", dragLeaveListener);

        window.removeEventListener("paste", onPaste);
      };
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    []
  );

  function onOk(file, desc, title) {
    setShowImageModal(false);

    if (file.type.match(VALID_IMAGE_RX) && isInSizeLimit(file)) {
      props.onDrop(file, desc, title);
    }
  }

  function isDraggingFile(ev) {
    return ev.dataTransfer.types.indexOf
      ? ev.dataTransfer.types.indexOf("Files") !== -1
      : ev.dataTransfer.types.contains("Files");
  }

  function ignoreEvents(ev, checkedForDraggingFile = false) {
    if (checkedForDraggingFile || isDraggingFile(ev)) {
      ev.stopPropagation();
      ev.preventDefault();
    }
  }

  function dropIgnoreListener(ev) {
    ignoreEvents(ev);
    dragEvents.current = 0;
    setDragging(false);
    props.onDragStop();
  }

  function dragEnterListener(ev) {
    dragEvents.current++;
    ignoreEvents(ev);

    if (!dragging && isDraggingFile(ev)) {
      setDragging(true);
      props.onDragStart();
    }
  }

  function dragLeaveListener(ev) {
    dragEvents.current--;
    ignoreEvents(ev);

    if (dragEvents.current === 0) {
      setDragging(false);
      props.onDragStop();
    }
  }

  function dropListener(ev) {
    ignoreEvents(ev);
    dragEvents.current = 0;
    setDragging(false);
    props.onDragStop();

    if (ev.dataTransfer.files && ev.dataTransfer.files[0]) {
      const droppedFile = ev.dataTransfer.files[0];
      if (droppedFile.type.match(VALID_IMAGE_RX) && isInSizeLimit(droppedFile)) {
        setFile(droppedFile);
        setShowImageModal(true);
      }
    }
  }

  function onPaste(ev) {
    if (ev.clipboardData.items[0].type.match(/^image\//)) {
      ignoreEvents(ev, true);

      const pastedFile = ev.clipboardData.items[0].getAsFile();
      const maxSize = conf("max_image_filesize");

      if (!isInSizeLimit(pastedFile)) {
        alertError(t("The image you tried to paste exceeds the size limit of {maxSize} mb", { maxSize }));
        return;
      }

      setFile(pastedFile);
      setShowImageModal(true);
    }
  }

  function onCancel() {
    setShowImageModal(false);
    setFile(null);
  }

  function doShowImageModal() {
    setShowImageModal(true);
  }

  function classes() {
    const classes = [];
    if (dragging) classes.push("dragging");
    if (props.loading) classes.push("loading");

    return classes.join(" ");
  }

  return (
    <>
      <div className={`cf-dropzone ${classes()}`} onDrop={dropListener}>
        <button onClick={doShowImageModal} type="button">
          <span>{t("drop file here or click here to upload")}</span>
        </button>
      </div>

      <ImageModal isOpen={showImageModal} file={file} onOk={onOk} onCancel={onCancel} />
    </>
  );
}

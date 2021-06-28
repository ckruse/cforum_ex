import React, { useEffect, useRef, useState } from "react";

import Modal from "react-modal";

import { t } from "../../../modules/i18n";
import { VALID_IMAGE_RX } from "../dropzone";
import { isInSizeLimit } from "../helpers";
import Thumb from "./thumb";

export default function ImageModal(props) {
  const [meta, setMeta] = useState({ title: "", desc: "" });
  const [file, setFile] = useState(props.file);
  const focusElementFile = useRef();
  const focusElement = useRef();

  useEffect(() => {
    setFile(props.file);
  }, [props.file]);

  function handleKeyPressed(event) {
    setMeta({ ...meta, [event.target.name]: event.target.value });
  }

  function handleFileChanged(ev) {
    const newFile = ev.target.files[0];

    if (newFile.type.match(VALID_IMAGE_RX) && isInSizeLimit(newFile)) {
      setFile(newFile);
    }
  }

  function onAfterOpen() {
    if (focusElementFile.current) {
      focusElementFile.current.focus();
    } else if (focusElement.current) {
      focusElement.current.focus();
    }
  }

  function okPressed() {
    if (file) {
      setFile(null);
      setMeta({ title: "", desc: "" });
      props.onOk(file, meta.desc, meta.title);
    } else {
      setFile(null);
      setMeta({ title: "", desc: "" });
      props.onCancel();
    }
  }

  function onCancel() {
    setFile(null);
    setMeta({ title: "", desc: "" });
    props.onCancel();
  }

  return (
    <Modal
      isOpen={props.isOpen}
      appElement={document.body}
      contentLabel={t("Add new image")}
      onRequestClose={props.onCancel}
      onAfterOpen={onAfterOpen}
      closeTimeoutMS={300}
      shouldReturnFocusAfterClose={false}
    >
      <div className="cf-form">
        <div className="cf-cgroup">
          <label htmlFor="add-image-modal-file">{t("choose image")}</label>
          <input ref={focusElementFile} type="file" id="add-image-modal-desc" onChange={handleFileChanged} />
        </div>

        <Thumb file={file} />

        <div className="cf-cgroup">
          <label htmlFor="add-image-modal-desc">{t("enter image description")}</label>
          <input
            ref={focusElement}
            type="text"
            id="add-image-modal-desc"
            name="desc"
            onChange={handleKeyPressed}
            value={meta.desc}
          />
        </div>

        <div className="cf-cgroup">
          <label htmlFor="add-image-modal-title">{t("enter image title")}</label>
          <input type="text" id="add-image-modal-title" name="title" onChange={handleKeyPressed} value={meta.title} />
        </div>

        <button className="cf-primary-btn" type="button" onClick={okPressed}>
          {t("add image")}
        </button>

        <button className="cf-btn" type="button" onClick={onCancel}>
          {t("cancel")}
        </button>
      </div>
    </Modal>
  );
}

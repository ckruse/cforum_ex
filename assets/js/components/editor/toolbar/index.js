import React, { useState, useEffect, useRef } from "react";
import ReactDOM from "react-dom";
import { Picker } from "emoji-mart";

import { t } from "../../../modules/i18n";
import * as ToolbarMethods from "./helpers";

import LinkModal from "./link_modal";

import CodeModal from "./code_modal";
import ImageModal from "./image_modal";
import { conf } from "../../../modules/helpers";

import(/* webpackChunkName: "vendor" */ "emoji-mart/css/emoji-mart.css");

const getCounterClass = (len, minLength = 10, maxLength = 12288) => {
  if (len < minLength || len >= maxLength) {
    return "error";
  } else if (len >= maxLength * 0.8) {
    return "warning";
  }

  return "success";
};

export default function Toolbar({ enableImages, value, textarea, changeValue, onImageUpload }) {
  const [pickerVisible, setPickerVisible] = useState(false);
  const [{ linkModalVisible, linkText }, setLink] = useState({
    linkModalVisible: false,
    linkText: null,
  });
  const [{ codeModalVisible, code }, setCode] = useState({ codeModalVisible: false, code: "" });
  const [imageModalVisible, setImageModalVisible] = useState(false);
  const picker = useRef();

  const [{ minLength, maxLength }, setMaxLength] = useState({
    minLength: conf("min_message_length") || 10,
    maxLength: conf("max_message_length") || 12288,
  });

  useEffect(() => {
    const handler = () => {
      setMaxLength({
        minLength: conf("min_message_length") || 10,
        maxLength: conf("max_message_length") || 12288,
      });
    };
    document.addEventListener("cf:configDidLoad", handler);
    return () => document.removeEventListener("cf:configDidLoad", handler);
  }, []);

  // we catch all click events for the whole document; if it was inside the picker, we ignore it.
  // If it was outside of the picker, we hide the picker.
  //
  // this is not the nicest way to handle it, but a very pragmatic way since an event
  // listener on the picker itself catches not all click events…
  function handleClick(event) {
    if (!picker.current || !pickerVisible || event.target.classList.contains("emoji-picker-btn")) {
      return;
    }

    let node = ReactDOM.findDOMNode(picker.current);
    if (!node) {
      return;
    }

    if (!node.contains(event.target)) {
      setPickerVisible(!pickerVisible);
    }
  }

  useEffect(() => {
    document.addEventListener("click", handleClick);

    return () => {
      document.removeEventListener("click", handleClick);
    };
  });

  function handleKeyDown(ev) {
    if (ev.keyCode === 27) {
      setPickerVisible(!pickerVisible);
    }
  }

  return (
    <div className="cf-editor-toolbar">
      <a
        href="https://wiki.selfhtml.org/wiki/SELFHTML:Forum/Formatierung_der_Beitr%C3%A4ge"
        title={t("help")}
        className="cf-editor-toolbar-help-btn"
      >
        ?
      </a>

      <button type="button" title={t("bold")} onClick={() => ToolbarMethods.toggleBold(textarea, value, changeValue)}>
        <img src="/images/bold.svg" alt="" />
      </button>

      <button
        type="button"
        title={t("italic")}
        onClick={() => ToolbarMethods.toggleItalic(textarea, value, changeValue)}
      >
        <img src="/images/italic.svg" alt="" />
      </button>

      <button
        type="button"
        title={t("strike through")}
        onClick={() => ToolbarMethods.toggleStrikeThrough(textarea, value, changeValue)}
      >
        <img src="/images/strikethrough.svg" alt="" />
      </button>

      <button
        type="button"
        title={t("header")}
        onClick={() => ToolbarMethods.toggleHeader(textarea, value, changeValue)}
      >
        <img src="/images/header.svg" alt="" />
      </button>

      <button type="button" title={t("link")} onClick={() => ToolbarMethods.addLink(textarea, setLink)}>
        <img src="/images/link.svg" alt="" />
      </button>

      {enableImages && (
        <button type="button" title={t("image")} onClick={() => setImageModalVisible(true)}>
          <img src="/images/image.svg" alt="" />
        </button>
      )}

      <button
        type="button"
        title={t("unordered list")}
        onClick={() => ToolbarMethods.toggleUl(textarea, value, changeValue)}
      >
        <img src="/images/list-ul.svg" alt="" />
      </button>

      <button
        type="button"
        title={t("ordered list")}
        onClick={() => ToolbarMethods.toggleOl(textarea, value, changeValue)}
      >
        <img src="/images/list-ol.svg" alt="" />
      </button>

      <button
        type="button"
        title={t("code")}
        onClick={() => ToolbarMethods.toggleCode(textarea, value, changeValue, setCode)}
      >
        <img src="/images/code.svg" alt="" />
      </button>

      <button type="button" title={t("cite")} onClick={() => ToolbarMethods.toggleCite(textarea, value, changeValue)}>
        <img src="/images/quote-left.svg" alt="" />
      </button>

      <button
        type="button"
        title={t("emoji picker")}
        onClick={() => setPickerVisible(true)}
        className="emoji-picker-btn"
      >
        <img src="/images/smile-o.svg" alt="" className="emoji-picker-btn" />
      </button>

      {pickerVisible && (
        <div onKeyDown={handleKeyDown} className="cf-emoji-picker">
          <Picker
            set={null}
            i18n={t("emojimart")}
            title="Emojis"
            native={true}
            onSelect={(emoji) => ToolbarMethods.addEmoji(textarea, value, changeValue, emoji)}
            autoFocus={true}
            ref={picker}
            unsized={true}
          />
        </div>
      )}

      <span className={`cf-content-counter ${getCounterClass(value.length, minLength, maxLength)}`}>
        {value.length}
      </span>

      <LinkModal
        isOpen={linkModalVisible}
        linkText={linkText}
        onOk={(text, target) => ToolbarMethods.addLinkFromModal(textarea, value, setLink, text, target, changeValue)}
        onCancel={() => setLink({ linkModalVisible: false, linkText: null })}
      />

      <CodeModal
        isOpen={codeModalVisible}
        code={code}
        onOk={(lang, code) => ToolbarMethods.addCodeBlockFromModal(textarea, value, lang, code, changeValue, setCode)}
        onCancel={() => setCode({ codeModalVisible: false, code: "" })}
      />

      {enableImages && (
        <ImageModal
          isOpen={imageModalVisible}
          onOk={(file, desc, title) =>
            ToolbarMethods.onImageUpload(setImageModalVisible, file, desc, title, onImageUpload)
          }
          onCancel={() => setImageModalVisible(false)}
        />
      )}
    </div>
  );
}

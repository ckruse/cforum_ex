import React from "react";
import { Picker } from "emoji-mart";

import { t } from "../../modules/i18n";
import {
  addEmoji,
  toggleBold,
  toggleItalic,
  toggleStrikeThrough,
  toggleHeader,
  toggleCite,
  toggleOl,
  toggleUl,
  toggleCode,
  addCodeBlockFromModal,
  togglePicker,
  hideCodeModal,
  hideLinkModal,
  addLinkFromModal,
  addLink
} from "./toolbar_methods";

import LinkModal from "./link_modal";

import "emoji-mart/css/emoji-mart.css";
import CodeModal from "./code_modal";

class Toolbar extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      pickerVisible: false,
      linkModalVisible: false,
      linkText: null,
      codeModalVisible: false,
      code: ""
    };

    this.addEmoji = addEmoji.bind(this);
    this.togglePicker = togglePicker.bind(this);
    this.toggleBold = toggleBold.bind(this);
    this.toggleItalic = toggleItalic.bind(this);
    this.toggleStrikeThrough = toggleStrikeThrough.bind(this);
    this.toggleHeader = toggleHeader.bind(this);
    this.toggleCite = toggleCite.bind(this);
    this.toggleUl = toggleUl.bind(this);
    this.toggleOl = toggleOl.bind(this);
    this.toggleCode = toggleCode.bind(this);
    this.addLink = addLink.bind(this);
    this.addLinkFromModal = addLinkFromModal.bind(this);
    this.hideLinkModal = hideLinkModal.bind(this);
    this.hideCodeModal = hideCodeModal.bind(this);
    this.addCodeBlockFromModal = addCodeBlockFromModal.bind(this);
  }

  render() {
    return (
      <div className="cf-editor-toolbar">
        <a
          href="https://wiki.selfhtml.org/wiki/SELFHTML:Forum/Formatierung_der_Beitr%C3%A4ge"
          title={t("help")}
          className="cf-editor-toolbar-help-btn"
        >
          ?
        </a>

        <button type="button" title={t("bold")} onClick={this.toggleBold}>
          <img src="/images/bold.svg" alt="" />
        </button>

        <button type="button" title={t("italic")} onClick={this.toggleItalic}>
          <img src="/images/italic.svg" alt="" />
        </button>

        <button type="button" title={t("strike through")} onClick={this.toggleStrikeThrough}>
          <img src="/images/strikethrough.svg" alt="" />
        </button>

        <button type="button" title={t("header")} onClick={this.toggleHeader}>
          <img src="/images/header.svg" alt="" />
        </button>

        <button type="button" title={t("link")} onClick={this.addLink}>
          <img src="/images/link.svg" alt="" />
        </button>

        <button type="button" title={t("image")} onClick={this.addImage}>
          <img src="/images/image.svg" alt="" />
        </button>

        <button type="button" title={t("unordered list")} onClick={this.toggleUl}>
          <img src="/images/list-ul.svg" alt="" />
        </button>

        <button type="button" title={t("ordered list")} onClick={this.toggleOl}>
          <img src="/images/list-ol.svg" alt="" />
        </button>

        <button type="button" title={t("code")} onClick={this.toggleCode}>
          <img src="/images/code.svg" alt="" />
        </button>

        <button type="button" title={t("cite")} onClick={this.toggleCite}>
          <img src="/images/quote-left.svg" alt="" />
        </button>

        <button type="button" title={t("emoji picker")} onClick={this.togglePicker}>
          <img src="/images/smile-o.svg" alt="" />
        </button>

        {this.state.pickerVisible && <Picker set={null} native={true} onSelect={this.addEmoji} />}
        <LinkModal
          isOpen={this.state.linkModalVisible}
          linkText={this.state.linkText}
          onOk={this.addLinkFromModal}
          onCancel={this.hideLinkModal}
        />
        <CodeModal
          isOpen={this.state.codeModalVisible}
          code={this.state.code}
          onOk={this.addCodeBlockFromModal}
          onCancel={this.hideCodeModal}
        />
      </div>
    );
  }
}

export default Toolbar;

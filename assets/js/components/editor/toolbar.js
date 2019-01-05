import React from "react";
import { Picker } from "emoji-mart";

import { t } from "../../modules/i18n";
import {
  getSelection,
  replaceAt,
  insertBlockAtFirstNewline,
  toggleInAccent,
  getSelectedText,
  leadingNewlines,
  isPreviousLineList,
  isBeginningOfLine
} from "./helpers";

import LinkModal from "./link_modal";

import "emoji-mart/css/emoji-mart.css";
import { alertError } from "../../alerts";
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

    this.addEmoji = this.addEmoji.bind(this);
    this.togglePicker = this.togglePicker.bind(this);
    this.toggleBold = this.toggleBold.bind(this);
    this.toggleItalic = this.toggleItalic.bind(this);
    this.toggleStrikeThrough = this.toggleStrikeThrough.bind(this);
    this.toggleHeader = this.toggleHeader.bind(this);
    this.toggleCite = this.toggleCite.bind(this);
    this.addLink = this.addLink.bind(this);
    this.addLinkFromModal = this.addLinkFromModal.bind(this);
    this.hideLinkModal = this.hideLinkModal.bind(this);
    this.toggleUl = this.toggleUl.bind(this);
    this.toggleOl = this.toggleOl.bind(this);
    this.toggleCode = this.toggleCode.bind(this);
    this.hideCodeModal = this.hideCodeModal.bind(this);
    this.addCodeBlockFromModal = this.addCodeBlockFromModal.bind(this);
  }

  addEmoji(emoji) {
    const { start, end } = getSelection(this.props.textarea);
    const val = replaceAt(this.props.value, emoji.native, start, end);
    const len = emoji.native.length;

    this.props.changeValue(val, { start: start + len, end: end + len });
    this.props.textarea.focus();
    this.togglePicker();
  }

  togglePicker() {
    this.setState({ pickerVisible: !this.state.pickerVisible });
  }

  toggleBold() {
    const { start, end, len } = getSelection(this.props.textarea);
    const { val, pos } = toggleInAccent(this.props.value, t("strong text"), "**", start, end, len);
    this.props.changeValue(val, { ...pos });
    this.props.textarea.focus();
  }

  toggleItalic() {
    const { start, end, len } = getSelection(this.props.textarea);
    const { val, pos } = toggleInAccent(this.props.value, t("italic text"), "*", start, end, len);
    this.props.changeValue(val, { ...pos });
    this.props.textarea.focus();
  }

  toggleStrikeThrough() {
    const { start, end, len } = getSelection(this.props.textarea);
    const { val, pos } = toggleInAccent(this.props.value, t("text"), "~~", start, end, len);
    this.props.changeValue(val, { ...pos });
    this.props.textarea.focus();
  }

  toggleHeader() {
    const { start, end } = getSelection(this.props.textarea);
    const { val, pos } = insertBlockAtFirstNewline(this.props.value, start, end, "# ", /^\s*(#+\s?)/);
    this.props.changeValue(val, { ...pos });
    this.props.textarea.focus();
  }

  toggleCite() {
    const { start, end } = getSelection(this.props.textarea);
    const { val, pos } = insertBlockAtFirstNewline(this.props.value, start, end, "> ", /^\s*(>\s?)+/);
    this.props.changeValue(val, { ...pos });
    this.props.textarea.focus();
  }

  addLink() {
    const text = getSelectedText(this.props.textarea);
    this.setState({ linkModalVisible: true, linkText: text });
  }

  addLinkFromModal(text, target) {
    if (!target) {
      alertError(t("You have to define at least the URL of the link!"), 10);
      return;
    }

    let link = "";
    if (!text) {
      link = `<${target}>`;
    } else {
      link = `[${text}](${target})`;
    }

    const { start, end } = getSelection(this.props.textarea);
    this.setState({ linkModalVisible: false, linkText: "" });

    this.props.changeValue(replaceAt(this.props.value, link, start, end), {
      start: start + link.length,
      end: start + link.length
    });
    this.props.textarea.focus();
  }

  hideLinkModal() {
    this.setState({ linkModalVisible: false, linkText: "" });
    this.props.textarea.focus();
  }

  toggleUl() {
    const selected = getSelectedText(this.props.textarea);
    const { start, end } = getSelection(this.props.textarea);
    let chunk, cursorPos, cursorEnd;

    if (selected.length === 0) {
      chunk = t("list text here");
      let prefix = "";

      if (isPreviousLineList(this.props.value, start, /-/)) {
        if (!isBeginningOfLine(this.props.value, start)) {
          prefix = "\n";
        }
      } else {
        prefix = leadingNewlines(this.props.value, start);
      }

      chunk = prefix + "- " + chunk;
      cursorPos = start + 2 + prefix.length;
      cursorEnd = start + chunk.length;
    } else {
      if (selected.indexOf("\n") < 0) {
        chunk = "- " + selected;
      } else {
        chunk =
          leadingNewlines(this.props.value, start) +
          selected
            .split("\n")
            .map(str => "- " + str)
            .join("\n");
      }

      cursorPos = start + chunk.length;
      cursorEnd = start + chunk.length;
    }

    this.props.changeValue(replaceAt(this.props.value, chunk, start, end), { start: cursorPos, end: cursorEnd });
    this.props.textarea.focus();
  }

  toggleOl() {
    const selected = getSelectedText(this.props.textarea);
    const { start, end } = getSelection(this.props.textarea);
    let chunk, cursorPos, cursorEnd;

    if (selected.length === 0) {
      let prefix = "";
      chunk = t("list text here");

      if (isPreviousLineList(this.props.value, start, /\d/)) {
        if (!isBeginningOfLine(this.props.value, start)) {
          prefix = "\n";
        }
      } else {
        prefix = leadingNewlines(this.props.value, start);
      }

      chunk = prefix + "1. " + chunk;
      cursorPos = start + 3 + prefix.length;
      cursorEnd = start + chunk.length;
    } else {
      if (selected.indexOf("\n") < 0) {
        chunk = "1. " + selected;
      } else {
        chunk =
          leadingNewlines(this.props.value, start) +
          selected
            .split("\n")
            .map((s, idx) => idx + 1 + ". " + s)
            .join("\n");
      }

      cursorPos = start + chunk.length;
      cursorEnd = start + chunk.length;
    }

    this.props.changeValue(replaceAt(this.props.value, chunk, start, end), { start: cursorPos, end: cursorEnd });
    this.props.textarea.focus();
  }

  toggleCode() {
    const selected = getSelectedText(this.props.textarea);
    const { start, end } = getSelection(this.props.textarea);
    const text = selected.length === 0 ? t("code here") : selected;

    const selectionIsCodeBlock = () =>
      this.props.value.substr(start - 4, 4) === "~~~\n" && this.props.value.substr(end, 4) === "\n~~~";
    const selectionIsInlineCode = () =>
      this.props.value.charAt(start - 1) === "`" && this.props.value.charAt(end) === "`";
    const selectionContainsNewlines = () => text.indexOf("\n") > -1;
    const selectionIsPrecededByNewlines = () => this.props.value.substr(start - 2, 2) === "\n\n";
    const selectionIsWholeLine = () => end === this.props.value.length || this.props.value.charAt(end) === "\n";
    const languageIsValid = lang => lang != null && lang.length < 20;

    const removeMarkup = function(type) {
      const characters = { block: 4, inline: 1 }[type];
      const cursor = start - characters;
      this.props.changeValue(replaceAt(this.props.value, text, cursur, end + characters), {
        start: cursor,
        end: cursor + text.length
      });
      this.props.textarea.focus();
    };

    const createInlineCode = () => {
      const cursor = start + 1;
      this.props.changeValue(replaceAt(this.props.value, "`" + text + "`", start, end), {
        start: cursor,
        end: cursor + text.length
      });
      this.props.textarea.focus();
    };

    // Do something
    switch (true) {
      case selectionIsCodeBlock():
        removeMarkup("block");
        break;
      case selectionIsInlineCode():
        removeMarkup("inline");
        break;
      case selectionContainsNewlines():
        createCodeBlock();
        break;
      case selectionIsPrecededByNewlines() && selectionIsWholeLine():
        this.setState({ codeModalVisible: true, code: text });
        break;
      default:
        createInlineCode();
    }
  }

  hideCodeModal() {
    this.setState({ codeModalVisible: false, code: "" });
    this.props.textarea.focus();
  }

  addCodeBlockFromModal(lang, code) {
    const { start, end } = getSelection(this.props.textarea);
    const prefix = leadingNewlines(this.props.value, start);
    const chunk = prefix + `~~~ ${lang}\n${code}\n~~~`;

    this.setState({ codeModalVisible: false, code: "" });
    this.props.changeValue(replaceAt(this.props.value, chunk, start, end), {
      start: start + lang.length + 5,
      end: start + lang.length + 5 + code.length
    });
    this.props.textarea.focus();
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

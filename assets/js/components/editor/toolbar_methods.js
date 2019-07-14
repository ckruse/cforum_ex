import { alertError } from "../../modules/alerts";
import { t } from "../../modules/i18n";
import {
  replaceAt,
  getSelection,
  toggleInAccent,
  insertBlockAtFirstNewline,
  getSelectedText,
  leadingNewlines,
  isBeginningOfLine,
  isPreviousLineList
} from "./helpers";

export function addEmoji(emoji) {
  const { start, end } = getSelection(this.props.textarea.current);
  const val = replaceAt(this.props.value, emoji.native, start, end);
  const len = emoji.native.length;

  this.props.changeValue(val, { start: start + len, end: end + len });
}

export function togglePicker() {
  this.setState(state => ({ pickerVisible: !state.pickerVisible }));
}

export function toggleBold() {
  const { start, end, len } = getSelection(this.props.textarea.current);
  const { val, pos } = toggleInAccent(this.props.value, t("strong text"), "**", start, end, len);
  this.props.changeValue(val, { ...pos });
  this.props.textarea.current.focus();
}

export function toggleItalic() {
  const { start, end, len } = getSelection(this.props.textarea.current);
  const { val, pos } = toggleInAccent(this.props.value, t("italic text"), "*", start, end, len);
  this.props.changeValue(val, { ...pos });
  this.props.textarea.current.focus();
}

export function toggleStrikeThrough() {
  const { start, end, len } = getSelection(this.props.textarea.current);
  const { val, pos } = toggleInAccent(this.props.value, t("strike-through text"), "~~", start, end, len);
  this.props.changeValue(val, { ...pos });
  this.props.textarea.current.focus();
}

export function toggleHeader() {
  const { start, end } = getSelection(this.props.textarea.current);
  const { val, pos } = insertBlockAtFirstNewline(this.props.value, start, end, "# ", /^\s*(#+\s?)/);
  this.props.changeValue(val, { ...pos });
  this.props.textarea.current.focus();
}

export function toggleCite() {
  const { start, end } = getSelection(this.props.textarea.current);
  const { val, pos } = insertBlockAtFirstNewline(this.props.value, start, end, "> ", /^\s*(>\s?)+/);
  this.props.changeValue(val, { ...pos });
  this.props.textarea.current.focus();
}

export function toggleUl() {
  const selected = getSelectedText(this.props.textarea.current);
  const { start, end } = getSelection(this.props.textarea.current);
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
  this.props.textarea.current.focus();
}

export function toggleOl() {
  const selected = getSelectedText(this.props.textarea.current);
  const { start, end } = getSelection(this.props.textarea.current);
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
  this.props.textarea.current.focus();
}

export function toggleCode() {
  const selected = getSelectedText(this.props.textarea.current);
  const { start, end } = getSelection(this.props.textarea.current);
  const text = selected.length === 0 ? t("code here") : selected;

  const selectionIsCodeBlock = () =>
    this.props.value.substr(start - 4, 4) === "~~~\n" && this.props.value.substr(end, 4) === "\n~~~";
  const selectionIsInlineCode = () =>
    this.props.value.charAt(start - 1) === "`" && this.props.value.charAt(end) === "`";
  const selectionContainsNewlines = () => text.indexOf("\n") > -1;
  const selectionIsPrecededByNewlines = () => this.props.value.substr(start - 2, 2) === "\n\n";
  const selectionIsWholeLine = () => end === this.props.value.length || this.props.value.charAt(end) === "\n";

  const removeMarkup = function(type) {
    const characters = { block: 4, inline: 1 }[type];
    const cursor = start - characters;
    this.props.changeValue(replaceAt(this.props.value, text, cursur, end + characters), {
      start: cursor,
      end: cursor + text.length
    });
    this.props.textarea.current.focus();
  };

  const createInlineCode = () => {
    const cursor = start + 1;
    this.props.changeValue(replaceAt(this.props.value, "`" + text + "`", start, end), {
      start: cursor,
      end: cursor + text.length
    });
    this.props.textarea.current.focus();
  };

  const createCodeBlock = () => {
    const block = (selectionIsPrecededByNewlines() ? "~~~\n" : "\n~~~\n") + text + "\n~~~\n";

    this.props.changeValue(replaceAt(this.props.value, block, start, end), {
      start,
      end: start + block.length
    });
    this.props.textarea.current.focus();
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

export function addCodeBlockFromModal(lang, code) {
  const { start, end } = getSelection(this.props.textarea.current);
  const prefix = leadingNewlines(this.props.value, start);
  const chunk = prefix + `~~~ ${lang}\n${code}\n~~~`;

  this.setState({ codeModalVisible: false, code: "" });
  this.props.changeValue(replaceAt(this.props.value, chunk, start, end), {
    start: start + lang.length + 5,
    end: start + lang.length + 5 + code.length
  });
  this.props.textarea.current.focus();
}

export function addLink() {
  const text = getSelectedText(this.props.textarea.current);
  this.setState({ linkModalVisible: true, linkText: text });
}

export function addLinkFromModal(text, target) {
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

  const { start, end } = getSelection(this.props.textarea.current);
  this.setState({ linkModalVisible: false, linkText: "" });

  this.props.changeValue(replaceAt(this.props.value, link, start, end), {
    start: start + link.length,
    end: start + link.length
  });
  this.props.textarea.current.focus();
}

export function hideLinkModal() {
  this.setState({ linkModalVisible: false, linkText: "" });
  this.props.textarea.current.focus();
}

export function hideCodeModal() {
  this.setState({ codeModalVisible: false, code: "" });
  this.props.textarea.current.focus();
}

export function hideImageModal() {
  this.setState({ showImageModal: false });
}

export function onImageUpload(file, desc, title) {
  this.setState({ showImageModal: false });
  this.props.onImageUpload(file, desc, title);
}

export function addImage() {
  this.setState({ showImageModal: true });
}

import { alertError } from "../../../modules/alerts";
import { t } from "../../../modules/i18n";
import {
  replaceAt,
  getSelection,
  toggleInAccent,
  insertBlockAtFirstNewline,
  getSelectedText,
  leadingNewlines,
  isBeginningOfLine,
  isPreviousLineList,
  escapeText,
} from "../helpers";

export function addEmoji(textarea, value, changeValue, emoji) {
  const { start, end } = getSelection(textarea.current);
  const val = replaceAt(value, emoji.native, start, end);
  const len = emoji.native.length;

  changeValue(val, { start: start + len, end: end + len });
}

export function toggleBold(textarea, value, changeValue) {
  const { start, end, len } = getSelection(textarea.current);
  const { val, pos } = toggleInAccent(value, t("strong text"), "**", start, end, len);
  changeValue(val, { ...pos });
  textarea.current.focus();
}

export function toggleItalic(textarea, value, changeValue) {
  const { start, end, len } = getSelection(textarea.current);
  const { val, pos } = toggleInAccent(value, t("italic text"), "*", start, end, len);
  changeValue(val, { ...pos });
  textarea.current.focus();
}

export function toggleStrikeThrough(textarea, value, changeValue) {
  const { start, end, len } = getSelection(textarea.current);
  const { val, pos } = toggleInAccent(value, t("strike-through text"), "~~", start, end, len);
  changeValue(val, { ...pos });
  textarea.current.focus();
}

export function toggleHeader(textarea, value, changeValue) {
  const { start, end } = getSelection(textarea.current);
  const { val, pos } = insertBlockAtFirstNewline(value, start, end, "# ", /^\s*(#+\s?)/);
  changeValue(val, { ...pos });
  textarea.current.focus();
}

export function toggleCite(textarea, value, changeValue) {
  const { start, end } = getSelection(textarea.current);
  const { val, pos } = insertBlockAtFirstNewline(value, start, end, "> ", /^\s*(>\s?)+/);
  changeValue(val, { ...pos });
  textarea.current.focus();
}

export function toggleUl(textarea, value, changeValue) {
  const selected = getSelectedText(textarea.current);
  const { start, end } = getSelection(textarea.current);
  let chunk, cursorPos, cursorEnd;

  if (selected.length === 0) {
    chunk = t("list text here");
    let prefix = "";

    if (isPreviousLineList(value, start, /-/)) {
      if (!isBeginningOfLine(value, start)) {
        prefix = "\n";
      }
    } else {
      prefix = leadingNewlines(value, start);
    }

    chunk = prefix + "- " + chunk;
    cursorPos = start + 2 + prefix.length;
    cursorEnd = start + chunk.length;
  } else {
    if (selected.indexOf("\n") < 0) {
      chunk = "- " + selected;
    } else {
      chunk =
        leadingNewlines(value, start) +
        selected
          .split("\n")
          .map((str) => "- " + str)
          .join("\n");
    }

    cursorPos = start + chunk.length;
    cursorEnd = start + chunk.length;
  }

  changeValue(replaceAt(value, chunk, start, end), { start: cursorPos, end: cursorEnd });
  textarea.current.focus();
}

export function toggleOl(textarea, value, changeValue) {
  const selected = getSelectedText(textarea.current);
  const { start, end } = getSelection(textarea.current);
  let chunk, cursorPos, cursorEnd;

  if (selected.length === 0) {
    let prefix = "";
    chunk = t("list text here");

    if (isPreviousLineList(value, start, /\d/)) {
      if (!isBeginningOfLine(value, start)) {
        prefix = "\n";
      }
    } else {
      prefix = leadingNewlines(value, start);
    }

    chunk = prefix + "1. " + chunk;
    cursorPos = start + 3 + prefix.length;
    cursorEnd = start + chunk.length;
  } else {
    if (selected.indexOf("\n") < 0) {
      chunk = "1. " + selected;
    } else {
      chunk =
        leadingNewlines(value, start) +
        selected
          .split("\n")
          .map((s, idx) => idx + 1 + ". " + s)
          .join("\n");
    }

    cursorPos = start + chunk.length;
    cursorEnd = start + chunk.length;
  }

  changeValue(replaceAt(value, chunk, start, end), { start: cursorPos, end: cursorEnd });
  textarea.current.focus();
}

export function toggleCode(textarea, value, changeValue, setCode) {
  const selected = getSelectedText(textarea.current);
  const { start, end } = getSelection(textarea.current);
  const text = selected.length === 0 ? t("code here") : selected;

  const selectionIsCodeBlock = () => value.substr(start - 4, 4) === "~~~\n" && value.substr(end, 4) === "\n~~~";
  const selectionIsInlineCode = () => value.charAt(start - 1) === "`" && value.charAt(end) === "`";
  const selectionContainsNewlines = () => text.indexOf("\n") > -1;
  const selectionIsPrecededByNewlines = () => value.substr(start - 2, 2) === "\n\n";
  const selectionIsWholeLine = () => end === value.length || value.charAt(end) === "\n";

  const removeMarkup = function (type) {
    const characters = { block: 4, inline: 1 }[type];
    const cursor = start - characters;
    changeValue(replaceAt(value, text, cursor, end + characters), {
      start: cursor,
      end: cursor + text.length,
    });
    textarea.current.focus();
  };

  const createInlineCode = () => {
    const cursor = start + 1;
    changeValue(replaceAt(value, "`" + text + "`", start, end), { start: cursor, end: cursor + text.length });
    textarea.current.focus();
  };

  const createCodeBlock = () => {
    const block = (selectionIsPrecededByNewlines() ? "~~~\n" : "\n~~~\n") + text + "\n~~~\n";

    changeValue(replaceAt(value, block, start, end), { start, end: start + block.length });
    textarea.current.focus();
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
      setCode({ codeModalVisible: true, code: text });
      break;
    default:
      createInlineCode();
  }
}

export function addCodeBlockFromModal(textarea, value, lang, code, changeValue, setCode) {
  const { start, end } = getSelection(textarea.current);
  const prefix = leadingNewlines(value, start);
  const chunk = prefix + `~~~ ${lang}\n${code}\n~~~`;

  setCode({ codeModalVisible: false, code: "" });
  changeValue(replaceAt(value, chunk, start, end), {
    start: start + lang.length + 5,
    end: start + lang.length + 5 + code.length,
  });
  textarea.current.focus();
}

export function addLink(textarea, setLink) {
  const linkText = getSelectedText(textarea.current);
  setLink({ linkModalVisible: true, linkText });
}

export function addLinkFromModal(textarea, value, setLink, text, target, changeValue) {
  if (!target) {
    alertError(t("You have to define at least the URL of the link!"), 10);
    return;
  }

  let link = "";
  if (!text) {
    link = `<${escapeText(target, ">")}>`;
  } else {
    link = `[${escapeText(text, "\\]")}](${escapeText(target, "()")})`;
  }

  const { start, end } = getSelection(textarea.current);
  setLink({ linkModalVisible: false, linkText: "" });

  changeValue(replaceAt(value, link, start, end), {
    start: start + link.length,
    end: start + link.length,
  });
  textarea.current.focus();
}

export function onImageUpload(setImageModalVisible, file, desc, title, onImageUpload) {
  setImageModalVisible(false);
  onImageUpload(file, desc, title);
}

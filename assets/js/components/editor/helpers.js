export const replaceAt = (text, replacement, start, end) =>
  text.substr(0, start) + replacement + text.substr(end, text.length);

export const getSelection = input => ({
  start: input.selectionStart,
  end: input.selectionEnd,
  len: input.selectionEnd - input.selectionStart
});

export const getSelectedText = input =>
  input.value.substr(input.selectionStart, input.selectionEnd - input.selectionStart);

export const replaceSelectedText = (input, replacement) => {
  const { start, end } = getSelection(input);
  return replaceAt(input.value, replacement, start, end);
};

const calcSelection = (markText, start, chunkLen, opLen = 0) => {
  if (markText) {
    return { start: start + opLen, end: start + chunkLen + opLen };
  }

  return { start: start + chunkLen + 2 * opLen, end: start + chunkLen + 2 * opLen };
};

export const toggleInAccent = (value, text, accent, start, end, len) => {
  const alen = accent.length;
  let val,
    pos,
    markText = true;

  let chunk = text;
  if (len > 0) {
    chunk = value.substr(start, len);
    markText = false;
  }

  if (value.substr(start - alen, alen) == accent && value.substr(end, alen) == accent) {
    val = replaceAt(value, chunk, start - alen, end + alen);
    pos = calcSelection(markText, start - alen, chunk.length);
  } else {
    val = replaceAt(value, `${accent}${chunk}${accent}`, start, end);
    pos = calcSelection(markText, start, chunk.length, alen);
  }

  return { val, pos };
};

export const countNewlinesBefore = (str, start, i) => {
  for (; i < start; ++i) {
    if (!str.slice(start - i, start).match(/^(?:\r\n|\r|\n)/)) {
      i -= 1;
      str.slice(start - i, start).match(/^((?:\r\n|\r|\n)+)/);
      return RegExp.$1.replace(/\r\n|\r|\n/, "\n").length;
    }
  }

  return 0;
};

export const findFirstNewlineBehind = (str, start) => {
  let i = 0;

  for (i = 0; i < start; ++i) {
    if (str.slice(start - i, start).match(/^(?:\r\n|\r|\n)/)) {
      i -= 1;
      break;
    }
  }

  return i;
};

export const insertBlockAtFirstNewline = (str, start, end, marker, searchRegex) => {
  let i = findFirstNewlineBehind(str, start),
    val,
    pos;

  if (str.slice(start - i, start).match(searchRegex)) {
    const replacement = RegExp.$1;
    val = str.slice(0, start - i) + str.slice(start - i, start).replace(searchRegex, "") + str.slice(start, str.length);
    pos = { start: start - replacement.length, end: end - replacement.length };
  } else {
    if (countNewlinesBefore(str, start, i + 1) < 2) {
      marker = "\n" + marker;
    }

    val = str.slice(0, start - i) + marker + str.slice(start - i, str.length);
    pos = { start: start + marker.length, end: end + marker.length };
  }

  return { val, pos };
};

export const leadingNewlines = (content, start) => {
  if (start === 0) {
    return "";
  }

  let newlines = "",
    str = content.substr(start - 2, 2);

  if (str.charAt(1) !== "\n") {
    newlines = "\n\n";
  } else if (str.charAt(0) !== "\n") {
    newlines = "\n";
  }

  return newlines;
};

export const isPreviousLineList = (content, start, rx) => {
  var i, c;

  for (i = start - 1; i >= 0; --i) {
    c = content.substr(i, 1);
    if (c == "\n") {
      if (content.substr(i + 1, 1).match(rx)) {
        return true;
      }
    }
  }

  return i === 0;
};

export const isBeginningOfLine = (content, start) => start === 0 || content.substr(start - 1, 1) === "\n";

export const escapeText = (text, escapes) => {
  const rx = new RegExp("([" + escapes + "])", "g");
  return text.replace(rx, "\\$1");
};

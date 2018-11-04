import { emojiIndex } from "emoji-mart";

const EmojiReplacements = {
  trigger: ":",
  type: "emoji",
  data: term => {
    if (term.length <= 0) {
      return [];
    }

    return emojiIndex
      .search(term)
      .slice(0, 10)
      .map(o => ({ id: o.native, display: o.native }));
  }
};

export default EmojiReplacements;

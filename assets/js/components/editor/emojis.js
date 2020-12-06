import React from "react";
import { emojiIndex } from "emoji-mart";

const EmojiReplacements = {
  trigger: /:[\w_+-]*$/,
  suggestions: (term, cb) => {
    let found = [];
    term = term.substr(1);

    if (term.length <= 0) {
      found = Object.values(emojiIndex.emojis);
    } else {
      found = emojiIndex.search(term);
    }

    const suggestions = found
      .slice(0, 10)
      .map((o) => ({ id: o.id, display: o.native }))
      .filter((o) => !!o.id);

    return cb(suggestions);
  },
  render: ({ id, display }) => (
    <>
      {display} :{id}
    </>
  ),
  complete: ({ id, display }) => display,
};

export default EmojiReplacements;

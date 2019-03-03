import React from "react";
import { render } from "react-dom";

import TagList from "../components/taglist";

const setupTaglist = () => {
  const el = document.querySelector(".cf-form-tagslist");
  if (!el) {
    return;
  }

  const tags = Array.from(el.querySelectorAll('input[data-tag="yes"]'))
    .filter(t => !!t.value)
    .map(t => {
      const elem = t.previousElementSibling.querySelector(".error");
      return [t.value, elem ? elem.textContent : null];
    });

  let globalTagsError = null;
  const globalTagsErrorElement = el.closest("fieldset").querySelector(".help.error");

  if (globalTagsErrorElement) {
    globalTagsError = globalTagsErrorElement.textContent;
  }

  let text = null;
  const post = document.querySelector(".cf-posting-content");
  if (post) {
    text = post.innerText;
  }

  const node = document.createElement("div");
  node.classList.add("cf-content-form");

  const fset = el.closest("fieldset");
  fset.parentElement.insertBefore(node, fset);

  fset.remove();

  render(<TagList tags={tags} postingText={text} globalTagsError={globalTagsError} />, node);
};

export default setupTaglist;

import { diffLines } from "diff";
import { clearChildren } from "../modules/helpers";

const elements = Array.from(document.querySelectorAll(".cf-posting-content-diff"));

elements.forEach((element, idx) => {
  if (idx >= elements.length - 1) return;

  const content = element.textContent;
  const prevContent = elements[idx + 1].textContent;

  const diff = diffLines(prevContent, content, { newlineIsToken: true });
  const fragment = document.createDocumentFragment();

  diff.forEach((part) => {
    const tag = part.added ? "ins" : part.removed ? "del" : "span";
    const element = document.createElement(tag);
    element.appendChild(document.createTextNode(part.value));
    fragment.appendChild(element);
  });

  clearChildren(element);
  element.appendChild(fragment);
});

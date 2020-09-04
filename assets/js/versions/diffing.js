import { diffLines, diffChars } from "diff";
import { clearChildren } from "../modules/helpers";

const elements = Array.from(document.querySelectorAll(".cf-posting-content-diff"));

elements.forEach((element, idx) => {
  if (idx >= elements.length - 1) return;

  const content = element.textContent;
  const prevContent = elements[idx + 1].textContent;

  const diff = diffLines(prevContent, content, { newlineIsToken: true });
  const fragment = document.createDocumentFragment();

  diff.forEach((part, idx) => {
    const tag = part.added ? "ins" : part.removed ? "del" : "span";
    let value;

    if (idx < diff.length - 1) {
      const prevPart = diff[idx + 1];

      if ((prevPart.added && part.removed) || (prevPart.removed && part.added)) {
        const lineDiff = diffChars(part.value, prevPart.value);
        value = document.createDocumentFragment();

        lineDiff.forEach((linePart) => {
          if ((part.added && linePart.removed) || (part.removed && linePart.added)) return;

          const lineTag = linePart.added ? "ins" : linePart.removed ? "del" : "span";
          const lineElement = document.createElement(lineTag);
          lineElement.appendChild(document.createTextNode(linePart.value));
          value.appendChild(lineElement);
        });
      }
    }

    if (!value) {
      value = document.createTextNode(part.value);
    }

    const element = document.createElement(tag);
    element.appendChild(value);
    fragment.appendChild(element);
  });

  clearChildren(element);
  element.appendChild(fragment);
});

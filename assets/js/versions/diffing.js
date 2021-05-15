import Diff from "text-diff";
import { clearChildren, parse } from "../modules/helpers";

const elements = Array.from(document.querySelectorAll(".cf-posting-content-diff"));
const differ = new Diff();

elements.forEach((element, idx) => {
  if (idx >= elements.length - 1) return;

  const content = element.textContent;
  const prevContent = elements[idx + 1].textContent;

  const diff = differ.main(prevContent, content);
  const fragment = parse(differ.prettyHtml(diff));

  clearChildren(element);
  element.appendChild(fragment);
});

import { conf } from "./modules/helpers";
import { t } from "./modules/i18n";

const unfold = ev => {
  const btn = ev.target;
  const posting = btn.closest(".posting-nested");
  posting.classList.toggle("folded");

  if (posting.classList.contains("folded")) {
    btn.firstChild.textContent = t("unfold");
  } else {
    btn.firstChild.textContent = t("fold");
  }
};

const foldMessage = el => {
  const posting = el.closest(".posting-nested");

  const node = document.createElement("button");
  node.type = "button";
  node.addEventListener("click", unfold);
  node.classList.add("cf-message-header-unfold-button");
  node.setAttribute("aria-live", "assertive");

  posting.querySelector(".cf-message-header .details").appendChild(node);

  if (!posting.classList.contains("active")) {
    node.appendChild(document.createTextNode(t("unfold")));
    posting.classList.add("folded");
  } else {
    node.appendChild(document.createTextNode(t("fold")));
  }
};

document.addEventListener("cf:configDidLoad", () => {
  if (!conf("fold_read_nested")) {
    return;
  }

  document
    .querySelectorAll(".cf-thread-nested .cf-thread-message > .posting-header > .cf-message-header.visited")
    .forEach(el => foldMessage(el));

  document.querySelector(".cf-thread-nested .cf-thread-message.active").scrollIntoView();
});

import { parse } from "../helpers";

import { maybeCloseThread, openOrCloseThread } from "./open_close";
import { hideThread, maybeHide } from "./hide";

const addIcons = el => {
  const id = el.closest(".cf-thread").id;
  const closeState = localStorage.getItem(`${id}_oc_state`);
  const icon = closeState === "closed" ? "svg-folder-closed" : "svg-folder-open";

  const node = parse(
    `<div class="thread-icons">
      <button class="icon-button open-close">
        <svg width="22" height="14" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg"><use xlink:href="/images/icons.svg#${icon}"></use></svg>
      </button>
      <button class="icon-button hide">
        <svg width="22" height="14" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg"><use xlink:href="/images/icons.svg#svg-remove"></use></svg>
      </button>
     </div>`
  );
  el.appendChild(node);
};

const handleClick = ev => {
  const target = ev.target.closest("button");
  if (!target.classList.contains("icon-button")) {
    return;
  }

  ev.preventDefault();
  const thread = target.closest(".cf-thread");

  if (target.classList.contains("open-close")) {
    openOrCloseThread(thread);
  } else if (target.classList.contains("hide")) {
    hideThread(thread);
  }
};

const setupAnonynmous = () => {
  document
    .querySelectorAll(
      "[data-controller='ThreadController'][data-action='index'] .cf-thread-list .cf-thread > .cf-message-header"
    )
    .forEach(el => {
      if (!maybeHide(el)) {
        maybeCloseThread(el);
        addIcons(el);
      }
    });

  const el = document.querySelector("[data-controller='ThreadController'][data-action='index'] .cf-thread-list");
  if (el) {
    el.addEventListener("click", handleClick);
  }
};

export default setupAnonynmous;

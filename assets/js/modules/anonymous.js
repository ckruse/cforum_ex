import { parse } from "./helpers";

const addIcons = el => {
  const id = el.closest(".cf-thread").id;
  const closeState = localStorage.getItem(`${id}_oc_state`);

  const node = parse(
    `<div class="thread-icons">
      <button class="icon-button open-close">
        <svg width="22" height="14" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#${
          closeState === "closed" ? "svg-folder-closed" : "svg-folder-open"
        }"></use></svg>
      </button>
      <button class="icon-button hide">
        <svg width="22" height="14" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#svg-remove"></use></svg>
      </button>
     </div>`
  );
  el.appendChild(node);
};

const maybeHide = el => {
  const thread = el.closest(".cf-thread");
  const id = thread.id;

  const state = localStorage.getItem(`${id}_hidden_state`);
  if (state === "hidden") {
    thread.remove();
    return true;
  }

  return false;
};

const maybeCloseThread = el => {
  const thread = el.closest(".cf-thread");
  const id = thread.id;
  const state = localStorage.getItem(`${id}_oc_state`);

  if (state === "closed") {
    thread.classList.add("closed");
  }
};

const hideThread = thread => {
  const id = thread.id;

  localStorage.setItem(`${id}_hidden_state`, "hidden");
  thread.remove();
};

const openOrCloseThread = thread => {
  const id = thread.id;
  const state = localStorage.getItem(`${id}_oc_state`);
  let newState = "closed";

  if (state === "closed") {
    newState = "open";
  }

  localStorage.setItem(`${id}_oc_state`, newState);
  thread.classList.toggle("closed");
  const svg = thread.querySelector(".cf-message-header .icon-button.open-close svg use");
  svg.setAttribute("xlink:href", "#svg-folder-" + newState);
};

const handleClick = ev => {
  if (!ev.target.classList.contains("icon-button")) {
    return;
  }

  ev.preventDefault();
  const thread = ev.target.closest(".cf-thread");

  if (ev.target.classList.contains("open-close")) {
    openOrCloseThread(thread);
  } else if (ev.target.classList.contains) {
    hideThread(thread);
  }
};

if (!document.body.dataset.userId) {
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
}

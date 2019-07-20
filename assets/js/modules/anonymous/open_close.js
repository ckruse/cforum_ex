export const maybeCloseThread = el => {
  const thread = el.closest(".cf-thread");
  const id = thread.id;
  const state = localStorage.getItem(`${id}_oc_state`);

  if (state === "closed") {
    thread.classList.add("closed");
  }
};

export const openOrCloseThread = thread => {
  const id = thread.id;
  const state = localStorage.getItem(`${id}_oc_state`);
  let newState = "closed";

  if (state === "closed") {
    newState = "open";
  }

  localStorage.setItem(`${id}_oc_state`, newState);
  thread.classList.toggle("closed");
  const svg = thread.querySelector(".cf-message-header .icon-button.open-close svg use");
  svg.setAttribute("xlink:href", "/images/icons.svg#svg-folder-" + newState);
};

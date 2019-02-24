export const maybeHide = el => {
  const thread = el.closest(".cf-thread");
  const id = thread.id;

  const state = localStorage.getItem(`${id}_hidden_state`);
  if (state === "hidden") {
    thread.remove();
    return true;
  }

  return false;
};

export const hideThread = thread => {
  const id = thread.id;

  localStorage.setItem(`${id}_hidden_state`, "hidden");
  thread.remove();
};

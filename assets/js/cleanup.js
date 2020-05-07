import { isBefore, addDays, parseJSON } from "date-fns";

const MAX_DRAFT_AGE = 14;

const cleanupLocalstorage = () => {
  const keys = Object.keys(window.localStorage);
  keys.forEach((key) => {
    if (!key.match(/_draft$/)) {
      return;
    }

    const draft = JSON.parse(localStorage.getItem(key));
    if (draft.saved && !isBefore(new Date(), addDays(parseJSON(draft.saved), MAX_DRAFT_AGE))) {
      localStorage.removeItem(key);
    }
  });
};

document.addEventListener("DOMContentLoaded", cleanupLocalstorage);

window.setInterval(cleanupLocalstorage, 36000);

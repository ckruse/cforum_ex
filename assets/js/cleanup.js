import { parse, isBefore, addDays } from "date-fns";

const MAX_DRAFT_AGE = 14;

const cleanupLocalstorage = () => {
  const keys = Object.keys(window.localStorage);
  keys.forEach(key => {
    if (!key.match(/_draft$/)) {
      return;
    }

    const draft = JSON.parse(localStorage.getItem(key));
    if (draft.saved && !isBefore(new Date(), addDays(parse(draft.saved), MAX_DRAFT_AGE))) {
      localStorage.removeItem(key);
    }
  });
};

document.addEventListener("DOMContentLoaded", cleanupLocalstorage);

window.setInterval(cleanupLocalstorage, 36000);

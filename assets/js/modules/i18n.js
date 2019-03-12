import { lang as de } from "../l10n/de.js";

const l10nData = {
  de: de
};

const defaultLanguage = de;

export const t = function(key, placeholders = {}) {
  const lang = l10nData[window.navigator.language] || defaultLanguage;
  if (!lang[key]) {
    return key;
  }

  let msg = lang[key] || key;
  Object.keys(placeholders).forEach(key => {
    msg = msg.replace(new RegExp(`{${key}}`, "g"), placeholders[key]);
  });

  return msg;
};

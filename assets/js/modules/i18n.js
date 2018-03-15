import { lang as de } from "../l10n/de.js";

const l10nData = {
  de: de
};

const defaultLanguage = de;

export const t = function(key) {
  const lang = l10nData[window.navigator.language] || defaultLanguage;
  if (!lang[key]) {
    return key;
  }

  return lang[key];
};

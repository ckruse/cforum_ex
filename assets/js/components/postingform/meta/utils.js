import { t } from "../../../modules/i18n";

const CONSTRAINTS = {
  message_author: { minLen: 2, maxLen: 50, required: true },
  message_email: { minLen: 6, maxLen: 60, required: false },
  message_subject: { minLen: 4, maxLen: 250, required: true },
  message_homepage: { minLen: 2, maxLen: 250, required: false },
  message_problematic_site: { minLen: 2, maxLen: 250, required: false },
  message_forum_id: { required: true }
};

export const isValid = (name, values) => {
  const val = values[name] || "";
  const len = val.length;

  if (CONSTRAINTS[name].required && !val) return false;
  if (val && CONSTRAINTS[name].minLen && len < CONSTRAINTS[name].minLen) return false;
  if (val && CONSTRAINTS[name].maxLen && len > CONSTRAINTS[name].maxLen) return false;

  return true;
};

export const hasErrorClass = (name, errors, touched, values) => {
  if (errors[name]) return "has-error";
  if (touched[name] && !isValid(name, values)) return "has-error";
  if (touched[name]) return "is-valid";

  return "";
};

export const hasMoreThanOneForum = forums => forums.filter(f => f.value !== "").length > 1;

export const showAuthor = () =>
  (!document.body.dataset.userId || document.body.dataset.moderator === "true") &&
  document.cookie.indexOf("cforum_author=") === -1;

const message = (val, len, minLen, maxLen, required) => {
  if (required && !val) return t("may not be empty");
  if (val && len < minLen) return t("should have at least {minLen} characters", { minLen });
  if (val && len > maxLen) return t("should have at most {maxLen} characters", { maxLen });

  return null;
};

export const getError = (name, errors, values, touched) => {
  if (errors[name]) return errors[name];
  if (!touched[name]) return null;

  const val = values[name] || "";
  const len = val.length;

  return message(val, len, CONSTRAINTS[name].minLen, CONSTRAINTS[name].maxLen, CONSTRAINTS[name].required);
};

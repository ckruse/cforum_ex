import { t } from "../../../modules/i18n";

const CONSTRAINTS = {
  message_author: { minLen: 2, maxLen: 50, required: true },
  message_email: { minLen: 6, maxLen: 60, required: false, type: "email" },
  message_subject: { minLen: 4, maxLen: 250, required: true },
  message_homepage: { minLen: 2, maxLen: 250, required: false, type: "url" },
  message_problematic_site: { minLen: 2, maxLen: 250, required: false, type: "url" },
  message_forum_id: { required: true },
};

const isUrl = (val) => {
  try {
    new URL(val);
    return true;
  } catch (_v) {
    return false;
  }
};

const isEmail = (val) => /^[^@]+@[^@\s]+/.test(val);

export const isValid = (name, values) => {
  const val = values[name] || "";
  const len = val.length;

  if (CONSTRAINTS[name]) {
    if (CONSTRAINTS[name].required && !val) return false;
    if (val && CONSTRAINTS[name].minLen && len < CONSTRAINTS[name].minLen) return false;
    if (val && CONSTRAINTS[name].maxLen && len > CONSTRAINTS[name].maxLen) return false;
    if (val && CONSTRAINTS[name].type === "url") return isUrl(val);
    if (val && CONSTRAINTS[name].type === "email") return isEmail(val);
  }

  return true;
};

export const hasErrorClass = (name, errors, touched, values) => {
  if (errors[name]) return "has-error";
  if (touched[name] && !isValid(name, values)) return "has-error";
  if (touched[name]) return "is-valid";

  return "";
};

export const hasMoreThanOneForum = (forums) => forums.filter((f) => f.value !== "").length > 1;

export const showAuthor = () => {
  const isRegistered = !!document.body.dataset.userId;
  const isModerator = document.body.dataset.moderator === "true";
  const isKnown = document.cookie.indexOf("cforum_author=") !== -1;
  const isEditing = document.body.dataset.action === "edit";

  if (isModerator && isEditing) return true;
  if (isRegistered || isKnown) return false;
  return true;
};

const message = (val, len, minLen, maxLen, required, type) => {
  if (required && !val) return t("may not be empty");
  if (val && len < minLen) return t("should have at least {minLen} characters", { minLen });
  if (val && len > maxLen) return t("should have at most {maxLen} characters", { maxLen });
  if (val && type === "url" && !isUrl(val)) return t("should be an URL");
  if (val && type === "email" && !isEmail(val)) return t("should be an email");

  return null;
};

export const getError = (name, errors, values, touched) => {
  if (errors[name]) return errors[name];
  if (!touched[name]) return null;

  const val = values[name] || "";
  const len = val.length;

  if (!CONSTRAINTS[name]) return null;

  return message(
    val,
    len,
    CONSTRAINTS[name].minLen,
    CONSTRAINTS[name].maxLen,
    CONSTRAINTS[name].required,
    CONSTRAINTS[name].type
  );
};

import { parseMessageUrl } from "../modules/helpers";
import { alertError } from "../modules/alerts";
import { t } from "../modules/i18n";

export const openThreadHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({ slug: parsedUrl.slug, forum: document.body.dataset.currentForum });

  return { url: "/api/v1/threads/close" };
};

export const closeThreadHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({ slug: parsedUrl.slug, forum: document.body.dataset.currentForum });

  return { url: "/api/v1/threads/open" };
};

export const hideThreadHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({ slug: parsedUrl.slug, forum: document.body.dataset.currentForum });

  return {
    url: "/api/v1/threads/hide",
    afterAction: response => {
      response.json().then(json => {
        if (json.status === "ok") {
          form.closest(".cf-thread").remove();
        } else {
          alertError(t("Oops, something went wrong!"));
        }
      });
    }
  };
};

export const unhideThreadHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({ slug: parsedUrl.slug, forum: document.body.dataset.currentForum });

  return {
    url: "/api/v1/threads/unhide",
    afterAction: response => {
      response.json().then(json => {
        if (json.status === "ok") {
          form.closest(".cf-thread").remove();
        } else {
          alertError(t("Oops, something went wrong!"));
        }
      });
    }
  };
};

export const noArchiveHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({ slug: parsedUrl.slug, forum: document.body.dataset.currentForum });

  return { url: "/api/v1/threads/no-archive" };
};

export const doArchiveHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({ slug: parsedUrl.slug, forum: document.body.dataset.currentForum });

  return { url: "/api/v1/threads/do-archive" };
};

export const markReadHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({
    slug: parsedUrl.slug,
    forum: document.body.dataset.currentForum,
    fold: document.body.dataset.controller !== "MessageController" ? "yes" : "no"
  });

  return { url: "/api/v1/messages/mark-read" };
};

export const markInterestingHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({
    slug: parsedUrl.slug,
    message_id: parsedUrl.messageId,
    forum: document.body.dataset.currentForum,
    fold: document.body.dataset.controller !== "MessageController" ? "yes" : "no"
  });

  return { url: "/api/v1/messages/interesting" };
};

export const markBoringHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({
    slug: parsedUrl.slug,
    message_id: parsedUrl.messageId,
    forum: document.body.dataset.currentForum,
    fold: document.body.dataset.controller !== "MessageController" ? "yes" : "no"
  });

  const retval = { url: "/api/v1/messages/boring" };

  if (document.body.dataset.controller === "Messages.InterestingController") {
    retval.afterAction = response => {
      if (response.status === 200) {
        form.closest(".cf-thread").remove();
      } else {
        alertError(t("Oops, something went wrong!"));
      }
    };
  }

  return retval;
};

export const subscribeMessageHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({
    slug: parsedUrl.slug,
    message_id: parsedUrl.messageId,
    forum: document.body.dataset.currentForum,
    fold: document.body.dataset.controller !== "MessageController" ? "yes" : "no"
  });

  return { url: "/api/v1/messages/subscribe" };
};

export const unsubscribeMessageHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({
    slug: parsedUrl.slug,
    message_id: parsedUrl.messageId,
    forum: document.body.dataset.currentForum,
    fold: document.body.dataset.controller !== "MessageController" ? "yes" : "no"
  });

  const retval = { url: "/api/v1/messages/unsubscribe" };

  if (document.body.dataset.controller === "Messages.SubscriptionController") {
    retval.afterAction = response => {
      if (response.status == 200) {
        form.closest(".cf-thread").remove();
      } else {
        alertError(t("Oops, something went wrong!"));
      }
    };
  }

  return retval;
};

export const deleteHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({
    slug: parsedUrl.slug,
    message_id: parsedUrl.messageId,
    forum: document.body.dataset.currentForum
  });

  return { url: "/api/v1/messages/delete" };
};

export const restoreHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({
    slug: parsedUrl.slug,
    message_id: parsedUrl.messageId,
    forum: document.body.dataset.currentForum
  });
  return { url: "/api/v1/messages/restore" };
};

export const noAnswerHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({
    slug: parsedUrl.slug,
    message_id: parsedUrl.messageId,
    forum: document.body.dataset.currentForum
  });

  return { url: "/api/v1/messages/no-answer" };
};

export const doAnswerHelper = (requestParams, form) => {
  const parsedUrl = parseMessageUrl(form.action);

  requestParams.method = "POST";
  requestParams.headers = { "Content-Type": "application/json; charset=utf-8" };
  requestParams.body = JSON.stringify({
    slug: parsedUrl.slug,
    message_id: parsedUrl.messageId,
    forum: document.body.dataset.currentForum
  });

  return { url: "/api/v1/messages/answer" };
};

import { parseMessageUrl } from "../modules/helpers";
import { alertError, alertSuccess } from "../modules/alerts";
import { t } from "../modules/i18n";

const voteForMessage = async (ev) => {
  if (ev.target.nodeName !== "BUTTON") {
    return;
  }

  ev.preventDefault();

  const btn = ev.target;
  const form = btn.closest("form");
  const url = form.action.replace(/\/(accept|unaccept|upvote|downvote)(?:\?.*)?$/, "");
  const type = RegExp.$1;
  const parsedUrl = parseMessageUrl(url);

  const inp = form.querySelector("[name='_csrf_token']");
  if (!inp) {
    return;
  }

  btn.classList.add("loading");
  btn.disabled = true;

  const params = {
    _csrf_token: inp.value,
    message_id: parsedUrl.messageId,
    slug: parsedUrl.slug,
    forum: parsedUrl.forum,
  };

  const targetUrl = `/api/v1/messages/${type}`;

  try {
    const rsp = await fetch(targetUrl, {
      credentials: "same-origin",
      method: "POST",
      body: JSON.stringify(params),
      headers: { "Content-Type": "application/json; charset=utf-8" },
    });
    const json = await rsp.json();

    updateVotingAreas(json, type, btn.closest(".cf-thread-message"), btn);
  } catch (e) {
    handleError(btn);
  }
};

const handleError = (btn) => {
  alertError(t("Oops, something went wrong!"));
  btn.classList.remove("loading");
  btn.disabled = false;
};

const updateVotingAreas = (json, type, message, btn) => {
  btn.classList.remove("loading");
  btn.disabled = false;

  const opposite = json.accepted ? "unaccept" : "accept";
  const klass = json.accepted ? "accepted-answer" : "unaccepted-answer";
  const areas = message.querySelectorAll(".cf-voting-area");

  switch (type) {
    case "accept":
      alertSuccess(t("You successfully accepted this answer."));
      break;
    case "unaccept":
      alertSuccess(t("You successfully unaccepted this answer."));
      break;
    case "upvote":
      if (json.upvoted) {
        alertSuccess(t("You successfully voted this message positively."));
      } else {
        alertSuccess(t("You successfully took back you vote."));
      }
      break;
    case "downvote":
      if (json.downvoted) {
        alertSuccess(t("You successfully voted this message negatively."));
      } else {
        alertSuccess(t("You successfully took back you vote."));
      }
      break;

    default:
      console.log(type, json, message);
  }

  areas.forEach((area) => {
    const downButton = area.querySelector(".vote-down");
    const upButton = area.querySelector(".vote-up");
    const acceptButton = area.querySelector(".accept");

    if (type === "accept" || type === "unaccept") {
      if (acceptButton) {
        acceptButton.classList.remove("accepted-answer", "unaccepted-answer");
        acceptButton.classList.add(klass);
        acceptButton.closest("form").action = acceptButton.closest("form").action.replace(/accept|unaccept/, opposite);
      }
    } else {
      area.querySelector(".votes").textContent = json.score_str;

      if (downButton) {
        setButtonStatus(downButton, json.downvoted);
      }

      if (upButton) {
        setButtonStatus(upButton, json.upvoted);
      }
    }
  });
};

const setButtonStatus = (button, active) => {
  if (active) {
    button.classList.add("active");
  } else {
    button.classList.remove("active");
  }
};

if (document.body.dataset.controller === "MessageController") {
  document.querySelectorAll(".cf-voting-area.bottom").forEach((elem) => elem.addEventListener("click", voteForMessage));
}

import { parseMessageUrl } from "./modules/helpers";
import { alertError } from "./alerts";
import { t } from "./modules/i18n";

const voteForMessage = ev => {
  if (ev.target.nodeName !== "BUTTON") {
    return;
  }

  ev.preventDefault();

  const btn = ev.target;
  const form = btn.closest("form");
  const url = form.action.replace(/\/(accept|unaccept|upvote|downvote)$/, "");
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
    forum: parsedUrl.forum
  };

  const targetUrl = `/api/v1/messages/${type}`;

  fetch(targetUrl, {
    credentials: "same-origin",
    method: "POST",
    body: JSON.stringify(params),
    headers: { "Content-Type": "application/json; charset=utf-8" }
  })
    .then(rsp => rsp.json(), err => handleError(btn))
    .then(json => updateVotingAreas(json, type, btn.closest(".cf-thread-message"), btn));
};

const handleError = btn => {
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

  areas.forEach(area => {
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
  document.querySelectorAll(".cf-voting-area.bottom").forEach(elem => elem.addEventListener("click", voteForMessage));
}

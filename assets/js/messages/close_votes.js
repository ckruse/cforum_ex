import { parseMessageUrl } from "../modules/helpers";
import { t } from "../modules/i18n";
import { alertSuccess, alertError } from "../modules/alerts";

const voteOrUnvote = ev => {
  ev.preventDefault();

  const form = ev.target.closest("form");
  const parsedUrl = parseMessageUrl(form.action.replace(/\/oc-vote\/\d+$/, ""));
  const inp = form.querySelector("[name='_csrf_token']");
  if (!inp) {
    return;
  }

  const params = {
    _csrf_token: inp.value,
    message_id: parsedUrl.messageId,
    slug: parsedUrl.slug,
    forum: parsedUrl.forum,
    id: form.action.replace(/.*\//, "")
  };

  fetch("/api/v1/messages/open-close-vote", {
    credentials: "same-origin",
    method: "POST",
    body: JSON.stringify(params),
    headers: { "Content-Type": "application/json; charset=utf-8" }
  })
    .then(rsp => rsp.json(), err => handleError(err))
    .then(json => updateState(json, ev.target));
};

const handleError = err => {
  console.log(err);
  alertError(t("Oops, something went wrong!"));
};

const updateState = (json, btn) => {
  if (json.status === "ok") {
    const msg = btn.classList.contains("vote") ? t("I changed my mind") : t("I agree");
    btn.textContent = msg;
    btn.classList.toggle("vote");
    btn.classList.toggle("unvote");

    const heading = btn.closest(".cf-close-vote").querySelector("h3");
    heading.textContent = heading.textContent.replace(/\(\d+\/\d+\)/, `(${json.votes}/${json.votes_needed})`);

    alertSuccess(json.message);
  } else {
    alertError(t("Oops, something went wrong!"));
  }
};

document.querySelectorAll(".close-vote-button").forEach(el => el.addEventListener("click", voteOrUnvote));

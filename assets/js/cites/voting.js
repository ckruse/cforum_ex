import { alertError, alertSuccess } from "../modules/alerts";
import { t } from "../modules/i18n";

const voteForMessage = (ev) => {
  if (ev.target.nodeName !== "BUTTON") {
    return;
  }

  ev.preventDefault();

  const btn = ev.target;
  const form = btn.closest("form");
  const url = new URL(form.action);
  if (!url.pathname.match(/\/cites\/(\d+)\/vote$/)) {
    return;
  }

  const id = RegExp.$1;
  const type = btn.value;

  const inp = form.querySelector("[name='_csrf_token']");
  if (!inp) {
    return;
  }

  btn.classList.add("loading");
  btn.disabled = true;

  const params = {
    _csrf_token: inp.value,
    type,
    id,
  };

  fetch("/api/v1/cites/vote", {
    credentials: "same-origin",
    method: "POST",
    body: JSON.stringify(params),
    headers: { "Content-Type": "application/json; charset=utf-8" },
  })
    .then(
      (rsp) => rsp.json(),
      (err) => handleError(btn)
    )
    .then((json) => updateVotingAreas(json, type, btn.closest(".cf-cite"), btn));
};

const handleError = (btn) => {
  alertError(t("Oops, something went wrong!"));
  btn.classList.remove("loading");
  btn.disabled = false;
};

const updateVotingAreas = (json, type, cite, btn) => {
  btn.classList.remove("loading");
  btn.disabled = false;

  const areas = cite.querySelectorAll(".cf-voting-area-cites");

  switch (type) {
    case "up":
      if (json.upvoted) {
        alertSuccess(t("You successfully voted this message positively."));
      } else {
        alertSuccess(t("You successfully took back you vote."));
      }
      break;

    case "down":
      if (json.downvoted) {
        alertSuccess(t("You successfully voted this message negatively."));
      } else {
        alertSuccess(t("You successfully took back you vote."));
      }
      break;

    default:
      console.log(type, json, cite);
  }

  areas.forEach((area) => {
    const downButton = area.querySelector(".vote-down");
    const upButton = area.querySelector(".vote-up");

    area.querySelector(".votes").textContent = json.score_str;

    if (downButton) {
      setButtonStatus(downButton, json.downvoted);
    }

    if (upButton) {
      setButtonStatus(upButton, json.upvoted);
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

document.querySelectorAll(".cf-voting-area-cites").forEach((elem) => elem.addEventListener("click", voteForMessage));

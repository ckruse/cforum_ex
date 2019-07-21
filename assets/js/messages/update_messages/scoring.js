import { t } from "../../modules/i18n";
import { getMessageTreeElement } from "./index";

const votesTitle = params => {
  const noVotes = params.upvotes + params.downvotes;

  if (noVotes === 0) {
    return t("scoring: no scores");
  }

  return t("scoring: {score}", { score: params.score_str });
};

const updateMessageTree = params => {
  const elem = getMessageTreeElement(params.message_id);
  if (!elem) {
    return;
  }

  const votes = elem.querySelector(".votes");
  votes.setAttribute("title", votesTitle(params));
  votes.textContent = params.upvotes - params.downvotes;
};

const updateVotingArea = params => {
  const elem = document.getElementById(`m${params.message_id}`);

  if (!elem) {
    return;
  }

  const thread = elem.closest(".cf-thread-message");
  if (!thread) {
    return;
  }

  thread.querySelectorAll(".cf-voting-area .votes").forEach(votes => {
    votes.setAttribute("title", votesTitle(params));
    votes.textContent = params.score_str;
  });
};

document.addEventListener("cf:forumChannel", event => event.detail.channel.on("message_rescored", updateMessageTree));
document.addEventListener("cf:forumChannel", event => event.detail.channel.on("message_rescored", updateVotingArea));

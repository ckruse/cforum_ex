import { parse } from "../../modules/helpers";
import { t } from "../../modules/i18n";

export default function restore(ev, button) {
  ev.preventDefault();
  const mid = button.dataset.mid;
  const slug = button.dataset.slug;

  restoreMessage(button, slug, mid);
}

async function restoreMessage(button, slug, messageId) {
  button.classList.add("loading");

  const response = await fetch("/api/v1/messages/restore", {
    method: "POST",
    credentials: "same-origin",
    cache: "no-cache",
    headers: { "Content-Type": "application/json; charset=utf-8" },
    body: JSON.stringify({
      slug,
      message_id: messageId,
      forum: document.body.dataset.currentForum,
      id_prefix: document.body.dataset.controller === "MessageController" ? "tree-" : ""
    })
  });

  const html = await response.text();
  const node = parse(html);
  const message = document.getElementById("tree-m" + messageId) || document.getElementById("m" + messageId);
  message.closest(".cf-thread").replaceWith(node);

  button.classList.remove("loading");

  const btt = document.querySelector(`.admin-links button[data-js="restore"][data-mid="${messageId}"]`);
  if (btt) {
    btt.dataset.js = "delete";
    btt.textContent = t("delete this message");
  }
}

import { parse } from "../../modules/helpers";

export default function restore(ev, button) {
  ev.preventDefault();
  const mid = button.dataset.mid;
  const slug = button.dataset.slug;

  restoreMessage(slug, mid);
}

async function restoreMessage(slug, messageId) {
  const response = await fetch("/api/v1/messages/restore", {
    method: "POST",
    credentials: "same-origin",
    cache: "no-cache",
    headers: { "Content-Type": "application/json; charset=utf-8" },
    body: JSON.stringify({
      slug,
      message_id: messageId,
      forum: document.body.dataset.currentForum
    })
  });

  const html = await response.text();
  const node = parse(html);
  const message = document.getElementById("tree-m" + messageId) || document.getElementById("m" + messageId);
  message.closest(".cf-thread").replaceWith(node);
}

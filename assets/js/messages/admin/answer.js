import { parse } from "../../modules/helpers";

export default function answer(ev, button) {
  ev.preventDefault();

  const mid = button.dataset.mid;
  const slug = button.dataset.slug;

  allowAnswer(slug, mid);
}

async function allowAnswer(slug, messageId) {
  const response = await fetch("/api/v1/messages/answer", {
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

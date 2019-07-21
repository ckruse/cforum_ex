import { queryString, parse, conf } from "../modules/helpers";
import { setNewFavicon } from "../title_infos";

const NEW_MESSAGES = [];

const insertRenderedThread = (thread, message, html) => {
  const node = parse(html).firstChild;
  const sortThreads = conf("sort_threads");
  const threadlist = document.querySelector(".cf-thread-list");
  const originalNode = document.getElementById(node.id);

  const messageNode = node.querySelector("[id=m" + message.message_id + "]");
  if (messageNode) {
    const svgNode = parse(
      '<svg class="new-svg" width="22" height="14" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg"><use xlink:href="/images/icons.svg#svg-new"></use></svg>'
    ).firstChild;
    messageNode.classList.add("new");
    messageNode.insertBefore(svgNode, messageNode.querySelector(".details").nextSibling);
  }

  switch (sortThreads) {
    case "ascending":
    case "descending":
      if (originalNode) {
        originalNode.replaceWith(node);
        return;
      }

      if (sortThreads === "ascending") {
        threadlist.appendChild(node);
      } else {
        threadlist.insertBefore(node, threadlist.querySelector(".cf-thread:not(.sticky)"));
      }

      break;

    // "newest-first" is the default
    default:
      if (originalNode) {
        originalNode.remove();
      }

      threadlist.insertBefore(node, threadlist.querySelector(".cf-thread:not(.sticky)"));
  }
};

const autoloadMessage = ev => {
  const { thread, message, forum } = ev.detail.data;

  if (!["all", forum.slug].includes(document.body.dataset.currentForum)) {
    return;
  }

  const slug = document.body.dataset.currentForum === "all" ? "all" : forum.slug;

  NEW_MESSAGES.push(message.message_id);

  const qs = queryString({ message_id: message.message_id, invisible: "no" });
  fetch(`/${slug}${thread.slug}?${qs}`, { credentials: "same-origin" })
    .then(rsp => {
      if (rsp.ok) {
        return rsp.text();
      }

      return "";
    })
    .then(
      text => {
        if (!text) {
          return;
        }

        setNewFavicon();
        insertRenderedThread(thread, message, text);
      },
      error => console.log(error)
    )
    .then(succs => console.log(succs), err => console.log(err));
};

export default () => document.addEventListener("cf:newMessage", autoloadMessage);

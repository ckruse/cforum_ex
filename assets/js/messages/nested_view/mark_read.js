import { privateUserChannel } from "../../socket";
import { conf } from "../../modules/helpers";

const options = {
  root: null,
  rootMargin: "0px",
  threshold: 0.4
};

const observerCallback = (entries, observer, channel) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const thread = entry.target.closest(".cf-thread-message");
      const header = thread.querySelector(".cf-message-header");

      if (header.classList.contains("visited") || thread.classList.contains("archived")) {
        return;
      }

      const message_id = header.getAttribute("id").replace(/^m/, "");
      channel.push("mark_read", { message_id }).receive("ok", _ => header.classList.add("visited"));
    }
  });
};

const setupObserver = event => {
  if (conf("mark_nested_read_via_js") !== "yes") {
    return;
  }

  const observer = new IntersectionObserver(
    (entries, observer) => observerCallback(entries, observer, privateUserChannel),
    options
  );

  const nodes = document.querySelectorAll(".cf-thread-nested .cf-posting-content");
  nodes.forEach(target => observer.observe(target));
};

if (window.IntersectionObserver) {
  if (window.currentConfig) {
    setupObserver();
  } else {
    document.addEventListener("cf:configDidLoad", setupObserver);
  }
}

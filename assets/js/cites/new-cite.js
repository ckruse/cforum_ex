import { parseMessageUrl } from "../modules/helpers";

const setup = (elem) => {
  elem.addEventListener("input", (ev) => {
    const url = parseMessageUrl(ev.target.value);
    const elem = document.getElementById("cite_author").closest(".cf-cgroup");

    if (!url) {
      elem.style.display = "block";
      return;
    }

    elem.classList.add("fade-in-exit");
    elem.classList.add("fade-in-exit-active");
    window.setTimeout(() => {
      elem.style.display = "none";
      elem.classList.remove("fade-in-exit", "fade-in-exit-active");
    }, 300);
  });
};

const elem = document.getElementById("cite_url");
if (elem) {
  setup(elem);
}

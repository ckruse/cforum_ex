import { t } from "./modules/i18n";

if (
  !window.NodeList ||
  !NodeList.prototype.forEach ||
  !Array.prototype.forEach ||
  !document.dispatchEvent ||
  !Element.prototype.matches ||
  typeof Event !== "function"
) {
  if (document.body.classList) {
    document.body.classList.remove("js");
  }

  const text = t(
    `You are using a very old browser. You might consider <a href="https://www.browser-update.org/de/update.html">upgrading</a>.`
  );
  const el = document.createElement("div");
  el.setAttribute("class", "cf-old-browser");
  el.innerHTML = text;

  const main = document.getElementsByTagName("main")[0];
  main.insertBefore(el, main.firstChild);

  throw new Error("Please update your browser!");
}

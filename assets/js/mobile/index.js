import { t } from "../modules/i18n";

const expand = () => {
  const quicklinks = document.querySelector(".cf-page-header .quicklinks");
  const subnav = document.querySelector(".cf-page-header .subnav");

  quicklinks.querySelector("button").remove();
  quicklinks.classList.add("expanded");
  subnav.classList.add("expanded");
};

const mql = window.matchMedia("only screen and (min-width: 35em)");

if (!mql.matches) {
  const quicklinks = document.querySelector(".cf-page-header .quicklinks");
  const btn = document.createElement("button");
  btn.classList.add("quicklinks-expand");
  btn.textContent = t("expand menu");
  btn.addEventListener("click", expand);

  quicklinks.appendChild(btn);
}

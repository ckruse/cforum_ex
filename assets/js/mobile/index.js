import { t } from "../modules/i18n";

const expand = () => {
  const quicklinks = document.querySelector(".cf-page-header .quicklinks");
  const subnav = document.querySelector(".cf-page-header .subnav");
  const personal = document.querySelector(".cf-personallinks");

  quicklinks.querySelector("button").remove();
  quicklinks.classList.add("expanded");
  subnav.classList.add("expanded");
  personal.classList.add("expanded");
};

const mql = window.matchMedia("only screen and (min-width: 35em)");
document.body.classList.add(mql.matches ? "broad" : "narrow");
window.viewType = mql.matches ? "broad" : "narrow";

if (!mql.matches) {
  const quicklinks = document.querySelector(".cf-page-header .quicklinks");
  const li = document.createElement("li");
  const btn = document.createElement("button");
  btn.classList.add("quicklinks-expand");
  btn.textContent = t("expand menu");
  btn.addEventListener("click", expand);

  li.appendChild(btn);
  quicklinks.querySelector("ul").appendChild(li);
}

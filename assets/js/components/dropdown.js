import { clearChildren } from "../modules/helpers";

export class Dropdown {
  constructor(element) {
    this.rootElement = element;
    this.menuElement = element.querySelector(".menu");

    let anchor = element.querySelector(".anchor");

    this.menuButton = document.createElement("button");
    this.menuButton.textContent = anchor.textContent;
    this.menuButton.setAttribute("type", "button");
    this.menuButton.setAttribute("aria-haspopup", "true");
    this.menuButton.setAttribute("aria-expanded", "false");

    clearChildren(anchor);
    anchor.appendChild(this.menuButton);
    element.classList.add("js");

    this.setupListeners();
  }

  setupListeners() {
    this.menuButton.addEventListener("click", ev => {
      ev.preventDefault();
      this.toggleMenu();
    });

    this.rootElement.addEventListener("keypress", ev => this.maybeHideForEsc(ev));
    this.rootElement.addEventListener("keydown", ev => this.handleUpAndDown(ev));

    this.rootElement.querySelectorAll("button, a").forEach(el => {
      el.addEventListener("blur", ev => this.checkForHideOnFocusLoss());
    });
  }

  handleUpAndDown(ev) {
    if (![40, 38, 27].includes(ev.keyCode)) {
      return;
    }

    ev.preventDefault();
    ev.stopPropagation();

    if (ev.keyCode === 27) {
      this.menuElement.querySelectorAll("li.active").forEach(el => el.classList.remove("active"));
      this.hideMenu(true);
      return;
    }

    this.showMenu(true);

    let links = this.menuElement.querySelectorAll("li a:first-of-type");
    let active = this.menuElement.querySelector("li a:first-of-type:focus");
    let direction = ev.keyCode === 40 ? 1 : -1;

    let el = this.nextFocusElement(links, active, direction);
    el.focus();
    el.closest("li").classList.add("active");

    if (active) {
      active.closest("li").classList.remove("active");
    }
  }

  nextFocusElement(links, active, direction) {
    if (!active) {
      return links[0];
    }

    for (let i = 0; i < links.length; ++i) {
      if (links[i] == active) {
        return this.nextLink(links, i, direction);
      }
    }

    return links[0];
  }

  nextLink(links, index, direction) {
    if (index + direction == links.length) {
      return links[0];
    } else if (index + direction == -1) {
      return links[links.length - 1];
    }

    return links[index + direction];
  }

  maybeHideForEsc(ev) {
    if (ev.keyCode == 27) {
      ev.preventDefault();
      this.hideMenu(true);
    }
  }

  checkForHideOnFocusLoss() {
    window.setTimeout(() => {
      let focused = this.rootElement.querySelectorAll(":focus");
      if (focused.length === 0) {
        this.hideMenu(false);
      }
    }, 200);
  }

  showMenu(omitFocus) {
    this.rootElement.classList.add("open");
    this.menuButton.setAttribute("aria-expanded", "true");

    if (!omitFocus) {
      this.menuButton.focus();
    }
  }

  hideMenu(withFocus) {
    this.rootElement.classList.remove("open");
    this.menuButton.setAttribute("aria-expanded", "false");

    if (withFocus) {
      this.menuButton.focus();
    }
  }

  toggleMenu() {
    if (this.rootElement.classList.contains("open")) {
      this.hideMenu(true);
    } else {
      this.showMenu();
    }
  }
}

document.addEventListener("DOMContentLoaded", () => {
  var mql = window.matchMedia("only screen and (min-width: 35em)");
  if (!mql.matches) {
    return;
  }

  Array.from(document.querySelectorAll("[data-dropdown='yes']")).forEach(element => new Dropdown(element));
});

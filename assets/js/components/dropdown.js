import { ready, bind, preventDefault, stopPropagation } from "../modules/events.js";
import { when } from "../modules/logic.js";
import { select, all } from "../modules/selectors.js";
import { create, clearChildren, focus } from "../modules/elements.js";
import { pipe } from "../modules/functional.js";

export class Dropdown {
  constructor(element) {
    this.rootElement = element;
    this.menuElement = select(".menu", element);

    let anchor = select(".anchor", element);

    this.menuButton = create("button");
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
    bind(this.menuButton, {
      click: pipe(
        preventDefault,
        ev => this.toggleMenu()
      )
    });

    bind(this.rootElement, {
      keypress: ev => this.maybeHideForEsc(ev),
      keydown: ev => this.handleUpAndDown(ev)
    });

    all("button, a", this.rootElement).forEach(el => {
      bind(el, {
        blur: ev => this.checkForHideOnFocusLoss()
      });
    });
  }

  handleUpAndDown(ev) {
    if (ev.keyCode != 40 && ev.keyCode != 38) {
      return;
    }

    preventDefault(ev);
    stopPropagation(ev);

    this.showMenu(true);

    let links = all("li a:first-of-type", this.menuElement);
    let active = select("li a:first-of-type:focus", this.menuElement);
    let direction = ev.keyCode == 40 ? 1 : -1;

    let el = this.nextFocusElement(links, active, direction);
    focus(el);
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
      preventDefault(ev);
      this.hideMenu(true);
    }
  }

  checkForHideOnFocusLoss() {
    window.setTimeout(() => {
      let focused = all(":focus", this.rootElement);
      if (focused.length === 0) {
        this.hideMenu(false);
      }
    }, 200);
  }

  showMenu(omitFocus) {
    this.rootElement.classList.add("open");
    this.menuButton.setAttribute("aria-expanded", "true");

    if (!omitFocus) {
      focus(this.menuButton);
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

ready(function() {
  var mql = window.matchMedia("only screen and (min-width: 35em)");
  if (!mql.matches) {
    return;
  }

  when(
    elements => elements.length,
    elements => elements.forEach(element => new Dropdown(element)),
    all("[data-dropdown='yes']")
  );
});

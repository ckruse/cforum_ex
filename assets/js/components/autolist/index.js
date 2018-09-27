import { t } from "../../modules/i18n";
import { ready, bind, preventDefault } from "../../modules/events";
import { when } from "../../modules/logic";
import { select, all } from "../../modules/selectors";
import { parse } from "../../modules/elements";
import { pipe } from "../../modules/functional";

class Autolist {
  constructor(element) {
    const tpl = select("template", element);

    this.root = element;
    this.template = tpl.content.firstElementChild;
    this.listElement = this.template.nodeName;
    this.index = 0;

    tpl.parentElement.removeChild(tpl);

    this.addButton = parse(`<button type="button" class="cf-btn">${t("add new element")}</button>`).firstChild;
    this.root.appendChild(this.addButton);

    bind(this.addButton, {
      click: pipe(
        preventDefault,
        () => this.addNewElement()
      )
    });

    const elements = all(this.listElement, this.root);
    this.index = elements[elements.length - 1].dataset.index || 0;
    elements.forEach(el => this.setupListElement(el));
  }

  setupListElement(element) {
    const btn = parse(`<button class="cf-btn" type="button">${t("remove element")}</button>`).firstChild;
    element.appendChild(btn);
    bind(btn, {
      click: pipe(
        preventDefault,
        () => this.removeElement(element)
      )
    });
  }

  removeElement(element) {
    element.parentElement.removeChild(element);
  }

  addNewElement() {
    const newNode = this.template.cloneNode(true);
    this.index += 1;
    all("input, textarea, select", newNode).forEach(el => this.updateFieldName(el));
    this.setupListElement(newNode);
    this.addButton.parentElement.insertBefore(newNode, this.addButton);
  }

  updateFieldName(el) {
    el.setAttribute("name", el.getAttribute("name").replace(/__index__/, this.index));
  }
}

const setupAutolist = function(elements) {
  elements.forEach(element => new Autolist(element));
};

ready(function() {
  when(elements => elements.length, setupAutolist, all("[data-autolist='yes']"));
});

import { t } from "../../modules/i18n";
import { parse } from "../../modules/helpers";

class Autolist {
  constructor(element) {
    const tpl = element.querySelector("template");

    this.root = element;
    this.template = tpl.content.firstElementChild;
    this.listElement = this.template.nodeName;
    this.index = 0;

    tpl.parentElement.removeChild(tpl);

    this.addButton = parse(`<button type="button" class="cf-btn">${t("add new element")}</button>`).firstChild;
    this.root.appendChild(this.addButton);

    this.addButton.addEventListener("click", ev => {
      ev.preventDefault();
      this.addNewElement();
    });

    const elements = this.root.querySelectorAll(this.listElement);
    this.index = elements[elements.length - 1].dataset.index || 0;
    elements.forEach(el => this.setupListElement(el));
  }

  setupListElement(element) {
    const btn = parse(`<button class="cf-btn" type="button">${t("remove element")}</button>`).firstChild;
    element.appendChild(btn);
    btn.addEventListener("click", ev => {
      ev.preventDefault();
      this.removeElement(element);
    });
  }

  removeElement(element) {
    element.parentElement.removeChild(element);
  }

  addNewElement() {
    const newNode = this.template.cloneNode(true);
    this.index += 1;
    newNode.querySelectorAll("input, textarea, select").forEach(el => this.updateFieldName(el));
    this.setupListElement(newNode);
    this.addButton.parentElement.insertBefore(newNode, this.addButton);
  }

  updateFieldName(el) {
    el.setAttribute("name", el.getAttribute("name").replace(/__index__/, this.index));
  }
}

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-autolist='yes']").forEach(element => new Autolist(element));
});

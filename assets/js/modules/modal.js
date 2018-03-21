import A11yDialog from "a11y-dialog";
import { t } from "./i18n.js";
import { parse } from "./elements.js";

export const createModal = function(title, content) {
  const modal = parse(`
<div class="cf-modal" aria-hidden="true">
  <div tabindex="-1" data-a11y-dialog-hide class="cf-modal-overlay"></div>
  <div role="dialog" aria-labelledby="dialog-title" class="cf-modal-content">
    <div role="document">
      <button type="button"
              data-a11y-dialog-hide
              class="cf-modal-close"
              aria-label="${t("Close this dialog window")}">&times;</button>
      <h1 id="dialog-title">${title}</h1>
    </div>
  </div>
</div>
`);

  if (content) {
    modal.querySelector("div[role='document']").appendChild(content);
  }

  const root = modal.firstElementChild;
  document.body.appendChild(modal);
  const dialog = new A11yDialog(root, document.querySelector("main"));
  dialog.create();

  return dialog;
};

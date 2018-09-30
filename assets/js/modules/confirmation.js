const disableConfiming = (element, origText) => {
  element.classList.remove("confirming");
  element.textContent = origText;
};

const enableConfirming = (event, element) => {
  element.textContent = element.dataset.confirm;
  element.classList.add("confirming");

  event.stopPropagation();
  event.preventDefault();
};

const enableConfirmation = element => {
  const text = element.textContent;

  element.addEventListener("click", event => {
    if (element.classList.contains("confirming")) {
      disableConfiming(element, text);
      element.setAttribute("aria-live", "off");
    } else {
      enableConfirming(event, element);
    }
  });

  element.addEventListener("blur", () => {
    if (element.classList.contains("confirming")) {
      disableConfiming(element, text);
    }

    element.setAttribute("aria-live", "off");
  });

  element.addEventListener("focus", () => element.setAttribute("aria-live", "assertive"));
};

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-confirm]").forEach(enableConfirmation);
});

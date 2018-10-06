document.addEventListener("DOMContentLoaded", () => {
  fetch("/api/v1/users/self", { credentials: "same-origin" })
    .then(rsp => {
      if (rsp.ok) {
        rsp.json();
      }
    })
    .then(json => {
      window.currentUser = json;
      document.dispatchEvent(new CustomEvent("cf:userDidLoad", { detail: json }));
    });

  fetch("/api/v1/config", { credentials: "same-origin" })
    .then(rsp => {
      if (rsp.ok) {
        rsp.json();
      }
    })
    .then(json => {
      window.currentConfig = json;
      document.dispatchEvent(new CustomEvent("cf:configDidLoad", { detail: json }));
    });
});

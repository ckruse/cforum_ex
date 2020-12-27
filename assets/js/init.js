if (document.body.dataset.userId) {
  document.addEventListener("cf:userPrivate", (event) => {
    const channel = event.detail;

    channel.push("current_user", {}).receive("ok", (user) => {
      window.currentUser = user;
      document.dispatchEvent(new CustomEvent("cf:userDidLoad", { detail: user }));
    });
  });
}

document.addEventListener("cf:userLobby", (event) => {
  const channel = event.detail;

  channel.push("settings", { current_forum: document.body.dataset.currentForum }).receive("ok", (config) => {
    window.currentConfig = config;
    document.dispatchEvent(new CustomEvent("cf:configDidLoad", { detail: config }));
  });
});

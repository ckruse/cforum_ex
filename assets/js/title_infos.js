import { privateUserChannel } from "./socket";
import { parse } from "./modules/helpers";

export const updateTitleInfos = () => {
  if (document.body.dataset.userId) {
    privateUserChannel.push("title_infos", {}).receive("ok", data => {
      document.title = document.title.replace(/^\([^)]+\)/, data.infos);
    });
  }
};

export const setNewFavicon = () => {
  const favicon = document.querySelector('link[rel="shortcut icon"]');
  if (!favicon.href.match(/-new\.ico$/)) {
    const node = parse(`<link rel="shortcut icon" type="image/x-icon" href="/images/favicon-new.ico">`);
    favicon.remove();
    document.querySelector("head").appendChild(node);
  }
};

export const setReadFavicon = () => {
  const favicon = document.querySelector('link[rel="shortcut icon"]');
  if (favicon.href.match(/-new\.ico$/)) {
    const node = parse(`<link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">`);
    favicon.remove();
    document.querySelector("head").appendChild(node);
  }
};

window.addEventListener("focus", function() {
  setReadFavicon();
});

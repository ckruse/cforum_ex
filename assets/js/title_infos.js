import { privateUserChannel } from "./socket";

export const updateTitleInfos = () => {
  if (document.body.dataset.userId) {
    privateUserChannel.push("title_infos", {}).receive("ok", data => {
      document.title = document.title.replace(/^\([^)]+\)/, data.infos);
    });
  }
};

import React from "react";
import Appsignal from "@appsignal/javascript";
import { plugin } from "@appsignal/plugin-window-events";

import { t } from "./modules/i18n";

const appsignal = new Appsignal({ key: "7f5fcb04-c262-4b2e-b383-9ce2a7b4a821" });
appsignal.use(plugin);

export const FallbackComponent = () => <div>{t("Oops, something went wrong!")}</div>;

export default appsignal;

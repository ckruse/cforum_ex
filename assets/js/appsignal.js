import React from "react";
import Appsignal from "@appsignal/javascript";
import { plugin } from "@appsignal/plugin-window-events";

import { t } from "./modules/i18n";

const appsignal = new Appsignal({ key: "fce1cc45-b503-4457-af8a-608be9f58f49" });
appsignal.use(plugin);

export const FallbackComponent = () => <div>{t("Oops, something went wrong!")}</div>;

export default appsignal;

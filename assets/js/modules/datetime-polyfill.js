import flatpickr from "flatpickr";
import { German } from "flatpickr/dist/l10n/de.js";
import "flatpickr/dist/themes/light.css";

import { ready } from "./events.js";
import { all } from "./selectors.js";
import { create } from "./elements.js";
import { t } from "./i18n";

ready(function() {
  const replacements = [
    {
      type: "datetime-local",
      enableTime: true,
      noCalendar: false,
      dateFormat: "Y-m-d\\TH:i",
      altFormat: t("dateTimeInputLocalFormat"),
      altInput: true
    },
    {
      type: "date",
      enableTime: false,
      noCalendar: false,
      dateFormat: "Y-m-d",
      altFormat: t("dateInputFormat"),
      altInput: true
    },
    {
      type: "time",
      enableTime: true,
      noCalendar: true,
      dateFormat: "H:i",
      altFormat: t("timeInputFormat"),
      altInput: false
    }
  ];

  replacements.forEach(replacement => {
    const field = create("input");
    field.type = replacement.type;

    if (field.type != replacement.type) {
      all("[type='" + replacement.type + "']").forEach(el => {
        flatpickr(el, {
          ...replacement,
          time_24hr: true,
          locale: German
        });
      });
    }
  });
});

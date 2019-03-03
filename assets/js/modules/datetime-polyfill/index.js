import "flatpickr/dist/themes/light.css";

import { t } from "../i18n";

document.addEventListener("DOMContentLoaded", () => {
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
    const field = document.createElement("input");
    field.type = replacement.type;

    if (field.type !== replacement.type) {
      document.querySelectorAll("[type='" + replacement.type + "']").forEach(el => {
        import(/* webpackChunkName: "flatpickr" */ "./flatpickr").then(({ flatpickr, German }) => {
          flatpickr(el, { ...replacement, time_24hr: true, locale: German });
        });
      });
    }
  });
});

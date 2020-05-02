import Highcharts from "highcharts";
import { parseISO, format } from "date-fns";
import { de } from "date-fns/locale";

import { t } from "../modules/i18n";

Highcharts.setOptions({
  lang: t("highcharts"),
});

const el = document.getElementById("user-activity-stats");
const id = document.location.href.replace(/.*\//, "");

if (id && el) {
  fetch(`/api/v1/users/${id}/activity`)
    .then((rsp) => rsp.json())
    .then((json) => {
      Highcharts.chart(el, {
        chart: { type: "spline" },
        title: null,
        xAxis: {
          categories: json.map((val) => format(parseISO(val.month), "MMMM yyyy", { locale: de })),
        },
        yAxis: { title: { text: t("number of new messages") } },
        series: [
          {
            name: t("new messages"),
            data: json.map((val) => val.messages),
          },
        ],
      });
    });
}

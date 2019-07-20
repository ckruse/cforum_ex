import Highcharts from "highcharts";
import { parse } from "date-fns";
import { t } from "../modules/i18n";

Highcharts.setOptions({
  lang: t("highcharts")
});

const el = document.getElementById("user-activity-stats");
if (el) {
  const id = document.location.href.replace(/.*\//, "");

  fetch(`/api/v1/users/${id}/activity`)
    .then(rsp => rsp.json())
    .then(json => {
      Highcharts.chart(el, {
        chart: { type: "spline" },
        title: null,
        xAxis: {
          categories: json.map(val => Highcharts.dateFormat("%B %Y", parse(val.month)))
        },
        yAxis: { title: { text: t("number of new messages") } },
        series: [
          {
            name: t("new messages"),
            data: json.map(val => val.messages)
          }
        ]
      });
    });
}

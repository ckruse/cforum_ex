import Highcharts from "highcharts";
import { parse } from "date-fns";
import { t } from "../modules/i18n";

Highcharts.setOptions({
  lang: t("highcharts")
});

const el = document.querySelector(".chart-cites");
if (el) {
  Highcharts.chart(el, {
    chart: { type: "spline" },
    title: null,
    xAxis: {
      categories: window.helpCitesData.map(val => Highcharts.dateFormat("%B %Y", parse(val.date)))
    },
    yAxis: { title: { text: t("number of new cites") } },
    series: [
      {
        name: t("new cites"),
        data: window.helpCitesData.map(val => val.cnt)
      }
    ]
  });
}

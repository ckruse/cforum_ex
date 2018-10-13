import { t } from "./modules/i18n.js";

document.addEventListener("DOMContentLoaded", () => {
  if (document.body.id != "forums-stats") {
    return;
  }

  Highcharts.setOptions({
    lang: t("highcharts")
  });

  Highcharts.chart(document.querySelector(".chart-all.chart"), {
    chart: { type: "line" },
    title: null,
    xAxis: {
      categories: window.forumStatsValues.map(val => Highcharts.dateFormat("%B %Y", new Date(val.mon)))
    },
    yAxis: [{ title: { text: t("number of threads") } }, { title: { text: t("number of messages") }, opposite: true }],
    series: [
      {
        name: t("threads"),
        data: window.forumStatsValues.map(val => val.threads),
        yAxis: 0
      },
      {
        name: t("messages"),
        data: window.forumStatsValues.map(val => val.messages),
        yAxis: 1
      }
    ]
  });

  let lastYear = moment()
    .subtract(13, "months")
    .startOf("month");

  let yearValues = window.forumStatsValues.filter(val => {
    let mmt = moment(val.mon);

    if (mmt.isBefore(lastYear)) {
      return false;
    }
    return true;
  });

  let lastFourYears = moment()
    .subtract(48, "months")
    .startOf("month");

  let lastFourYearValues = window.forumStatsValues.filter(val => {
    let mmt = moment(val.mon);
    if (mmt.isBefore(lastFourYears)) {
      return false;
    }
    return true;
  });

  Highcharts.chart(document.querySelector(".chart-year.chart"), {
    chart: { type: "spline" },
    title: null,
    xAxis: {
      categories: yearValues.map(val => Highcharts.dateFormat("%B %Y", new Date(val.moment)))
    },
    yAxis: [{ title: { text: t("number of threads") } }, { title: { text: t("number of messages") }, opposite: true }],
    series: [
      {
        name: t("threads"),
        data: yearValues.map(val => val.threads),
        yAxis: 0
      },
      {
        name: t("messages"),
        data: yearValues.map(val => val.messages),
        yAxis: 1
      }
    ]
  });

  Highcharts.chart(document.querySelector(".chart-users-year.chart"), {
    chart: { type: "spline" },
    title: null,
    xAxis: {
      categories: window.forumStatsUsersTwelveMonths.map(val => Highcharts.dateFormat("%B %Y", new Date(val.moment)))
    },
    yAxis: {
      title: { text: t("number of users") }
    },
    series: [
      {
        name: t("users"),
        data: window.forumStatsUsersTwelveMonths.map(val => val.cnt)
      }
    ]
  });

  Highcharts.chart(document.querySelector(".chart-48-months.chart"), {
    chart: { type: "spline" },
    title: null,
    xAxis: {
      categories: lastFourYearValues.map(val => Highcharts.dateFormat("%B %Y", new Date(val.moment)))
    },
    yAxis: [{ title: { text: t("number of threads") } }, { title: { text: t("number of messages") }, opposite: true }],
    series: [
      {
        name: t("threads"),
        data: lastFourYearValues.map(val => val.threads),
        yAxis: 0
      },
      {
        name: t("messages"),
        data: lastFourYearValues.map(val => val.messages),
        yAxis: 1
      }
    ]
  });
});

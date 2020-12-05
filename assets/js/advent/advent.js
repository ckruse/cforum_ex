import { isBefore } from "date-fns";
import { clearChildren } from "../modules/helpers";

const genOrder = (year) => {
  const val = localStorage.getItem(`advent-order-${year}`);
  if (val) {
    return JSON.parse(val);
  }

  const elements = [...Array(24).keys()];

  for (let i = elements.length - 1; i > 0; i--) {
    let j = Math.floor(Math.random() * (i + 1));
    [elements[i], elements[j]] = [elements[j], elements[i]];
  }

  const str = JSON.stringify(elements);
  localStorage.setItem(`advent-order-${year}`, str);

  return elements;
};

const randomizeOrder = (calendar, year) => {
  const elements = Array.from(calendar.querySelectorAll("li"));
  const order = genOrder(year);

  const newElements = order.map((i) => elements[i]);

  clearChildren(calendar);
  newElements.forEach((day) => calendar.appendChild(day));
};

const parseOpened = (year) => {
  const today = new Date();
  const opened = JSON.parse(localStorage.getItem(`advent-calendar-${year}`) || "[]");

  if (!(opened instanceof Array)) {
    return [];
  }

  return opened.filter((day) => isBefore(new Date(year, 11, day), today));
};

const addToOpened = (ev, year) => {
  const el = ev.target.closest("li");

  if (!el || !el.classList.contains("closed")) return;

  const opened = parseOpened(year);
  const no = parseInt(el.querySelector(".day").textContent);
  const today = new Date();
  const dayDate = new Date(year, 11, no);

  if (isBefore(dayDate, today)) {
    opened.push(no);

    localStorage.setItem(`advent-calendar-${year}`, JSON.stringify(opened));
  }
};

const hideUnopenedElements = (year) => {
  const opened = parseOpened(year);
  localStorage.setItem(`advent-calendar-${year}`, JSON.stringify(opened));

  document.querySelectorAll(".cf-advent-calendar-list .open").forEach((el) => {
    const no = parseInt(el.querySelector(".day").textContent);

    if (opened.find((el) => el === no)) return;

    el.classList.remove("open");
    el.classList.add("closed");
  });
};

const calendar = document.querySelector(".cf-advent-calendar-list");
const year = Array.from(calendar.classList)
  .find((el) => el.match(/^year-/))
  .replace(/^year-/, "");

randomizeOrder(calendar, year);
hideUnopenedElements(year);

calendar.addEventListener("click", (ev) => addToOpened(ev, year));

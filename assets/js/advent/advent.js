import { clearChildren } from "../modules/helpers";

const genOrder = year => {
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

  const newElements = order.map(i => elements[i]);

  clearChildren(calendar);
  newElements.forEach(day => calendar.appendChild(day));
};

const addToOpened = ev => {
  ev.preventDefault();
  const el = ev.target.closest("li");

  if (!el || !el.classList.contains("closed")) return;

  const opened = JSON.parse(localStorage.getItem("advent-calendar") || "[]");
  const no = parseInt(el.querySelector(".day").textContent);
  opened.push(no);

  localStorage.setItem("advent-calendar", JSON.stringify(no));
};

const hideUnopenedElements = () => {
  const opened = JSON.parse(localStorage.getItem("advent-calendar") || "[]");

  document.querySelectorAll(".cf-advent-calendar-list .open").forEach(el => {
    const no = parseInt(el.querySelector(".day").textContent);

    if (opened.find(el => el === no)) return;

    el.classList.remove("open");
    el.classList.add("closed");
  });
};

if (document.body.dataset.action === "index") {
  const calendar = document.querySelector(".cf-advent-calendar-list");
  const year = Array.from(calendar.classList)
    .find(el => el.match(/^year-/))
    .replace(/^year-/, "");

  randomizeOrder(calendar, year);
  hideUnopenedElements();

  calendar.addEventListener("click", addToOpened);
}

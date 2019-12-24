import L from "leaflet";
import { OpenStreetMapProvider } from "leaflet-geosearch";

import("leaflet/dist/leaflet.css");

const showEvent = async (id, map) => {
  const response = await fetch(`/api/v1/event/${id}`);
  const event = await response.json();
  const provider = new OpenStreetMapProvider();
  const results = await provider.search({ query: event.location });

  // map.setView([0, 0], 0);
  if (results.length >= 1) {
    results.forEach(result => {
      console.log(result);
      L.marker([result.y, result.x])
        .addTo(map)
        .bindPopup(`<strong>${event.name}</strong><br>${event.location}`)
        .openPopup();
      map.setView([result.y, result.x], 13);
    });
  }
};

console.log(L.Icon.Default.imagePath);
L.Icon.Default.imagePath = "/images/leaflet/";

const eventId = document.location.href.replace(/.*\//, "");
const map = L.map("event-map").setView([0, 0], 0);

L.tileLayer("https://a.tile.openstreetmap.de/{z}/{x}/{y}.png", {
  maxZoom: 18,
  attribution:
    'Kartendaten &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a>, ' +
    '<a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
    'Bilddaten &copy; <a href="https://www.openstreetmap.de/">OpenStreetMap Deutschland</a>'
}).addTo(map);

showEvent(eventId, map);

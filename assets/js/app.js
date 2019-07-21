// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
//import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import "../css/app.scss";

import "./modules/closest";
import "./modules/alerts";

import "./socket";

// import "./modules/tabs.js";
import "./modules/datetime-polyfill";
import "./modules/confirmation";
import "./modules/show-password";
import "./components/autolist";
import "./components/dropdown";
import "./components/badge_management";
import "./user-selector";
import "./autorender";
import "./autoload_threads";

// site specific JS
import "./flag_message";
import "./thread_actions";
import "./messages";
import "./messages/update_messages";
import "./notifications";
import "./notifications/notification-updates";
import "./stats";
import "./help";
import "./user";
import "./cites";

import "./init";
import "./cleanup";

import "./modules/anonymous";

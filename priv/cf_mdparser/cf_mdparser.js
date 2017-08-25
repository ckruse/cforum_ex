const readline = require("readline");
const cmark = require("commonmark");

process.stdin.resume();
process.stdin.setEncoding("utf8");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

const reader = new cmark.Parser();
var writer = new cmark.HtmlRenderer({
  smart: false,
  safe: false,
  softbreak: " "
});

rl.on("line", function(line) {
  try {
    let json = JSON.parse(line);
    let doc = reader.parse(json["markdown"]);
    let result = writer.render(doc);

    process.stdout.write(JSON.stringify({ status: "ok", html: result }) + "\n");
  } catch (e) {
    process.stdout.write(
      JSON.stringify({ status: "error", message: "Input is no valid JSON" })
    );
  }
});

const express = require("express"),
  puppeteer = require("puppeteer"),
  fetch = require("node-fetch");

const TITLES = [
  "Important update",
  "Very important update",
  "An update",
  "An FYI",
  "FYI",
  "Did you know...",
  "Possibly of interest",
  "Definitely of interest",
  "You probably don't care but...",
  "Because I feel like posting",
  "Note",
  "You probably don't know",
  "Guess what?",
  "Might want to take note",
  "A really cool update"
];

const BODIES = [
  "I am hungry",
  "Anyone want to play tennis?",
  "Up for some racquetball?",
  "Hey!",
  "I'm bored. Anyone want to play a game?",
  "Ooh, I think I found something",
  "Why is it so hard to find good juice restaurants?",
  "You should all invite your friends to join Streamer!",
  "Why is everyone trying to exploit Streamer?",
  "Streamer is *soo* secure",
  "Welcome!",
  "Glad to have you here!",
  "I know what you're doing right now. You are reading this message."
];

async function getToken(url) {
  const metadataServerTokenURL =
    "http://metadata/computeMetadata/v1/instance/service-accounts/default/identity?audience=";
  const res = await fetch(metadataServerTokenURL + url, {
    method: "get",
    headers: { "Metadata-Flavor": "Google" }
  });
  const token = await res.text();
  return token;
}

async function browse(url, username, password) {
  const browser = await puppeteer.launch({
    args: ["--no-sandbox", "--disable-dev-shm-usage"]
  });
  const page = await browser.newPage();
  if (process.env.ENABLE_TOKENS === "1") {
    const token = await getToken(url);
    page.setExtraHTTPHeaders({
      Authorization: `Bearer ${token}`
    });
  }
  await page.goto(url);
  url = await page.url();
  console.log(`Page address is ${url}`);
  await page.evaluate(
    (username, password) => {
      document.querySelector("input[name=username]").value = username;
      document.querySelector("input[name=password]").value = password;
      document.querySelector("form input[type=submit]").click();
    },
    username,
    password
  );
  try {
    await page.waitForNavigation({ timeout: 10000 });
  } catch (e) {
    browser.close();
    return;
  }
  let title = await page.title();
  console.log("On the main page.");
  console.log(`Before posting title is: ${title} (${url})`);
  const h3 = await page.evaluate(() => {
    return document.querySelectorAll("h3")[0].innerHTML;
  });
  console.log(`First h3 has contents ${h3}`);
  if (Math.random() < 0.5) {
    console.log("Decided to post.");
    await page.evaluate(
      (title, body) => {
        document.querySelector("input[name=title]").value = title;
        document.querySelector("textarea[name=body]").value = body;
        document.querySelector("input[type=submit]").click();
      },
      TITLES[Math.floor(Math.random() * TITLES.length)],
      BODIES[Math.floor(Math.random() * BODIES.length)]
    );
    title = await page.title();
    console.log(`After posting title is: ${title} (${url})`);
  } else {
    console.log("Decided not to post.");
  }
  browser.close();
  return;
}

(() => {
  const app = express();
  const port = process.env.PORT || 8000;
  const url = process.env.URL;
  const password = process.env.LEVEL6_PW;
  app.get("/", (req, res) => {
    res.send("OK");
  });
  app.post("/", (req, res) => {
    console.log(`Checking credits`);
    browse(url, "level07-password-holder", password).then(() => {
      res.send("OK");
    });
  });
  app.listen(port, "0.0.0.0", () => {
    console.log(`Listening on port ${port}`);
  });
})();

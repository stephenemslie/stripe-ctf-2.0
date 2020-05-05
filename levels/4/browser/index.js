const express = require("express"),
  puppeteer = require("puppeteer"),
  fetch = require("node-fetch");

async function getToken(url) {
  const metadataServerTokenURL =
    "http://metadata/computeMetadata/v1/instance/service-accounts/default/identity?audience=";
  const res = await fetch(url, {
    method: "get",
    headers: { "Metadata-Flavor": "Google" }
  });
  const token = await res.text();
  return token;
}

async function checkCredits(url, username, password) {
  const browser = await puppeteer.launch({
    args: ["--no-sandbox", "--disable-dev-shm-usage"]
  });
  const page = await browser.newPage();
  if (process.env.ENABLE_TOKENS === "1") {
    const token = await getToken(url);
    console.log(`Token is ${token}`);
    page.setExtraHTTPHeaders({
      Authorization: `Bearer ${token}`
    });
  }
  await page.goto(url);
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
  const { title, actionURL, credits } = await page.evaluate(() => {
    return {
      title: document.title,
      actionURL: document.URL,
      credits: document.querySelectorAll("p")[1].innerHTML
    };
  });
  console.log(`Page title is: ${title} (url: ${actionURL})`);
  const creditsLeft = credits.match(/-?\d+/);
  console.log(`Guard Llama has ${creditsLeft}, credits left.`);
  await page.waitFor(1000);
  await browser.close();
}

(() => {
  const app = express();
  const port = process.env.PORT || 8000;
  const url = process.env.URL;
  app.get("/", (req, res) => {
    res.send("OK");
  });
  app.post("/", (req, res) => {
    console.log(`Checking credits`);
    checkCredits(url, "karma_fountain", process.env.LEVEL4_PW).then(() => {
      res.send("OK");
    });
  });
  app.listen(port, "0.0.0.0", () => {
    console.log(`Listening on port ${port}`);
  });
})();

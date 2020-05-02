const express = require("express"),
    puppeteer = require("puppeteer");

async function checkCredits(url, username, password) {
  const browser = await puppeteer.launch({ args: ['--no-sandbox'] });
  const page = await browser.newPage();
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
  } catch {
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
  app.get('/', (req, res) => {
    res.send("OK")
  });
  app.post('/', (req, res) => {
    console.log(`Checking credits`)
    checkCredits(url, "karma_fountain", process.env.LEVEL4_PW);
    res.send("OK")
  })
  app.listen(port, "0.0.0.0", () => {
    console.log(`Listening on port ${port}`);
  });
})();

const fs = require("fs"),
  puppeteer = require("puppeteer");

async function checkCredits(username, password) {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto(`http://level4-server:4567`);
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
  const { title, url, credits } = await page.evaluate(() => {
    return {
      title: document.title,
      url: document.URL,
      credits: document.querySelectorAll("p")[1].innerHTML
    };
  });
  console.log(`Page title is: ${title} (url: ${url})`);
  const creditsLeft = credits.match(/-?\d+/);
  console.log(`Guard Llama has ${creditsLeft}, credits left.`);
  await page.waitFor(1000);
  await browser.close();
}

(() => {
  const password = fs.readFileSync(process.env.PW_FILE, "utf-8");
  const intervalSeconds = 30;
  console.log(
    `Starting timer to check credits every ${intervalSeconds} seconds.`
  );
  setInterval(() => {
    checkCredits("karma_fountain", password);
  }, intervalSeconds * 1000);
})();

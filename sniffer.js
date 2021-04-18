const puppeteer = require("puppeteer");
const util = require("util");
const fs = require("fs");

const URL = "https://www.notion.so/Test-page-e1220dc928e9490b9d336e49ae125313";
const WAIT_TIME = 5 * 1000;
const URLS_NOT_TO_HIT = [
  /amplitude\.com/,
  /fullstory\.com/,
  /intercom\.io/,
  /connect\.facebook\.net/,
  /googletagmanager\.com/,
  /adsymptotic\.com/,
  /ads\.linkedin\.com/,
];
const URLS_HIDDEN_FROM_LOGS = [
  /\.html$/,
  /\.svg$/,
  /\.js$/,
  /\.css$/,
  /\.woff$/,
  /^data:/,
  "https://www.notion.so/api/v3/ping",
  "https://www.notion.so/api/v3/getUserAnalyticsSettings",
  "https://www.notion.so/api/v3/getClientExperimentsV2",
  "https://msgstore.www.notion.so/",
  "https://api.pgncs.notion.so/",
  "https://www.notion.so/api/v3/getAssetsJsonV2",
];

function shouldMakeRequestTo(url) {
  return !URLS_NOT_TO_HIT.some((pattern) => {
    if (typeof pattern === "string") {
      return url.startsWith(pattern);
    } else {
      return pattern.test(url);
    }
  });
}

function shouldLogResponseFrom(url) {
  return !URLS_HIDDEN_FROM_LOGS.some((pattern) => {
    if (typeof pattern === "string") {
      return url.startsWith(pattern);
    } else {
      return pattern.test(url);
    }
  });
}

// Source: <https://blog.kowalczyk.info/article/88aee8f43620471aa9dbcad28368174c/how-i-reverse-engineered-notion-api.html>
async function sniffRequests() {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.setRequestInterception(true);
  page.setDefaultTimeout(5000);

  page.on("request", (request) => {
    const url = request.url();

    if (shouldMakeRequestTo(url)) {
      request.continue();
    } else {
      request.abort();
    }
  });

  page.on("requestfailed", (request) => {
    const url = request.url();

    if (shouldMakeRequestTo(url)) {
      const method = request.method();
      console.log(`[ERR] ${method.toUpperCase()} ${url}`);
    } else {
      // it was us who failed this request
    }
  });

  page.on("response", async (response) => {
    const request = response.request();
    const url = request.url();
    const status = response.status();

    if (shouldLogResponseFrom(url)) {
      const method = request.method();
      const requestHeaders = request.headers();
      const postData = request.postData();
      const responseHeaders = response.headers();

      if (status >= 300 && status <= 399) {
        console.log(`[${status}] ${method.toUpperCase()} ${url}`);
        console.log("REQUEST HEADERS:");
        console.log(util.inspect(requestHeaders, { depth: null }));
        if (postData) {
          console.log("REQUEST BODY:");
          console.log(postData);
        }
      } else {
        const responseText = await response.text();
        console.log(
          `[${status}] ${method.toUpperCase()} ${url} (${
            responseText.length
          } bytes)`
        );
        console.log("REQUEST HEADERS:");
        console.log(util.inspect(requestHeaders, { depth: null }));
        if (postData) {
          console.log("REQUEST BODY:");
          console.log(postData);
        }
        console.log("RESPONSE HEADERS:");
        console.log(util.inspect(responseHeaders, { depth: null }));
        if (responseText != "") {
          console.log("RESPONSE BODY:");
          let responseData;
          try {
            responseData = JSON.parse(responseText);
            console.log(util.inspect(responseData, { depth: null }));
          } catch (error) {
            responseData = responseText;
            console.log(responseData);
          }
        }
      }
      console.log("");
    }
  });

  console.log("----- GOING TO PAGE -------");
  await page.goto(URL);

  console.log("\n----- SIGNING IN -------");
  const editButton = await page.waitForXPath(
    `//div[@role="button" and contains(text(), "Edit")]`
  );
  await editButton.click();
  const emailField = await page.waitForSelector(`input[type='email']`);
  await emailField.focus();
  await emailField.type(`elliot.winkler@gmail.com`, { delay: 50 });
  //const continueWithEmailButton = await page.waitForXPath(
  //`.//div[@role="button" and contains(./text(), "Continue with email")]`
  //);
  const continueWithEmailButton = await page.waitForSelector(
    `.notion-login > div:nth-child(3) > form > div:nth-child(5)`
  );
  await continueWithEmailButton.click();
  const passwordField = await page.waitForSelector(`input[type='password']`);
  await passwordField.click();
  // TODO: Sometimes this fails for no reason
  await passwordField.type(`qqvF33*voLPGGcNuF4cRZkatYjpG!kD6`, { delay: 100 });
  const continueWithPasswordButton = await page.waitForXPath(
    `//div[@role="button" and contains(text(), "Continue with password")]`
  );
  await continueWithPasswordButton.click();

  console.log("\n----- MAKING CHANGES -------");
  const contenteditable = await page.waitForXPath(
    `//*[contains(concat(" ", normalize-space(@class), " "), " notion-page-content ")]//div[@contenteditable="true"]`
  );
  await contenteditable.click();
  await page.keyboard.type("Hello", { delay: 100 });
  await page.screenshot({ path: "tmp/screenie.png" });
  fs.writeFileSync(
    "tmp/screenie.html",
    await page.evaluate(() => document.documentElement.innerHTML)
  );
  await page.waitForXPath(
    `//*[contains(concat(" ", normalize-space(@class), " "), " notion-page-content ")]//div[@contenteditable="true" and contains(text(), "Hello")]`
  );
  // let the ajax request happen
  await new Promise((resolve) => setTimeout(resolve, 5000));

  await browser.close();
}

sniffRequests().then(() => {
  process.exit();
});

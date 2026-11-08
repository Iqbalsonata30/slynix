// Reuse installed Playwright for this test only; no production JS runtime.
import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
const { chromium } = await import(process.env.PLAYWRIGHT_MODULE);
let browser;
try {
  const session = JSON.parse(readFileSync(process.argv[2], 'utf8'));
  const origin = new URL(session.url).origin;
  browser = await chromium.launch({ executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH });
  const page = await browser.newPage();
  const external = [];
  page.on('request', request => { if (new URL(request.url()).origin !== origin) external.push(request.url()); });
  await page.goto(session.url);
  await page.getByRole('heading', { name: 'Your decision journal', exact: true }).waitFor();
  assert.equal(new URL(page.url()).hash, '', 'capability removed from browser history');
  assert.equal(await page.locator('a[href="#/new-decision"]').count(), 0);
  assert.equal(await page.evaluate(async () => (await fetch('/api/health')).status), 401);
  assert.deepEqual(external, []);
  assert.equal(await page.evaluate(() => localStorage.length), 0);
} catch {
  process.stderr.write('Browser integration assertion failed (private URL suppressed).\n');
  process.exitCode = 1;
} finally {
  if (browser) await browser.close();
}

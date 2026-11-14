// Real Chromium UI checks against local fixtures; every request is intercepted.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const { execFileSync } = require('node:child_process');
const { chromium } = require('/runner/node_modules/playwright');
execFileSync('python3', ['/kit/browser/scripts/configure.py', '--env', '/kit/.env.example', '--out', '/tmp/generated']);
const script = name => fs.readFileSync(`/tmp/generated/${name}.js`, 'utf8');
const base = 'https://gitlab.fixture.invalid';
let passed = 0;
async function check(name, fn) { await fn(); passed++; console.log(`PASS ${name}`); }
(async () => {
  const browser = await chromium.launch({ headless: true, args: ['--no-sandbox'] });
  const context = await browser.newContext();
  await context.addInitScript(() => {
    window.GM_addStyle = text => { const s = document.createElement('style'); s.textContent = text; document.head.append(s); };
    window.GM_getValue = (_, fallback) => fallback;
    window.GM_setValue = () => {};
    window.submits = 0;
    document.addEventListener('submit', e => { e.preventDefault(); window.submits++; });
  });
  const malicious = '\"><img src=x onerror="window.XSS=1">.txt';
  const requests = [];
  let html = '<main class="content"><div data-project-id="1" data-ref="main">Repository</div></main>';
  await context.route('**/*', route => {
    requests.push({ method: route.request().method(), url: route.request().url() });
    if (route.request().url().includes('/api/v4/')) {
      return route.fulfill({ contentType: 'application/json', body: JSON.stringify([
        { name: malicious, path: malicious, type: 'blob' },
        { name: 'file #?.txt', path: 'folder/file #?.txt', type: 'blob' }
      ]) });
    }
    return route.fulfill({ contentType: 'text/html', body: html });
  });
  const page = await context.newPage();
  await check('file tree escapes names and encodes navigation URLs', async () => {
    await page.goto(`${base}/team/project/-/blob/main/readme.md`);
    await page.addScriptTag({ content: script('GitLab-File-Tree') });
    const link = page.locator('a.gl-filetree__name').filter({ hasText: malicious });
    await link.waitFor();
    assert.equal(await link.textContent(), malicious);
    assert.equal(await page.locator('.gl-filetree img').count(), 0);
    assert.equal(await page.evaluate(() => window.XSS), undefined);
    const encoded = await page.locator('a.gl-filetree__name').filter({ hasText: 'file #?.txt' }).getAttribute('href');
    assert.match(encoded, /folder\/file%20%23%3F.txt$/);
    await page.getByRole('button', { name: '🔍 Quick' }).click();
    await page.locator('.gl-filetree__quicksearch-input').fill('img');
    assert.equal(await page.locator('.gl-filetree__quicksearch-name').textContent(), malicious);
    assert.equal(await page.locator('.gl-filetree__quicksearch img').count(), 0);
  });
  await check('MR helper stays within its project and avoids duplicate descriptions', async () => {
    html = '<main><form class="merge-request-form"><input id="merge_request_title"><textarea id="merge_request_description"></textarea><button type="submit">Submit</button></form></main>';
    const payload = { issueNumber: '42', title: '<img src=x onerror=alert(1)>', body: 'Issue body',
      username: 'fixture', labels: ['bug'], projectPath: '/team/project', createdAt: Date.now() };
    await page.goto(`${base}/team/project/-/merge_requests/new`);
    await page.evaluate(data => localStorage.setItem('yc_gitlab_mr_template_v3', JSON.stringify(data)), payload);
    await page.addScriptTag({ content: script('GitLab-Issue-MR') });
    assert.equal(await page.locator('[data-branch]').getAttribute('type'), 'button');
    await page.locator('#merge_request_description').fill('### Issue\nCloses #42\n\nExisting body');
    await page.getByRole('button', { name: 'Apply template' }).click();
    const description = await page.locator('#merge_request_description').inputValue();
    assert.equal((description.match(/Closes #42/g) || []).length, 1);
    assert.equal(await page.evaluate(() => window.submits), 0);
    await page.goto(`${base}/other/project/-/merge_requests/new`);
    await page.evaluate(data => localStorage.setItem('yc_gitlab_mr_template_v3', JSON.stringify(data)), payload);
    await page.addScriptTag({ content: script('GitLab-Issue-MR') });
    assert.equal(await page.locator('.yc-mr-banner').count(), 0);
  });
  const timesheet = () => '<main><input id="unrelated" value="keep"><table><tr>' +
    Array.from({ length: 7 }, (_, i) => `<td><input type="text" class="time-input" value="2" data-column="${i}"></td>`).join('') +
    '</tr></table></main>';
  await check('ActiTIME defaults to no grid writes', async () => {
    html = timesheet();
    await page.goto('https://online.actitime.com/fixture/timetrack/enter.do');
    page.once('dialog', dialog => dialog.accept());
    await page.addScriptTag({ content: script('ActiTime-AutoFill') });
    await page.locator('#tm-fill-weekdays').click();
    assert.deepEqual(await page.locator('.time-input').evaluateAll(nodes => nodes.map(n => n.value)), Array(7).fill('2'));
    assert.equal(await page.locator('#unrelated').inputValue(), 'keep');
  });
  await check('ActiTIME respects cancel, weekday mapping, unrelated fields, and no form submission', async () => {
    html = timesheet();
    await page.goto('https://online.actitime.com/fixture/timetrack/enter.do');
    const enabled = script('ActiTime-AutoFill')
      .replace("const TIMESHEET_INPUT_SELECTOR = '';", "const TIMESHEET_INPUT_SELECTOR = '.time-input';")
      .replace('const FIRST_COLUMN_WEEKDAY = null;', 'const FIRST_COLUMN_WEEKDAY = 1;');
    await page.addScriptTag({ content: enabled });
    page.once('dialog', dialog => dialog.dismiss());
    await page.locator('#tm-fill-weekdays').click();
    assert.deepEqual(await page.locator('.time-input').evaluateAll(nodes => nodes.map(n => n.value)), Array(7).fill('2'));
    const handler = dialog => dialog.accept();
    page.on('dialog', handler);
    await page.locator('#tm-fill-weekdays').click();
    assert.deepEqual(await page.locator('.time-input').evaluateAll(nodes => nodes.map(n => n.value)), ['8','8','8','8','2','2','8']);
    assert.equal(await page.locator('#unrelated').inputValue(), 'keep');
    assert.equal(await page.evaluate(() => window.submits), 0);
    page.off('dialog', handler);
  });
  assert(requests.every(request => request.method === 'GET'));
  await browser.close();
  console.log(`${passed} browser fixture scenarios passed; no live services contacted.`);
})().catch(error => { console.error(error); process.exit(1); });

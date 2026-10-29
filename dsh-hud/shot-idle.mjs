// Waits until the agent is genuinely idle (server reports running=0 && rateShort=0
// for a sustained streak — i.e. no tool is executing and no events arrive),
// then captures the HUD. Runs detached from any tool call, so the pending-tool
// counter is truly zero at capture time.
// usage: node shot-idle.mjs <url> <out.png> [port] [idleMs]
const [url, out, portArg = '9444', idleMsArg = '6000'] = process.argv.slice(2);
const PORT = Number(portArg);
const IDLE_MS = Number(idleMsArg);
const CDP = `http://127.0.0.1:${PORT}`;
const HUD = 'http://127.0.0.1:7788';

const sleep = (ms) => new Promise(r => setTimeout(r, ms));
const get = (u, init) => fetch(u, { ...init, signal: AbortSignal.timeout(4000) });

/* ---- open a page target ---- */
let target = null;
try {
  const list = await (await get(`${CDP}/json/list`)).json();
  target = (list || []).find(t => t.type === 'page' && t.webSocketDebuggerUrl &&
    (t.url.startsWith('about:blank') || t.url.startsWith(HUD)));
} catch {}
if (!target) target = await (await get(`${CDP}/json/new?about:blank`, { method: 'PUT' })).json();
if (!target?.webSocketDebuggerUrl) { console.error('no target'); process.exit(2); }

const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
let id = 0; const pending = new Map();
ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); } };
const send = (method, params = {}) => new Promise((res) => { const i = ++id; pending.set(i, res); ws.send(JSON.stringify({ id: i, method, params })); });

await send('Page.enable');
await send('Emulation.setDeviceMetricsOverride', { width: 1600, height: 900, deviceScaleFactor: 1, mobile: false });
await send('Page.navigate', { url });

/* ---- wait for a sustained idle window ---- */
const deadline = Date.now() + 180000;
let idleSince = 0;
for (;;) {
  if (Date.now() > deadline) { console.error('no idle window within 180s'); process.exit(5); }
  let st = null;
  try { st = await (await get(`${HUD}/state`)).json(); } catch {}
  const busy = !st || (st.totals?.activeTools || 0) > 0 || (st.rateShort || 0) > 0;
  if (busy) { idleSince = 0; }
  else {
    if (!idleSince) idleSince = Date.now();
    if (Date.now() - idleSince >= IDLE_MS) break;
  }
  await sleep(250);
}

const shot = await send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false });
if (!shot.result?.data) { console.error('capture failed'); process.exit(3); }
const { writeFile } = await import('node:fs/promises');
const buf = Buffer.from(shot.result.data, 'base64');
await writeFile(out, buf);
console.log('saved idle', out, buf.length, 'bytes');
ws.close();
process.exit(0);

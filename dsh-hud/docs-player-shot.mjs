// 截图：打开播放器面板后截左上角区域（docs/screenshots/player.png 用）
import { writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const PORT = 9990;
const ROOT = dirname(fileURLToPath(import.meta.url));
const OUT = join(ROOT, '..', 'dsh-hud-haloflux', 'docs', 'screenshots');

const t = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: 'PUT' })).json();
const ws = new WebSocket(t.webSocketDebuggerUrl);
await new Promise((r) => (ws.onopen = r));
let id = 0; const pending = new Map();
ws.addEventListener('message', (e) => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
});
const send = (method, params = {}) => new Promise((res) => {
  const i = ++id; pending.set(i, res); ws.send(JSON.stringify({ id: i, method, params }));
});

await send('Page.enable');
await send('Runtime.enable');
await send('Emulation.setDeviceMetricsOverride', { width: 1920, height: 1080, deviceScaleFactor: 1, mobile: false });
await send('Page.navigate', { url: 'http://127.0.0.1:7788/wall' });
await new Promise((r) => setTimeout(r, 9000));

// 注入系统状态 + 打开播放器面板
await send('Runtime.evaluate', { expression: `window.postMessage({type:'sysinfo',cpu:23,gpu:20,ramTotal:65400,ramAvail:33500},'*')` });
await send('Runtime.evaluate', { expression: `document.getElementById('dsh-media-toggle')?.click()` });
await new Promise((r) => setTimeout(r, 800));

const clip = { x: 0, y: 46, width: 470, height: 250, scale: 2 };
const r = await send('Page.captureScreenshot', { format: 'png', clip });
if (!r.result?.data) throw new Error('capture failed');
await writeFile(join(OUT, 'player.png'), Buffer.from(r.result.data, 'base64'));
console.log('player.png saved');
ws.close();
process.exit(0);

// 生成 docs/screenshots 用的截图与 GIF 帧（headless Chrome + CDP）
// 用法：node docs-shots.mjs
// 前置：本机 7788 服务在跑；Chrome 以 --remote-debugging-port=9990 启动。
import { mkdir, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const PORT = 9990;
const ROOT = dirname(fileURLToPath(import.meta.url));
const OUT = join(ROOT, '..', 'dsh-hud-haloflux', 'docs', 'screenshots');
const FRAMES = join(ROOT, 'shots', 'doc-frames');

const DEMO_SYS = {
  type: 'sysinfo', cpu: 23, gpu: 20, ramTotal: 65400, ramAvail: 33500
};

async function cdp() {
  const t = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: 'PUT' })).json();
  const ws = new WebSocket(t.webSocketDebuggerUrl);
  await new Promise((r) => (ws.onopen = r));
  let id = 0;
  const pending = new Map();
  ws.addEventListener('message', (e) => {
    const m = JSON.parse(e.data);
    if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
  });
  const send = (method, params = {}) => new Promise((res) => {
    const i = ++id; pending.set(i, res); ws.send(JSON.stringify({ id: i, method, params }));
  });
  return { ws, send };
}

async function shot(send) {
  const r = await send('Page.captureScreenshot', { format: 'png' });
  if (!r.result?.data) throw new Error('capture failed');
  return Buffer.from(r.result.data, 'base64');
}

async function main() {
  await mkdir(OUT, { recursive: true });
  await mkdir(FRAMES, { recursive: true });

  // ---------- 1) 静态截图（1920x1080）----------
  {
    const { ws, send } = await cdp();
    await send('Page.enable');
    await send('Runtime.enable');
    await send('Emulation.setDeviceMetricsOverride', { width: 1920, height: 1080, deviceScaleFactor: 1, mobile: false });
    await send('Page.navigate', { url: 'http://127.0.0.1:7788/wall' });
    await new Promise((r) => setTimeout(r, 9000)); // 等 SSE 数据、面板与光环稳定

    // 注入宿主系统状态（headless 里没有 Lively 的宿主 API）
    for (let i = 0; i < 6; i++) {
      await send('Runtime.evaluate', {
        expression: `window.postMessage(${JSON.stringify(DEMO_SYS)}, '*')`
      });
      await new Promise((r) => setTimeout(r, 700));
    }
    await new Promise((r) => setTimeout(r, 1200));

    await writeFile(join(OUT, 'overview.png'), await shot(send));
    console.log('overview.png saved');
    ws.close();
  }

  // ---------- 2) GIF 帧（1152x648，8fps，4.5s）----------
  {
    const { ws, send } = await cdp();
    await send('Page.enable');
    await send('Runtime.enable');
    await send('Emulation.setDeviceMetricsOverride', { width: 1152, height: 648, deviceScaleFactor: 1, mobile: false });
    await send('Page.navigate', { url: 'http://127.0.0.1:7788/wall' });
    await new Promise((r) => setTimeout(r, 7000));
    for (let i = 0; i < 3; i++) {
      await send('Runtime.evaluate', { expression: `window.postMessage(${JSON.stringify(DEMO_SYS)}, '*')` });
      await new Promise((r) => setTimeout(r, 500));
    }

    const fps = 8, secs = 4.5;
    const frames = Math.round(fps * secs);
    const interval = 1000 / fps;
    for (let i = 0; i < frames; i++) {
      const t0 = Date.now();
      await writeFile(join(FRAMES, `f${String(i).padStart(4, '0')}.png`), await shot(send));
      const wait = interval - (Date.now() - t0);
      if (wait > 0) await new Promise((r) => setTimeout(r, wait));
    }
    console.log(`frames saved: ${frames}`);
    ws.close();
  }
  process.exit(0);
}

main().catch((e) => { console.error(e); process.exit(1); });

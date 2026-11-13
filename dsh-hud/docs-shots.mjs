// 生成 docs/screenshots 用的截图与 GIF 帧（headless Chrome + CDP）
// 用法：node docs-shots.mjs
// 前置：本机 7788 数据服务在跑；Chrome 以 --remote-debugging-port=9990 启动。
//
// 说明：
// - 截图期间会向 http://127.0.0.1:7788/hook 定时发送 PreToolUse 事件，制造“卡片活动”，
//   保证截出来的画面里始终有标题卡（Codex / DSH 等），不必手动去点 Codex。
// - 输出：overview-3.png / panels-3.png / ring-3.png + GIF 帧（dsh-hud/shots/doc-frames3）。
//   GIF 用 Pillow 合成：python -c "from PIL import Image; ..."（见 CHANGELOG / README 说明）。

import { mkdir, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const PORT = Number(process.env.CDP_PORT || 9990);
const SERVER = process.env.HUD_URL || 'http://127.0.0.1:7788';
const ROOT = dirname(fileURLToPath(import.meta.url));
const OUT = join(ROOT, '..', 'dsh-hud-haloflux', 'docs', 'screenshots');
const FRAMES = join(ROOT, 'shots', 'doc-frames3');

const DEMO_SYS = { type: 'sysinfo', cpu: 23, gpu: 20, ramTotal: 65400, ramAvail: 33500 };

/* ---------------- stdin 截图会话 ---------------- */
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

async function shot(send, clip) {
  const r = await send('Page.captureScreenshot', clip ? { format: 'png', clip } : { format: 'png' });
  if (!r.result?.data) throw new Error('capture failed');
  return Buffer.from(r.result.data, 'base64');
}

/* ---------------- 制造卡片活动：给 /hook 发事件 ---------------- */
let hookTimer = null;
async function fireHook() {
  try {
    await fetch(`${SERVER}/hook`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ event: 'PreToolUse', tool: 'shell' })
    });
  } catch (e) { /* 服务没起时忽略 */ }
}
function startHooks(everyMs = 1600) {
  if (hookTimer) return;
  hookTimer = setInterval(fireHook, everyMs);
}
function stopHooks() {
  if (hookTimer) { clearInterval(hookTimer); hookTimer = null; }
}

/* ---------------- 主流程 ---------------- */
async function main() {
  await mkdir(OUT, { recursive: true });
  await mkdir(FRAMES, { recursive: true });
  const wait = (ms) => new Promise((r) => setTimeout(r, ms));

  // ---------- 1) 静态截图（1920x1080）----------
  {
    const { ws, send } = await cdp();
    await send('Page.enable');
    await send('Runtime.enable');
    await send('Emulation.setDeviceMetricsOverride', { width: 1920, height: 1080, deviceScaleFactor: 1, mobile: false });
    await send('Page.navigate', { url: `${SERVER}/wall` });
    await wait(9000);                         // 等 SSE 数据、面板与光环稳定

    startHooks();                             // 制造 Codex / DSH 卡片活动
    for (let i = 0; i < 6; i++) {             // 注入宿主系统状态（headless 没有 Lively API）
      await send('Runtime.evaluate', { expression: `window.postMessage(${JSON.stringify(DEMO_SYS)}, '*')` });
      await wait(700);
    }
    await wait(1200);

    await writeFile(join(OUT, 'overview-3.png'), await shot(send));
    console.log('overview-3.png saved');
    await writeFile(join(OUT, 'panels-3.png'), await shot(send, { x: 0, y: 830, width: 1920, height: 250, scale: 1 }));
    console.log('panels-3.png saved');
    await writeFile(join(OUT, 'ring-3.png'), await shot(send, { x: 60, y: 60, width: 1000, height: 750, scale: 1 }));
    console.log('ring-3.png saved');
    stopHooks();
    ws.close();
  }

  // ---------- 2) GIF 帧（1152x648，8fps，5s）----------
  {
    const { ws, send } = await cdp();
    await send('Page.enable');
    await send('Runtime.enable');
    await send('Emulation.setDeviceMetricsOverride', { width: 1152, height: 648, deviceScaleFactor: 1, mobile: false });
    await send('Page.navigate', { url: `${SERVER}/wall` });
    await wait(7000);
    for (let i = 0; i < 3; i++) {
      await send('Runtime.evaluate', { expression: `window.postMessage(${JSON.stringify(DEMO_SYS)}, '*')` });
      await wait(500);
    }
    startHooks();                             // 动图里也保持标题卡活动
    const fps = 8, secs = 5.0;
    const frames = Math.round(fps * secs);
    const interval = 1000 / fps;
    for (let i = 0; i < frames; i++) {
      const t0 = Date.now();
      await writeFile(join(FRAMES, `f${String(i).padStart(4, '0')}.png`), await shot(send));
      const w = interval - (Date.now() - t0);
      if (w > 0) await wait(w);
    }
    stopHooks();
    console.log(`frames saved: ${frames} -> ${FRAMES}`);
    console.log('GIF: 用 Pillow 合成（20 帧 / 2.5s / 800x450）');
    ws.close();
  }
  process.exit(0);
}

main().catch((e) => { stopHooks(); console.error(e); process.exit(1); });

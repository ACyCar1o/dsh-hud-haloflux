// Codex Hook forwarder
// Codex 的事件钩子通过 stdin 把 JSON 传进来；这里只做一件事：
// 把事件名/工具名转成一次本地 HTTP POST 给 dsh-hud 服务（127.0.0.1:7788/hook）。
// 要求：必须在 ~1 秒内退出（Codex 侧 timeout=1），不能有任何控制台输出。

import { request } from 'node:http';

const PORT = Number(process.env.HUD_PORT || 7788);
let raw = '';
let done = false;

function post(payload) {
  if (done) return;
  done = true;
  try {
    const body = Buffer.from(JSON.stringify(payload));
    const req = request({
      host: '127.0.0.1', port: PORT, path: '/hook', method: 'POST',
      headers: { 'content-type': 'application/json', 'content-length': body.length },
      timeout: 650
    }, (res) => { res.resume(); });
    req.on('error', () => {});
    req.on('timeout', () => { try { req.destroy(); } catch (e) {} });
    req.end(body);
  } catch (e) {}
  setTimeout(() => process.exit(0), 120);
}

process.stdin.setEncoding('utf8');
process.stdin.on('data', (c) => { raw += c; if (raw.length > 65536) raw = raw.slice(0, 65536); });
process.stdin.on('end', () => {
  let d = {};
  try { d = JSON.parse(raw); } catch (e) {}
  const event = d.hook_event_name || d.hookEventName || d.event || 'unknown';
  const tool = d.tool_name || (d.tool && (d.tool.name || d.tool)) || d.command || '';
  const session = d.session_id || d.sessionId || '';
  post({ event: String(event), tool: String(tool).slice(0, 120), session: String(session), at: Date.now() });
});
process.stdin.on('error', () => post({ event: 'unknown', at: Date.now() }));
setTimeout(() => post({ event: 'timeout', at: Date.now() }), 700);

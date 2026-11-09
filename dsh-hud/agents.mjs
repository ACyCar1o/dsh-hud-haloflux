// 多 Agent 探测器：读取 Codex / WorkBuddy / Claude Code 的本地会话记录，
// 归一成统一结构交给 /state（桥渲染成底部身份条）。
// 只读本机文件，不读登录凭据；状态判定全部基于文件修改时间 + 最后一条事件类型。

import { readdirSync, statSync, openSync, readSync, closeSync } from 'node:fs';
import { join, basename } from 'node:path';
import { homedir } from 'node:os';

const HOME = homedir();
const ACTIVE_MS = 90 * 1000;        // 90 秒内有写入算“活跃”
const RECENT_MS = 30 * 60 * 1000;   // 30 分钟内出现过才算“最近用过”

const COLORS = {
  codex: '#10A37F',
  workbuddy: '#4C7DFF',
  claude: '#D97757',
  dsh: '#E8EAEE'
};

function tailLines(file, bytes = 256 * 1024) {
  let fd = null;
  try {
    const st = statSync(file);
    const start = Math.max(0, st.size - bytes);
    const len = st.size - start;
    const buf = Buffer.alloc(len);
    fd = openSync(file, 'r');
    readSync(fd, buf, 0, len, start);
    return buf.toString('utf8').split('\n').filter(Boolean);
  } catch (e) {
    return [];
  } finally {
    if (fd !== null) { try { closeSync(fd); } catch (e) {} }
  }
}

function parseLines(lines) {
  const out = [];
  for (const l of lines) {
    if (!l.trim()) continue;
    try { out.push(JSON.parse(l)); } catch (e) { /* 半行跳过 */ }
  }
  return out;
}

// 在目录里找最近修改的匹配文件（限制深度/数量，避免扫描爆炸）
function newestFile(dir, match, maxDepth = 5, limit = 400) {
  let best = null, seen = 0;
  const walk = (d, depth) => {
    if (depth > maxDepth || seen > limit) return;
    let entries;
    try { entries = readdirSync(d, { withFileTypes: true }); } catch (e) { return; }
    for (const e of entries) {
      if (seen++ > limit) return;
      const p = join(d, e.name);
      if (e.isDirectory()) { walk(p, depth + 1); continue; }
      if (!match(e.name)) continue;
      try {
        const m = statSync(p).mtimeMs;
        if (!best || m > best.mtimeMs) best = { path: p, mtimeMs: m };
      } catch (e2) {}
    }
  };
  if (dir) walk(dir, 0);
  return best;
}

function asText(v) {
  if (v == null) return '';
  if (typeof v === 'string') return v;
  if (Array.isArray(v)) return v.map((x) => (x && typeof x === 'object' ? (x.text || x.content || '') : x)).join(' ');
  if (typeof v === 'object') return v.text || v.content || v.message || '';
  return String(v);
}

function shortText(s, n = 46) {
  const v = asText(s).replace(/\s+/g, ' ').trim();
  return v.length > n ? v.slice(0, n - 1) + '…' : v;
}

/* ---------------- Codex ---------------- */
function probeCodex(now) {
  const root = join(HOME, '.codex', 'sessions');
  const f = newestFile(root, (n) => n.startsWith('rollout-') && n.endsWith('.jsonl'));
  if (!f) return { id: 'codex', name: 'Codex', color: COLORS.codex, state: '未运行', detail: '', active: false, at: 0 };
  const ago = now - f.mtimeMs;
  if (ago > RECENT_MS) return { id: 'codex', name: 'Codex', color: COLORS.codex, state: '未运行', detail: '', active: false, at: f.mtimeMs };
  const recs = parseLines(tailLines(f.path));
  let state = '空闲', detail = '', at = f.mtimeMs;
  for (let i = recs.length - 1; i >= 0; i--) {
    const r = recs[i], p = r.payload || {};
    const ts = r.timestamp ? Date.parse(r.timestamp) : 0;
    if (ts && !at) at = ts;
    if (r.type === 'event_msg') {
      if (p.type === 'task_complete') { state = '空闲'; detail = shortText(p.last_agent_message || ''); break; }
      if (p.type === 'task_started') { state = '思考'; detail = '开始处理任务'; break; }
      if (p.type === 'token_count') { state = '输出'; detail = '正在生成'; break; }
      if (p.type === 'agent_message') { state = '输出'; detail = shortText(p.message || ''); break; }
    }
    if (r.type === 'response_item' && (p.type === 'function_call' || p.type === 'custom_tool_call' || p.type === 'tool_call')) {
      state = '干活'; detail = shortText(p.name || p.tool || ''); break;
    }
  }
  const active = ago < ACTIVE_MS;
  if (!active) state = '空闲';
  return { id: 'codex', name: 'Codex', color: COLORS.codex, state, detail, active, at };
}

/* ---------------- WorkBuddy ---------------- */
function probeWorkBuddy(now) {
  const root = join(HOME, '.workbuddy', 'projects');
  const f = newestFile(root, (n) => n.endsWith('.jsonl'), 3);
  if (!f) return { id: 'workbuddy', name: 'WorkBuddy', color: COLORS.workbuddy, state: '未运行', detail: '', active: false, at: 0 };
  const ago = now - f.mtimeMs;
  if (ago > RECENT_MS) return { id: 'workbuddy', name: 'WorkBuddy', color: COLORS.workbuddy, state: '未运行', detail: '', active: false, at: f.mtimeMs };
  const recs = parseLines(tailLines(f.path));
  let state = '空闲', detail = '';
  for (let i = recs.length - 1; i >= 0; i--) {
    const r = recs[i];
    if (r.type === 'reasoning') { state = '思考'; detail = '推理中'; break; }
    if (r.type === 'tool-call' || r.type === 'tool_call' || r.type === 'tool-result') { state = '干活'; detail = shortText(r.name || r.toolName || ''); break; }
    if (r.type === 'message') {
      if (r.role === 'assistant') { state = '输出'; detail = shortText(r.content || (r.message && r.message.content) || ''); break; }
      if (r.role === 'user') { state = '思考'; detail = '等待回复'; break; }
    }
  }
  const active = ago < ACTIVE_MS;
  if (!active) state = '空闲';
  return { id: 'workbuddy', name: 'WorkBuddy', color: COLORS.workbuddy, state, detail, active, at: f.mtimeMs };
}

/* ---------------- Claude Code ---------------- */
function probeClaude(now) {
  const root = join(HOME, '.claude', 'projects');
  const f = newestFile(root, (n) => n.endsWith('.jsonl'), 2);
  if (!f) return { id: 'claude', name: 'Claude Code', color: COLORS.claude, state: '未安装', detail: '', active: false, at: 0 };
  const ago = now - f.mtimeMs;
  if (ago > RECENT_MS) return { id: 'claude', name: 'Claude Code', color: COLORS.claude, state: '未运行', detail: '', active: false, at: f.mtimeMs };
  const recs = parseLines(tailLines(f.path));
  let state = '空闲', detail = '';
  for (let i = recs.length - 1; i >= 0; i--) {
    const r = recs[i];
    const m = r.message || {};
    const txt = Array.isArray(m.content)
      ? (m.content.find((c) => c && c.text) || {}).text
      : m.content;
    if (r.type === 'assistant') {
      const tool = Array.isArray(m.content) ? m.content.find((c) => c && c.type === 'tool_use') : null;
      if (tool) { state = '干活'; detail = shortText(tool.name || ''); }
      else { state = '输出'; detail = shortText(txt || ''); }
      break;
    }
    if (r.type === 'user') { state = '思考'; detail = '等待回复'; break; }
  }
  const active = ago < ACTIVE_MS;
  if (!active) state = '空闲';
  return { id: 'claude', name: 'Claude Code', color: COLORS.claude, state, detail, active, at: f.mtimeMs };
}

let cache = { at: 0, data: [] };

export function collectAgents(force = false) {
  const now = Date.now();
  if (!force && now - cache.at < 2000) return cache.data;
  const list = [];
  try { list.push(probeCodex(now)); } catch (e) {}
  try { list.push(probeWorkBuddy(now)); } catch (e) {}
  try { list.push(probeClaude(now)); } catch (e) {}
  cache = { at: now, data: list };
  return list;
}

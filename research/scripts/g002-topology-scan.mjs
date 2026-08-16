#!/usr/bin/env node
// Mechanical inventory for G-002 topology. Does not print secret values.
// Usage: node research/scripts/g002-topology-scan.mjs

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");

const EXEC = [
  ["System.cmd", "System\\.cmd\\s*\\("],
  ["Port.open", "Port\\.open\\s*\\("],
  ["Node.spawn", "Node\\.spawn"],
  ["erpc", ":erpc"],
  ["rpc", ":rpc\\."],
  ["peer", ":peer"],
  ["net_kernel", "net_kernel"],
  ["Task.async", "Task\\.async"],
  ["spawn_link", "spawn_link"],
  ["open_port", "open_port"],
  ["NIF", ":erlang\\.load_nif|use Rustler"],
  ["File.read", "File\\.read(?:!)?\\s*\\("],
  ["File.write", "File\\.write(?:!)?\\s*\\("],
];

const SECRET = [
  ["XAI_API_KEY", "XAI_API_KEY"],
  ["ARVO_AUTH_FILE", "ARVO_AUTH_FILE"],
  ["auth.json", "auth\\.json"],
  ["persistent_term", "persistent_term"],
  ["cookie", "cookie"],
  ["RELEASE_COOKIE", "RELEASE_COOKIE"],
  ["access_token", "access_token"],
  ["refresh_token", "refresh_token"],
];

function walk(dir, acc = []) {
  if (!fs.existsSync(dir)) return acc;
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    if (["_build", "deps", ".git", "node_modules"].includes(ent.name)) continue;
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) walk(p, acc);
    else if (/\.(ex|exs|erl|config|eex)$/.test(ent.name) || /vm\.args/.test(ent.name)) {
      acc.push(p);
    }
  }
  return acc;
}

function hits(content, patterns) {
  const out = [];
  for (const [name, src] of patterns) {
    const m = content.match(new RegExp(src, "g"));
    if (m && m.length) out.push(`${name}x${m.length}`);
  }
  return out;
}

const files = walk(path.join(ROOT, "lib"))
  .concat(walk(path.join(ROOT, "rel")))
  .concat(walk(path.join(ROOT, "config")));
const mix = path.join(ROOT, "mix.exs");
if (fs.existsSync(mix)) files.push(mix);

const toolDir = path.join(ROOT, "lib/arvo/tools");
console.log("=== TOOLS ===");
for (const t of fs.readdirSync(toolDir).filter((f) => f.endsWith(".ex"))) {
  const c = fs.readFileSync(path.join(toolDir, t), "utf8");
  const e = hits(c, EXEC);
  const s = hits(c, SECRET);
  console.log(
    `${t} | exec=${e.join(",") || "NONE-in-VM"} | secret=${s.join(",") || "none"}`,
  );
}

console.log("\n=== EXEC OUTSIDE tools/ (no File.read/write) ===");
const skip = new Set(["File.read", "File.write"]);
for (const f of files) {
  if (f.includes("/tools/")) continue;
  const e = hits(fs.readFileSync(f, "utf8"), EXEC).filter(
    (x) => !skip.has(x.split("x")[0]),
  );
  if (e.length) console.log(`${path.relative(ROOT, f)} | ${e.join(", ")}`);
}

console.log("\n=== SECRET HITS ===");
for (const f of files) {
  const s = hits(fs.readFileSync(f, "utf8"), SECRET);
  if (s.length) console.log(`${path.relative(ROOT, f)} | ${s.join(", ")}`);
}

const libText = files
  .filter((f) => f.includes("/lib/"))
  .map((f) => fs.readFileSync(f, "utf8"))
  .join("\n");
const absences = ["Port.open", ":peer", ":erpc", "net_kernel", "ARVO_AUTH_FILE"];
console.log("\n=== ABSENCES IN lib/ ===");
for (const a of absences) {
  const found = libText.includes(a);
  console.log(`${a}: ${found ? "PRESENT" : "absent"}`);
}

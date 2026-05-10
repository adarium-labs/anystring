#!/usr/bin/env -S deno run --allow-read --allow-write
/**
 * Roadmap CLI — token-efficient interaction with `existing/frameworks-analysis/roadmap.json`.
 *
 * Designed for LLM use: terse output, stable exit codes, no decorative whitespace.
 * Pretty mode (`--pretty`) is opt-in for human inspection.
 * This script is the canonical non-interactive interface for reading and editing
 * the roadmap used by development workflows.
 *
 * Usage:
 *   deno run -A tools/roadmap.ts <command> [args]
 *
 * Common commands:
 *   deno run -A tools/roadmap.ts next
 *   deno run -A tools/roadmap.ts show HELP-PIPELINE-REDESIGN --pretty
 *   deno run -A tools/roadmap.ts add --tier 3 --id EXAMPLE ...
 *   deno run -A tools/roadmap.ts update HELP-PIPELINE-REDESIGN --add-doc-ref "file:section:1"
 *   deno run -A tools/roadmap.ts deps
 *
 * Run `deno run -A tools/roadmap.ts --help` for the full command list.
 */

import { Command } from "jsr:@cliffy/command@^1.0.1";

// ────────────────────────────────────────────────────────────────────────────
// Types
// ────────────────────────────────────────────────────────────────────────────

type Status = "done" | "next" | "in_progress" | "pending" | "skipped";

interface DocRef {
  file: string;
  section: string;
  approx_line: number;
}

interface Feature {
  id: string;
  name: string;
  summary: string;
  status: Status;
  spark_level: string;
  ffi: boolean;
  requirement_uids: string[];
  source_files: string[];
  doc_refs: DocRef[];
  depends_on?: string[];
  rationale?: string;
  target_crate?: string;
}

interface Tier {
  tier: number;
  name: string;
  description: string;
  doc_refs: DocRef[];
  features: Feature[];
}

interface Roadmap {
  version: string;
  project: string;
  generated: string;
  description?: string;
  statuses: Status[];
  scope_notes?: Record<string, unknown>;
  tiers: Tier[];
}

const VALID_STATUSES: Status[] = [
  "done",
  "next",
  "in_progress",
  "pending",
  "skipped",
];

// ────────────────────────────────────────────────────────────────────────────
// IO helpers
// ────────────────────────────────────────────────────────────────────────────

const DEFAULT_PATH = ".opencode/roadmap.json";

async function loadRoadmap(path: string): Promise<Roadmap> {
  try {
    const text = await Deno.readTextFile(path);
    return JSON.parse(text) as Roadmap;
  } catch (err) {
    fail(`cannot read ${path}: ${(err as Error).message}`, 2);
  }
}

async function saveRoadmap(path: string, rm: Roadmap): Promise<void> {
  // Stable, indented output — keeps git diffs clean.
  await Deno.writeTextFile(path, JSON.stringify(rm, null, 2) + "\n");
}

function fail(msg: string, code = 1): never {
  console.error(`error: ${msg}`);
  Deno.exit(code);
}

function findFeature(
  rm: Roadmap,
  id: string,
): { tier: Tier; feature: Feature } | null {
  const upper = id.toUpperCase();
  for (const tier of rm.tiers) {
    const f = tier.features.find((x) => x.id.toUpperCase() === upper);
    if (f) return { tier, feature: f };
  }
  return null;
}

function emit(value: unknown, pretty: boolean): void {
  if (typeof value === "string") {
    console.log(value);
    return;
  }
  console.log(JSON.stringify(value, null, pretty ? 2 : 0));
}

// Compact one-line representation of a feature — token-efficient.
function compact(f: Feature, tier: number): string {
  const reqs = f.requirement_uids.length
    ? ` reqs=${f.requirement_uids.join(",")}`
    : "";
  const deps = f.depends_on && f.depends_on.length
    ? ` deps=${f.depends_on.join(",")}`
    : "";
  return `T${tier} ${f.id} [${f.status}] ${f.name} :: ${f.summary}${reqs}${deps}`;
}

// ID format: uppercase letters, digits, and '-'. Matches existing roadmap convention.
const ID_RE = /^[A-Z][A-Z0-9-]*[A-Z0-9]$/;

// Split a comma-separated CLI list, trimming and dropping empties.
function splitList(raw: string | undefined): string[] {
  if (!raw) return [];
  return raw
    .split(",")
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
}

// Parse "file:section:line" doc-ref triples.
function parseDocRef(raw: string): DocRef {
  // Allow ':' inside section by splitting from the right for line, then left for file.
  const lastColon = raw.lastIndexOf(":");
  if (lastColon < 0) {
    fail(`invalid --doc-ref '${raw}'; expected 'file:section:line'`, 8);
  }
  const lineStr = raw.slice(lastColon + 1);
  const rest = raw.slice(0, lastColon);
  const firstColon = rest.indexOf(":");
  if (firstColon < 0) {
    fail(`invalid --doc-ref '${raw}'; expected 'file:section:line'`, 8);
  }
  const file = rest.slice(0, firstColon).trim();
  const section = rest.slice(firstColon + 1).trim();
  const approx_line = Number.parseInt(lineStr.trim(), 10);
  if (!file || !section || !Number.isFinite(approx_line)) {
    fail(`invalid --doc-ref '${raw}'; expected 'file:section:line'`, 8);
  }
  return { file, section, approx_line };
}

function docRefKey(ref: DocRef): string {
  return `${ref.file}:${ref.section}:${ref.approx_line}`;
}

function uniqueDocRefs(refs: DocRef[]): DocRef[] {
  const seen = new Set<string>();
  const out: DocRef[] = [];
  for (const ref of refs) {
    const key = docRefKey(ref);
    if (!seen.has(key)) {
      seen.add(key);
      out.push(ref);
    }
  }
  return out;
}

function parseBooleanValue(raw: string, flagName: string): boolean {
  const normalized = raw.trim().toLowerCase();
  if (["true", "1", "yes", "y", "on"].includes(normalized)) return true;
  if (["false", "0", "no", "n", "off"].includes(normalized)) return false;
  fail(
    `invalid value '${raw}' for ${flagName}; expected true/false`,
    8,
  );
}

function validateDependsOn(rm: Roadmap, id: string, deps: string[]): void {
  for (const dep of deps) {
    if (dep === id) fail(`feature cannot depend on itself: ${id}`, 12);
    if (!findFeature(rm, dep)) {
      const sug = suggest(rm, dep);
      fail(
        `unknown dependency ${dep}` +
          (sug.length ? `; did you mean: ${sug.join(", ")}?` : ""),
        13,
      );
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Levenshtein (for typo suggestions in `show`/`complete`/etc.)
// ────────────────────────────────────────────────────────────────────────────

function editDistance(a: string, b: string): number {
  const m = a.length, n = b.length;
  if (!m) return n;
  if (!n) return m;
  const dp = Array.from({ length: m + 1 }, () => new Array<number>(n + 1).fill(0));
  for (let i = 0; i <= m; i++) dp[i][0] = i;
  for (let j = 0; j <= n; j++) dp[0][j] = j;
  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      dp[i][j] = a[i - 1] === b[j - 1]
        ? dp[i - 1][j - 1]
        : 1 + Math.min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]);
    }
  }
  return dp[m][n];
}

function suggest(rm: Roadmap, id: string, max = 3): string[] {
  const upper = id.toUpperCase();
  const all = rm.tiers.flatMap((t) => t.features.map((f) => f.id));
  return all
    .map((cand) => ({ cand, d: editDistance(upper, cand.toUpperCase()) }))
    .sort((a, b) => a.d - b.d)
    .slice(0, max)
    .filter((x) => x.d <= 4)
    .map((x) => x.cand);
}

// ────────────────────────────────────────────────────────────────────────────
// Commands
// ────────────────────────────────────────────────────────────────────────────

const cli = new Command()
  .name("roadmap")
  .version("1.0.0")
  .description(
    "Token-efficient CLI for the project roadmap.json. " +
      "Designed for LLM-driven workflows.",
  )
  .globalOption("-f, --file <path:string>", "Roadmap JSON path", {
    default: DEFAULT_PATH,
  })
  .globalOption("--pretty", "Pretty-print JSON output (default: compact)")
  .action(function () {
    this.showHelp();
  });

// ── next ───────────────────────────────────────────────────────────────────
cli.command("next")
  .description(
    "Print the feature(s) with status=next. " +
      "Exits 0 if found, 3 if none. Use this to ask: what should I work on?",
  )
  .option("--json", "Output full JSON object instead of one-line summary")
  .action(async ({ file, pretty, json }) => {
    const rm = await loadRoadmap(file);
    const hits: { tier: number; feature: Feature }[] = [];
    for (const t of rm.tiers) {
      for (const f of t.features) {
        if (f.status === "next") hits.push({ tier: t.tier, feature: f });
      }
    }
    if (hits.length === 0) {
      console.error("no feature has status=next");
      Deno.exit(3);
    }
    if (json) {
      emit(hits.map((h) => ({ tier: h.tier, ...h.feature })), !!pretty);
    } else {
      for (const h of hits) console.log(compact(h.feature, h.tier));
    }
  });

// ── show ───────────────────────────────────────────────────────────────────
cli.command("show <id:string>")
  .description("Print the full JSON object for a feature by ID.")
  .action(async ({ file, pretty }, id) => {
    const rm = await loadRoadmap(file);
    const hit = findFeature(rm, id);
    if (!hit) {
      const sug = suggest(rm, id);
      console.error(
        `unknown feature ${id}` +
          (sug.length ? `; did you mean: ${sug.join(", ")}?` : ""),
      );
      Deno.exit(4);
    }
    emit({ tier: hit.tier.tier, ...hit.feature }, !!pretty);
  });

// ── list ───────────────────────────────────────────────────────────────────
cli.command("list")
  .description(
    "List features as one-line summaries. Filter with --tier and/or --status.",
  )
  .option("-t, --tier <n:integer>", "Only show features in this tier (1-4)")
  .option(
    "-s, --status <s:string>",
    "Only show features with this status",
  )
  .option("--json", "Output JSON array instead of compact lines")
  .action(async ({ file, pretty, tier, status, json }) => {
    const rm = await loadRoadmap(file);
    if (status && !VALID_STATUSES.includes(status as Status)) {
      fail(
        `invalid status '${status}'; expected one of ${VALID_STATUSES.join(", ")}`,
        5,
      );
    }
    const rows: { tier: number; feature: Feature }[] = [];
    for (const t of rm.tiers) {
      if (tier !== undefined && t.tier !== tier) continue;
      for (const f of t.features) {
        if (status && f.status !== status) continue;
        rows.push({ tier: t.tier, feature: f });
      }
    }
    if (json) {
      emit(rows.map((r) => ({ tier: r.tier, ...r.feature })), !!pretty);
    } else {
      for (const r of rows) console.log(compact(r.feature, r.tier));
    }
  });

// ── stats ──────────────────────────────────────────────────────────────────
cli.command("stats")
  .description("Aggregate counts by tier × status. Compact JSON by default.")
  .action(async ({ file, pretty }) => {
    const rm = await loadRoadmap(file);
    const overall: Record<string, number> = {};
    const byTier: Record<string, Record<string, number>> = {};
    let total = 0;
    for (const t of rm.tiers) {
      const key = `tier_${t.tier}`;
      byTier[key] = {};
      for (const f of t.features) {
        total++;
        overall[f.status] = (overall[f.status] ?? 0) + 1;
        byTier[key][f.status] = (byTier[key][f.status] ?? 0) + 1;
      }
    }
    emit({ total, by_status: overall, by_tier: byTier }, !!pretty);
  });

// ── set-status ─────────────────────────────────────────────────────────────
cli.command("set-status <id:string> <status:string>")
  .description(
    `Set a feature's status. Valid: ${VALID_STATUSES.join(", ")}.`,
  )
  .action(async ({ file }, id, status) => {
    if (!VALID_STATUSES.includes(status as Status)) {
      fail(
        `invalid status '${status}'; expected one of ${VALID_STATUSES.join(", ")}`,
        5,
      );
    }
    const rm = await loadRoadmap(file);
    const hit = findFeature(rm, id);
    if (!hit) {
      const sug = suggest(rm, id);
      fail(
        `unknown feature ${id}` +
          (sug.length ? `; did you mean: ${sug.join(", ")}?` : ""),
        4,
      );
    }
    const prev = hit.feature.status;
    hit.feature.status = status as Status;
    await saveRoadmap(file, rm);
    console.log(`${hit.feature.id}: ${prev} -> ${status}`);
  });

// ── complete ───────────────────────────────────────────────────────────────
cli.command("complete <id:string>")
  .description(
    "Mark a feature as done. Convenience wrapper around `set-status <id> done`.",
  )
  .action(async ({ file }, id) => {
    const rm = await loadRoadmap(file);
    const hit = findFeature(rm, id);
    if (!hit) {
      const sug = suggest(rm, id);
      fail(
        `unknown feature ${id}` +
          (sug.length ? `; did you mean: ${sug.join(", ")}?` : ""),
        4,
      );
    }
    const prev = hit.feature.status;
    if (prev === "done") {
      console.log(`${hit.feature.id}: already done`);
      return;
    }
    hit.feature.status = "done";
    await saveRoadmap(file, rm);
    console.log(`${hit.feature.id}: ${prev} -> done`);
  });

// ── search ─────────────────────────────────────────────────────────────────
cli.command("search <query:string>")
  .description(
    "Substring search (case-insensitive) across id, name, summary, and requirement UIDs.",
  )
  .option("--json", "Output JSON array instead of compact lines")
  .action(async ({ file, pretty, json }, query) => {
    const rm = await loadRoadmap(file);
    const q = query.toLowerCase();
    const hits: { tier: number; feature: Feature }[] = [];
    for (const t of rm.tiers) {
      for (const f of t.features) {
        const hay = [
          f.id,
          f.name,
          f.summary,
          ...f.requirement_uids,
        ].join("\n").toLowerCase();
        if (hay.includes(q)) hits.push({ tier: t.tier, feature: f });
      }
    }
    if (json) {
      emit(hits.map((h) => ({ tier: h.tier, ...h.feature })), !!pretty);
    } else {
      for (const h of hits) console.log(compact(h.feature, h.tier));
    }
    if (hits.length === 0) Deno.exit(3);
  });

// ── bump-next ──────────────────────────────────────────────────────────────
cli.command("bump-next")
  .description(
    "Auto-promote the lowest-tier pending feature to status=next. " +
      "Refuses if a feature is already 'next' or 'in_progress' unless --force is given.",
  )
  .option("-t, --tier <n:integer>", "Restrict promotion to this tier")
  .option("--force", "Override existing 'next' / 'in_progress' status")
  .option("--dry-run", "Print what would change without writing")
  .action(async ({ file, tier, force, dryRun }) => {
    const rm = await loadRoadmap(file);
    // Detect existing in-flight feature.
    const inFlight: Feature[] = [];
    for (const t of rm.tiers) {
      for (const f of t.features) {
        if (f.status === "next" || f.status === "in_progress") {
          inFlight.push(f);
        }
      }
    }
    if (inFlight.length > 0 && !force) {
      console.error(
        `refusing: already in flight: ${inFlight.map((f) => `${f.id}=${f.status}`).join(", ")}. ` +
          `Use --force to override.`,
      );
      Deno.exit(6);
    }
    // Pick lowest-tier pending feature.
    let chosen: { tier: number; feature: Feature } | null = null;
    for (const t of rm.tiers) {
      if (tier !== undefined && t.tier !== tier) continue;
      const f = t.features.find((x) => x.status === "pending");
      if (f) {
        chosen = { tier: t.tier, feature: f };
        break;
      }
    }
    if (!chosen) {
      console.error("no pending feature to promote");
      Deno.exit(3);
    }
    // Demote previous in-flight items if --force.
    if (force) {
      for (const f of inFlight) f.status = "pending";
    }
    chosen.feature.status = "next";
    if (dryRun) {
      console.log(`would promote: ${chosen.feature.id} -> next`);
      return;
    }
    await saveRoadmap(file, rm);
    console.log(`${chosen.feature.id}: pending -> next`);
  });

// ── move ──────────────────────────────────────────────────────────────────
cli.command("move")
  .description(
    "Move a feature to a new position. Target tier defaults to its current tier. " +
      "Position defaults to end-of-tier; use --before/--after for a specific slot " +
      "(mutually exclusive). Exits: 3 unknown id, 8 bad input, 10 unknown tier, " +
      "14 missing position target.",
  )
  .option("--id <id:string>", "Feature ID to move", { required: true })
  .option("--tier <n:integer>", "Destination tier (default: current tier)")
  .option("--before <id:string>", "Place before this feature (same destination tier)")
  .option("--after <id:string>", "Place after this feature (same destination tier)")
  .option("--end", "Place at end of destination tier (default behaviour)")
  .action(async (opts) => {
    const o = opts as {
      file: string;
      pretty?: boolean;
      id: string;
      tier?: number;
      before?: string;
      after?: string;
      end?: boolean;
    };
    const { file, pretty } = o;
    const positionFlags = [o.before, o.after, o.end].filter(Boolean).length;
    if (positionFlags > 1) {
      fail("--before, --after and --end are mutually exclusive", 8);
    }
    const rm = await loadRoadmap(file);
    // Locate source.
    let src: { tier: Tier; index: number } | null = null;
    for (const t of rm.tiers) {
      const idx = t.features.findIndex(
        (f) => f.id.toUpperCase() === o.id.toUpperCase(),
      );
      if (idx >= 0) {
        src = { tier: t, index: idx };
        break;
      }
    }
    if (!src) fail(`unknown feature ${o.id}`, 3);
    // Resolve destination tier (default = current).
    const destTierNum = o.tier ?? src.tier.tier;
    const destTier = rm.tiers.find((t) => t.tier === destTierNum);
    if (!destTier) {
      const known = rm.tiers.map((t) => t.tier).join(", ");
      fail(
        `unknown tier ${destTierNum}; known tiers: ${known || "(none)"}`,
        10,
      );
    }
    const feature = src.tier.features[src.index];
    // Remove from source first so --before/--after indices in same-tier moves
    // refer to the post-removal feature list, matching user intuition.
    src.tier.features.splice(src.index, 1);
    let insertAt = destTier.features.length;
    if (o.before) {
      const idx = destTier.features.findIndex(
        (f) => f.id.toUpperCase() === o.before!.toUpperCase(),
      );
      if (idx < 0) {
        // Restore before failing to keep file integrity on dry exit.
        src.tier.features.splice(src.index, 0, feature);
        fail(
          `--before target ${o.before} not found in tier ${destTierNum}`,
          14,
        );
      }
      insertAt = idx;
    } else if (o.after) {
      const idx = destTier.features.findIndex(
        (f) => f.id.toUpperCase() === o.after!.toUpperCase(),
      );
      if (idx < 0) {
        src.tier.features.splice(src.index, 0, feature);
        fail(`--after target ${o.after} not found in tier ${destTierNum}`, 14);
      }
      insertAt = idx + 1;
    }
    destTier.features.splice(insertAt, 0, feature);
    await saveRoadmap(file, rm);
    emit(
      {
        id: feature.id,
        from_tier: src.tier.tier,
        to_tier: destTier.tier,
        position: insertAt,
      },
      !!pretty,
    );
  });

// ── skip ──────────────────────────────────────────────────────────────────
cli.command("skip <id:string>")
  .description(
    "Mark a feature as skipped (excluded from next/bump-next selection). " +
      "Optionally record a reason in the feature's rationale field. " +
      "Exits 3 if the id is unknown.",
  )
  .option("--reason <text:string>", "Rationale stored on the feature")
  .action(async (opts, id) => {
    const o = opts as { file: string; pretty?: boolean; reason?: string };
    const rm = await loadRoadmap(o.file);
    let target: { tier: number; feature: Feature } | null = null;
    for (const t of rm.tiers) {
      const f = t.features.find(
        (x) => x.id.toUpperCase() === id.toUpperCase(),
      );
      if (f) {
        target = { tier: t.tier, feature: f };
        break;
      }
    }
    if (!target) fail(`unknown feature ${id}`, 3);
    const prev = target.feature.status;
    target.feature.status = "skipped";
    if (o.reason) target.feature.rationale = o.reason;
    await saveRoadmap(o.file, rm);
    emit(
      {
        id: target.feature.id,
        tier: target.tier,
        previous_status: prev,
        status: "skipped",
        rationale: target.feature.rationale,
      },
      !!o.pretty,
    );
  });

// ── add-tier ───────────────────────────────────────────────────────────────
cli.command("add-tier")
  .description(
    "Append a new tier to the roadmap. Tier numbers must be unique and positive. " +
      "Use this before `add` if the target tier does not yet exist.",
  )
  .option("-t, --tier <n:integer>", "Tier number (positive integer, unique)", {
    required: true,
  })
  .option("-n, --name <s:string>", "Tier display name", { required: true })
  .option("-d, --description <s:string>", "Tier description", {
    required: true,
  })
  .option(
    "--doc-ref <ref:string>",
    "Documentation reference 'file:section:line' (repeatable)",
    { collect: true },
  )
  .action(async (opts) => {
    const { file, pretty, tier, name, description } = opts as {
      file: string;
      pretty?: boolean;
      tier: number;
      name: string;
      description: string;
      docRef?: string[];
    };
    if (!Number.isInteger(tier) || tier <= 0) {
      fail(`invalid tier ${tier}; expected positive integer`, 8);
    }
    const rm = await loadRoadmap(file);
    if (rm.tiers.some((t) => t.tier === tier)) {
      fail(`tier ${tier} already exists`, 9);
    }
    const docRefs = ((opts as { docRef?: string[] }).docRef ?? []).map(
      parseDocRef,
    );
    const newTier: Tier = {
      tier,
      name,
      description,
      doc_refs: docRefs,
      features: [],
    };
    rm.tiers.push(newTier);
    rm.tiers.sort((a, b) => a.tier - b.tier);
    await saveRoadmap(file, rm);
    emit({ tier: newTier.tier, name: newTier.name }, !!pretty);
  });

// ── add ────────────────────────────────────────────────────────────────────
cli.command("add")
  .description(
    "Add a new feature to a tier. Position defaults to end-of-tier; " +
      "use --before <id> or --after <id> to insert relative to a sibling.",
  )
  .option("-i, --id <s:string>", "Feature ID (unique, uppercase, [A-Z0-9-])", {
    required: true,
  })
  .option("-n, --name <s:string>", "Feature display name", { required: true })
  .option("-s, --summary <s:string>", "One-sentence summary", {
    required: true,
  })
  .option("-t, --tier <n:integer>", "Target tier number (must exist)", {
    required: true,
  })
  .option(
    "--status <s:string>",
    `Initial status (default: pending). One of: ${VALID_STATUSES.join(", ")}`,
    { default: "pending" },
  )
  .option(
    "--spark-level <s:string>",
    "SPARK proof level tag (e.g. candidate, partial, gold, none)",
    { default: "candidate" },
  )
  .option("--ffi", "Mark feature as requiring FFI")
  .option(
    "--reqs <list:string>",
    "Comma-separated requirement UIDs (e.g. FUNC-PARSE-001,FUNC-HELP-002)",
  )
  .option(
    "--source-files <list:string>",
    "Comma-separated source file paths",
  )
  .option(
    "--depends-on <list:string>",
    "Comma-separated feature IDs this feature depends on (must already exist)",
  )
  .option(
    "--doc-ref <ref:string>",
    "Documentation reference 'file:section:line' (repeatable)",
    { collect: true },
  )
  .option("--rationale <s:string>", "Optional rationale text")
  .option(
    "--target-crate <s:string>",
    "Optional target crate (e.g. aclida_cli, myapp)",
  )
  .option(
    "--before <id:string>",
    "Insert before this sibling feature ID (must be in the same tier)",
  )
  .option(
    "--after <id:string>",
    "Insert after this sibling feature ID (must be in the same tier)",
  )
  .action(async (opts) => {
    const o = opts as {
      file: string;
      pretty?: boolean;
      id: string;
      name: string;
      summary: string;
      tier: number;
      status: string;
      sparkLevel: string;
      ffi?: boolean;
      reqs?: string;
      sourceFiles?: string;
      dependsOn?: string;
      docRef?: string[];
      rationale?: string;
      targetCrate?: string;
      before?: string;
      after?: string;
    };
    const { file, pretty } = o;

    if (o.before && o.after) {
      fail("--before and --after are mutually exclusive", 8);
    }

    const id = o.id;
    if (!ID_RE.test(id)) {
      fail(
        `invalid id '${o.id}'; expected uppercase [A-Z0-9-], starting with a letter`,
        8,
      );
    }

    if (!VALID_STATUSES.includes(o.status as Status)) {
      fail(
        `invalid status '${o.status}'; expected one of ${VALID_STATUSES.join(", ")}`,
        5,
      );
    }

    const rm = await loadRoadmap(file);

    const tier = rm.tiers.find((t) => t.tier === o.tier);
    if (!tier) {
      const known = rm.tiers.map((t) => t.tier).join(", ");
      fail(
        `unknown tier ${o.tier}; known tiers: ${known || "(none)"}. ` +
          `Create it first with 'add-tier'.`,
        10,
      );
    }

    if (findFeature(rm, id)) {
      fail(`duplicate id ${id}; already present in roadmap`, 11);
    }

    const dependsOn = splitList(o.dependsOn).map((d) => d.toUpperCase());
    validateDependsOn(rm, id, dependsOn);

    let insertAt = tier.features.length;
    if (o.before) {
      const idx = tier.features.findIndex(
        (f) => f.id.toUpperCase() === o.before!.toUpperCase(),
      );
      if (idx < 0) {
        fail(
          `--before target ${o.before} not found in tier ${o.tier}`,
          14,
        );
      }
      insertAt = idx;
    } else if (o.after) {
      const idx = tier.features.findIndex(
        (f) => f.id.toUpperCase() === o.after!.toUpperCase(),
      );
      if (idx < 0) {
        fail(`--after target ${o.after} not found in tier ${o.tier}`, 14);
      }
      insertAt = idx + 1;
    }

    const docRefs = (o.docRef ?? []).map(parseDocRef);

    const feature: Feature = {
      id,
      name: o.name,
      summary: o.summary,
      status: o.status as Status,
      spark_level: o.sparkLevel,
      ffi: !!o.ffi,
      requirement_uids: splitList(o.reqs),
      source_files: splitList(o.sourceFiles),
      doc_refs: docRefs,
    };
    if (dependsOn.length > 0) feature.depends_on = dependsOn;
    if (o.rationale) feature.rationale = o.rationale;
    if (o.targetCrate) feature.target_crate = o.targetCrate;

    tier.features.splice(insertAt, 0, feature);
    await saveRoadmap(file, rm);
    emit({ tier: tier.tier, position: insertAt, ...feature }, !!pretty);
  });

// ── update ─────────────────────────────────────────────────────────────────
cli.command("update <id:string>")
  .description(
    "Update fields on an existing feature non-interactively. " +
      "Supports scalar replacement and doc-ref add/remove/set operations.",
  )
  .option("--name <s:string>", "Replace feature name")
  .option("--summary <s:string>", "Replace feature summary")
  .option(
    "--status <s:string>",
    `Replace feature status. One of: ${VALID_STATUSES.join(", ")}`,
  )
  .option("--spark-level <s:string>", "Replace SPARK proof level tag")
  .option("--ffi <b:string>", "Replace ffi flag with true/false")
  .option(
    "--reqs <list:string>",
    "Replace requirement UIDs with a comma-separated list",
  )
  .option(
    "--source-files <list:string>",
    "Replace source file paths with a comma-separated list",
  )
  .option(
    "--depends-on <list:string>",
    "Replace dependencies with a comma-separated list of feature IDs",
  )
  .option("--rationale <s:string>", "Replace rationale text")
  .option("--clear-rationale", "Remove rationale field")
  .option("--target-crate <s:string>", "Replace target crate")
  .option("--clear-target-crate", "Remove target crate field")
  .option(
    "--set-doc-ref <ref:string>",
    "Replace doc_refs with these 'file:section:line' refs (repeatable)",
    { collect: true },
  )
  .option(
    "--add-doc-ref <ref:string>",
    "Append doc_refs in 'file:section:line' form (repeatable)",
    { collect: true },
  )
  .option(
    "--remove-doc-ref <ref:string>",
    "Remove matching doc_refs in 'file:section:line' form (repeatable)",
    { collect: true },
  )
  .option("--clear-doc-refs", "Remove all doc_refs")
  .option("--dry-run", "Print the updated feature without writing")
  .action(async (opts, id) => {
    const o = opts as {
      file: string;
      pretty?: boolean;
      name?: string;
      summary?: string;
      status?: string;
      sparkLevel?: string;
      ffi?: string;
      reqs?: string;
      sourceFiles?: string;
      dependsOn?: string;
      rationale?: string;
      clearRationale?: boolean;
      targetCrate?: string;
      clearTargetCrate?: boolean;
      setDocRef?: string[];
      addDocRef?: string[];
      removeDocRef?: string[];
      clearDocRefs?: boolean;
      dryRun?: boolean;
    };
    const { file, pretty } = o;

    if (o.clearRationale && o.rationale !== undefined) {
      fail("--rationale and --clear-rationale are mutually exclusive", 8);
    }
    if (o.clearTargetCrate && o.targetCrate !== undefined) {
      fail("--target-crate and --clear-target-crate are mutually exclusive", 8);
    }
    if ((o.setDocRef?.length ?? 0) > 0 && ((o.addDocRef?.length ?? 0) > 0 || (o.removeDocRef?.length ?? 0) > 0 || o.clearDocRefs)) {
      fail(
        "--set-doc-ref is mutually exclusive with --add-doc-ref, --remove-doc-ref, and --clear-doc-refs",
        8,
      );
    }
    if (o.clearDocRefs && (o.addDocRef?.length ?? 0) > 0) {
      fail("--clear-doc-refs and --add-doc-ref are mutually exclusive", 8);
    }

    const requestedChanges = [
      o.name !== undefined,
      o.summary !== undefined,
      o.status !== undefined,
      o.sparkLevel !== undefined,
      o.ffi !== undefined,
      o.reqs !== undefined,
      o.sourceFiles !== undefined,
      o.dependsOn !== undefined,
      o.rationale !== undefined,
      !!o.clearRationale,
      o.targetCrate !== undefined,
      !!o.clearTargetCrate,
      (o.setDocRef?.length ?? 0) > 0,
      (o.addDocRef?.length ?? 0) > 0,
      (o.removeDocRef?.length ?? 0) > 0,
      !!o.clearDocRefs,
    ].some(Boolean);

    if (!requestedChanges) {
      fail("no update flags provided", 8);
    }

    if (o.status !== undefined && !VALID_STATUSES.includes(o.status as Status)) {
      fail(
        `invalid status '${o.status}'; expected one of ${VALID_STATUSES.join(", ")}`,
        5,
      );
    }

    const rm = await loadRoadmap(file);
    const hit = findFeature(rm, id);
    if (!hit) {
      const sug = suggest(rm, id);
      fail(
        `unknown feature ${id}` +
          (sug.length ? `; did you mean: ${sug.join(", ")}?` : ""),
        4,
      );
    }

    const feature = hit.feature;
    const changedFields: string[] = [];

    if (o.name !== undefined && o.name !== feature.name) {
      feature.name = o.name;
      changedFields.push("name");
    }
    if (o.summary !== undefined && o.summary !== feature.summary) {
      feature.summary = o.summary;
      changedFields.push("summary");
    }
    if (o.status !== undefined && o.status !== feature.status) {
      feature.status = o.status as Status;
      changedFields.push("status");
    }
    if (o.sparkLevel !== undefined && o.sparkLevel !== feature.spark_level) {
      feature.spark_level = o.sparkLevel;
      changedFields.push("spark_level");
    }
    if (o.ffi !== undefined) {
      const nextFfi = parseBooleanValue(o.ffi, "--ffi");
      if (nextFfi !== feature.ffi) {
        feature.ffi = nextFfi;
        changedFields.push("ffi");
      }
    }
    if (o.reqs !== undefined) {
      feature.requirement_uids = splitList(o.reqs);
      changedFields.push("requirement_uids");
    }
    if (o.sourceFiles !== undefined) {
      feature.source_files = splitList(o.sourceFiles);
      changedFields.push("source_files");
    }
    if (o.dependsOn !== undefined) {
      const nextDependsOn = splitList(o.dependsOn).map((d) => d.toUpperCase());
      validateDependsOn(rm, feature.id, nextDependsOn);
      if (nextDependsOn.length > 0) {
        feature.depends_on = nextDependsOn;
      } else {
        delete feature.depends_on;
      }
      changedFields.push("depends_on");
    }
    if (o.rationale !== undefined) {
      feature.rationale = o.rationale;
      changedFields.push("rationale");
    } else if (o.clearRationale && feature.rationale !== undefined) {
      delete feature.rationale;
      changedFields.push("rationale");
    }
    if (o.targetCrate !== undefined) {
      feature.target_crate = o.targetCrate;
      changedFields.push("target_crate");
    } else if (o.clearTargetCrate && feature.target_crate !== undefined) {
      delete feature.target_crate;
      changedFields.push("target_crate");
    }

    const setDocRefs = (o.setDocRef ?? []).map(parseDocRef);
    const addDocRefs = (o.addDocRef ?? []).map(parseDocRef);
    const removeDocRefs = (o.removeDocRef ?? []).map(parseDocRef);
    if (setDocRefs.length > 0) {
      feature.doc_refs = uniqueDocRefs(setDocRefs);
      changedFields.push("doc_refs");
    } else if (o.clearDocRefs) {
      feature.doc_refs = [];
      changedFields.push("doc_refs");
    } else if (addDocRefs.length > 0 || removeDocRefs.length > 0) {
      const removeKeys = new Set(removeDocRefs.map(docRefKey));
      const kept = uniqueDocRefs(feature.doc_refs).filter((ref) => !removeKeys.has(docRefKey(ref)));
      feature.doc_refs = uniqueDocRefs([...kept, ...addDocRefs]);
      changedFields.push("doc_refs");
    }

    if (!o.dryRun) {
      await saveRoadmap(file, rm);
    }

    emit(
      {
        tier: hit.tier.tier,
        dry_run: !!o.dryRun,
        changed_fields: [...new Set(changedFields)],
        ...feature,
      },
      !!pretty,
    );
  });

// Examples for LLM/tooling workflows:
//   roadmap update HELP-PIPELINE-REDESIGN \
//     --add-doc-ref "existing/frameworks-analysis/08_help_pipeline_redesign_execution_breakdown.md:Help Pipeline Redesign Execution Breakdown:1"
//
//   roadmap update CONFIG-FILES-TOML \
//     --status next \
//     --rationale "Ready once help redesign/export work is complete"
//
//   roadmap update MAN-PAGE-GEN \
//     --set-doc-ref "existing/frameworks-analysis/prompt-part2-doc-generation.md:Help Export and Documentation Generation Preparation:1" \
//     --dry-run

// ── deps (validate) ────────────────────────────────────────────────────────
cli.command("deps")
  .description(
    "Validate roadmap schema: required fields, status values, ID uniqueness, " +
      "tier shape. Exits 0 on success, 7 on schema errors.",
  )
  .action(async ({ file }) => {
    const rm = await loadRoadmap(file);
    const errors: string[] = [];
    const seen = new Set<string>();

    if (!rm.version) errors.push("missing top-level 'version'");
    if (!rm.project) errors.push("missing top-level 'project'");
    if (!Array.isArray(rm.tiers)) errors.push("'tiers' is not an array");

    for (const t of rm.tiers ?? []) {
      if (typeof t.tier !== "number") {
        errors.push(`tier entry missing numeric 'tier'`);
      }
      if (!Array.isArray(t.features)) {
        errors.push(`tier ${t.tier}: 'features' is not an array`);
        continue;
      }
      for (const f of t.features) {
        if (!f.id) errors.push(`tier ${t.tier}: feature missing 'id'`);
        if (f.id && seen.has(f.id)) errors.push(`duplicate id: ${f.id}`);
        if (f.id) seen.add(f.id);
        if (!f.name) errors.push(`${f.id}: missing 'name'`);
        if (!f.summary) errors.push(`${f.id}: missing 'summary'`);
        if (!VALID_STATUSES.includes(f.status)) {
          errors.push(`${f.id}: invalid status '${f.status}'`);
        }
        if (!Array.isArray(f.requirement_uids)) {
          errors.push(`${f.id}: 'requirement_uids' must be an array`);
        }
        if (!Array.isArray(f.source_files)) {
          errors.push(`${f.id}: 'source_files' must be an array`);
        }
        if (!Array.isArray(f.doc_refs)) {
          errors.push(`${f.id}: 'doc_refs' must be an array`);
        }
        if (f.depends_on !== undefined && !Array.isArray(f.depends_on)) {
          errors.push(`${f.id}: 'depends_on' must be an array if present`);
        }
      }
    }

    // Referential integrity + cycle detection on depends_on edges.
    const idIndex = new Map<string, Feature>();
    for (const t of rm.tiers ?? []) {
      for (const f of t.features ?? []) {
        if (f.id) idIndex.set(f.id, f);
      }
    }
    for (const f of idIndex.values()) {
      for (const dep of f.depends_on ?? []) {
        if (!idIndex.has(dep)) {
          errors.push(`${f.id}: depends_on '${dep}' is not a known feature`);
        }
        if (dep === f.id) {
          errors.push(`${f.id}: depends_on contains self-reference`);
        }
      }
    }
    // Detect cycles via DFS over depends_on edges.
    const WHITE = 0, GRAY = 1, BLACK = 2;
    const color = new Map<string, number>();
    const cycleHits: string[] = [];
    const visit = (id: string, stack: string[]): void => {
      const c = color.get(id) ?? WHITE;
      if (c === GRAY) {
        const cyc = [...stack.slice(stack.indexOf(id)), id].join(" -> ");
        cycleHits.push(cyc);
        return;
      }
      if (c === BLACK) return;
      color.set(id, GRAY);
      const f = idIndex.get(id);
      for (const dep of f?.depends_on ?? []) {
        if (idIndex.has(dep)) visit(dep, [...stack, id]);
      }
      color.set(id, BLACK);
    };
    for (const id of idIndex.keys()) visit(id, []);
    for (const cyc of cycleHits) errors.push(`cycle: ${cyc}`);

    if (errors.length === 0) {
      console.log(`ok: ${seen.size} features validated`);
      return;
    }
    for (const e of errors) console.error(e);
    Deno.exit(7);
  });

// ────────────────────────────────────────────────────────────────────────────

await cli.parse(Deno.args);

//! Minimal search NIF for the fff flagship plugin seam.
//! Walks `path` and returns lines matching `pattern` (substring, not full regex).

use rustler::{Encoder, Env, Term};
use std::fs;
use std::path::Path;
use walkdir::WalkDir;

#[rustler::nif]
fn search<'a>(env: Env<'a>, pattern: String, path: String) -> Term<'a> {
    if pattern.is_empty() {
        return error(env, "pattern must not be empty");
    }

    let root = Path::new(&path);
    if !root.exists() {
        return error(env, &format!("path not found: {path}"));
    }

    let mut hits: Vec<String> = Vec::new();
    let mut scanned = 0u32;

    for entry in WalkDir::new(root)
        .follow_links(false)
        .into_iter()
        .filter_map(|e| e.ok())
    {
        if !entry.file_type().is_file() {
            continue;
        }
        // Skip obvious non-text / huge trees
        let p = entry.path();
        if let Some(name) = p.file_name().and_then(|n| n.to_str()) {
            if name.starts_with('.') {
                continue;
            }
        }
        if let Some(ext) = p.extension().and_then(|e| e.to_str()) {
            let skip = matches!(
                ext,
                "beam" | "o" | "so" | "a" | "png" | "jpg" | "jpeg" | "gif" | "webp" | "pdf" | "zip"
            );
            if skip {
                continue;
            }
        }

        scanned += 1;
        if scanned > 5_000 {
            break;
        }

        let Ok(content) = fs::read_to_string(p) else {
            continue;
        };
        if content.contains('\0') {
            continue;
        }

        for (idx, line) in content.lines().enumerate() {
            if line.contains(&pattern) {
                hits.push(format!("{}:{}:{}", p.display(), idx + 1, line));
                if hits.len() >= 200 {
                    break;
                }
            }
        }
        if hits.len() >= 200 {
            break;
        }
    }

    if hits.is_empty() {
        ok(env, "No matches".to_string())
    } else {
        ok(env, hits.join("\n"))
    }
}

fn ok<'a>(env: Env<'a>, text: String) -> Term<'a> {
    // {:ok, text}
    (rustler::types::atom::ok(), text).encode(env)
}

fn error<'a>(env: Env<'a>, msg: &str) -> Term<'a> {
    (rustler::types::atom::error(), msg).encode(env)
}

rustler::init!("Elixir.Fff.Native");

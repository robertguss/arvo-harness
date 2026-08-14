#!/usr/bin/env python3
"""Dump X bookmarks for the authenticated user. Never prints tokens."""

from __future__ import annotations

import json
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / ".env"
OUT_DIR = ROOT / "docs" / "working" / "x-bookmarks"
TWEET_FIELDS = "created_at,author_id,text,public_metrics,conversation_id,lang,entities,referenced_tweets,note_tweet"
USER_FIELDS = "username,name,description,public_metrics"
EXPANSIONS = "author_id,referenced_tweets.id,referenced_tweets.id.author_id"


def load_env(path: Path) -> dict[str, str]:
    env: dict[str, str] = {}
    for raw in path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env[key.strip()] = value.strip().strip('"').strip("'")
    return env


def api_get(url: str, token: str) -> dict:
    req = urllib.request.Request(url)
    req.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as exc:
        body = exc.read().decode(errors="replace")
        raise SystemExit(f"HTTP {exc.code} {url.split('?',1)[0]}: {body[:400]}") from exc


def fetch_all(token: str, user_id: str) -> tuple[list[dict], dict[str, dict]]:
    tweets: list[dict] = []
    users: dict[str, dict] = {}
    pagination = None
    pages = 0
    while True:
        params = {
            "max_results": 100,
            "tweet.fields": TWEET_FIELDS,
            "user.fields": USER_FIELDS,
            "expansions": EXPANSIONS,
        }
        if pagination:
            params["pagination_token"] = pagination
        url = f"https://api.twitter.com/2/users/{user_id}/bookmarks?{urllib.parse.urlencode(params)}"
        payload = api_get(url, token)
        tweets.extend(payload.get("data") or [])
        includes = payload.get("includes") or {}
        for user in includes.get("users") or []:
            users[user["id"]] = user
        for extra in includes.get("tweets") or []:
            # keep referenced tweets on the parent object only
            extra_author = extra.get("author_id")
            extra["_included"] = True
            tweets.append(extra) if False else None
            # stash referenced by id on users map side channel
            users.setdefault(f"tweet:{extra['id']}", extra)
        meta = payload.get("meta") or {}
        pages += 1
        print(f"page {pages}: +{len(payload.get('data') or [])} (total {len(tweets)})")
        pagination = meta.get("next_token")
        if not pagination:
            break
        time.sleep(0.4)
    return tweets, users


def flatten(tweets: list[dict], users: dict[str, dict]) -> list[dict]:
    rows = []
    for tweet in tweets:
        if tweet.get("_included"):
            continue
        author = users.get(tweet.get("author_id") or "", {})
        metrics = tweet.get("public_metrics") or {}
        refs = tweet.get("referenced_tweets") or []
        note = ((tweet.get("note_tweet") or {}).get("text")) or tweet.get("text") or ""
        rows.append(
            {
                "id": tweet.get("id"),
                "created_at": tweet.get("created_at"),
                "author_id": tweet.get("author_id"),
                "username": author.get("username"),
                "name": author.get("name"),
                "text": note,
                "url": f"https://x.com/{author.get('username') or 'i'}/status/{tweet.get('id')}",
                "likes": metrics.get("like_count"),
                "reposts": metrics.get("retweet_count"),
                "replies": metrics.get("reply_count"),
                "quotes": metrics.get("quote_count"),
                "conversation_id": tweet.get("conversation_id"),
                "referenced": refs,
            }
        )
    return rows


def write_outputs(rows: list[dict], raw_tweets: list[dict], users: dict[str, dict]) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    json_path = OUT_DIR / "bookmarks.json"
    md_path = OUT_DIR / "INDEX.md"
    json_path.write_text(json.dumps({"fetched": stamp, "count": len(rows), "bookmarks": rows}, indent=2) + "\n")
    # strip any accidental token-like keys from raw dump
    safe_users = {k: v for k, v in users.items() if not k.startswith("tweet:")}
    (OUT_DIR / "bookmarks.raw.json").write_text(
        json.dumps({"fetched": stamp, "tweets": raw_tweets, "users": safe_users}, indent=2) + "\n"
    )
    lines = [
        f"# X bookmarks dump",
        "",
        f"- **Fetched:** {stamp}",
        f"- **Count:** {len(rows)}",
        f"- **Account:** @_robguss (id not repeated here)",
        f"- **Raw:** [bookmarks.json](bookmarks.json)",
        "",
        "Working export for idea mining. Not an accepted research report.",
        "",
        "| # | Author | Date | Post |",
        "|---|--------|------|------|",
    ]
    for i, row in enumerate(rows, 1):
        text = (row["text"] or "").replace("|", "\\|").replace("\n", " ")
        if len(text) > 140:
            text = text[:137] + "..."
        date = (row.get("created_at") or "")[:10]
        handle = row.get("username") or "?"
        url = row.get("url") or ""
        lines.append(f"| {i} | [@{handle}](https://x.com/{handle}) | {date} | [{text}]({url}) |")
    md_path.write_text("\n".join(lines) + "\n")
    print(f"wrote {len(rows)} bookmarks → {md_path.relative_to(ROOT)}")


def main() -> None:
    env = load_env(ENV_PATH)
    token = env.get("X_USER_BEARER") or ""
    user_id = env.get("X_USER_ID") or ""
    if not token or not user_id:
        raise SystemExit(".env missing X_USER_BEARER or X_USER_ID")
    tweets, users = fetch_all(token, user_id)
    rows = flatten(tweets, users)
    write_outputs(rows, tweets, users)


if __name__ == "__main__":
    main()

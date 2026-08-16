#!/usr/bin/env python3
"""OAuth 2.0 PKCE for X bookmarks. Never prints token values."""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import secrets
import sys
import urllib.error
import urllib.parse
import urllib.request
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / ".env"
REDIRECT_URI = "http://127.0.0.1:8765/callback"
SCOPES = "bookmark.read tweet.read users.read offline.access"
AUTHORIZE_URL = "https://twitter.com/i/oauth2/authorize"
TOKEN_URL = "https://api.twitter.com/2/oauth2/token"
ME_URL = "https://api.twitter.com/2/users/me"
STATE_PATH = ROOT / "secrets" / "x_oauth_state.json"


def load_env(path: Path) -> dict[str, str]:
    env: dict[str, str] = {}
    if not path.exists():
        return env
    for raw in path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env[key.strip()] = value.strip().strip('"').strip("'")
    return env


def write_env_keys(path: Path, updates: dict[str, str]) -> None:
    existing = path.read_text() if path.exists() else ""
    lines = existing.splitlines()
    keys_seen: set[str] = set()
    out: list[str] = []
    for line in lines:
        stripped = line.strip()
        if stripped and not stripped.startswith("#") and "=" in stripped:
            key = stripped.split("=", 1)[0].strip()
            if key in updates:
                out.append(f"{key}={updates[key]}")
                keys_seen.add(key)
                continue
        out.append(line)
    for key, value in updates.items():
        if key not in keys_seen:
            if out and out[-1] != "":
                out.append("")
            out.append(f"{key}={value}")
    path.write_text("\n".join(out) + "\n")
    os.chmod(path, 0o600)


def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def pkce_pair() -> tuple[str, str]:
    verifier = b64url(secrets.token_bytes(32))
    challenge = b64url(hashlib.sha256(verifier.encode("ascii")).digest())
    return verifier, challenge


def authorize_url(client_id: str, challenge: str, state: str) -> str:
    query = urllib.parse.urlencode(
        {
            "response_type": "code",
            "client_id": client_id,
            "redirect_uri": REDIRECT_URI,
            "scope": SCOPES,
            "state": state,
            "code_challenge": challenge,
            "code_challenge_method": "S256",
        }
    )
    return f"{AUTHORIZE_URL}?{query}"


def save_state(verifier: str, state: str) -> None:
    STATE_PATH.parent.mkdir(mode=0o700, exist_ok=True)
    STATE_PATH.write_text(json.dumps({"verifier": verifier, "state": state}))
    os.chmod(STATE_PATH, 0o600)


def load_state() -> dict[str, str]:
    if not STATE_PATH.exists():
        raise SystemExit("No pending OAuth state. Run: python3 scripts/x_oauth_pkce.py start")
    return json.loads(STATE_PATH.read_text())


def extract_code(redirect_or_code: str) -> tuple[str, str | None]:
    text = redirect_or_code.strip()
    if text.startswith("http://") or text.startswith("https://"):
        parsed = urllib.parse.urlparse(text)
        qs = urllib.parse.parse_qs(parsed.query)
        if "error" in qs:
            raise SystemExit(f"X returned error: {qs.get('error')} {qs.get('error_description')}")
        code = (qs.get("code") or [""])[0]
        state = (qs.get("state") or [None])[0]
        if not code:
            raise SystemExit("URL has no ?code= — copy the full address bar after authorize.")
        return code, state
    return text, None


def exchange(client_id: str, client_secret: str, code: str, verifier: str) -> dict:
    body = urllib.parse.urlencode(
        {
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": REDIRECT_URI,
            "code_verifier": verifier,
            "client_id": client_id,
        }
    ).encode()
    req = urllib.request.Request(TOKEN_URL, data=body, method="POST")
    req.add_header("Content-Type", "application/x-www-form-urlencoded")
    basic = base64.b64encode(f"{client_id}:{client_secret}".encode()).decode()
    req.add_header("Authorization", f"Basic {basic}")
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode(errors="replace")
        raise SystemExit(f"Token exchange failed HTTP {exc.code}: {detail[:300]}") from exc


def fetch_me(access_token: str) -> dict:
    req = urllib.request.Request(ME_URL)
    req.add_header("Authorization", f"Bearer {access_token}")
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode(errors="replace")
        raise SystemExit(f"/users/me failed HTTP {exc.code}: {detail[:300]}") from exc


def cmd_start() -> None:
    env = load_env(ENV_PATH)
    client_id = env.get("X_CLIENT_ID") or ""
    if not client_id:
        raise SystemExit(".env is missing X_CLIENT_ID")
    verifier, challenge = pkce_pair()
    state = secrets.token_urlsafe(16)
    save_state(verifier, state)
    url = authorize_url(client_id, challenge, state)
    print("Callback registered in the X app must be exactly:")
    print(f"  {REDIRECT_URI}")
    print()
    print("Open this URL, authorize, then either:")
    print("  - leave the browser on the redirected page, or")
    print("  - copy the full address-bar URL (even if the page fails to load)")
    print("    and run: python3 scripts/x_oauth_pkce.py finish 'PASTE_URL'")
    print()
    print(url)


class _Handler(BaseHTTPRequestHandler):
    code: str | None = None
    state: str | None = None
    error: str | None = None

    def log_message(self, fmt: str, *args) -> None:  # noqa: A003
        return

    def do_GET(self) -> None:  # noqa: N802
        parsed = urllib.parse.urlparse(self.path)
        if parsed.path != "/callback":
            self.send_response(404)
            self.end_headers()
            return
        qs = urllib.parse.parse_qs(parsed.query)
        if "error" in qs:
            _Handler.error = qs.get("error_description", qs.get("error", [""]))[0]
        else:
            _Handler.code = (qs.get("code") or [""])[0]
            _Handler.state = (qs.get("state") or [None])[0]
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(b"You can close this tab and return to the terminal.")


def cmd_wait(timeout: int) -> None:
    print(f"Listening on {REDIRECT_URI} for {timeout}s (only works if THIS machine is 127.0.0.1)...")
    server = HTTPServer(("127.0.0.1", 8765), _Handler)
    server.timeout = 1
    waited = 0
    while waited < timeout and _Handler.code is None and _Handler.error is None:
        server.handle_request()
        waited += 1
    server.server_close()
    if _Handler.error:
        raise SystemExit(f"X returned error: {_Handler.error}")
    if not _Handler.code:
        raise SystemExit("No callback received. Use: python3 scripts/x_oauth_pkce.py finish 'PASTE_URL'")
    _finish_with_code(_Handler.code, _Handler.state)


def cmd_finish(redirect_or_code: str) -> None:
    code, state = extract_code(redirect_or_code)
    _finish_with_code(code, state)


def _finish_with_code(code: str, state: str | None) -> None:
    env = load_env(ENV_PATH)
    client_id = env.get("X_CLIENT_ID") or ""
    client_secret = env.get("X_CLIENT_SECRET") or ""
    if not client_id or not client_secret:
        raise SystemExit(".env needs X_CLIENT_ID and X_CLIENT_SECRET")
    pending = load_state()
    if state and state != pending["state"]:
        raise SystemExit("OAuth state mismatch. Run start again.")
    tokens = exchange(client_id, client_secret, code, pending["verifier"])
    access = tokens.get("access_token")
    refresh = tokens.get("refresh_token", "")
    if not access:
        raise SystemExit("Token response had no access_token")
    me = fetch_me(access)
    data = me.get("data") or {}
    user_id = str(data.get("id") or "")
    username = data.get("username") or ""
    write_env_keys(
        ENV_PATH,
        {
            "X_USER_BEARER": access,
            "X_REFRESH_TOKEN": refresh,
            "X_USER_ID": user_id,
        },
    )
    if STATE_PATH.exists():
        STATE_PATH.unlink()
    print("OK: user token saved to .env (not printed).")
    if username:
        print(f"Authenticated as @{username} id={user_id}")
    else:
        print(f"Authenticated user id={user_id or '(unknown)'}")


def main() -> None:
    parser = argparse.ArgumentParser(description="X OAuth 2.0 PKCE helper")
    parser.add_argument("command", choices=["start", "wait", "finish"])
    parser.add_argument("url", nargs="?", help="Full redirect URL for finish")
    parser.add_argument("--timeout", type=int, default=180)
    args = parser.parse_args()
    if args.command == "start":
        cmd_start()
    elif args.command == "wait":
        cmd_wait(args.timeout)
    else:
        if not args.url:
            raise SystemExit("usage: python3 scripts/x_oauth_pkce.py finish 'http://127.0.0.1:8765/callback?code=...'")
        cmd_finish(args.url)


if __name__ == "__main__":
    main()

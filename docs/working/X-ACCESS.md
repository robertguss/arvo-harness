# X access (bookmarks + search)

- **Status:** Setup note. No tokens live here.
- **Updated:** 2026-08-14

Robert wants the lab to search **his X bookmarks** (and related public trails) for harness ideas.

## Do not

- Paste API keys or tokens in chat.
- Commit `.env` or anything under `secrets/`.

## What actually works for bookmarks

X bookmarks are **user-scoped**. Needed:

`GET /2/users/:id/bookmarks`

Auth: **OAuth 2.0 user context** (PKCE), not an app-only Bearer.

Scopes: `bookmark.read` `tweet.read` `users.read`  
Optional: `offline.access` (refresh token; access tokens expire ~2h).

An “API key” / app Bearer from the developer portal will 403 this endpoint.

## Drop path (OAuth 2.0 — current)

`.env` already has `X_CLIENT_ID` + `X_CLIENT_SECRET`.

In the X app, callback must be exactly:

`http://127.0.0.1:8765/callback`

Then:

```bash
python3 scripts/x_oauth_pkce.py start
```

Open the printed URL, authorize. If the tab fails to load (this VM is not your laptop), copy the **full address bar** and:

```bash
python3 scripts/x_oauth_pkce.py finish 'PASTE_URL'
```

Do not paste that URL in chat (it contains a one-time code). Run `finish` locally. Then say “token is in .env.”

Then we can page bookmarks into `docs/working/x-bookmarks/` (text/JSON, no secrets) and card them with the same circle/underline lens.

## Already possible without his key

Public posts (José, `@Vtrivedy10`, etc.) via built-in X search. Bookmarks are the missing private pile.

## Still useful if the token is only app-only

We can still search public accounts he names. Bookmarks wait until there is a user token.

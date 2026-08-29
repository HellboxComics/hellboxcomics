# Hellbox Comics

**Hellbox Comics is an underground digital publishing house operated by Harrow.**

The product priority is:

1. comics
2. collecting
3. ownership
4. interaction
5. blockchain

Blockchain is infrastructure underneath the publishing experience, not the product itself. Hellbox is PulseChain-rooted, multi-chain-ready, and uses native deployments per chain rather than bridged Hellbox NFTs.

## Start here

Before changing this repository, read:

- `HELLBOX_PROJECT_STATE.md` — authoritative project handoff/bible, current production truth, locked decisions, known risks, exact next step
- `docs/HARROW_CHARACTER_BIBLE_V1.md` — Harrow character, voice, visual and lore direction
- `docs/ACCESSIBILITY_AND_LOCALIZATION_STANDARD.md` — accessibility/localization requirements

If this README conflicts with `HELLBOX_PROJECT_STATE.md`, the project-state bible wins.

## Harrow

Harrow is Hellbox's writer, artist, publisher, operator, narrator, host, and problem.

The public character should feel like a real outlaw creator inside the audience's world—not a generic Web3 founder, community manager, fantasy demon king, superhero, or Joker copy. The core production rule is:

> **The machinery is disciplined. The operator is not.**

Detailed characterization and visual canon live in `docs/HARROW_CHARACTER_BIBLE_V1.md` and `HELLBOX_PROJECT_STATE.md`.

## Current production checkpoint

**Gate 2 COMPLETE — SciVive Reader vertical slice**  
**Gate 3 NEXT — Identity, Ownership & Archive**

The site is live at `hellboxcomics.com` and deploys from `main` through Cloudflare.

### Completed

**Gate 0 — Stabilization & Platform Foundation**

- recovered stable production baseline
- responsive laptop/mobile foundation
- accessibility and localization architecture
- English/Spanish interface support
- GA4 integration
- multi-chain configuration/status foundation
- usable temporary Press prototype
- locked incremental development workflow

**Gate 1 — Publication Platform & Data Model**

- Cloudflare D1 publication platform
- chain-independent `publicationKey`
- public/private publication lifecycle
- per-chain mint/deployment configuration
- publication package/schema validation
- R2 public/private asset-location model
- SciVive seeded as the first real private publication
- Worker publication APIs now read D1 instead of a hardcoded registry

**Gate 2 — Reader Vertical Slice**

- canonical SciVive source verified by byte size, SHA-256 and page count
- 461-page deterministic Reader manifest
- reproducible PDF → WebP Reader build pipeline
- 461 protected Reader presentation pages
- 462/462 private R2 objects remotely downloaded and hash-verified
- durable D1 Reader manifest/page-prefix binding
- Worker loads protected Reader configuration from D1 and private R2
- protected page delivery proven byte-for-byte through the production Worker
- frontend uses authenticated `fetch` → Blob → `URL.createObjectURL(...)`
- Reader does not embed the source PDF
- browser acceptance passes at:
  - laptop `1440x900`
  - tablet `820x1180`
  - phone `390x844`
- temporary Gate 2 preview authorization was removed and its Cloudflare secret deleted
- normal public `/api/reader/scivive` remains intentionally hidden with HTTP `404`

## Reader product direction

Website first.

The web Reader must deliver an exceptional PC/Mac experience while remaining polished and genuinely usable on tablet and phone browsers. Desktop/tablet may expose a richer control surface; compact phone layouts can simplify controls as long as reading, navigation, containment and access protection remain strong.

A dedicated native mobile/tablet app is a later product phase and does **not** begin until the website/platform is dialed in.

## Current SciVive state

SciVive is deliberately private and not yet mintable.

- `publicationKey`: `scivive`
- presentation: `book`
- chain: PulseChain (`369`)
- max supply: `5555`
- payment model: free
- royalty: `369` bps
- Reader policy: ownership
- package status: `draft`
- publishing enabled: `false`
- contract address: not deployed yet
- Reader pages: `461`

Protected Reader storage:

```text
hellbox-private/
└── comics/scivive/001/reader/
    ├── manifest.json
    └── pages/
        ├── page-0001.webp
        ├── ...
        └── page-0461.webp
```

## Architecture

```text
Browser
  │
  ├── Static frontend
  │   ├── index.html
  │   ├── style.css
  │   ├── gate02.css
  │   └── app.js
  │
  └── /api/*
      │
      ▼
Cloudflare Worker — src/index.js
      │
      ├── D1: hellbox-production
      │     publication/package/Reader authority
      │
      ├── R2: hellbox-public
      │     public delivery assets
      │
      └── R2: hellbox-private
            protected publication/Reader assets
```

Configured Worker bindings are defined in `wrangler.jsonc`:

- `DB` → `hellbox-production`
- `PUBLIC_BUCKET` → `hellbox-public`
- `PRIVATE_BUCKET` → `hellbox-private`
- `ASSETS` → static repository assets

The legacy `hellbox-assets` R2 bucket is intentionally excluded from this architecture.

## Important repository paths

```text
index.html                         public DOM / application shell
style.css                         primary visual system
app.js                            browser runtime / Reader transport
src/index.js                      Cloudflare Worker / API
wrangler.jsonc                    Cloudflare runtime bindings
migrations/                       D1 schema + durable data migrations
publications/scivive/             SciVive publication package
publications/scivive/reader/      committed Reader manifest
schemas/                          publication package schemas
config/chains.js                  chain configuration
locales/                          interface localization packs
tools/build_scivive_reader.py     reproducible Reader asset builder
tools/upload_scivive_reader.py    private R2 upload + remote verification
tools/test_reader_ui.py           browser Reader acceptance test
docs/                             product/canon standards
HELLBOX_PROJECT_STATE.md          authoritative living handoff
```

Generated 461-page Reader output is intentionally kept outside Git under the local Hellbox build directory.

## Production D1 migrations

Applied in order:

```text
0001_publication_platform.sql
0002_refine_asset_location_identity.sql
0003_seed_scivive.sql
0004_connect_scivive_reader.sql
```

Do not re-run or rewrite applied production migrations casually. Add a new migration for future durable changes.

## Basic validation

Production health:

```bash
curl -sS https://hellboxcomics.com/api/health | python3 -m json.tool
```

The current healthy publication state reports D1 as the registry source with one configured private publication and one configured Reader.

Public publication enumeration is intentionally empty while SciVive remains private:

```bash
curl -sS https://hellboxcomics.com/api/publications | python3 -m json.tool
```

The normal public SciVive Reader must remain blocked:

```bash
curl -sS -o /dev/null -w "HTTP %{http_code}\n" \
  https://hellboxcomics.com/api/reader/scivive
```

Expected: `HTTP 404`.

### Reader tooling environment

The Gate 2 Reader tools were validated with Python plus:

```bash
python -m pip install pymupdf pillow playwright
python -m playwright install chromium
```

Reader browser acceptance:

```bash
python tools/test_reader_ui.py
```

Current expected result:

```text
Gate 2 Reader UI laptop: PASS (1440x900)
Gate 2 Reader UI tablet: PASS (820x1180)
Gate 2 Reader UI mobile: PASS (390x844)
Gate 2 Reader browser acceptance: PASS
```

## Development workflow

Hellbox is changed incrementally.

- one implementation file at a time
- explain why that file is next
- provide a complete replacement file, not splice instructions
- validate only the expected file changed
- commit/deploy
- verify live behavior
- only then continue

For terminal work, proceed **one immediate action at a time** rather than dumping a long future command sequence.

At every Gate close:

1. finish technical acceptance
2. update `HELLBOX_PROJECT_STATE.md`
3. update `README.md`
4. commit/verify each incrementally
5. give a macro-progress report based on actual scope/remaining risk
6. then begin the next Gate

## File handoff convention

- `.js` replacements are delivered as ZIP files because direct JavaScript downloads have been unreliable
- ordinary `.md`, `.json`, `.sql`, `.py`, `.html`, etc. should generally be offered both directly and zipped
- if the destination folder already exists, the exact destination path is stated
- if a required folder does not exist, the delivered archive includes the needed folder structure

## Next Gate

### Gate 3 — Identity, Ownership & Archive

Goal: make wallet identity and ownership authoritative while preserving the proven Gate 2 Reader.

Target authority flow:

```text
wallet signature
    ↓
short server session
    ↓
chain-aware wallet identity
    ↓
indexed + verified ownership
    ↓
Archive + Reader use the same authority
```

Gate 3 work begins by inspecting the existing wallet/session/Reader authorization paths and choosing the smallest single-file change.

Do **not** deploy the NFT contract yet. Contract deployment belongs to Gate 4 after identity/ownership architecture is ready to consume it.

## Security / repository rules

Never commit:

- wallet private keys or seed phrases
- Cloudflare API tokens
- Worker/admin/session secrets
- unreleased protected publication packages
- private Reader page binaries
- temporary test credentials

Do not make a private publication public merely to simplify testing.

Do not resurrect the removed Gate 2 preview route/key as an authorization shortcut.

---

For the complete current production truth, locked product direction, Harrow canon, visual language, token/publication rules, roadmap and exact next engineering action, read **`HELLBOX_PROJECT_STATE.md` before making changes**.

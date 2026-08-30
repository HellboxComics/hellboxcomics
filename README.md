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
- `HARROW_CHARACTER_BIBLE.md` — authoritative Harrow character, voice, visual, lore, satire and campaign canon
- `docs/ACCESSIBILITY_AND_LOCALIZATION_STANDARD.md` — accessibility/localization requirements

If this README conflicts with `HELLBOX_PROJECT_STATE.md`, the project-state bible wins.

## Repository privacy

Public Git identity is:

```text
Harrow <noreply@hellboxcomics.com>
```

After Gate 2, the repository history was privacy-rewritten and verified so the user's personal identity no longer appears in Git author/committer metadata, tracked historical content, commit messages, or historical paths.

Repository rules:
- do not place the user's personal/legal name, personal email, local machine username/hostname, private tokens, or secrets into tracked files or public documentation
- sanitize terminal logs before committing them
- do not merge old pre-privacy clones/bundles/history back into `main`
- do not use commit SHA values as durable project-state anchors; history/privacy maintenance can invalidate them
- prefer Gate names, commit subjects, migrations, file paths, durable data state, and explicit production validation results

## Harrow

Harrow is Hellbox's writer, artist, publisher, operator, narrator, host, and problem.

The public character should feel like a real outlaw creator inside the audience's world—not a generic Web3 founder, community manager, fantasy demon king, superhero, or Joker copy. The core production rule is:

> **The machinery is disciplined. The operator is not.**

Detailed characterization and visual canon live in `HARROW_CHARACTER_BIBLE.md` and `HELLBOX_PROJECT_STATE.md`.

## Current production checkpoint

**Gate 3 COMPLETE — Identity, Ownership, Archive, SEALED PRESS & Permanent Public Entry**
**Gate 4 CURRENT — Hellbox Artifact Kernel + Versioned Publication Factory**
**Gate 4 implementation has NOT started; Publication Configuration Blueprint is next**

The site is deployed at `hellboxcomics.com` from `main` through Cloudflare. The unfinished development site is intentionally hidden behind the sealed `THE PRESS IS CLOSED` surface for outside visitors; Harrow has a separate private bypass.

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

**Post-Gate-2 repository privacy hardening**

- Git author/committer history rewritten to Harrow-only public identity
- historical tracked-content identity references scrubbed
- commit messages and historical paths scanned clean
- both public branches replaced with scrubbed history using guarded force-with-lease
- pre-scrub local backup and filter-repo temporary data removed
- old pre-rewrite commit SHAs are intentionally obsolete and should not be used as handoff anchors

**Gate 3 — Identity, Ownership, Archive & Permanent Public Entry**

- durable D1-backed wallet-signature challenges
- single-use challenge consumption and replay rejection
- short D1-backed wallet sessions with expiration/revocation
- chain-aware wallet identity
- real production `personal_sign` browser flow
- authenticated `/api/wallet-status` ownership authority
- durable D1 ownership verification/cache + audit events
- blockchain remains ownership source of truth; D1 is bounded evidence/cache only
- one native ERC-721 collection contract per publication/release is now the locked architecture
- publication-level ownership uses that publication contract's `balanceOf(wallet)`
- Archive and Reader use the same Worker ownership authority
- browser/localStorage state cannot grant ownership
- Reader regression still passes on laptop, tablet and phone under authoritative ownership fixtures
- SciVive still has no contract, so no positive real owner is fabricated before Gate 4

**Gate 3.1 — SEALED PRESS**

- unfinished public site is intentionally blinded by `prelaunch.html`
- Worker-first static routing ensures the sealed surface wins before `index.html`
- public document responses are non-cacheable/cache-evicting
- private Harrow entry: `/__harrow`
- private reseal: `/__harrow/reseal`
- public status: `/api/prelaunch/status`
- secure bypass secret/cookie is separate from wallet/ownership/Reader authority
- `.assetsignore` protects repository internals from static publication
- live `/.git/config` was verified `404`

**THE 30-MACHINE PROBLEM — permanent first introduction**

- 30 owned Pulse Bytes carry one linear Harrow-hosted interactive comic
- canonical opening: Byte #6 / TX01 / `ONE OF MINE FOUND YOU.`
- sequence ends at Byte #333
- every page uses the real Byte as a subordinate machine character and routes to the next actual Byte
- HairyLabs-required progression currently uses native HTML/CSS interaction with zero JavaScript dependency
- campaign remains the first-introduction medium after main launch; its story will be updated to reflect current Hellbox status rather than removed
- visitors can deliberately replay it indefinitely

Locked sequence:

```text
#6 → #11 → #13 → #19 → #20 → #23
→ #27 → #39 → #41 → #44 → #55 → #62
→ #64 → #67 → #77 → #82 → #84 → #85
→ #100 → #103 → #104 → #122 → #145 → #149
→ #219 → #223 → #237 → #238 → #282 → #333
→ Hellbox
```

Permanent onboarding integration is now live:
- first outside document visit to `hellboxcomics.com` redirects to Byte #6
- Byte #333 returns through `/campaign-complete`
- completion lands on the current public Hellbox experience; during development this is `THE PRESS IS CLOSED`
- the sealed surface offers `START ANOTHER INCIDENT` through `/campaign-reset`
- Harrow's valid `/__harrow` access bypasses both campaign completion and the sealed public surface
- campaign completion state is routing only and never grants privileged access

Current external dependency:
- HairyLabs may temporarily show stale historical versions of Bytes `#6, #11, #13, #19, #20, #23, #104, #223, #333`
- this does not block Gate 4
- no Byte pages are used in testing until the creator explicitly confirms the lane is refreshed
- at every upcoming Gate close, ask whether the HairyLabs refresh has completed

## Gate 3 final live acceptance

Verified 2026-08-30:

- public root → HTTP `302` → `https://hairylabs.io/page/6`
- public redirect is `no-store` and marked `X-Hellbox-Campaign: first-introduction`
- `/campaign-complete` → HTTP `200` sealed Press with replay control
- `/campaign-reset` → HTTP `303` → Byte #6 and clears the completion cookie
- valid `/__harrow` session enters the real development site directly
- `/api/health`: healthy
- auth engine: `wallet-signature-d1-session`
- ownership engine: `publication-contract-balance-d1-cache-v1`
- `/api/prelaunch/status`: sealed, campaign start Byte #6
- unauthenticated `/api/reader/scivive`: HTTP `404`
- `/.git/config`: HTTP `404`
- full 30-Byte traversal: external HairyLabs cache pending / intentionally excluded from testing

## Gate 4 architecture alignment — read before coding

Gate 4 is **not** simply “make an NFT contract.” It establishes the immutable/versioned artifact kernel that later Hellbox protocols build around.

Locked/working native issue direction includes:
- one native ERC-721 collection per publication
- released publication instances are non-upgradeable
- future capability through versioned templates + modular protocols
- rules freeze at mint-go-live while artifact state/metadata may evolve
- token ID is the collector copy number
- public IDs shuffled/randomized rather than sequentially assigned
- standard native run `216`
- PRESS MARK: HELLBOUND `6`, PRESS PROOF `12`, GOLD `18`, STANDARD `180`
- PRESS DEFECT: REDACTED `6`, CORRUPTED PLATE `12`, BLED OUT `18`, OFF REGISTER `24`, NONE `156`
- #001–#006 are Harrow's fixed special creator pull
- #066 is a public HELLBOUND grail
- Harrow receives three additional copies only as the literal last three after a true mint-out
- Harrow's PRESS DEFECT results are random too
- max primary allowance `6` per wallet; **one copy per transaction**
- configurable free/reserve/allowlist/early/public phases
- public Press shows live eligibility, allocations, remaining MARK/DEFECT counts and recalculated odds
- pricing policy per publication; FREE / FIXED_STABLE / FIXED_PLS / USD_TARGET_DUAL
- dynamic PLS quote must use trusted price-adapter/oracle/TWAP-style architecture rather than manual edits
- dynamic metadata required
- SEALED → UNSEALED irreversible
- ARCHIVE reversible while sealed and transfer-locks the token
- ERC-6551 compatibility required for Native Issue #1
- official Archive rewards separate from arbitrary token-bound-account assets
- Hellforge/burn/evolution compatibility required before Native Issue #1 mainnet
- SciVive remains a narrower proving exception

The private gated Press becomes a **publication compiler**: Harrow supplies canonical cover + actual Reader/comic package + approved MARK/DEFECT layer art. The system validates, commits, randomizes, reproducibly composites cover variants, generates metadata and prepares deployment. This is deterministic/reproducible compositing, not AI image generation by default.

### Immediate next deliverable

Before installing Foundry or writing Solidity, create and approve the **Publication Configuration Blueprint**: one exhaustive schema of every field Harrow's private Press must decide, preview, validate and irreversibly freeze before `PUBLISH`.

Repository/tooling discovery already showed no existing Solidity framework/config or contracts/test directories. Foundry is not installed. Working tool recommendation after blueprint approval: Foundry.

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
First outside visit
  │
  └── THE 30-MACHINE PROBLEM
      Byte #6 → ... → Byte #333
      │
      └── /campaign-complete → current Hellbox experience

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
      │     publications/packages
      │     Reader delivery pointers
      │     wallet challenges/sessions
      │     bounded ownership evidence/cache
      │
      ├── EVM RPC
      │     authoritative publication ownership checks
      │     against each release's native ERC-721 contract
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


The on-chain publication model is **one standardized native ERC-721 collection contract per release**. Hellbox.com is the publisher/library tying those finite collections together. Gate 4 will implement the standardized `HellboxPublication` + `HellboxPublicationFactory` pattern on PulseChain Testnet V4.

Identity layers:

```text
publicationKey
    conceptual publication identity

(chainId, contractAddress)
    native on-chain release/collection identity

(chainId, contractAddress, tokenId)
    individual collectible identity
```

Never bridge Hellbox NFTs.

## Important repository paths

```text
index.html                         public DOM / application shell
prelaunch.html                     sealed public development surface
style.css                         primary visual system
app.js                            browser runtime / Reader transport
src/index.js                      Cloudflare Worker / API + prelaunch/onboarding boundary
wrangler.jsonc                    Cloudflare runtime bindings
migrations/                       D1 schema + durable data migrations
publications/scivive/             SciVive publication package
publications/scivive/reader/      committed Reader manifest
schemas/                          publication package schemas
config/chains.js                  chain configuration
locales/                          interface localization packs
tools/build_scivive_reader.py     reproducible Reader asset builder
tools/upload_scivive_reader.py    private R2 upload + remote verification
tools/test_reader_ui.py           Reader/ownership browser regression test
tools/test_wallet_auth_ui.py      live wallet identity/security acceptance test
docs/                             supporting product/canon standards
HELLBOX_PROJECT_STATE.md          authoritative living project/engineering handoff
HARROW_CHARACTER_BIBLE.md         authoritative living Harrow creative canon
README.md                         concise repository orientation
```

Generated 461-page Reader output is intentionally kept outside Git under the local Hellbox build directory.

## Production D1 migrations

Applied in order:

```text
0001_publication_platform.sql
0002_refine_asset_location_identity.sql
0003_seed_scivive.sql
0004_connect_scivive_reader.sql
0005_wallet_identity.sql
0006_ownership_index.sql
```

Do not re-run or rewrite applied production migrations casually. Add a new migration for future durable changes.

## Basic validation

Production health:

```bash
curl -sS https://hellboxcomics.com/api/health | python3 -m json.tool
```

The current healthy state reports D1-backed publication/Reader authority, `wallet-signature-d1-session` authentication, and `publication-contract-balance-d1-cache-v1` ownership verification.

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
Hellbox Reader browser acceptance: PASS
Authoritative ownership fixture: PASS
```


Live wallet identity/security acceptance:

```bash
python tools/test_wallet_auth_ui.py
```

Expected highlights:

```text
Gate 3 live wallet browser acceptance: PASS
Real personal_sign flow: PASS
UI identity state VERIFIED: PASS
Identity remains separate from ownership: PASS
Browser/localStorage cannot grant ownership: PASS
D1 session restore after reload: PASS
Throwaway D1 auth records cleanup: PASS
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

For handoff/checkpoint references:
- use Gate names, commit subjects, file paths, migration names, and validation results
- do not rely on commit hashes as permanent identifiers

At every Gate close:

1. finish technical acceptance
2. update `HELLBOX_PROJECT_STATE.md`
3. review/update `HARROW_CHARACTER_BIBLE.md`
4. update `README.md`
5. keep all three mutually consistent and remove stale contradictions
6. commit/verify
7. give a macro-progress report based on actual scope/remaining risk
8. then begin the next Gate

## File handoff convention

- every replacement artifact is delivered as both a direct file and a ZIP copy
- JavaScript still gets both; the ZIP is especially important because direct `.js` downloads have been unreliable
- if the destination folder already exists, the ZIP contains only the replacement file(s), without recreating that existing folder hierarchy
- if a required folder does not exist, the ZIP includes only the structure needed to create it
- the exact destination path is always stated

## Exact next action

Move this work to a fresh Gate 4 thread.

The new thread should read:
1. `HELLBOX_PROJECT_STATE.md`
2. `HARROW_CHARACTER_BIBLE.md`
3. `README.md`

Then create the **Publication Configuration Blueprint** before installing tooling or writing Solidity.

Only after the creator approves the blueprint should the thread install/initialize Foundry (working recommendation) and create the first Gate 4 implementation file under the one-file-at-a-time workflow.

## Working roadmap — Gate 0 through Gate 10

- Gate 0 — foundation — COMPLETE
- Gate 1 — publication/data model — COMPLETE
- Gate 2 — protected Reader — COMPLETE
- Gate 3 — identity/ownership/Archive/public entry — COMPLETE
- Gate 4 — artifact kernel + versioned publication factory — CURRENT
- Gate 5 — Press V2 + private release/contract builder + real mint UX
- Gate 6 — ingest + dynamic metadata + rarity/rendering/package engine
- Gate 7 — artifact protocols: Archive rewards, ERC-6551, contextual/permanent state, Hellforge/burn/evolution
- Gate 8 — Hellion/relationship depth
- Gate 9 — experience/content freeze + audit/hardening/localization/accessibility
- Gate 10 — mainnet release candidate + first native Hellbox issue

Native Issue #1 does not go mainnet until the complete intended artifact model is genuinely proven.

At every future Gate close:
- update all three living documents
- provide weighted progress
- ask whether HairyLabs has refreshed Bytes `#6, #11, #13, #19, #20, #23, #104, #223, #333`
- do not include the Bytes in testing until the creator says the lane is clear

## Security / repository rules

Never commit:

- the user's personal/legal identity, personal email, local machine username/hostname, or unsanitized terminal logs
- wallet private keys or seed phrases
- Cloudflare API tokens
- Worker/admin/session secrets
- unreleased protected publication packages
- private Reader page binaries
- temporary test credentials

Do not make a private publication public merely to simplify testing.

Do not resurrect the removed Gate 2 preview route/key as an authorization shortcut.

Do not allow localStorage, frontend flags, or client claims to grant publication ownership or Reader access.

---

For the complete current production truth, locked product direction, Harrow canon, visual language, token/publication rules, roadmap and exact next engineering action, read **`HELLBOX_PROJECT_STATE.md` before making changes**.

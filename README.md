# Hellbox Comics

**Hellbox Comics is an underground digital publishing house operated by Harrow.**

Product priority:

1. comics
2. collecting
3. ownership
4. interaction
5. blockchain

> **The machinery is disciplined. The operator is not.**

## Start here

Before changing this repository, read in this exact order:

1. `HELLBOX_PROJECT_STATE.md` — authoritative technical/product/handoff state.
2. `HARROW_CHARACTER_BIBLE.md` — Harrow autobiography, voice, visual and creative canon.
3. `README.md` — concise repository orientation.
4. `CURRENT_GATE_BLUEPRINT.md` — complete detailed architecture for the Gate currently being implemented.
5. only then inspect the implementation files relevant to the immediate frontier.

Do not reconstruct Hellbox architecture from old chat history.

If README conflicts with Project State, Project State wins.

If a current-Gate progress sentence lags behind verified committed source/tests/terminal or Testnet evidence, preserve the verified implementation and synchronize the documentation rather than rolling working code backward.

## Authoritative root documentation

Keep only four authoritative Markdown files at repository root:

```text
HELLBOX_PROJECT_STATE.md
HARROW_CHARACTER_BIBLE.md
README.md
CURRENT_GATE_BLUEPRINT.md
```

Completed Gate blueprints are archived below root under:

```text
docs/architecture/gates/
```

A completed Gate's detailed architecture must be archived before `CURRENT_GATE_BLUEPRINT.md` is repurposed for the next Gate.

## Current checkpoint

- Gate 0 — COMPLETE
- Gate 1 — COMPLETE
- Gate 2 — COMPLETE
- Gate 3 — COMPLETE
- **Gate 4 — IN PROGRESS**
- Mainnet — NOT part of Gate 4

Current verified Gate 4 implementation:

- Foundry configured
- Foundry `1.8.1` verified in creator terminal output
- Solidity `0.8.36`
- EVM `shanghai`
- OpenZeppelin Contracts `v5.1.0` pinned
- `HellboxPublication.sol` V1 kernel implemented
- JavaScript/Solidity `HELLBOX_ABI_V1` golden vector implemented
- deterministic issuance accounting core implemented
- `HellboxPublicationFactory.sol` V1 implemented with size-safe full deployment
- factory provenance/uniqueness + approved creation-code-hash controls implemented
- factory runtime: **8,020 bytes** with **16,556 bytes EIP-170 headroom**
- current regression: **40 Solidity tests passed / 0 failed**
- issuance fuzz boundary: **256 runs passed**

**Exact next frontier:** deployment-time enforcement preimages + fixed-copy / birth-trait policy enforcement.

## Gate 4 issuance invariant

For the standard native 216-copy profile, after Harrow's immediate #001–#006:

```text
candidatePoolRemaining   = 210
nonTailIssuanceRemaining = 207
```

Those values are intentionally different.

The final Harrow three are not preselected or removed from the 210-candidate pool. They are the literal final three candidates left after all 207 allowed non-tail primary issuances.

Therefore the initial next-pull odds denominator is **210**, not 207.

## Current architecture

```text
First outside visit
    ↓
THE 30-MACHINE PROBLEM
Byte #6 → ... → Byte #333
    ↓
/campaign-complete
    ↓
current Hellbox public experience

Browser
    ├── static site / Press / Reader
    └── /api/*
          ↓
Cloudflare Worker — src/index.js
    ├── D1: hellbox-production
    ├── EVM RPC ownership checks
    ├── R2: hellbox-public
    └── R2: hellbox-private
```

On-chain publication model:

```text
reviewed HellboxPublication V1 creation bytecode
    ↓ exact hash approved per factory generation
HellboxPublicationFactory V1
    ↓ ordinary CREATE / full deployment
fresh HellboxPublication V1 per release
```

One publication/release = one native ERC-721 collection.

V1 is not a clone/proxy/upgrade model, and does not use CREATE2.

Never bridge Hellbox NFTs.

## Current native issue model

Standard native baseline:

- max supply: `216`
- tokenId = collector-facing copy number
- public/non-tail issuance randomized and non-sequential
- primary lifetime wallet cap: `6`
- max per transaction: `1`
- batch mint: false

PRESS MARK:

- HELLBOUND `6`
- PRESS PROOF `12`
- GOLD `18`
- STANDARD `180`

PRESS DEFECT:

- REDACTED `6`
- CORRUPTED PLATE `12`
- BLED OUT `18`
- OFF REGISTER `24`
- NONE `156`

Harrow immediate copies:

- #001/#002 HELLBOUND
- #003/#004 PRESS PROOF
- #005/#006 GOLD

Harrow's DEFECTS remain random.

#066 is a public HELLBOUND and remains in the random candidate pool.

Harrow's final three are the literal final three candidates left only after true non-tail mint-out. They are not preselected. Early permanent close forfeits that tail.

## SciVive

`publicationKey: scivive`

- ERC-721
- max supply `5,555`
- free mint
- max 1 primary copy/wallet
- max 1/tx
- royalty 369 bps
- protected 461-page Reader
- still private/not publicly mintable
- Gate 4 will use it to prove real Testnet mint → ownership → Archive/library → Reader

SciVive is intentionally narrower than Native Issue #1.

## Reader / ownership

Gate 3 production authority:

- wallet identity: D1-backed challenge/signature/session
- ownership: publication contract `balanceOf(wallet)`
- D1 ownership rows: bounded evidence/cache only
- Archive and Reader share one Worker ownership verifier
- localStorage/frontend flags cannot grant ownership

Normal public SciVive Reader remains protected.

## Public development routing

Outside first visit:

```text
hellboxcomics.com → Byte #6
```

Completion:

```text
Byte #333 → /campaign-complete → current Hellbox
```

Replay:

```text
/campaign-reset → Byte #6
```

Harrow private access:

```text
/__harrow
```

Campaign completion never grants wallet, Reader, ownership or Harrow-private authority.

## HairyLabs testing exclusion

Until the creator explicitly confirms the Byte lane is refreshed, do not use Byte pages in acceptance/regression.

Known externally stale pages when last checked:

```text
#6 #11 #13 #19 #20 #23 #104 #223 #333
```

Pulse Byte / `$SPUNK` world note, exact mechanics excluded from Gate 4 issuance:

- real Pulse Bytes can replenish/reload RPC allowance through `$SPUNK`;
- `$SPUNK` burns in that loop;
- Hellbox may use the hungry-Byte/feeding-infrastructure joke;
- exact amounts, thresholds, formulas and deeper Hellbox integration timing remain outside this Gate unless explicitly resolved from authoritative Byte rules.

## Important repository paths

```text
contracts/                         Gate 4 Solidity
test/                              Foundry tests
script/                            deployment scripts
lib/                               pinned Solidity dependencies
src/press/releaseFingerprint.js    Press-side HELLBOX_ABI_V1 encoder
src/index.js                       Cloudflare Worker
index.html                         application shell
prelaunch.html                     sealed public surface
app.js                             browser runtime
style.css / gate02.css             visual system
migrations/                        production D1 schema
publications/scivive/              SciVive package
schemas/                           package schemas
locales/                           UI locale packs
tools/                             Reader/auth/build tests
docs/architecture/gates/           archived finalized Gate blueprints
HELLBOX_PROJECT_STATE.md           authoritative project state
HARROW_CHARACTER_BIBLE.md          authoritative Harrow canon
README.md                          concise orientation
CURRENT_GATE_BLUEPRINT.md          active detailed Gate architecture
```

## Development workflow

- one implementation file at a time
- complete replacement files, never splice patches
- direct file + ZIP
- exact destination path
- one immediate Terminal action at a time
- validate every backend/contract change before moving on
- verify deployments/live behavior
- routine engineering decisions belong to the engineer
- open technical decisions are researched/tested by the engineer
- creator approval is reserved for product/economic/scarcity/authority/immutability/canon decisions
- before each major implementation file, the engineer performs the internal checkpoint defined in `HELLBOX_PROJECT_STATE.md`
- documentation contradiction sweeps are mandatory before synchronization is declared complete
- the public prelaunch progress percentage represents **overall Hellbox completeness**, not current-Gate completion; formally review/recalculate it at each Gate close

## Gate 4 security / economics

- minimize custom Solidity
- use pinned audited OpenZeppelin primitives for solved standards
- no publication proxy/upgrades in V1
- no generic publication owner
- no collector-token seizure/forced transfer
- no per-publication custom-Solidity/audit treadmill
- security cost is amortized across reusable reviewed versions/modules
- ERC-2981 royalty information does not guarantee marketplace enforcement or revenue

Strong pre-mainnet durability requirement:

> **dynamic when alive; durable when dead**

The principle is preserved; the exact continuity/fallback mechanism remains open.

## Security / privacy

Public Git identity:

```text
Harrow <noreply@hellboxcomics.com>
```

Never commit:

- creator personal/legal identity
- personal email/local hostname
- private keys/seed phrases
- Cloudflare/API secrets
- private Reader binaries
- temporary credentials
- unsanitized terminal output

Do not resurrect old pre-privacy repository history.

## Roadmap

- Gate 4 — artifact kernel/factory/issuance/Testnet ownership proof
- Gate 5 — Press V2 + private release builder + real mint UX
- Gate 6 — ingest + deterministic art/metadata/package engine
- Gate 7 — Seal/Archive/rewards/ERC-6551/Hellforge/evolution
- Gate 8 — Hellion relationship depth
- Gate 9 — freeze/security/accessibility/localization/content/durability hardening
- Gate 10 — mainnet release candidate + first native issue

Native Issue #1 does not launch until the promised foundational artifact model is proven.

For full detail, read `HELLBOX_PROJECT_STATE.md`, then `CURRENT_GATE_BLUEPRINT.md`.

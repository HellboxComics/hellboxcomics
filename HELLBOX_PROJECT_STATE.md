# HELLBOX PROJECT STATE

**Status:** Authoritative cross-chat project handoff
**Repository:** `main`
**Current Gate:** Gate 4 — HELLBOX ARTIFACT KERNEL + VERSIONED PUBLICATION FACTORY
**Current implementation checkpoint:** V1 publication kernel + `HELLBOX_ABI_V1` release fingerprint + deterministic issuance core + size-safe V1 full-deployment factory + versioned enforcement-preimage anchors + modular `HellboxBirthPolicy` foundation implemented; verified post-push regression **65 Solidity tests passed, 0 failed**; current unoptimized Shanghai runtimes: publication **16,334 bytes**, factory **8,020 bytes**, birth-policy module **5,561 bytes**
**Exact next frontier:** atomically wire deployment-time enforcement preimages and the immutable per-publication `HellboxBirthPolicy` companion through the publication/factory deployment path, prove EIP-170/EIP-3860 headroom, then wire permanent per-token MARK/DEFECT consumption/assignment without prematurely selecting production randomness
**Mainnet:** prohibited during Gate 4

This file intentionally combines project state, engineering handoff, development process and future-Gate continuity. It replaces separate root-level master-handoff and engineering-execution-standard documents **only because their durable rules are folded here in full**.

---

# 1. DOCUMENT AUTHORITY — KEEP THE ROOT CLEAN

## 1.1 Truth / conflict order

Resolve truth in this order:

1. **Newest explicit creator instruction.**
2. **`HELLBOX_PROJECT_STATE.md`** for cross-project product/technical architecture, workflow, handoff state, Gate boundaries and durable decisions.
3. **`HARROW_CHARACTER_BIBLE.md`** for Harrow creative/visual/voice canon and creator-supplied visual-reference authority.
4. **`CURRENT_GATE_BLUEPRINT.md`** for the detailed implementation contract of the Gate currently being built.
5. **`README.md`** for concise orientation only.
6. **Verified implementation evidence** — committed source, committed tests, compiler/test output and Testnet evidence — for determining *implementation progress*.
7. Older chat/history only when it does not conflict with the above.

Important distinction:

- product promises and architecture come from authoritative documents/newest creator decisions;
- **implementation progress comes from verified source/tests/live evidence**;
- if a root document temporarily lags behind a just-verified Gate checkpoint, do not roll code backward to match stale progress prose;
- instead synchronize the active Gate blueprint/project state at the next clean documentation checkpoint.

This rule exists specifically to prevent a future thread from seeing an old sentence such as "Foundry is not installed" and undoing work that the repository already proves exists.

**Authority/conflict order is not the same thing as bootstrap read order.** Fresh chats still read State → Bible → README → Current Gate Blueprint; the authority rules above govern how conflicts are resolved after all four have been read.

## 1.2 Four authoritative root Markdown files

The repository should have only four authoritative root Markdown documents:

1. `HELLBOX_PROJECT_STATE.md` — full technical/product/handoff authority.
2. `HARROW_CHARACTER_BIBLE.md` — Harrow autobiography, voice, visual and creative canon.
3. `README.md` — concise repository orientation.
4. `CURRENT_GATE_BLUEPRINT.md` — **full detailed architecture for the Gate currently being implemented**.

Do not create additional root handoff/process/bible Markdown files.

Do not create:
- `HELLBOX_MASTER_PROJECT_HANDOFF.md`;
- `HELLBOX_ENGINEERING_EXECUTION_STANDARD.md`;
- versioned duplicate Harrow bibles;
- copies of the current Gate blueprint inside `test/`.

## 1.3 Root cleanliness must not destroy durable architecture

`CURRENT_GATE_BLUEPRINT.md` is a working root filename, **not a disposable history mechanism**.

At formal Gate close:

1. reconcile durable Gate conclusions into this Project State;
2. update Harrow Bible only if creative canon changed;
3. update README;
4. finalize the current Gate blueprint;
5. archive that finalized blueprint under `docs/architecture/gates/` using a stable Gate-specific filename;
6. only after the next Gate's architecture review is approved, replace root `CURRENT_GATE_BLUEPRINT.md` with the new Gate blueprint.

For Gate 4, the archive target should be conceptually:

```text
docs/architecture/gates/GATE_04_PUBLICATION_CONFIGURATION.md
```

The archived Gate blueprint is reference history, not competing root authority.

**Do not throw away Gate 4's field-by-field Publication Configuration Blueprint merely to keep the root short.** Gate 5 Press and later tooling still need that exact configuration/freeze contract. The root stays clean by archiving finalized Gate artifacts, not by deleting their detail.

Chat history is not authoritative project storage.

---

# 2. DEVELOPMENT OPERATING RULES — LOCKED

## 2.1 One-file implementation workflow

For implementation/config changes:

1. explain why that exact file is next;
2. provide a complete replacement file, never splice instructions;
3. give direct file + ZIP;
4. state exact destination;
5. give one immediate Terminal action;
6. wait for output;
7. verify/test the change;
8. only then move on.

Do not stack unverified backend/contract changes.

## 2.2 Pre-Gate architecture review

Before every new Gate:

- explain goal in plain English;
- define non-goals;
- identify collector/product promises affected;
- identify irreversible/hard-to-change choices;
- identify future capability that current architecture must preserve;
- identify technical questions that remain open;
- define acceptance path;
- define stop/re-review conditions.

Do not begin a Gate merely because the next code file seems obvious.

## 2.3 What the engineer decides versus what Harrow decides

### Routine engineering — engineer decides

Do not ask Harrow to adjudicate:

- mapping vs struct;
- helper layout;
- event indexing when semantics are unchanged;
- custom-error naming;
- normal OpenZeppelin composition;
- test fixture organization;
- defensive checks;
- other implementation details that do not alter product behavior.

### Open technical decisions — engineer researches/tests

Examples:

- randomness provider;
- oracle/TWAP;
- optimizer/via-ir;
- renderer transport;
- external protocol binding;
- exact early-close mechanism.

Research viable options, test them, compare risk/gas/dependencies/failure modes, and recommend one. Escalate only if options materially change collector experience, economics, trust or long-term architecture.

### Creator/product decisions — ask Harrow

Examples:

- supply;
- rarity counts;
- creator allocation;
- price philosophy;
- royalties;
- owner rights;
- reversible/irreversible actions;
- Harrow authority;
- cross-chain scarcity;
- public vocabulary/canon.

## 2.4 Contradiction sweep

Before declaring documentation synchronized, search for:

- stale field names;
- superseded deployment modes;
- old version numbers;
- old Gate status;
- old authority terminology;
- arithmetic/state contradictions;
- statements saying a component does not exist when it now exists;
- statements implying a future component already exists.

Question:

> Can two competent engineers read two sections and implement different behavior?

If yes, documentation is not synchronized.


## 2.5 Mandatory internal engineering checkpoint before every major implementation file

Before creating or replacing a major contract/backend implementation file, the engineer answers internally:

1. What exact Blueprint sections does this file implement?
2. What collector/product invariants does it enforce?
3. What does it deliberately **not** implement yet?
4. What state must exist on-chain?
5. What only needs cryptographic commitment?
6. What belongs in D1/package/external protocols instead?
7. What new authority, if any, does it introduce?
8. Can that authority be narrower?
9. Does it introduce a setter, upgrade path, proxy, initializer, external registration path, arbitrary transfer/burn power, custody, or hidden admin escape hatch?
10. Is it reimplementing an established audited primitive unnecessarily?
11. Does it change `HELLBOX_ABI_V1`, a commitment-field order, or a golden-vector encoding?
12. Does it change a previously frozen collector/product promise?
13. Can an unchanged reviewed publication version still be reused for later issues without another code change?
14. What Foundry/tests prove the allowed behavior?
15. What adversarial actions must fail?

If #11 or #12 is yes, stop before coding unless the architecture explicitly authorized that change.

Do **not** ask Harrow these routine engineering questions.

## 2.6 Invariant ledger — maintain at meaningful checkpoints

Maintain a compact mental/documentation ledger:

| Locked rule / technical item | Implemented? | Tested? | Still open? |
|---|---|---|---|
| tokenId = copy number | yes/no | yes/no | yes/no |
| final-three tail | yes/no | yes/no | mechanics/provider only if applicable |
| production randomness | yes/no | yes/no | yes/no |
| HELLBOUND total = 6 | yes/no | yes/no | yes/no |

A prose rule is not "done" merely because it is documented.

## 2.7 Testing standard

Use the cheapest strong evidence appropriate to the boundary:

- unit/revert/boundary tests;
- fuzz tests;
- invariant tests;
- cross-language golden vectors;
- static analysis;
- ERC/interface conformance;
- adversarial test contracts;
- Testnet deployment;
- real wallet/backend flows;
- browser/device regression.

Every checkpoint should prove both:

```text
ALLOWED THINGS WORK
FORBIDDEN THINGS CANNOT HAPPEN
```

## 2.8 Overall public completion percentage — LOCKED PROCESS

The public prelaunch progress bar represents **overall Hellbox project completeness**, not the percentage complete inside the current Gate.

Rules:

- recalculate the public overall-completion percentage at every **formal Gate close**;
- do **not** change it merely because an ordinary commit landed;
- a mid-Gate change is appropriate only after a genuinely material scope expansion, setback, architecture rebaseline or equivalent project-wide change;
- the percentage may move forward or backward when the evidence warrants it;
- a Gate close is not operationally complete until the public percentage has been reviewed and updated if needed;
- the calculation should eventually come from **one explicit auditable source/value**, not duplicated hardcoded marketing numbers scattered across pages.

The Gate 4 factory-size repair and birth-policy modularization are material engineering corrections, but they do **not** by themselves trigger a new public overall percentage because they preserve the approved product scope rather than expand or remove it. Recalculate at formal Gate 4 close unless a later Gate 4 event materially rebaselines the overall project.

Do not churn stable public APIs merely to satisfy style-only lint notes. Security-relevant warnings must be investigated; style/optimization notes are tracked and revisited during hardening.

---

# 3. PRODUCT NORTH STAR — LOCKED

Hellbox Comics is an underground digital publishing house operated by Harrow.

Priority:

> **COMICS → COLLECTING → OWNERSHIP → INTERACTION → BLOCKCHAIN**

Blockchain is infrastructure, not the product headline.

Core creative/engineering rule:

> **THE MACHINERY IS DISCIPLINED. THE OPERATOR IS NOT.**

Native artifact rule:

> **THE RULES ARE IMMUTABLE. THE ARTIFACT IS ALIVE.**

The website should be exceptional on PC/Mac and polished/usable on tablet/mobile web before native-app development.

Accessibility target: practical WCAG 2.2 AA.

---

# 4. WHAT HELLBOX IS NOT

Do not turn Hellbox into:

- generic mint site;
- generic wallet-connect dashboard;
- one giant master NFT collection;
- bridged NFT system;
- upgradeable publication contracts by default;
- a DAO;
- an NFT marketplace clone;
- public publication-builder SaaS before Hellbox itself is mature;
- a DeFi product wearing a comic skin;
- generic XP loyalty software;
- static PDF storefront;
- architecture requiring bespoke Solidity/audit for every new issue.

---

# 5. REPOSITORY / PRIVACY

Local repo used by the creator:

`~/Desktop/hellbox-recovery`

Public Git identity:

`Harrow <noreply@hellboxcomics.com>`

Never commit:

- creator legal/personal identity;
- personal email;
- local username/hostname;
- wallet seed/private keys;
- Cloudflare/API secrets;
- unsanitized terminal logs;
- private Reader binaries;
- temporary test credentials.

Repository history was privacy-rewritten after Gate 2.

Old pre-rewrite hashes are not durable handoff anchors.

Broken forensic branch:

`backup-broken-gate02-20260828`

Never merge it wholesale.

Prefer:
- Gate/checkpoint names;
- commit subjects;
- file paths;
- migration names;
- live validation evidence.

---

# 6. CURRENT REPOSITORY SNAPSHOT — 2026-08-31 HANDOFF

The supplied local repository shows:

## Tracked Gate 4 implementation

- `foundry.toml`
- `foundry.lock`
- `package.json`
- `package-lock.json`
- `lib/openzeppelin-contracts` submodule
- `contracts/HellboxPublication.sol`
- `contracts/HellboxBirthPolicy.sol`
- `contracts/HellboxPublicationFactory.sol`
- `src/press/releaseFingerprint.js`
- `test/HellboxPublication.t.sol`
- `test/HellboxPublicationFactory.t.sol`
- `test/HellboxPublicationIssuance.t.sol`
- `test/HellboxPublicationPolicy.t.sol`
- `test/HellboxBirthPolicy.t.sol`
- `test/HellboxPublicationGoldenVector.t.sol`
- `test/press/releaseFingerprint.golden.mjs`

Pinned OpenZeppelin source:

- package version: `5.1.0`
- submodule commit: `69c8def5f222ff96f2b5beff05dfba996368aa79`

Toolchain snapshot:

- Foundry `1.8.1` — verified in creator terminal output during Gate 4
- Solidity `0.8.36`
- exact Hellbox pragma `0.8.36`
- EVM target `shanghai`
- OpenZeppelin Contracts `v5.1.0`
- optimizer/runs/via-ir still open pending evidence
- Node `v26.8.1`
- npm `11.19.0`

Press fingerprint dependency:

- `viem` `2.55.19`

## Latest committed Gate 4 checkpoints by subject

- `Add HellboxPublication V1 factory`
- `Add HellboxPublication factory tests`
- `Synchronize authoritative Hellbox documentation`
- `Add deterministic publication issuance core`
- `Make publication factory deployment size safe`
- `Add publication policy preimage anchors`
- `Add modular publication birth policy`

## Verified test / deployability state

The current committed test suites contain:
- 16 publication-kernel tests;
- 11 factory/provenance/deployability tests;
- 12 deterministic issuance tests;
- 9 publication enforcement-preimage anchor/golden-vector tests;
- 16 dedicated modular birth-policy tests;
- 1 cross-language `HELLBOX_ABI_V1` golden-vector test.

Total: **65**

Verified post-push creator-side evidence:
- **65 passed**;
- **0 failed**;
- issuance fuzz boundary: **256 runs passed**;
- `HellboxPublication` runtime: **16,334 bytes**;
- publication EIP-170 runtime margin: **8,242 bytes**;
- `HellboxPublicationFactory` runtime: **8,020 bytes**;
- factory EIP-170 runtime margin: **16,556 bytes**;
- `HellboxBirthPolicy` runtime: **5,561 bytes**;
- birth-policy EIP-170 runtime margin: **19,015 bytes**;
- `HellboxBirthPolicy` initcode: **17,018 bytes**;
- birth-policy EIP-3860 initcode margin: **32,134 bytes**;
- local HEAD and `origin/main` matched after push;
- `git diff --check`: clean;
- worktree: clean.

The factory test suite additionally proves:
- zero approved creation-code hash is rejected;
- unapproved publication creation code is rejected;
- failed/unapproved deployment cannot become official provenance;
- ownership remains two-step and renunciation remains disabled;
- the factory itself remains below the EIP-170 runtime limit.

The dedicated birth-policy suite additionally proves:
- the module is constructor-frozen and permanently records its deploying publication as `publication`;
- fixed-copy, birth-trait and randomization preimages must independently hash to their frozen commitment digests;
- duplicate fixed-copy rules and invalid inventory/fairness shapes revert;
- native MARK inventory and reservations match the frozen 216-copy model;
- native DEFECT inventory matches the frozen 216-copy model with no fixed creator DEFECT reservations;
- Harrow #001–#006 fixed MARK rules and #066 HELLBOUND/public-random-pool reservation shape are represented correctly;
- the randomization policy requires the approved global shared trait-pool model;
- a trait-disabled reusable publication shape such as SciVive is accepted.

This is the current verified Gate 4 engineering checkpoint.

## Documentation reset target

The 2026-08-31 documentation reset is intended to leave four authoritative root Markdown files while preserving detailed finalized Gate architecture under `docs/architecture/gates/`.

Deprecated/redundant documentation must not remain authoritative after the reset.

Retired filenames may still be named in this Project State **only as historical/prohibition notes so future work does not recreate them**. Such a mention is not an active dependency.

Retired/redundant documentation includes:

- separate root `HELLBOX_ENGINEERING_EXECUTION_STANDARD.md`, whose durable execution rules are folded into this Project State;
- accidental `test/PUBLICATION_CONFIGURATION_BLUEPRINT.md`;
- obsolete/versioned Harrow bible copies;
- obsolete standalone accessibility/localization standard after its durable requirements are folded here;
- stale root `PUBLICATION_CONFIGURATION_BLUEPRINT.md` after its complete field-by-field architecture is migrated into Gate 4 `CURRENT_GATE_BLUEPRINT.md`.

For Gate 4, **`CURRENT_GATE_BLUEPRINT.md` is now the surviving complete detailed architecture**. At formal Gate 4 close, archive that finalized current blueprint to:

```text
docs/architecture/gates/GATE_04_PUBLICATION_CONFIGURATION.md
```

The retired root `PUBLICATION_CONFIGURATION_BLUEPRINT.md` does **not** need to remain present until that later archive step.

Remove `.DS_Store` debris and ignore it going forward.

This reset is documentation cleanup only. It must not change application, contract, package, D1, R2, Worker, or deployment behavior.

---

# 7. PLATFORM / HOSTING ARCHITECTURE

## Cloudflare

- Worker backend: `src/index.js`
- D1: `hellbox-production`
- R2 public: `hellbox-public`
- R2 private: `hellbox-private`
- static binding: `ASSETS`
- `wrangler.jsonc` uses Worker-first behavior

Custom domains:
- `cdn.hellboxcomics.com` → public delivery
- `assets.hellboxcomics.com` → legacy/asset context as currently configured outside the core Reader path

## Public site

Main surface:
- `index.html`
- `style.css`
- `gate02.css`
- `app.js`

Sealed development surface:
- `prelaunch.html`

Do not casually modify:
- `src/index.js`
- `wrangler.jsonc`
- `.assetsignore`
- `index.html`
- `style.css`
- `app.js`

---

# 8. GATES 0–3 — COMPLETE

## Gate 0 — foundation

Delivered:

- recovered stable baseline after broken all-at-once attempt;
- incremental workflow;
- responsive web foundation;
- environmental discovery system;
- accessibility/localization foundation;
- English/Spanish website UI;
- GA4;
- multi-chain registry/status foundation;
- Press prototype;
- repo privacy/recovery discipline.

## Gate 1 — publication/data model

Delivered:

- D1 publication model;
- chain-independent `publicationKey`;
- package/schema model;
- public/private asset location model;
- SciVive seeded as first private publication;
- Worker APIs reading D1 rather than hardcoded publication registry.

## Gate 2 — protected Reader

SciVive source:

- PDF bytes: `8,433,084`
- SHA-256: `d105e16e991944b63d8e696c8236f5b4497d3c959119a87e580f46f2181bc548`
- pages: `461`

Reader:

- PDF → WebP reproducible build;
- 461 protected pages;
- 462 private R2 objects including manifest;
- 462/462 downloaded and hash/size verified;
- D1 manifest/prefix binding;
- Worker/private-R2 delivery;
- browser transport uses authenticated fetch → Blob → object URL;
- no embedded source PDF;
- laptop/tablet/mobile acceptance passed;
- temporary preview auth removed;
- public `/api/reader/scivive` remains 404.

## Gate 3 — identity / ownership / Archive / public entry

Delivered:

- D1 wallet challenges;
- single-use challenge consumption;
- `personal_sign`;
- expiring/revocable D1 sessions;
- challenge replay rejection;
- chain/account-change auth clearing;
- authenticated `/api/wallet-status`;
- D1 bounded ownership evidence/cache;
- blockchain remains ownership authority;
- Archive and Reader share the same Worker ownership verifier;
- localStorage cannot grant ownership;
- Reader ownership regression passed.

### Gate 3.1 — SEALED PRESS

Delivered:

- `THE PRESS IS CLOSED`;
- Harrow private route `/__harrow`;
- `/__harrow/reseal`;
- `/api/prelaunch/status`;
- secure HttpOnly bypass cookie;
- no-store/no-cache behavior;
- `.assetsignore` hardened;
- `/.git/config` verified 404.

### Permanent public onboarding

THE 30-MACHINE PROBLEM is permanent Hellbox first introduction.

Live route:

`new outside visitor → Byte #6 → ... → Byte #333 → /campaign-complete → current Hellbox`

Replay:

`current Hellbox → /campaign-reset → Byte #6`

Campaign completion is routing only.

It grants no:
- wallet identity;
- ownership;
- Reader access;
- Harrow private access;
- Hellion status.

Harrow private bypass outranks public onboarding.

---

# 9. HAIRYLABS EXTERNAL DEPENDENCY

Known stale/history-refresh pages when last checked:

- #6
- #11
- #13
- #19
- #20
- #23
- #104
- #223
- #333

This is external/non-blocking.

Until creator explicitly says the lane is clear:

- do not include Byte pages in acceptance/regression;
- public-gated tests may use Hellbox completion/prelaunch endpoints;
- real application tests use Harrow private bypass;
- do not change Hellbox merely to chase HairyLabs caching.

Ask about HairyLabs refresh at every Gate close.

## Pulse Byte / `$SPUNK` durable Hellbox-world note

Real Pulse Byte NFTs can replenish/level their RPC-call allowance by being fed `$SPUNK`; `$SPUNK` burns in that reload loop.

Hellbox may use this as recurring world humor around hungry Bytes / feeding infrastructure.

Locked boundary:
- the joke/mechanic concept is durable;
- exact amounts, thresholds and formulas must come from authoritative Pulse Byte rules rather than being invented by Hellbox;
- the timing/scope of deeper Hellbox integration remains **OPEN**;
- do not smuggle `$SPUNK` mechanics into Gate 4 issuance merely because the lore exists.

---

# 10. READER PRODUCT

Reader is central.

Presentation classes:

- `BOOK`
- `COMIC`
- future `ENHANCED`

BOOK:
- proven through SciVive.

COMIC:
- fixed page/spread reading;
- future comic-specific behavior.

ENHANCED:
- deliberate artist-authored effects only;
- no automatic gimmick animation.

Reader principles:

- art/content is the star;
- UI disappears when not needed;
- keyboard/touch;
- paged/continuous;
- fit page/width;
- preloading;
- accessibility;
- protected ownership access;
- no dishonest DRM claims.

---

# 11. HARROW

Full creative authority lives in `HARROW_CHARACTER_BIBLE.md`.

Cross-project summary:

- writer;
- artist;
- publisher;
- operator;
- narrator;
- host;
- problem;
- manic;
- sleepless;
- perfectionistic;
- paranoid;
- narcissistic;
- reckless;
- brilliant;
- funny;
- highly productive;
- convinced he is normal.

Not:
- generic Web3 founder;
- community manager;
- Joker imitation;
- superhero;
- demon king;
- generic edgelord.

Private/classified:
- career fireman;
- never state publicly;
- only subtle clues.

Bike:
- creator-established **2019 Harley-Davidson FLHRXS Road King Special**;
- frame-up custom Harrow build, not stock;
- blacked-out first, with blood-red cherry-candy-over-flake graphics that reveal in strong light;
- full custom detail authority lives in `HARROW_CHARACTER_BIBLE.md`;
- cars are cages;
- `DEADLINE` rejected;
- bike currently unnamed.

---

# 12. COMIC FORMAT — STRONG PROTOTYPE

Current working standard for **ordinary Hellbox comic books**:

- 14 story pages;
- 64 chronological frames;
- frame numbering does not reset inside an issue;
- page count and chronological frame count are intended to remain standardized across ordinary Hellbox comics once the production model is formally locked.

Still **OPEN / PROTOTYPE**:

- exact page-by-page frame distribution;
- exact panel/grid/layout grammar.

Once the ordinary-comic layout grammar is established, it should remain coherent and repeatable across Hellbox comic books rather than every title inventing a new structural language.

Exceptions:

- graphic novels;
- prose-to-graphic adaptations;
- SciVive and similar proving/source-book cases.

Those exceptions are not required to follow the ordinary-comic page/frame/grid structure.

There is no separate locked rule called "no filler frames." The intended quality rule is that, once the production standard is finalized, each frame should earn its place in story, pacing, character, atmosphere, information or visual rhythm.

`NO CONSENSUS` is **not an established Hellbox series**. It is currently only a fill-in/example title from format exploration. Do not create a series, cast, faction or canon around it unless the creator later explicitly establishes it.

Harrow can rotate titles, publish one-shots and return to dormant series.

Do not force monthly flagship behavior.

---

# 13. NATIVE PUBLICATION MODEL — LOCKED

## One publication = one native ERC-721 collection

Hellbox.com ties releases together as publisher/library.

Never return to one giant master collection.

Never bridge Hellbox NFTs.

Conceptual identity:

`publicationKey`

Chain edition:

`(chainId, contractAddress)`

Copy:

`(chainId, contractAddress, tokenId)`

For native Hellbox:

> `tokenId = collector-facing copy number`

No second visible copy-number system.

## Versioning

- standardized publication versions;
- factory version/generation;
- fresh collection per release;
- released instances do not upgrade;
- future versions/modules add capability;
- V1 does not mutate into V2.

---

# 14. STANDARD NATIVE 216 BIRTH MODEL — LOCKED

## Supply

`216`

## PRESS MARK

- HELLBOUND — 6
- PRESS PROOF — 12
- GOLD — 18
- STANDARD — 180

## PRESS DEFECT

- REDACTED — 6
- CORRUPTED PLATE — 12
- BLED OUT — 18
- OFF REGISTER — 24
- NONE — 156

MARK and DEFECT are separate permanent birth axes.

## Harrow immediate six

- #001 HELLBOUND
- #002 HELLBOUND
- #003 PRESS PROOF
- #004 PRESS PROOF
- #005 GOLD
- #006 GOLD

Harrow DEFECT remains random.

## Public grail

#066 is HELLBOUND and remains in random collector pool.

## Harrow tail

Final three go to Harrow only after true collector mint-out.

They are not preselected.

Early close forfeits the tail.

---

# 15. ISSUANCE MATH — DO NOT GET THIS WRONG

After #001–#006 leave the machine:

```text
candidatePoolRemaining   = 210
nonTailIssuanceRemaining = 207
```

`collectorPullsRemaining` may appear in older explanatory notes, but the preferred implementation-facing name is `nonTailIssuanceRemaining` because reserved/free/allowlist/early/public primary issuances can all consume the same 207 non-tail capacity.

The arithmetic and product promise do not change:

```text
candidate pool = 210
maximum non-tail primary issuances = 207
```

The last three are still in the random candidate pool.

They are not removed in advance.

Therefore the first collector draw after creator allocation sees all 210 candidates.

If 4 HELLBOUND remain:

```text
next-pull HELLBOUND odds = 4 / 210
```

NOT `4 / 207`.

The modular birth-policy foundation now makes the #066 reservation arithmetic explicit. At construction of the native policy, seven MARK reservations exist: the six creator fixed MARKS plus #066. That gives:

```text
markInventoryRemainingTotal = 216
markReservedRemainingTotal  = 7
randomAssignableMarkTotal    = 209
HELLBOUND reserved           = 3   // #001, #002, #066
HELLBOUND random-assignable  = 3
```

`209` is **not** the collector copy denominator. #066 remains a drawable candidate with its fixed HELLBOUND MARK. After the six creator copies are eventually consumed, the correct first collector HELLBOUND probability remains:

```text
P(#066) + P(other candidate) × P(random HELLBOUND among the other candidates)
= 1/210 + (209/210 × 3/209)
= 4/210
```

The current module has not yet wired issuance-time consumption, so these are validated construction-time reservation semantics, not yet live mutable Press odds.

Near true mint-out:

```text
candidatePoolRemaining   = 4
nonTailIssuanceRemaining = 1
```

After the final non-tail issuance:

```text
candidatePoolRemaining   = 3
nonTailIssuanceRemaining = 0
```

Those exact three become Harrow's tail.

Any implementation using 207 as the initial random-candidate denominator is wrong.

---

# 16. STANDARD MINT RULES

Standard native:

- lifetime primary cap = 6 per wallet;
- max per transaction = 1;
- batch mint = false.

One copy per transaction is intentional chaos.

It is not Sybil protection.

Mint phases must support:

- reserve/partner;
- free;
- allowlist;
- early Press;
- public Press.

Unless frozen/disclosed otherwise, every ordinary non-Harrow phase draws from the same remaining random pool.

No secret privileged rarity odds.

---

# 17. LIVE PRESS TRANSPARENCY

Public Press should show real state:

- run size;
- minted/remaining;
- current phase;
- Harrow pull;
- tail still in machine;
- wallet;
- eligibility;
- lifetime used/remaining;
- phase allowance;
- free/reserve/WL status;
- payment routes;
- current quote;
- remaining MARK counts/odds;
- remaining DEFECT counts/odds;
- transaction state;
- ejected copy/result.

After every successful single-copy mint:
- refresh authoritative state;
- recalculate odds;
- only then allow next pull.

No fake odds/countdowns.

---

# 18. PRICING MODEL

Pricing is per release.

Required policy modes:

- `FREE`
- `FIXED_STABLE`
- `FIXED_PLS`
- `USD_TARGET_DUAL`

`FIXED_PLS`:
- frozen PLS amount.

`USD_TARGET_DUAL`:
- frozen USD/stable target;
- collector can choose stable route or live PLS equivalent;
- PLS quote comes from approved adapter/oracle/TWAP;
- Harrow does not manually update the price.

Collector protection:
- quote freshness;
- tolerance/max authorization;
- explicit rounding;
- revert/refund policy.

Exact PulseChain price adapter is still open technical work.

---

# 19. SEALED / ARCHIVE / UNSEALED — LOCKED PRODUCT MODEL

## SEALED

Unopened.

Potentially Archive-eligible.

## ARCHIVE

Reversible while sealed.

- NFT remains in wallet;
- transfer execution locked;
- Hellbox does not list it while archived;
- visual protective sleeve;
- unarchive stops earning/unlocks transfer;
- may rearchive while still sealed.

Third-party off-chain listings may still display; actual transfer must fail while archived.

## UNSEALED

Permanent.

Once opened:
- cannot reseal;
- cannot re-enter Archive;
- cannot regain official reward eligibility.

Irreversible actions require explicit Harrow warning and deliberate confirmation.

---

# 20. DYNAMIC METADATA / ARTIFACT STATE

Rules freeze.

Metadata output may change according to frozen rules.

Permanent birth:
- token/copy ID;
- PRESS MARK;
- PRESS DEFECT.

Ruled state:
- SEAL;
- ARCHIVE;
- cover;
- permanent history;
- Hellforge/evolution state;
- official Archive status/balance;
- contextual current-wallet traits.

Permanent events follow the token.

Contextual traits can appear/disappear with current conditions.

Marketplace metadata-update signaling must be supported.

---

# 21. ERC-6551 / REWARDS / HELLFORGE BOUNDARIES

## ERC-6551

Native Issue #1 must remain compatible.

Token-bound account:
- general-purpose;
- arbitrary assets;
- controlled through token ownership;
- no Harrow sweep authority.

## Official Archive rewards

Separate from arbitrary TBA asset balances.

Preferred:
- dedicated protocol accounting keyed to NFT;
- owner can claim;
- unclaimed balance can follow NFT if frozen protocol says so;
- unarchive stops new accrual;
- unseal permanently finalizes/clears eligibility.

Before future reward-token launch:
- do not publicly name `$SIN`;
- use neutral `ARCHIVE BALANCE`.

## Hellforge

Modular/external where practical.

Requires current owner authorization.

No publisher forced burn.

Burn/consume must produce a direct participant result, not merely reduce supply.

---

# 22. SCIVIVE — PROVING EXCEPTION

`publicationKey = scivive`

Known:

- PulseChain;
- ERC-721;
- max supply 5,555;
- free primary mint;
- primary cap 1;
- max per transaction 1;
- royalty 369 bps;
- Reader enabled.

May use:
- dynamic covers;
- SEALED/UNSEALED;
- later contextual reaction to holding SciVive Graphic Novel.

Does not automatically use:
- native 216 MARK/DEFECT grammar;
- full Archive reward economy;
- full Hellforge;
- broad burn/evolution system.

Purpose:

`mint → ownership → Archive/library recognition → protected Reader`

---

# 23. PRIVATE PRESS / PUBLICATION COMPILER — TARGET END STATE

Harrow supplies:

1. canonical cover;
2. actual comic/Reader package;
3. MARK layers/rules;
4. DEFECT layers/rules;
5. credits/metadata;
6. economics;
7. mint phases;
8. capabilities/version.

Compiler:

`INPUT → VALIDATE → PREVIEW → COMMIT → RANDOMIZE/ASSIGN → RENDER → METADATA → DEPLOY → VERIFY → OPEN PRESS`

Default art pipeline:
- deterministic/reproducible compositing;
- Harrow-authored layers/masks/effects;
- not AI generation by default.

Harrow should not know the complete hidden random map in advance.

No future release should require:
- bespoke Solidity;
- hand-writing every metadata JSON;
- manual R2 juggling;
- manual rendering of every combination.

---

# 24. PUBLISH FREEZE

`PUBLISH` is the irreversible release-configuration boundary.

It resolves/commits:
- identity;
- chain/factory/version;
- supply;
- creator rules;
- fixed copy rules;
- trait distributions;
- randomization policy;
- package/art;
- pricing;
- phases;
- wallet rules;
- royalty/treasury;
- capability policy;
- renderer/version;
- closure/authority rules.

After PUBLISH:
- no editable release promises.

Artifact state may still evolve under those rules.

---

# 25. GATE 4 IMPLEMENTATION — CURRENT

Detailed active architecture lives in `CURRENT_GATE_BLUEPRINT.md`.

## Proven V1 publication kernel

`contracts/HellboxPublication.sol`

Current V1 uses:

- OpenZeppelin `ERC721Royalty`;
- no publication `Ownable`;
- full-deployment constructor;
- no proxy;
- no initializer;
- no delegatecall;
- no upgrades;
- actual `block.chainid`;
- actual factory `msg.sender`;
- constructor-side release digest recomputation;
- digest mismatch revert;
- frozen supply/wallet/creator/royalty/authority/capability config;
- publication/package commitment roots;
- config frozen provenance event.

ReleaseConfig currently includes:

- `publicationKey`
- `collectionName`
- `collectionSymbol`
- `maxSupply`
- `primaryLifetimeCap`
- `maxPerTransaction`
- immediate creator recipient/count
- tail recipient/count
- royalty receiver/bps
- `publisherAuthority`
- reader/seal/archive/dynamic-metadata/ERC6551/reward/Hellforge/contextual compatibility flags

No caller-supplied factory version exists inside ReleaseConfig.

## HELLBOX_ABI_V1 — LOCKED

Constants:

- `COMMITMENT_SCHEME_VERSION = 1`
- `CONFIG_SCHEMA_VERSION = 1`
- `PUBLICATION_VERSION = 1`
- `TEMPLATE_ID = keccak256("HELLBOX_PUBLICATION")`
- `RELEASE_CONFIG_DOMAIN = keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG")`

Fingerprint uses:

`keccak256(abi.encode(domain, versions, template, actual chainId, actual factory, ReleaseConfig, CommitmentSet))`

Never `abi.encodePacked`.

Golden vector is shared between JavaScript and Solidity.

## Canonical text rules implemented

`publicationKey`:
- 1–64 bytes;
- lowercase ASCII `[a-z0-9]`;
- single hyphen separators;
- no leading/trailing/consecutive hyphen.

`collectionName`:
- 1–128 UTF-8 bytes;
- Press must perform normalization before encoding.

`collectionSymbol`:
- 1–16 visible ASCII bytes.

## CommitmentSet

V1 fixes an ordered 18-`bytes32` commitment envelope covering:

- publication manifest;
- package;
- fixed copy rules;
- birth traits;
- randomization policy;
- renderer;
- Reader;
- pricing;
- payment routes;
- phases;
- royalty;
- treasury;
- metadata;
- capabilities;
- protocol compatibility;
- closure;
- authority;
- events.

Changing meaning/order requires a new commitment/config version.

## Versioned enforcement-preimage anchors — implemented

`HellboxPublication` now defines canonical V1 enforcement encodings for the three collector-affecting commitment fields that Gate 4 must enforce directly:

- `FIXED_COPY_RULES_ENFORCEMENT_DOMAIN = keccak256("HELLBOX_ENFORCEMENT_V1:FIXED_COPY_RULES")`;
- `BIRTH_TRAITS_ENFORCEMENT_DOMAIN = keccak256("HELLBOX_ENFORCEMENT_V1:BIRTH_TRAITS")`;
- `RANDOMIZATION_POLICY_ENFORCEMENT_DOMAIN = keccak256("HELLBOX_ENFORCEMENT_V1:RANDOMIZATION_POLICY")`.

The publication permanently anchors:

- `fixedCopyRulesDigest`;
- `birthTraitsDigest`;
- `randomizationPolicyDigest`.

Canonical typed `abi.encode` hashing and mismatch verification for those three policy preimages are implemented/tested without changing `ReleaseConfig`, `CommitmentSet`, their field order/meaning, or the `HELLBOX_ABI_V1` release fingerprint.

The same canonical policy structures/domains are used by `HellboxBirthPolicy`.

Important current boundary:

- the publication constructor does **not yet receive** the three enforcement preimages;
- the publication does **not yet create or permanently store** its `HellboxBirthPolicy` companion;
- the factory does **not yet transport** those preimages through `publish(...)`;
- therefore deployment is not yet atomically locked to the companion despite the independent anchors/module both being implemented and tested.

There is no post-deployment activation setter or temporary configuration window. The missing work is constructor/deployment wiring, not an invitation to add one.

---

# 26. GATE 4 FACTORY — CURRENT

`contracts/HellboxPublicationFactory.sol`

V1 remains **FULL_DEPLOYMENT**, but its deployment mechanism was corrected after an EIP-170 blocker was discovered.

## Current deployment mechanism

- ordinary EVM `CREATE`;
- no `new HellboxPublication(...)` embedded in factory runtime;
- exact reviewed `HellboxPublication` creation bytecode is supplied to `publish(...)`;
- the factory generation freezes an immutable `approvedPublicationCreationCodeHash`;
- supplied creation bytecode must hash exactly to that approved value or deployment reverts;
- zero approved creation-code hash is rejected at factory construction;
- the factory ABI-encodes the current `ReleaseConfig`, `CommitmentSet` and expected release digest and appends those constructor arguments to the approved creation bytecode;
- because the factory itself executes `CREATE`, the publication constructor still observes the approved factory as `msg.sender`;
- the publication still independently recomputes and validates the `HELLBOX_ABI_V1` release digest.

This is **not** a clone or implementation-proxy model.

The approved creation-code hash is factory/version-generation provenance. It is **not**:
- a new `ReleaseConfig` field;
- a change to `CommitmentSet`;
- a change to `HELLBOX_ABI_V1`;
- a universal runtime hash for all publication instances.

## Why this correction was required

The earlier Solidity `new HellboxPublication(...)` path embedded publication creation bytecode inside factory runtime.

With the deterministic issuance core present, verified unoptimized Shanghai build evidence showed:

```text
HellboxPublicationFactory runtime = 32,116 bytes
EIP-170 limit                    = 24,576 bytes
runtime margin                   = -7,540 bytes
```

That factory was not deployable under EIP-170.

After moving reviewed publication creation bytecode out of factory runtime and hash-binding it per factory generation:

```text
HellboxPublicationFactory runtime = 8,020 bytes
EIP-170 limit                    = 24,576 bytes
runtime margin                   = +16,556 bytes
```

Do **not** reintroduce embedded `new HellboxPublication(...)` deployment merely for convenience.

Do **not** enable optimizer/via-IR merely to hide a structurally oversized factory. Optimizer/runs/via-IR remains a separate open engineering decision.

## Version / authority

- `FACTORY_VERSION = 1`;
- `PUBLICATION_VERSION = 1`;
- template `HELLBOX_PUBLICATION`;
- deployment mode `FULL_DEPLOYMENT`;
- `Ownable2Step` on factory only;
- renunciation disabled;
- owner/factory publishing authority can rotate;
- only factory owner can publish new official collections;
- no power over already-deployed collector ownership/frozen publication configuration.

No V1 factory had been deployed before this correction, so this remains the pre-deployment V1 implementation rather than a post-release upgrade.

## Provenance

- duplicate publicationKey hash rejected;
- duplicate release digest rejected;
- unapproved creation bytecode rejected;
- no `registerExisting()`;
- no arbitrary authenticity setter;
- minimal append-only lookup state;
- richer event provenance;
- exact runtime code hash is instance forensic evidence only;
- defensive post-deploy check verifies:
  - factory;
  - chain;
  - template;
  - publication version;
  - release digest;
  - publicationKey.

Factory cannot prove its own social legitimacy.

Hellbox chain/version registry is the root declaring which factory generation and approved creation-code hash are official for the target chain/version.

Do not invent a new on-chain registry contract solely for this.

V1 has no shared implementation address.

## Remaining factory/publication/birth-policy boundary work

The current factory still ABI-encodes only the publication's current constructor arguments. The standalone `HellboxBirthPolicy` exists, but the deployment graph is not wired yet.

Current companion facts:

- `HellboxBirthPolicy` is a non-upgradeable per-publication companion;
- it is constructor-configured only;
- its constructor permanently sets `publication = msg.sender`;
- it narrowly decodes the fixed-copy, birth-trait and randomization policy preimages and independently verifies each digest;
- it validates/stores inventory, fixed reservations and randomization-policy boundaries;
- at this checkpoint it exposes read-only policy/inventory surfaces and **no external mutation/admin surface**;
- per-token trait consumption/assignment is intentionally not implemented yet.

The preferred next topology to test is:

```text
Factory ordinary CREATE
        ↓
HellboxPublication constructor
        ↓  atomic constructor-time CREATE
HellboxBirthPolicy companion
```

That topology is preferred because the companion can bind `publication = msg.sender` without a setter, initializer, predicted-address trick or factory impersonation. It is **not yet proven or frozen as implementation fact** until exact compile/size tests pass.

Critical size boundary: `new HellboxBirthPolicy(...)` inside the publication constructor would embed the companion creation bytecode in publication **initcode**. Current separate unoptimized evidence is:

```text
HellboxPublication initcode = 24,855 bytes
HellboxBirthPolicy initcode = 17,018 bytes
EIP-3860 initcode limit     = 49,152 bytes
```

The simple sum is below the limit, but that is **not** deployment proof because constructor wiring/arguments add overhead. The combined publication initcode must be measured after the actual wiring. If it exceeds EIP-3860 or causes unacceptable runtime/deployability headroom, stop and redesign the topology without adding a setter/proxy/upgrade escape hatch.

Before changing either factory or publication for this wiring, preserve all of these:

- exact `HELLBOX_ABI_V1` field order/meaning;
- immutable approved publication creation-code hash per factory generation;
- no post-deployment configuration window;
- no arbitrary bytecode deployment;
- ordinary full deployment;
- factory remains EIP-170 deployable;
- the three enforcement preimages are narrowly typed/decoded and must match the already-bound corresponding commitment digests;
- companion deployment and publication deployment succeed/fail atomically;
- the publication stores an immutable/permanent companion address;
- SciVive's trait-disabled policy shape remains supported;
- production randomness/provider selection remains separate.

Adding narrow constructor/publish transport for these preimages may change the pre-deployment factory/publication call ABI, but it must **not** change the frozen `ReleaseConfig`/`CommitmentSet` field order or `HELLBOX_ABI_V1` fingerprint merely for convenience. The factory generation's approved publication creation-code hash will naturally change when reviewed publication creation bytecode changes before Testnet deployment.

Do not embed publication creation bytecode back into factory runtime. Do not add a generic arbitrary constructor-data escape hatch.

---

# 27. GATE 4 EXACT NEXT FRONTIER — ATOMIC BIRTH-POLICY WIRING + TRAIT CONSUMPTION

The deterministic issuance accounting core, the publication-side enforcement digest anchors, and the standalone modular birth-policy foundation are now implemented and tested without selecting a production randomness provider.

## Implemented / tested

Current `HellboxPublication` proves or represents:

- frozen max-supply accounting;
- `candidatePoolRemaining`;
- `nonTailIssuanceRemaining`;
- standard native `210 / 207` initialization;
- immediate creator-copy reservation/issuance ordering;
- normal issuance blocked until the immediate allocation is complete;
- sparse remaining-candidate bookkeeping;
- unique in-range candidate draws;
- #066 remains candidate-eligible until actually drawn;
- lifetime primary wallet accounting;
- transfer and burn do not restore primary lifetime allowance;
- one normal primary token per internal issuance call;
- true-mintout detection;
- literal final-three remaining-candidate tail award;
- tail cannot be awarded before true mint-out;
- SciVive can use the same deterministic issuance core without native 216-copy assumptions;
- deterministic entropy-word/test-double boundary without selecting production entropy;
- canonical fixed-copy/birth-trait/randomization enforcement domains, typed preimage hashing and immutable digest anchors.

Current `HellboxBirthPolicy` proves or represents:

- versioned `BIRTH_POLICY_VERSION = 1` / `MODULE_ID = keccak256("HELLBOX_BIRTH_POLICY")`;
- constructor-only configuration;
- permanent `publication = msg.sender` binding;
- no proxy, initializer, upgrade, ownership/admin or external mutator surface at this checkpoint;
- narrow typed deployment preimages for fixed-copy, birth-trait and randomization policy;
- independent digest verification against all three frozen commitment anchors;
- native MARK inventory `6 / 12 / 18 / 180`;
- native DEFECT inventory `6 / 12 / 18 / 24 / 156`;
- fixed MARK reservations for Harrow #001–#006;
- creator DEFECT fixed assignment prohibited so those DEFECTS remain shared-random;
- #066 fixed HELLBOUND rule while remaining public-random-pool eligible;
- reservation-over-inventory and duplicate-rule rejection;
- randomization boundary requires random non-sequential copy shuffle, global shared trait pool, independent MARK/DEFECT axes, shared-random creator DEFECT semantics and no full preknown publisher rarity map;
- trait-disabled reusable publication shape for SciVive;
- read-only inventory/reservation surfaces needed as the foundation for later Press odds.

Current verification includes:

- **65/65** full Solidity regression;
- **16/16** dedicated `HellboxBirthPolicy` tests;
- **9/9** publication policy-anchor tests;
- **12/12** deterministic issuance tests;
- issuance fuzz boundary **256 runs**;
- unoptimized Shanghai `HellboxBirthPolicy` runtime **5,561 bytes** with **19,015 bytes** EIP-170 headroom.

## Not implemented yet — do not overclaim

The current code does **not** yet complete:

- atomic publication → birth-policy companion deployment;
- factory/publication transport of the three policy preimages;
- immutable publication storage/exposure of the deployed companion address;
- exact combined publication initcode/EIP-3860 proof after companion creation is wired;
- issuance-time consumption of creator MARK reservations;
- random creator DEFECT assignment through the final approved shared-random process;
- permanent per-token MARK/DEFECT birth identity;
- normal-issuance MARK/DEFECT inventory consumption;
- live post-mint remaining inventory/next-pull odds;
- early permanent close endpoint/outcome;
- phase eligibility/economics;
- public collector mint endpoint;
- production entropy provider/reveal/fallback semantics.

The module's current `*Remaining` views are therefore construction-time policy/reservation state. They do not yet mutate with mints and must not be presented as live Press odds until issuance-time consumption is wired and tested.

## Exact next engineering objective

Wire the existing module into publication deployment **before** adding trait consumption or exposing a real collector mint.

The next implementation checkpoint must:

1. pass the three narrow enforcement preimages through the factory/publication constructor path without changing `HELLBOX_ABI_V1` field order/meaning;
2. build `HellboxBirthPolicy.PublicationBinding` only from already-validated publication config/commitment anchors;
3. atomically create exactly one companion during publication construction if the preferred publication-created topology passes exact size/deployability tests;
4. permanently store/expose the companion address in the publication with no setter or replacement path;
5. prove a malformed or digest-mismatched preimage reverts the entire publication deployment;
6. prove the companion's `publication` binding equals the actual deployed publication, not the factory or publisher authority;
7. preserve factory ordinary `CREATE`, approved publication creation-code hash checking and provenance checks;
8. measure exact publication runtime and initcode after wiring and preserve EIP-170/EIP-3860 headroom;
9. prove the trait-disabled SciVive path still deploys through the same reviewed publication version;
10. introduce no generic owner, rarity setter, activation window, proxy, clone, upgrade, arbitrary transfer/burn, seizure or generic arbitrary bytes execution surface;
11. keep production randomness/provider selection outside this deterministic deployment work.

If the preferred publication-created companion exceeds a chain/code-size boundary, **stop and re-review topology** rather than silently weakening the permanent publication binding.

After that atomic wiring checkpoint passes, the next module step is publication-only per-token MARK/DEFECT assignment/consumption with authoritative live inventory/odds. Any future module mutator must be narrowly callable only by its permanently bound publication state machine; it must not become a publisher/admin control surface.

Do not build:
- final oracle;
- Archive rewards;
- Hellforge recipes;
- Gate 5 Press UX;
- Gate 6 renderer pipeline.

---

# 28. GATE 4 OPEN TECHNICAL DECISIONS

Still open:

1. exact publication ↔ `HellboxBirthPolicy` deployment/payload wiring until combined EIP-170/EIP-3860 proof is measured;
2. production randomness/entropy/reveal mechanism;
3. exact PulseChain USD/PLS price adapter;
4. optimizer/runs/via-ir;
5. metadata renderer transport/interface details;
6. future external-protocol binding mechanics;
7. exact early-close implementation.

These are technical research/testing tasks, not invitations to invent product rules.

---

# 29. GATE 4 ACCEPTANCE / EXIT

Gate 4 closes only after:

## Factory reuse proof

Same approved factory/template/version deploys:
- SciVive test configuration;
- second dummy publication;
- no bespoke Solidity change.

## Real Testnet ownership path

`SciVive Testnet V4 mint → balanceOf(wallet) → Gate 3 Worker ownership → Archive/library owned → protected Reader opens`

## Immutability proof

No post-PUBLISH mutation path for:
- supply;
- identity;
- creator allocation;
- fixed rules;
- trait totals;
- pricing;
- phases;
- wallet limits;
- royalty;
- package/renderer commitments;
- capability/closure policy.

## Issuance proof

Required state-machine invariants pass.

## Documentation close

Update:
- this file;
- Harrow Bible if canon changed;
- README;
- current Gate blueprint;
- archive the finalized Gate 4 blueprint under the approved Gate-specific path;
- review/recalculate the **overall Hellbox public completion percentage** and update its single auditable source/value if needed.

Ask whether HairyLabs refreshed the pending Bytes.

Only then start Gate 5.

---

# 30. FUTURE GATES — WORKING ROADMAP

## Gate 5 — Press V2 + private release builder + real mint UX

Before code, replace `CURRENT_GATE_BLUEPRINT.md` with an approved Gate 5 blueprint defining:

Private Press:
- Harrow auth;
- draft lifecycle;
- validation;
- immutable freeze preview;
- publish transaction;
- deployment verification.

Public Press:
- wallet;
- phase/eligibility;
- allowance;
- quote;
- physical lever/single pull;
- confirmation/ejection;
- live odds refresh;
- faults/sold-out.

Do not build Gate 6 compositor or Gate 7 protocols here.

## Gate 6 — ingest / package / dynamic metadata / rendering

Blueprint must define:
- package schema;
- cover + Reader inputs;
- MARK/DEFECT layer format;
- deterministic compositor;
- randomness/render boundary;
- metadata renderer;
- marketplace refresh;
- reproducibility;
- protected Reader ingest;
- durability/fallback.

## Gate 7 — artifact protocols

Split into sub-checkpoints:
- Seal/Archive;
- official reward accounting;
- ERC-6551;
- permanent incident/history state;
- contextual traits;
- Hellforge/burn/evolution.

Do not build one giant everything-contract.

## Gate 8 — Hellion relationship system

Server-authoritative durable relationship:
- history;
- standing;
- favor;
- privacy;
- recognition;
- revocation/restoration.

No generic XP.

## Gate 9 — freeze / audit / hardening / content

- content/code freeze;
- accessibility;
- localization;
- responsive/browser matrix;
- privacy/consent;
- performance;
- analytics/SEO/legal;
- threat model;
- fuzz/invariant/static analysis;
- targeted independent security review;
- metadata/content continuity;
- publisher continuity plan;
- Native Issue #1 content readiness.

## Gate 10 — mainnet release candidate

- exact deployment runbook;
- production versions/config;
- monitoring;
- SciVive production;
- Native Issue #1 only after full hard release barrier.

---

# 31. NATIVE ISSUE #1 HARD RELEASE BARRIER

SciVive may be simpler.

The first native Hellbox comic must not make early collectors structurally inferior to later releases.

Before Native Issue #1 mainnet, prove as promised:

- versioned immutable collection;
- 216 profile;
- randomized copy assignment;
- Harrow immediate/tail behavior;
- PRESS MARK/DEFECT;
- dynamic generated art/metadata;
- mint phases;
- one-at-a-time mint;
- live odds;
- chosen payment mode;
- SEALED;
- reversible ARCHIVE;
- transfer lock;
- irreversible UNSEALED;
- official reward protocol behavior if promised;
- ERC-6551;
- permanent history;
- contextual traits;
- Hellforge;
- owner-authorized burn/evolution;
- marketplace refresh;
- Reader ownership access;
- clear irreversible warnings.

---

# 32. SECURITY / CASH-FLOW STANDARD

Hellbox cannot require a new audit for every ~$6.66 issue.

Security cost is amortized across reusable reviewed versions/modules.

Use:
- pinned OpenZeppelin;
- established ERCs;
- small custom Solidity;
- AI review;
- unit tests;
- fuzz tests;
- invariant tests;
- static analysis;
- adversarial tests;
- Testnet;
- targeted independent review after code freezes.

Do not:
- reimplement ERC-721;
- bridge;
- custody NFTs for Archive;
- add publisher seizure;
- build monolithic protocol;
- make every publication new Solidity.

A publication using unchanged reviewed versioned bytecode should not need a new full code audit just because title/art/config changed.

ERC-2981 expresses royalty information; it does not guarantee every marketplace will enforce or pay royalties. Do not model secondary royalties as guaranteed cash flow.

Operational continuity is a **STRONG PRE-MAINNET DURABILITY REQUIREMENT**, not a locked implementation mechanism:

> **dynamic when alive; durable when dead**

The principle must survive architecture decisions through Gate 9/mainnet hardening. The exact continuity/fallback mechanism remains OPEN and must be researched/tested rather than invented from this phrase alone. Possible mechanisms are not canon until explicitly selected.

Future architecture should avoid requiring Hellbox infrastructure to remain online forever merely for an owned publication to retain meaningful identity.

---

# 33. ACCESSIBILITY / LOCALIZATION — FOLDED STANDARD

The former standalone accessibility/localization document is retired **only after these durable requirements are preserved here**.

Hellbox may be hostile in character.

The product itself must not be hostile to disabled visitors.

## 33.1 Accessibility target

Practical baseline:

> **WCAG 2.2 AA**

Every new Hellbox feature must define its:

- non-visual strategy;
- non-audio strategy;
- keyboard strategy;
- focus behavior;
- touch-target behavior;
- reduced-motion behavior;
- high-contrast behavior;
- readable system/error/money/signature language;
- localization/content-language behavior.

Accessibility is not a skin added after launch.

## 33.2 Blind / low-vision access

Permanent requirements:

- every functional control must be keyboard reachable and operable;
- invisible/interactively discovered artwork must expose meaningful accessible control names;
- pannable art rooms must support keyboard movement in addition to touch/drag, including directional keys and Home/End behavior where appropriate;
- dialogs, drawers, Reader surfaces and access settings must announce themselves semantically;
- modal/dialog focus must be contained appropriately;
- Escape should close dismissible overlays;
- focus should return to the triggering control after closure;
- decorative images use empty alternative text;
- informational images use concise useful alternative text;
- status must never rely on color alone;
- text enlargement and high-contrast modes must not hide controls or destroy layout;
- comic packages should support creator/publication-supplied page summaries and optional panel descriptions rather than expecting assistive technology to interpret a flattened comic page with no alternative;
- transcript/caption assets belong in the publication package when story information depends on audio.

## 33.3 Deaf / hard-of-hearing access

- sound is optional and off until the visitor intentionally enables it;
- every spoken line, sound-dependent clue or timed audio event requires a caption, transcript or equivalent visible cue;
- no discovery, ownership right, Reader access, publication content entitlement or relationship progression may require hearing;
- future enhanced comics must let the creator author caption/sound-description equivalents alongside audio events.

## 33.4 Motor / cognitive access

- primary controls should provide at least a **44 × 44 CSS-pixel usable target** where practical;
- precision drag must never be the only way to reach content;
- moving content must be pausable;
- reduced-motion preferences must suppress unnecessary ticker motion, ambient hotspot pulses, automatic nudges and transition effects;
- interactions must remain understandable without forcing rushed/short time limits;
- Harrow may insult the visitor in character, but system language about money, signatures, errors, ownership, irreversible actions and access must remain plain and unambiguous.

## 33.5 Reader accessibility

The Reader is one of the highest-priority accessibility surfaces.

### BOOK mode

Where legally/editorially appropriate:

- support semantic/reflowable text;
- preserve facsimile mode when source fidelity matters.

### COMIC mode

- support page-level descriptions supplied with the publication;
- support optional panel-level descriptions when provided;
- do not require a screen reader to infer flattened art with no authored alternative.

### Navigation

Reader access should remain available through:

- keyboard;
- swipe/touch;
- paged navigation;
- fit-page;
- fit-width;
- continuous mode where the publication supports it.

These controls must not depend on animation.

Reader progress should be announced accessibly without repeatedly interrupting screen-reader users.

### Enhanced effects

Enhanced effects must:

- be individually suppressible where appropriate;
- never replace the original art;
- never replace required story information;
- never make motion/audio mandatory for comprehension.

## 33.6 Localization architecture

Permanent rules:

- source text/files use UTF-8;
- documents declare language/direction correctly;
- interface strings live outside layout code and load from locale packs;
- publication language is independent of site-UI language;
- dates, numbers, prices and pluralization should use locale-aware formatting once those surfaces become live;
- Harrow-authored prose/jokes/insults require human voice adaptation, not blind literal machine translation;
- RTL support must be designed before an RTL locale is exposed;
- artwork is not blindly mirrored merely because UI direction changes.

## 33.7 Current locale implementation evidence

Current repository evidence shows:

```text
locales/en.json
locales/es.json
locales/pt-BR.json
locales/manifest.json
```

However, **file presence is not the same thing as active product support**.

Current application evidence also shows:

- `app.js` intentionally describes the active interface as **English and Spanish only**;
- `index.html` exposes Spanish as the selectable alternate language;
- `locales/es.json` identifies an approved static Spanish locale/editorial pass;
- `pt-BR` exists in the locale assets/manifest but is **not currently exposed as an active supported UI language**.

Therefore current truth is:

```text
English            = canonical / active
Spanish            = approved / active / proven
Brazilian Portuguese = dormant/deferred asset, not currently exposed
```

Do not advertise Brazilian Portuguese support merely because `locales/pt-BR.json` exists.

Do not delete the `pt-BR` asset merely because it is dormant unless a later cleanup explicitly proves it is obsolete.

Additional languages remain deferred until intentionally reviewed/activated.

## 33.8 Historical Gate 0 accessibility work that remains durable

The earlier Gate 0/0.1 accessibility foundation included concepts such as:

- skip navigation;
- meaningful landmarks/dialog semantics;
- keyboard-pannable interactive art rooms;
- accessible names for invisible visual discoveries;
- focus containment/restoration;
- pause controls for moving thought/ticker content;
- reduced-motion, larger-text and high-contrast controls;
- forced-colors/system-contrast support;
- compact mobile navigation;
- separation of interface localization from Harrow's authored English voice.

Future refactors must preserve equivalent functionality rather than deleting it because the old standalone standard is retired.

## 33.9 Non-negotiable rule

> **Every new Hellbox feature must ship with its non-visual, non-audio, keyboard, motion-reduced and localization/content-language strategy defined.**

---

# 34. MULTI-CHAIN

PulseChain is root/first chain.

Configured architecture already includes disabled future EVM networks.

Native deployments per chain.

Never bridge.

Do not show chain selector when only one chain is active.

Before first second-chain publication, explicitly lock a cross-chain edition/printing doctrine so later chain editions do not dilute the meaning of a PulseChain first edition.

This doctrine remains OPEN strategic work.

---

# 35. LOW-COST OPERATIONS

Hellbox is a solo/part-time creator project.

Prefer:

- Cloudflare Worker/static;
- D1;
- R2;
- no always-on app server unless needed;
- no expensive indexer initially;
- no CMS unless justified;
- direct-to-R2 large upload paths;
- lazy Reader delivery;
- reusable publication versions.

Do not create infrastructure cost because a larger company would.

---

# 36. CURRENT KNOWN RISKS / DEBT

- `app.js` large/monolithic;
- `src/index.js` large/monolithic;
- historical CSS overrides;
- final Press art/UX not built;
- final widescreen tuning deferred;
- positive real SciVive owner still waits for Gate 4 Testnet deployment/mint;
- full random assignment provider unresolved;
- price adapter unresolved;
- full dynamic renderer not built;
- Archive rewards/ERC-6551/Hellforge remain later Gates;
- relationship/Hellion not server-authoritative yet;
- frontend/backend chain registry can drift until parity/generated source exists;
- internationalization incomplete by design;
- dynamic metadata durability/publisher-continuity strategy remains future hardening work;
- HairyLabs Byte cache/history external;
- current Forge/static-analysis output includes non-blocking style/optimization notes; investigate security-relevant warnings, but do not mutate stable ABI/semantics merely to satisfy lint style.

---

# 37. OPEN STRATEGIC ITEMS — DO NOT SILENTLY LOCK

- publisher continuity covenant — **STRONG PRE-MAINNET DURABILITY REQUIREMENT:** `dynamic when alive; durable when dead`; exact technical mechanism OPEN;
- dynamic-metadata fallback if Hellbox infrastructure disappears;
- cross-chain edition lineage;
- sealed versus unsealed value-balance doctrine;
- launch-health KPIs beyond "sold out";
- final permanent-history public label;
- exact randomness provider;
- exact price oracle;
- Archive reward formulas;
- Hellforge recipes;
- Native Issue #1 exact title/content/price/royalty/phases.

Future AI must not convert these into canon because it likes an idea.

---

# 38. ROOT-DOCUMENT HANDOFF PROCEDURE

Every fresh development chat reads, in order:

1. `HELLBOX_PROJECT_STATE.md`
2. `HARROW_CHARACTER_BIBLE.md`
3. `README.md`
4. `CURRENT_GATE_BLUEPRINT.md`
5. implementation files for the immediate frontier

Before code it must state:

- current Gate;
- latest verified checkpoint;
- exact next frontier;
- relevant locked invariants;
- open technical decisions;
- non-goals;
- contradictions found;
- files that must not be touched yet.

Then inspect the actual implementation files relevant to the immediate frontier and run the mandatory internal engineering checkpoint before writing a major file.

If implementation evidence is newer than stale progress prose, preserve the working implementation and synchronize the docs; do not backtrack.

Do not ask Harrow to re-explain project architecture.

---

# 39. CONTEXT-LIMIT PROCEDURE

Do not keep coding until a chat collapses.

At a clean checkpoint:

1. run tests;
2. commit/push if appropriate;
3. synchronize `CURRENT_GATE_BLUEPRINT.md` if stale text could mislead the next engineer;
4. update this file with the verified checkpoint/frontier;
5. update Harrow Bible only if canon changed;
6. update README;
7. open a fresh chat using the root-document handoff order.

Do not archive/replace the current Gate blueprint merely because chat context changed. Archive it only at formal Gate close.

Context exhaustion is a handoff event, not a reason to lose architecture.

---

# 40. EXACT NEXT ACTION

Current committed/pushed code checkpoint:

```text
publication kernel                    implemented / passing
HELLBOX_ABI_V1 golden vector         implemented / passing
deterministic issuance core          implemented / passing
policy preimage digest anchors       implemented / passing
modular HellboxBirthPolicy           implemented / passing
size-safe FULL_DEPLOYMENT factory    implemented / passing
publication runtime                  16,334 bytes
publication EIP-170 margin           +8,242 bytes
birth-policy runtime                  5,561 bytes
birth-policy EIP-170 margin          +19,015 bytes
birth-policy initcode                17,018 bytes
birth-policy EIP-3860 margin         +32,134 bytes
factory runtime                       8,020 bytes
factory EIP-170 margin               +16,556 bytes
Solidity regression                  65 passed / 0 failed
issuance fuzz                         256 runs passed
```

The next engineering step is **atomic publication/factory deployment wiring for the existing `HellboxBirthPolicy` companion and its three enforcement preimages**.

Before touching source, the implementing engineer must read the full `CURRENT_GATE_BLUEPRINT.md` sections governing:

- factory/full-deployment provenance;
- `HELLBOX_ABI_V1` and commitment envelope;
- fixed copy rules;
- birth trait axes;
- randomness/allocation/reveal;
- deployment-time enforcement preimages;
- authority boundaries;
- public Press runtime odds.

The preferred topology to test is publication-constructor creation of the companion so `publication = msg.sender` binds without a setter. This preference is conditional on exact combined initcode/runtime proof; it is not permission to ignore EIP-3860.

The wiring must preserve:

```text
candidatePoolRemaining   = 210
nonTailIssuanceRemaining = 207
```

and explain why the values differ.

It must also preserve the verified factory rule:

> exact reviewed publication creation bytecode is supplied at PUBLISH, hash-checked against the immutable factory-generation approval, and deployed through ordinary `CREATE`.

Do not reintroduce embedded publication creation bytecode into factory runtime.

Do not add a post-deploy policy setter/initializer/activation window.

Do not expose a collector mint until publication deployment is atomically bound to the EVM-enforced birth policy and later per-token consumption is wired.

The current production-randomness decision remains intentionally open.

---

# 41. FINAL NON-REGRESSION LIST

Stop before introducing:

- one master NFT collection;
- ERC-1155 replacement of native ERC-721 releases;
- bridges;
- publication proxy upgrades in V1;
- generic publication owner;
- publisher seizure/forced transfer;
- unlimited creator mint;
- max-supply increase;
- sequential public copy assignment;
- preselected final-three tail IDs;
- using 207/non-tail capacity as the initial random-candidate denominator;
- Harrow-controlled rarity reroll;
- secret phase rarity advantages;
- static metadata requirement for native issues;
- custodial Archive staking;
- TBA sweep authority;
- publisher forced Hellforge burn;
- per-release custom Solidity/audit treadmill;
- generic XP Hellion;
- localStorage ownership;
- public protected Reader assets for convenience;
- HairyLabs cache issues treated as Hellbox defects without evidence.

The creator defines the machine's rules.

The engineer builds the machine.

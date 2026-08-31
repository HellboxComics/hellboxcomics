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
- deployment-time enforcement-preimage digest anchors implemented without changing the frozen `HELLBOX_ABI_V1` release fingerprint
- `HellboxPublicationFactory.sol` V1 implemented with size-safe full deployment
- factory provenance/uniqueness + approved creation-code-hash controls implemented
- `HellboxBirthPolicy.sol` non-upgradeable per-publication companion foundation implemented and independently tested
- `HellboxBirthPolicyCodeStore.sol` immutable inert bytecode store implemented, committed, pushed and independently tested
- code-store runtime begins with `STOP`; the remaining bytes are the exact `HellboxBirthPolicy` creation code
- direct publication-constructor `new HellboxBirthPolicy(...)` topology was measured and rejected/restored because it left inadequate EIP-3860 deployment runway
- current post-push regression: **69 Solidity tests passed / 0 failed**
- issuance fuzz boundary: **256 runs passed**
- dedicated code-store proofs: **4 passed / 0 failed**
- unoptimized Shanghai runtimes:
  - `HellboxPublication`: **16,334 bytes** / **8,242 bytes EIP-170 headroom**
  - `HellboxPublicationFactory`: **8,020 bytes** / **16,556 bytes EIP-170 headroom**
  - `HellboxBirthPolicy`: **5,561 bytes** / **19,015 bytes EIP-170 headroom**
- `HellboxBirthPolicy` initcode: **17,018 bytes** / **32,134 bytes EIP-3860 headroom**

**Exact next frontier:** bind the approved BirthPolicy code store/hash into the factory generation, have each publication copy and verify the exact policy creation bytes, then execute publication-owned ordinary `CREATE` with the three enforcement preimages so the companion permanently binds to the actual publication.

The newly locked interactive-comic/Archive direction does **not** change this immediate Gate 4 frontier and does not currently require a `HELLBOX_ABI_V1` change. Gate 4 must preserve clean later-package/reward/state boundaries without embedding game logic into the publication kernel.

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

On-chain publication model currently committed:

```text
reviewed HellboxPublication V1 creation bytecode
    ↓ exact hash approved per factory generation
HellboxPublicationFactory V1
    ↓ ordinary CREATE / full deployment
fresh HellboxPublication V1 per release
```

The reusable `HellboxBirthPolicy` companion and immutable inert `HellboxBirthPolicyCodeStore` are implemented and tested, but **publication/factory code-store wiring is not complete yet**.

Immediate target topology to prove:

```text
approved HellboxBirthPolicyCodeStore
    ↓ runtime byte 0 = STOP
    ↓ bytes [1..] = exact approved BirthPolicy creation code

HellboxPublicationFactory V1
    ↓ binds approved publication creation hash
    ↓ binds approved BirthPolicy code store + creation-code hash
    ↓ ordinary CREATE / full deployment

HellboxPublication V1 constructor
    ↓ EXTCODECOPY policy creation bytes from offset 1
    ↓ verify exact approved creation-code hash
    ↓ append canonical BirthPolicy constructor args
    ↓ ordinary CREATE executed by the publication

HellboxBirthPolicy companion
    publication = actual HellboxPublication
```

The direct `new HellboxBirthPolicy(...)` publication-constructor embed was measured at **42,840 bytes of publication initcode** before the real native constructor payload and was rejected/restored because the practical deployment runway was too small. Do not resurrect that topology merely because it remained technically below the hard EIP-3860 ceiling in the experiment.

The code-store path must still receive exact post-wiring EIP-170/EIP-3860/deployment-payload proof and may not introduce a setter, proxy, initializer, `delegatecall`, CREATE2 dependency or upgrade escape hatch.

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
- V1 primary payment: **PLS only**
- per-issue PLS mint price: frozen at PUBLISH and allowed to differ by issue
- native primary mint window: exactly **66 days + 6 hours + 6 minutes + 6 seconds** from that issue's frozen go-live time
- sellout may finish sooner; the published deadline cannot be extended or reopened

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

Harrow's Final 3 are never preselected by token ID and Harrow cannot choose them.

- if all allowed non-tail issuances finish before the native deadline, the literal final three candidates go to Harrow at true mint-out;
- if the native deadline arrives first while more than three candidates remain, exactly three remaining candidates must go to Harrow through the final approved unbiased closure mechanism;
- every other still-unminted candidate is permanently extinguished and can never be reopened or minted later;
- #066, if still present at expiry, participates under the same unbiased remaining-candidate rule.

## SciVive

`publicationKey: scivive`

- ERC-721
- max supply `5,555`
- free mint
- max 1 primary copy/wallet
- max 1/tx
- royalty 369 bps
- explicitly exempt from the native `66d 6h 6m 6s` mint-window rule
- protected 461-page Reader
- still private/not publicly mintable
- Gate 4 will use it to prove real Testnet mint → ownership → Archive/library → Reader

SciVive is intentionally narrower than Native Issue #1 and is not required to use the native interactive-comic structure.

## Native owner experience direction

A native Hellbox comic is intended to be more than a linear digital page reader.

The private owner experience is a **finite, Harrow-authored interactive narrative graph**:

```text
comic stage/page
    ↓
final frame becomes an escape-room entrance
    ↓
escape / timed survival
    ↓
authored decision or consequence
    ↓
next pre-authored stage
```

Locked principles:

- all canonical pages, stage variants, rooms, branches and endings are authored before PUBLISH;
- AI may assist Harrow during production, testing and asset creation, but canonical story content is **not generated live by AI for the reader**;
- early rooms teach the interaction language and difficulty rises toward the end;
- community collaboration around difficult rooms is intentional;
- progress saves between visits and meaningful progression must ultimately be server-authoritative;
- story choices create legitimate surviving branches, not merely disguised right/wrong buttons;
- every interactive issue has one intended/ideal surviving ending and at least one authored alternate surviving ending;
- authored deaths may result from consequential choices and/or failure to complete a timed room;
- branches should reconverge where practical so one creator can author and validate the issue without exponential content growth;
- MARK/DEFECT can create trait-specific interactions, rooms, presentation and Harrow dialogue;
- HELLBOUND should have genuine HELLBOUND-specific experiences;
- ordinary/common copies must still be able to complete the core story and reach the ideal ending;
- rarity changes the experience without becoming pay-to-win access to the core story.

Birth rarity and experience history are different systems. MARK/DEFECT are permanent birth traits and do not change because a reader dies, escapes, earns an achievement, burns something or participates in rewards.

## Archive / reward direction

Archive is the digital preservation state: the sealed collectible is metaphorically protected under plastic/slab rather than handled.

Current doctrine:

- Archive is available only while the artifact remains SEALED;
- archived copies cannot enter/play the interactive Reader;
- archived copies cannot acquire handling-derived experience marks while archived;
- **only archived copies earn ordinary official Archive rewards** under the current model;
- official Archive earning is intended to be **rarity-weighted** from immutable MARK/DEFECT;
- exact MARK/DEFECT weights, combination formula, emissions, reward asset and payout rules are **not locked yet**;
- unarchive stops new accrual but the artifact may rearchive while still SEALED;
- UNSEAL is irreversible and ends ordinary Archive eligibility under the current model.

Harrow's immediate creator copies **#001–#006 earn zero official Archive rewards for six years after mint**. If archived during that period, their effective official reward weight is `0`.

Future burn/consume mechanics may affect earning or effective reward power, but burn economics remain deliberately open and may never rewrite MARK/DEFECT birth rarity.

## Gate 4 V1 pricing / revenue boundary

V1 pricing scope is intentionally narrow:

- `FREE` for SciVive/proving releases explicitly configured free;
- `FIXED_PLS` for native Hellbox issues;
- no V1 stablecoin mint route;
- no V1 USD-target pricing;
- no V1 PLS/USD oracle, adapter or conversion path.

Frozen per issue at PUBLISH:

- accepted primary payment asset;
- primary mint price;
- headline ERC-2981 royalty rate/BPS;
- native go-live/deadline where applicable;
- supply/copy/rarity promises.

Operationally mutable downstream of receipt:

- mint-proceeds destinations/splits;
- royalty-proceeds destinations/splits;
- reward-pool routing;
- future reward-token identity/address/tokenomics;
- buy/burn/reward strategy;
- project-funding allocation.

The publication should point at durable Hellbox routing endpoints rather than hard-code today's final downstream wallets/splits into every issue.

Current operating concept — **not protocol-locked**:

```text
ROYALTIES
1/3 → Feed Harrow and future plans
1/3 → holder reward pool in native token
1/3 → buy/burn future reward-token mechanism

MINT PROCEEDS
1/3 → Feed Harrow and future plans
2/3 → buy future Hellbox reward token
      ├─ 1/2 → holder reward pool
      └─ 1/2 → burn
```

No reward-token name, address, supply, emissions, formula, distribution or tokenomics is locked by Gate 4.

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

## Development / solo-operator workflow

Hellbox must remain safely operable by one non-developer creator with a demanding primary career and fragmented availability.

Core rules:

- one implementation file at a time
- complete replacement files, never splice patches
- direct file + ZIP
- exact destination path
- one immediate Terminal action at a time
- verify source/target hashes before replacement
- validate every backend/contract/content change before moving on
- verify deployments/live behavior
- routine engineering decisions belong to the engineer/AI assistant
- open technical decisions are researched/tested by the engineer
- creator approval is reserved for product/economic/scarcity/authority/immutability/canon decisions
- before each major implementation file, perform the internal checkpoint defined in `HELLBOX_PROJECT_STATE.md`
- documentation contradiction sweeps are mandatory before synchronization is declared complete
- repeated manual operations must become scripts, validators, generated interfaces or executable runbooks
- no critical workflow may exist only in chat history, Terminal scrollback or Harrow's memory
- after interruption/new session, prove actual Git/hash/test state rather than assuming the previous command finished
- unexpected hashes, files, failing tests or unclear authority boundaries are stop-the-line conditions
- the public prelaunch progress percentage represents **overall Hellbox completeness**, not current-Gate completion; formally review/recalculate it at each Gate close

AI is expected to reduce workload through engineering, testing, narrative planning, puzzle design, asset production, validation and documentation. AI output receives the same tests/review as human output.

AI may **not** autonomously publish irreversible releases, sign mainnet/treasury transactions, receive signing secrets, change frozen product promises, or substitute plausible-looking output for repository/test evidence.

The finished production machine should be pre-engineered enough that Harrow can safely operate reviewed workflows in short, interrupted sessions without reproducing developer-only reasoning.

## Gate 4 security / economics

- minimize custom Solidity
- use pinned audited OpenZeppelin primitives for solved standards
- no publication or birth-policy proxy/upgrades in V1
- no generic publication owner
- `HellboxBirthPolicy` has no publisher/admin setter surface; future state mutation must be narrowly bound to its publication state machine
- `HellboxBirthPolicyCodeStore` is inert immutable infrastructure, not an admin/economic control surface
- no collector-token seizure/forced transfer
- no per-publication custom-Solidity/audit treadmill
- security cost is amortized across reusable reviewed versions/modules
- V1 collector economics freeze the issue's payment asset, mint price and royalty rate; downstream routing/splits remain operational
- do not hard-code an unlaunched reward token, Archive-weight formula, burn modifier or today's downstream revenue split into the publication kernel
- ERC-2981 royalty information does not guarantee marketplace enforcement or revenue
- production randomness/failure policy must be manipulation-resistant before valuable rarity/timed-Final-3 behavior reaches mainnet
- ownership-critical and mint-critical operation must not ultimately depend on one unmonitored RPC/provider
- when authoritative truth is unavailable, unsafe writes fail closed rather than guessing

Hellbox must remain worth owning if:
- a future reward token never launches or has little value;
- secondary royalties are zero;
- secondary-market liquidity is poor;
- Archive rewards are reduced or paused.

Strong pre-mainnet durability requirement:

> **dynamic when alive; durable when dead**

Before Native Issue #1 mainnet release, documented backups and a successful clean-room recovery drill must prove that the platform/publication/Reader state can be recovered without relying on one workstation, one chat or Harrow's memory.

## Risk controls

The detailed risk register lives in `HELLBOX_PROJECT_STATE.md`. The highest-priority controls are:

- **scope:** interactive issues use finite scope budgets, branch reconvergence, reusable room/trait components and a vertical slice before full production;
- **solo operation:** recurring work becomes automation/runbooks and normal production cannot require daily Harrow intervention;
- **content workload:** Gate 6 must produce a reusable narrative/package compiler with automated reachability, asset, trait-combination and ending validation;
- **puzzle quality:** progressive difficulty, human playtesting, accessibility and fair timer/start/outage behavior are hard release requirements;
- **immutable code:** unit/revert/fuzz/invariant/adversarial/static/Testnet evidence plus focused external review before mainnet;
- **randomness:** never silently fall back to manipulable entropy; pause safely instead;
- **economics:** rewards remain modular and cannot become a prerequisite for the comic/artifact to have value;
- **infrastructure:** backups, low-noise monitoring, provider failover and clean-room restoration are required before first native mainnet release;
- **handoff:** repository evidence must let a different AI/developer resume without oral reconstruction.

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
- Gate 6 — deterministic ingest/art/metadata + interactive narrative/package compiler
- Gate 7 — Seal/Archive + rarity-weighted rewards + ERC-6551 + artifact history + Hellforge/evolution
- Gate 8 — Hellion relationship depth
- Gate 9 — freeze/security/accessibility/localization/content/performance/operations/recovery hardening
- Gate 10 — deterministic mainnet release candidate + first native issue

Native Issue #1 does not launch until the promised foundational artifact model is proven **and** its interactive narrative package, path coverage, human playtesting, performance/accessibility, operational runbooks and clean-room recovery barrier pass.

For full detail, read `HELLBOX_PROJECT_STATE.md`, then `CURRENT_GATE_BLUEPRINT.md`.

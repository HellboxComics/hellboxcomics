# HELLBOX PROJECT STATE

**Status:** Authoritative cross-chat project handoff
**Repository:** `main`
**Current Gate:** Gate 4 — HELLBOX ARTIFACT KERNEL + VERSIONED PUBLICATION FACTORY
**Current implementation checkpoint:** V1 publication kernel + `HELLBOX_ABI_V1` release fingerprint + deterministic issuance core + size-safe V1 full-deployment factory + versioned enforcement-preimage anchors + modular `HellboxBirthPolicy` + immutable inert `HellboxBirthPolicyCodeStore` + factory-generation code-store/hash binding + atomic publication-owned BirthPolicy deployment + publication-only one-time MARK/DEFECT assignment/inventory consumption across the internal immediate-creator, normal non-tail and Final-3 issuance state machine are implemented and pushed; verified regression **85 Solidity tests passed, 0 failed**; issuance fuzz boundary **256 runs**; current unoptimized Shanghai runtimes are publication **16,411 bytes**, factory **9,423 bytes**, birth-policy module **9,123 bytes**, and actual deployed code-store payload **20,609 bytes** with **3,967 bytes** of EIP-170 headroom (the compiler-reported nominal runtime stub is **62 bytes**); measured native publication `CREATE` payload remains **31,665 bytes** with **17,487 bytes** of EIP-3860 headroom
**Exact next frontier:** complete the Gate 4 production-randomness/native-timed-closure architecture checkpoint before opening collector minting: select and prove the entropy request/fulfillment/fallback boundary that feeds normal copy assignment and unbiased native-expiry Final-3 selection, then implement phase eligibility, V1 `FREE`/`FIXED_PLS` payment enforcement and the public collector mint path one file at a time. No external mint endpoint opens until randomness, payment, phase and closure behavior fail closed and pass focused/full regression.
**New locked owner-experience direction:** a normal Hellbox comic release may present publicly as the same finite collectible, but the private owner Reader is a finite Harrow-authored interactive narrative: comic stages lead into frame-native escape rooms, timed survival, authored branches, alternate endings, death outcomes and trait-specific interactions. AI may assist Harrow during issue production, but published owner paths/pages/rooms are pre-authored and finite; no canonical story page is generated live by AI at read time. This expands later Reader/package/Archive work and does **not** change the immediate Gate 4 randomness/payment/phase/closure frontier or require a `HELLBOX_ABI_V1` change.
**New locked future Press direction:** after Hellbox's own Press is mature, a separate independent-creator launch lane may let outside authors/artists deploy their own non-Hellbox titles and make conforming packages readable in the Hellbox Reader. Outside titles never receive Hellbox-native title stamps/canon/reward status merely for using the Press; creators remain responsible for their own canonical asset hosting; Harrow's proprietary comic-generation machinery remains private; exact launch prerequisites and fee/royalty economics remain OPEN.
**New locked token/settlement separation direction:** Harrow is a comic creator/publisher and Press operator, not a crypto-founder identity. Any future Hellbox-endorsed/project-used token remains separate from Hellbox publication-contract control: official Hellbox project wallets do not deploy that token, Hellbox does not hold token admin keys or control permanently locked liquidity, and official Hellbox wallets may later acquire an already-public token through ordinary market transactions before/after endorsement. Public statements must describe actual launch/control/holdings facts truthfully. Customer-facing Hellbox commerce remains PLS-denominated/on-chain rather than USD checkout, while back-office accounting still records required transaction-time fiat fair-market values separately.
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

## 2.1 One-file / one-command operator workflow — LOCKED

For implementation/config changes:

1. explain why that exact file is next;
2. provide a complete replacement file, never splice instructions;
3. give a direct file + ZIP;
4. state the exact destination;
5. Harrow downloads the ZIP into `~/Downloads`;
6. give exactly **one Bash command/block for the current turn**;
7. that Bash verifies package/current-source/target hashes and installs the file in the correct repo path — no manual file placement;
8. wait for the complete Terminal output;
9. verify focused/full tests, production sizes, diff checks and Git status as applicable;
10. only then stage, commit, push or move to the next file.

Code changes return to **one implementation file at a time**. Do not batch source, test or configuration files merely to reduce operator steps. A multi-file code package requires a new explicit creator exception after explaining why the files cannot be safely isolated; prior general permission to batch code is not active.

Documentation may be batched **only at the final deployment layer**: independently rebuild/review each affected authoritative document in dependency/authority order, run contradiction sweeps across the complete candidate set, and then install the finished documents through one atomic ZIP/Bash and normally one documentation checkpoint. Installation batching is not review or engineering batching.

Never queue later Terminal commands before Harrow has returned the current command's output. Do not stack unverified backend/contract changes.

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
- optimizer/via-ir;
- renderer transport;
- external protocol binding;
- exact deterministic/native timed-closure implementation;
- revenue-router implementation/authority mechanics.

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

## 2.9 Solo-operator maintainability standard — LOCKED

Hellbox must remain operable by **one non-developer creator with a demanding full-time primary career and fragmented availability**, without enterprise staffing, hidden tribal knowledge or repetitive manual heroics.

Architecture and workflow must assume:
- one primary operator;
- work may occur from home or another trusted workstation;
- sessions may be interrupted without warning;
- long uninterrupted development blocks are not guaranteed;
- ordinary home-office hardware/connectivity;
- context switches and long pauses between work sessions;
- the operator cannot be expected to remember undocumented sequences;
- routine use of reviewed systems must not require understanding Solidity internals;
- future handoff to another competent AI/developer without oral reconstruction.

Therefore:
- no critical workflow may exist only in chat history, Terminal scrollback or Harrow's memory;
- every repeated multi-step operation must become a script, compiler task, template, checklist, generated interface or guided Press action;
- recurring manual steps are technical debt and must be automated before they become operationally critical;
- routine operations must be preflighted, self-checking, explicit about expected output and safe to rerun;
- commands should be idempotent or safely resumable where practical;
- incomplete or ambiguous state must fail closed rather than guessing;
- failures must be explicit rather than silently producing partial releases;
- generated artifacts must carry hashes/manifests sufficient to verify and reproduce them;
- per-issue custom Solidity and per-issue infrastructure snowflakes are prohibited unless a formal architecture review approves an exception;
- issue production must reuse versioned schemas, renderers, room components, validators and deployment tooling;
- complex engineering must be absorbed into reusable machinery rather than transferred to Harrow as manual procedure;
- a smaller shippable issue is preferred over reducing validation/quality to preserve an oversized scope;
- every clean checkpoint must be understandable from the repository and living documents alone.

The target is not merely "documented enough for a developer." It is:

> **pre-engineered enough that Harrow can operate the finished machine safely in short, interrupted sessions.**

A process that only works while the original chat, Terminal scrollback or Harrow's short-term memory is available is not a production process.

## 2.10 Session resume / interruption protocol — LOCKED

At the beginning of every fresh Terminal, resumed work session or new AI thread:

1. enter the exact repository;
2. inspect `git status --short`;
3. inspect the current `HEAD` subject/hash;
4. compare local and remote when the previous checkpoint should have been pushed;
5. verify the hash of the immediate target file;
6. read this document's Exact Next Action;
7. read the relevant `CURRENT_GATE_BLUEPRINT.md` section;
8. run the narrowest relevant validation before modifying a major boundary when state is uncertain.

After an interruption:
- never infer that a command completed from memory;
- rerun safe read-only/preflight checks;
- treat an already-installed expected target hash as success;
- treat an unexpected source hash as a stop condition;
- never continue from copied Terminal fragments without proving actual repository state;
- leave no assumed background task.

Terminal output is evidence for the current session, not durable project storage. Durable state belongs in Git, manifests, tests and living documents.

## 2.11 AI-assisted engineering and authoring policy — LOCKED

AI is a force multiplier for a solo operator, not a replacement for canonical source, deterministic tooling, security review or Harrow's final judgment.

Approved AI assistance may include:
- architecture option analysis;
- code/test drafting;
- adversarial-test ideation;
- documentation synchronization;
- story/branch/room ideation;
- continuity and canon checks;
- asset concepts and production assistance;
- narrative-graph simulation;
- puzzle variant generation;
- unreachable-path/dead-end discovery;
- accessibility text/caption drafts;
- localization drafts;
- performance/test-case generation;
- release-checklist generation.

AI output must pass the same gates as human output:
- schema validation;
- deterministic/reproducible build rules;
- automated tests;
- contradiction sweeps;
- copyright/provenance review where applicable;
- human visual/editorial approval;
- Harrow approval for canon/economics/authority/scarcity decisions.

AI must not:
- generate canonical story pages live at Reader runtime;
- directly hold or receive private keys, seed phrases or production secrets;
- directly publish a release or send a mainnet transaction without explicit reviewed operator action;
- silently change collector promises;
- bypass failing tests/validators;
- substitute for specialist security, legal or tax review where those are materially required;
- become an undocumented external dependency needed to reproduce an already-published issue.

The authoritative output is the reviewed source package and deterministic build, not an AI conversation.

## 2.12 Scope budget and change-control rule — LOCKED

Every Gate and every native issue must declare a scope budget before deep implementation/content production.

For an interactive issue, the budget must at minimum identify:
- surviving story-stage count;
- maximum simultaneous branch width;
- intended reconvergence points/windows;
- number of required escape rooms;
- number of ending classes;
- number of authored room variants;
- MARK/DEFECT intervention count;
- required unique visual/audio assets;
- performance budget;
- accessibility obligations;
- required human playtest coverage.

Exact values are issue-specific and remain open until that issue is designed.

Any mid-production idea must do one of the following:
1. fit inside the existing budget;
2. replace another scoped item;
3. move to a later issue/Gate;
4. trigger an explicit rebaseline.

Do not allow a branching graph to expand merely because every new idea is good. Good ideas that prevent shipment are backlog items.

Stop/re-review conditions include:
- branch count grows faster than reconvergence;
- unique asset count exceeds the declared production budget;
- required manual steps multiply per copy/path;
- one issue requires bespoke contract behavior;
- the validation matrix can no longer cover every reachable path;
- Harrow cannot realistically author/review/playtest the scope without lowering quality.

## 2.13 Repeatable production pipeline — LOCKED TARGET

Every native issue should eventually move through one reproducible pipeline:

```text
CANONICAL SOURCE PACKAGE
        ↓
SCHEMA + RIGHTS/PROVENANCE VALIDATION
        ↓
NARRATIVE GRAPH / ROOM / TRAIT VALIDATION
        ↓
DETERMINISTIC PREVIEW + PLAYTHROUGH MATRIX
        ↓
ACCESSIBILITY / PERFORMANCE / DEVICE CHECKS
        ↓
HUMAN EDITORIAL + HARROW APPROVAL
        ↓
FREEZE PREVIEW
        ↓
PUBLISH COMMITMENTS
        ↓
DEPLOY / VERIFY
        ↓
OPEN PRESS
        ↓
POST-RELEASE MONITORING
```

The pipeline must prefer:
- one canonical machine-readable manifest rather than duplicated configuration;
- generated metadata rather than hand-written per-copy JSON;
- generated route/ending coverage reports;
- generated asset inventories and hashes;
- generated deployment/config summaries;
- dry-run and production modes using the same underlying code path;
- explicit artifacts that can be rechecked later.

Manual intervention may approve or abort a release. It should not be required to assemble hundreds of files by hand.

## 2.14 Definition of done — code, content and operations

A feature is not done because it looks correct once.

Code completion requires, as applicable:
- allowed-path tests;
- forbidden-path tests;
- fuzz/invariant/adversarial evidence;
- size/deployability proof;
- security review proportional to the change;
- documentation sync;
- clean committed/pushed checkpoint.

Interactive content completion requires:
- every reachable node/room/ending validated;
- no orphan or accidental dead-end routes;
- all required assets present and hashed;
- ordinary copies can reach the ideal/core ending;
- trait interventions cannot corrupt unrelated paths;
- timer/death behavior tested;
- human playtests across intended difficulty;
- accessibility and performance checks;
- deterministic rebuild from source.

Operational completion requires:
- runbook;
- monitoring/alert behavior;
- backup/export path;
- tested recovery path;
- safe abort/fail-closed behavior;
- no secret/manual step omitted from documentation.

A backup is not considered proven until a restore has succeeded.

## 2.15 Stop-the-line conditions — LOCKED

Stop immediately rather than improvising around:

- unexpected source/artifact hash;
- unexpected staged or unstaged file;
- failing test, invariant, deployment or package validation;
- unexplained reduction in EIP-170/EIP-3860 safety margin;
- unclear authority or mutable/immutable boundary;
- conflicting authoritative documents;
- secret/private data exposed in output or Git;
- production write without a verified backup/recovery path;
- a critical third-party dependency without outage/fallback behavior;
- interactive scope exceeding its approved budget;
- AI output that cannot be reproduced or independently checked;
- manual operation whose consequences are not understood.

Required response:

1. stop;
2. preserve evidence;
3. restore the known-good checkpoint if needed;
4. document the conflict/failure;
5. redesign or repair;
6. rerun proof before continuing.

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
- public publication-builder SaaS before Hellbox itself is mature; a later independent-creator Press lane must remain explicitly non-native and separately classified;
- a DeFi product wearing a comic skin;
- a token-founder/issuer business whose comics exist merely to market a coin;
- a system where paying to use the Press makes an outsider title an official Hellbox title;
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
- `contracts/HellboxBirthPolicyCodeStore.sol`
- `contracts/HellboxPublicationFactory.sol`
- `src/press/releaseFingerprint.js`
- `test/HellboxPublication.t.sol`
- `test/HellboxPublicationFactory.t.sol`
- `test/HellboxPublicationIssuance.t.sol`
- `test/HellboxPublicationPolicy.t.sol`
- `test/HellboxBirthPolicy.t.sol`
- `test/HellboxBirthPolicyCodeStore.t.sol`
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
- `Bind BirthPolicy infrastructure to factory generation`
- `Wire atomic BirthPolicy deployment into publications`
- `Enforce atomic birth trait assignment during issuance`

## Verified test / deployability state

The current committed test suites contain:
- 16 publication-kernel tests;
- 21 factory/provenance/atomic-deployment tests;
- 13 deterministic issuance + atomic trait-assignment tests;
- 9 publication enforcement-preimage anchor/golden-policy tests;
- 21 dedicated modular birth-policy tests;
- 4 dedicated immutable code-store tests;
- 1 cross-language `HELLBOX_ABI_V1` golden-vector test.

Total: **85**

Verified creator-side evidence after the trait-enforcement push:
- **85 passed**;
- **0 failed**;
- issuance fuzz boundary: **256 runs passed**;
- `HellboxPublication` runtime: **16,411 bytes**;
- publication EIP-170 runtime margin: **8,165 bytes**;
- `HellboxPublication` creation size: **26,737 bytes**;
- `HellboxPublicationFactory` runtime: **9,423 bytes**;
- factory EIP-170 runtime margin: **15,153 bytes**;
- `HellboxPublicationFactory` creation size: **10,499 bytes**;
- `HellboxBirthPolicy` runtime: **9,123 bytes**;
- birth-policy EIP-170 runtime margin: **15,453 bytes**;
- `HellboxBirthPolicy` initcode: **20,608 bytes**;
- birth-policy EIP-3860 initcode margin: **28,544 bytes**;
- compiler-reported `HellboxBirthPolicyCodeStore` nominal runtime stub: **62 bytes**;
- actual constructor-returned deployed code-store runtime (`STOP || HellboxBirthPolicy.creationCode`): **20,609 bytes**;
- actual deployed code-store EIP-170 runtime margin: **3,967 bytes**;
- future BirthPolicy growth must measure the actual deployed code-store `address.code.length`; the compiler-reported 62-byte stub is not the production EIP-170 measure;
- code-store creation size: **20,871 bytes**;
- code-store EIP-3860 creation margin: **28,281 bytes**;
- measured native publication `CREATE` payload including constructor arguments: **31,665 bytes**;
- measured EIP-3860 headroom for that native publication payload: **17,487 bytes**;
- production `HellboxPublication`/factory source contains **0** direct `new HellboxBirthPolicy(...)` or `type(HellboxBirthPolicy).creationCode` embeds;
- `HELLBOX_ABI_V1` `ReleaseConfig` + `CommitmentSet` structure hash remained unchanged;
- local HEAD and `origin/main` matched after pushing `Enforce atomic birth trait assignment during issuance`;
- `git diff --check`: clean;
- worktree: clean.

The factory/atomic-deployment suite additionally proves:
- zero approved publication creation-code hash is rejected;
- zero BirthPolicy code-store address is rejected;
- zero approved BirthPolicy creation-code hash is rejected;
- unapproved publication creation code is rejected;
- malformed, non-STOP, short or wrong-hash BirthPolicy stores fail atomically;
- malformed or digest-mismatched BirthPolicy preimages fail atomically;
- failed deployment cannot become official factory provenance;
- native publication deployment creates the companion and binds it back to the actual publication;
- the trait-disabled SciVive path deploys through the same reviewed publication version;
- factory ownership remains two-step and renunciation remains disabled;
- factory-generation BirthPolicy infrastructure bindings do not change when publishing authority rotates;
- the factory remains comfortably below EIP-170.

The dedicated birth-policy/code-store suites additionally prove:
- the module is constructor-frozen and permanently records its deploying publication as `publication`;
- fixed-copy, birth-trait and randomization preimages independently hash to their frozen commitment digests;
- duplicate fixed-copy rules and invalid inventory/fairness shapes revert;
- native MARK inventory and reservations match the frozen 216-copy model;
- native DEFECT inventory matches the frozen 216-copy model with no fixed creator DEFECT reservations;
- Harrow #001–#006 fixed MARK reservations are consumed exactly once while their DEFECTS remain shared-random;
- #066 remains candidate-eligible until drawn, then consumes its fixed HELLBOUND reservation exactly once;
- only the permanently bound publication may call `assignBirthIdentity`; no publisher/admin caller receives that authority;
- every applicable issued copy receives one permanent MARK and one permanent DEFECT; duplicate/reroll assignment reverts;
- random assignment cannot consume inventory reserved for an undrawn fixed copy;
- issuance failure during trait assignment rolls supply, wallet, candidate and trait inventory state back atomically;
- enabled-axis remaining inventory stays equal to candidate inventory after the immediate creator allocation, and reaches zero after the literal Final 3;
- transfer and burn do not restore allowance, inventory or rewrite stored birth identity;
- a trait-disabled reusable publication shape such as SciVive assigns a permanent zero/zero identity without inventing traits;
- code-store runtime is exactly inert `STOP || HellboxBirthPolicy.creationCode`.

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

# 10. READER PRODUCT — LOCKED OWNER-EXPERIENCE DIRECTION

Reader is central.

Presentation classes:

- `BOOK`
- `COMIC`
- `INTERACTIVE_COMIC`
- future deliberately-authored enhanced classes if justified

BOOK:
- proven through SciVive;
- conventional protected reading remains supported.

COMIC:
- conventional fixed page/spread reading remains supported where the publication calls for it.

## INTERACTIVE_COMIC — locked Hellbox direction for native comics

The public collectible may still look like a finite comic/NFT release. The private owner experience is allowed to be fundamentally different from a traditional digital comic.

A published interactive issue is a **finite, Harrow-authored narrative graph**.

AI may assist Harrow during production with:
- story mapping;
- branch planning;
- continuity checks;
- puzzle/escape-room ideation;
- art/animation/audio production;
- difficulty review;
- playthrough simulation;
- impossible/dead-path detection;
- workload reduction.

AI does **not** invent canonical next pages or story paths live for the collector. By PUBLISH, the allowed pages/stage variants, rooms, choices, consequences, endings, trait interactions and rules are already authored and part of the frozen issue/package identity.

### Core stage loop

A successful stage normally behaves as:

```text
comic page/stage
    ↓
reader reaches final frame
    ↓
final frame becomes the entrance to that stage's Hellbox escape room
    ↓
room must be escaped before story advancement
    ↓
authored decision / consequence
    ↓
next allowed authored story stage
```

The escape room is an interactive extension of the stage's final comic frame, not a random external minigame pasted onto the issue.

### Difficulty curve

Required product direction:
- opening rooms teach the interaction language and begin simple;
- puzzle complexity increases as the issue progresses;
- later rooms should become meaningfully difficult;
- finishing the complete surviving story should be challenging;
- community discussion/collaboration around puzzles is an intended part of the Hellion experience.

Exact room timers, puzzle mechanics and hint policy are publication/package design decisions.

### Timed survival

A room may have a frozen authored time limit.

If a required timed room is not completed before its authoritative deadline, the run may terminate in an authored death outcome.

Timer authority must not rely on the collector changing a local browser clock. Exact server/runtime implementation belongs to later Reader work.

### Branching rules

Branches are **real story branches**, not merely disguised right/wrong buttons.

A branch may:
- continue through a distinct surviving route;
- diverge and later reconverge;
- alter later dialogue/clues/rooms;
- produce an alternate surviving ending;
- produce a secret outcome;
- produce death when that consequence is actually authored.

Not every non-ideal branch ends in death.

Each interactive issue must support:
- one intended/ideal surviving ending;
- at least one authored alternate surviving ending;
- authored death outcomes where appropriate.

Death may occur from:
- a consequential branch choice;
- failing a timed escape room.

Death is terminal for the current run. Exact restart/retry policy beyond that remains later Reader-product detail.

### Progress

Live run progress must persist between visits.

The later implementation should treat meaningful progress as server-authoritative rather than allowing localStorage/front-end flags to claim a solved room or completed branch.

Expected logical identity:

```text
publication
tokenId
wallet
runId
```

Exact transfer/new-owner handling for private prior-run state remains later product detail and must be resolved before this system ships.

### Trait-specific owner experiences

Immutable birth traits can alter what an owner encounters.

MARK may unlock or alter:
- trait-specific interactions;
- optional rooms;
- Harrow dialogue;
- clues;
- visual layers;
- hidden passages;
- achievements;
- special authored side content.

HELLBOUND in particular should have genuine HELLBOUND-specific interactions rather than functioning only as a scarcity/market label.

DEFECT may intentionally change how the comic/room behaves. Examples of the design language, not a requirement that every issue use every effect:
- REDACTED can conceal/reveal authored information;
- CORRUPTED PLATE can introduce deliberate visual/data corruption;
- BLED OUT can let ink/color bleed become part of the interaction;
- OFF REGISTER can use intentional layer misalignment as presentation/puzzle language;
- NONE remains the clean baseline.

Trait behavior must be pre-authored/validated for the issue. It is not runtime AI generation.

### Fairness boundary

Rarity may make a copy **different**, not cripple ordinary collectors.

A normal/common copy must remain capable of:
- experiencing the complete core story;
- surviving the required rooms;
- reaching the ideal ending;
- reaching the issue's ordinary alternate ending(s).

Rare traits may add secret/alternate content, interactions, presentation or achievements, but must not turn the core narrative/ideal ending into pay-to-win access.

### Achievement / completion direction

Hellbox may persist:
- survival/completion achievements;
- deaths;
- discovered endings;
- authored experience marks;
- a Harrow completion/certificate artifact.

Exact achievement taxonomy, certificate implementation and public/private disclosure are later Reader/artifact-state design. The Harrow certificate concept may keep the joke that Harrow retains the "original."

Reader principles:

- art/content is the star;
- UI disappears when not needed;
- keyboard/touch;
- fit page/width;
- preloading;
- accessibility;
- protected ownership access;
- no dishonest DRM claims;
- story/puzzle state is authored, deterministic under its frozen rules and reproducible;
- no runtime-AI dependency for canonical story continuity.

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
- crypto/token founder, issuer or token-contract administrator;
- community manager;
- Joker imitation;
- superhero;
- demon king;
- generic edgelord.

Future token separation rule:
- Harrow/Hellbox may later buy, use or endorse a separately deployed public token;
- an official Hellbox project wallet is not required to be the launch wallet and Hellbox should not hold token admin keys or control permanently locked liquidity;
- wallet anonymity alone does not prove independence, so public descriptions must match the real facts about control, coordination, compensation, funding and beneficial ownership;
- Hellbox does not promise token price support, appreciation, liquidity support or holder profit from Harrow's efforts;
- no future token launch/address/economics belong in the immutable publication kernel merely because Harrow likes the token.

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

# 12. COMIC / INTERACTIVE NARRATIVE FORMAT

Current working structural standard for **ordinary Hellbox comic books** remains:

- 14 comic story stages/pages on a complete surviving path;
- 64 chronological comic-frame positions on a complete surviving path;
- frame numbering does not reset inside an issue;
- the interactive system does not automatically create extra numbered comic frames merely because an escape room opens from the final frame.

For an `INTERACTIVE_COMIC`, "page" should be understood as a **story-stage position** that may have multiple pre-authored variants.

Conceptually:

```text
STAGE 6
├── page/stage variant A
├── page/stage variant B
├── optional trait-specific authored intervention
├── final-frame escape room
├── branch/death consequence
└── transition to an allowed next stage
```

A surviving branch may diverge for one or more stages and later reconverge. This is the primary workload-control strategy: Hellbox should create strong perceived consequence without requiring an exponentially expanding tree of wholly independent books.

Still **OPEN / PROTOTYPE**:
- exact page-by-page frame distribution;
- exact panel/grid/layout grammar;
- whether every stage variant must preserve an identical local frame count once the final layout grammar is locked;
- exact branch-reconvergence conventions.

What is now **LOCKED**:
- the published interactive issue is finite/pre-authored;
- successful paths may legitimately differ;
- at least one alternate surviving ending exists in addition to the ideal ending;
- death paths can terminate before the final stage;
- the final-frame room/branch experience is part of the authored issue;
- rare-trait interactions cannot block ordinary copies from the complete core story or ideal ending.

Once the ordinary-comic layout grammar is established, it should remain coherent and repeatable across Hellbox comics rather than every title inventing a new structural language.

Exceptions:
- graphic novels;
- prose-to-graphic adaptations;
- SciVive and similar proving/source-book cases.

Those exceptions are not required to follow the ordinary-comic page/frame/interactive structure.

There is no separate locked rule called "no filler frames." The intended quality rule is that, once the production standard is finalized, each frame should earn its place in story, pacing, character, atmosphere, information, clueing or visual rhythm.

`NO CONSENSUS` is **not an established Hellbox series** under current root-document authority. It remains only a fill-in/example title from format exploration unless the creator later explicitly establishes it.

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

## Harrow tail / native timed closure

Harrow's Final 3 are always the literal three candidates ultimately reserved to Harrow from the still-random candidate pool. They are never preselected by token ID and Harrow cannot choose them.

For a standard native issue:

- if all 207 allowed non-tail primary issuances are consumed before the deadline, the literal final three remaining candidates go to Harrow at true mint-out;
- if the immutable native mint deadline arrives first, exactly three candidates from the then-remaining pool go to Harrow through the final approved unbiased closure mechanism;
- every other still-unminted candidate is permanently extinguished and can never be reopened or minted later.

There is no discretionary early-close button that changes this promise. A sellout can naturally finish before the deadline; otherwise the native timer controls closure.

The exact unbiased entropy/final-selection mechanism at timed expiry remains technical work and must not give Harrow a grail-selection path.

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

The current module now consumes inventory atomically through the internal issuance state machine. These reservation semantics are live authoritative on-chain state after assignment; Gate 5 Press/API odds must derive from actual `candidatePoolRemaining` plus BirthPolicy remaining inventory rather than maintaining a second rarity ledger.

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
- accepted payment asset;
- frozen issue mint price;
- native mint deadline/countdown when applicable;
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

# 18. PRICING, PAYMENT ASSET, REVENUE ROUTING & NATIVE MINT WINDOW

Pricing is per release and is part of the collector-facing release promise.

## Gate 4 / V1 payment scope — LOCKED

Current V1 publication targets only:

- `FREE` — used by SciVive and other explicitly free proving releases;
- `FIXED_PLS` — native Hellbox issues mint for one frozen PLS amount.

For a published issue:

- accepted primary payment asset is immutable for that issue;
- primary mint price is immutable for that issue;
- one issue may use a different frozen PLS price than another;
- Gate 4 does **not** implement stablecoin minting;
- Gate 4 does **not** implement USD-target pricing;
- Gate 4 does **not** require a PLS/USD oracle, adapter or conversion path;
- collectors do not choose between PLS and a stable token.

A future publication version/module may add another accepted payment token. That future capability must not rewrite an already-published issue's payment asset or price.

## PLS settlement / accounting boundary — LOCKED

For Hellbox-native paid releases, the customer-facing transaction is PLS-denominated and settled on-chain:

- Hellbox does not need a USD checkout path for native V1;
- a `FIXED_PLS` release freezes the collector-facing amount in PLS, not a hidden USD target;
- PLS market volatility does not authorize the Press to change an already-published issue's frozen PLS price;
- no PLS/USD oracle is required inside the publication contract merely for checkout.

This commercial/UX choice is separate from back-office accounting and tax records.

The operational ledger must be able to record at least:
- publication/copy;
- payer/transaction hash;
- PLS amount received;
- block/timestamp;
- transaction-time USD fair-market value when required for accounting/tax reporting;
- later disposition/basis evidence where applicable.

Hellbox can remain PLS-only to collectors while the accounting system quietly produces the records an accountant needs. Do not treat “not bridged to dollars” as a reason to omit transaction-time accounting evidence.

## Native issue mint duration — LOCKED

Every native Hellbox issue has an immutable primary mint window of exactly:

```text
66 days
+ 6 hours
+ 6 minutes
+ 6 seconds
```

measured from that issue's configured go-live time.

Rules:

- sellout may naturally end primary issuance earlier;
- otherwise primary issuance closes exactly at the configured deadline;
- the deadline cannot be extended or reopened after PUBLISH;
- at deadline, Harrow's Final 3 survive according to the tail rule;
- every other still-unminted candidate is permanently extinguished;
- extinguished capacity cannot be restored by transfer, burn, admin action or later configuration.

**SciVive's free proving mint is explicitly exempt from the native `66d 6h 6m 6s` rule.** Its closure/timing may use its own frozen proving configuration.

## Revenue routing — operationally mutable

The issue contract must distinguish immutable collector economics from mutable downstream project operations.

Frozen per issue at PUBLISH:
- accepted payment asset;
- primary mint price;
- royalty rate/BPS;
- mint timing/closure rule;
- supply/copy/rarity promises.

Not frozen as final-wallet economics:
- downstream mint-proceeds split percentages;
- downstream royalty-proceeds split percentages;
- payout destination wallets;
- holder reward-pool destination/mechanics;
- reward-token identity/address/tokenomics;
- buy/burn/reward strategy;
- future project-funding allocation.

The publication should therefore route proceeds to a durable Hellbox operational routing endpoint/protocol rather than hard-code final dev/reward/burn wallets into every issue. The exact routing-contract/controller implementation remains technical work. The current immutable `royaltyReceiver` field must be treated as the issue's routing endpoint, not as a promise that downstream recipients/splits can never change.

Current operating concepts — **not protocol-locked and explicitly adjustable by Harrow through the gated operational system**:

Royalties:
```text
1/3 → Feed Harrow and future plans
1/3 → holder reward pool in native token
1/3 → buy and burn the future reward-token mechanism
```

Primary mint proceeds:
```text
1/3 → Feed Harrow and future plans
2/3 → buy the future Hellbox reward token
          ├─ 1/2 → holder reward pool
          └─ 1/2 → burn
```

No reward-token address, name, supply, emissions, distribution, tokenomics or reward formula is locked by Gate 4. Generic rewards compatibility may be preserved, but the future reward system may change structure before it is explicitly approved.

`CommitmentSet.pricingDigest`, `paymentRoutesDigest`, `royaltyDigest` and `treasuryDigest` must not be interpreted as permission to freeze today's downstream split table by accident. Their eventual V1 preimages must clearly separate the immutable per-issue collector promise/routing protocol boundary from operational downstream routing state that is intentionally adjustable.

---

# 19. SEALED / ARCHIVE / UNSEALED — LOCKED PRODUCT MODEL

## SEALED

Unopened.

Potentially Archive-eligible.

## ARCHIVE

Reversible while sealed.

Archive is the digital equivalent of preserving the comic under protective plastic/slab rather than handling/reading it.

- NFT remains in wallet;
- transfer execution locked;
- Hellbox does not list it while archived;
- NFT/metadata presentation should visibly communicate the protective sleeve/plastic state;
- current Hellbox reward doctrine: **only archived copies accrue official Archive rewards**;
- an archived copy cannot enter/play the interactive Reader run;
- an archived copy cannot acquire experience marks, puzzle scars, deaths, run achievements or other handling-derived artifact state while archived;
- unarchive stops new earning/unlocks transfer and returns the still-sealed artifact to SEALED state;
- may rearchive while still sealed.

Third-party off-chain listings may still display; actual transfer must fail while archived.

## UNSEALED

Permanent.

Once opened:
- cannot reseal;
- cannot re-enter Archive under the current product model;
- cannot regain ordinary official Archive reward eligibility merely by finishing/closing the Reader;
- may participate in the interactive owner experience;
- may acquire authored experience/history state according to the issue's frozen rules.

Irreversible actions require explicit Harrow warning and deliberate confirmation.

Future burn/consume systems may create a different approved way to earn or modify reward power, but that possibility is **OPEN** and must not be interpreted as permission to make UNSEALED copies re-Archive under today's rules.

---

# 20. DYNAMIC METADATA / ARTIFACT STATE

Rules freeze.

Metadata output may change according to frozen rules.

Permanent birth:
- token/copy ID;
- PRESS MARK;
- PRESS DEFECT.

**Birth rarity never changes.** Reading, dying, escaping, achievements, experience marks, Archive status, burns or future reward modifiers must not rewrite a token's MARK/DEFECT birth identity.

Ruled artifact state may include:
- SEAL;
- ARCHIVE;
- cover/presentation;
- permanent history;
- authored experience marks/scars earned while the artifact is unsealed;
- discovered artifact-level achievements where the publication rules say they follow the token;
- Hellforge/evolution state;
- official Archive status/balance;
- contextual current-wallet traits.

Private run state is distinct from permanent birth rarity and may also be distinct from artifact-level permanent history. Exact wallet-run versus token-history boundaries remain later Reader/artifact-state work.

Archived copies are protected from handling-derived experience mutation while archived.

Permanent artifact events follow the token.

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

Separate from arbitrary TBA asset balances and separate from birth-trait assignment itself.

Current locked product doctrine:
- **archived copies are the ordinary reward-earning state**;
- reward earning is **rarity-weighted** using the token's immutable birth rarity;
- MARK and DEFECT may both contribute to relative Archive weight;
- exact numeric weights, combination formula, emissions, reward asset and payout schedule remain later Gate 7 product/economic decisions;
- experience marks do **not** alter MARK/DEFECT rarity and do not retroactively reroll the birth-rarity basis;
- unarchive stops new ordinary Archive accrual;
- unseal permanently ends ordinary Archive eligibility under the current model.

Preferred implementation boundary:
- dedicated external/protocol accounting keyed to NFT;
- publication/BirthPolicy expose or preserve the immutable inputs but do not hard-code a reward token or emissions formula;
- owner can claim under the active external reward protocol;
- unclaimed balance can follow NFT if the later frozen protocol explicitly says so.

### Harrow creator-copy reward delay — LOCKED

Harrow's creator-reserved immediate copies **#001–#006 earn zero official Archive rewards for six years after their mint**.

During that six-year period:
- they may still exist/display under the normal artifact rules;
- if archived, their effective official reward weight is `0`;
- their special MARKS do not create an immediate creator reward advantage.

After the six-year delay, the external Archive/reward protocol may allow them to participate under the same approved rarity-weight doctrine then in force.

This lock belongs in the external Archive/reward eligibility layer, not as a reward-token formula inside `HellboxPublication` or `HellboxBirthPolicy`.

Rationale:
- if Hellbox does not survive/grow long enough, Harrow never receives the benefit of those creator-reserved rarity allocations;
- it prevents the creator from immediately assigning himself rare copies and simultaneously extracting enhanced rarity-weighted rewards from them.

### Future ecosystem token separation — LOCKED CONTROL BOUNDARY / ECONOMICS OPEN

A future token that Hellbox chooses to endorse or use is not automatically a Hellbox-issued contract.

Locked control boundary:
- Harrow's product identity remains comics/collectibles/Press infrastructure, not “crypto founder”;
- an official Hellbox project wallet does **not** deploy the token;
- Hellbox does **not** hold token admin keys or control permanently locked liquidity;
- the launch may originate from an unattributed/anonymous wallet, but “anonymous” must not be publicly rewritten as “independent/unaffiliated” unless that is factually true;
- if Hellbox later acquires the public token, those acquisitions are ordinary project treasury/market transactions and may occur before or after public endorsement;
- material Hellbox holdings, compensation or relationships should be described accurately when public endorsement would otherwise create a misleading impression;
- Hellbox makes no promise of price support, appreciation, liquidity maintenance or profit from Harrow's/Hellbox's future efforts;
- no token address, launch wallet, launch date, supply, distribution, reward formula or buy/burn strategy is frozen by Gate 4.

Architecture:
- publication ownership/authenticity does not depend on controlling the future token;
- `HellboxPublication` and `HellboxBirthPolicy` must not gain token-admin powers;
- any future project-token/reward-token integration remains modular/external and can be delayed, replaced or omitted without invalidating the comic artifact.

### Burn/reward interaction — deliberately OPEN

Do **not** lock today's burn economics.

A future approved burn/consume system might:
- create a separate earning event;
- increase another archived artifact's effective reward power;
- feed a permanence/inscription mechanism;
- do something else entirely.

Any future burn modifier must remain distinct from birth rarity: it may modify **effective reward power** under the external protocol but must not rewrite MARK/DEFECT.

Before any future reward-token launch:
- do not lock or publicly promise a token address, supply, emissions model, tokenomics or distribution merely because an earlier concept exists;
- the reward token/system remains an open product decision until explicitly approved;
- use neutral `ARCHIVE BALANCE` / reward-language where a specific token is not yet locked.

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
- Reader enabled;
- free-mint proving configuration is **not subject to the native `66d 6h 6m 6s` mint-duration rule**.

May use:
- dynamic covers;
- SEALED/UNSEALED;
- later contextual reaction to holding SciVive Graphic Novel.

Does not automatically use:
- native 216 MARK/DEFECT grammar;
- native interactive-comic escape-room/branch/death structure;
- full Archive reward economy;
- full Hellforge;
- broad burn/evolution system.

Purpose:

`mint → ownership → Archive/library recognition → protected Reader`

---

# 23. PRIVATE PRESS / PUBLICATION COMPILER — TARGET END STATE

Harrow supplies:

1. canonical cover;
2. actual comic/Reader source package;
3. finite narrative graph, stage/page variants, choices and endings where interactive;
4. escape-room definitions, timers, solutions, hints and death consequences where interactive;
5. MARK interaction layers/rules;
6. DEFECT interaction layers/rules;
7. credits/metadata;
8. economics;
9. mint phases;
10. capabilities/version;
11. rights/provenance records for included assets.

Compiler target:

`INPUT → VALIDATE → GRAPH-CHECK → PREVIEW → PLAYTHROUGH MATRIX → COMMIT → RANDOMIZE/ASSIGN → RENDER → METADATA → DEPLOY → VERIFY → OPEN PRESS`

Compiler/Press must eventually generate:
- route/reachability report;
- ending coverage;
- room/timer inventory;
- trait-intervention compatibility report;
- missing-asset report;
- deterministic asset/hash manifest;
- accessibility checklist;
- performance budget report;
- immutable freeze summary;
- exact deployment/config package;
- post-deploy verification report.

Default production pipeline:
- deterministic/reproducible compositing and packaging;
- Harrow-authored/approved layers, rooms, branches and effects;
- AI assistance permitted during production under the locked AI policy;
- no runtime-AI dependency for canonical story continuity.

Harrow should not know the complete hidden random copy/trait assignment map in advance.

No future release should require:
- bespoke Solidity;
- hand-writing every metadata JSON;
- manual R2 juggling;
- manual rendering of every combination;
- manually checking every graph edge in a spreadsheet;
- remembering unrecorded release steps;
- rebuilding the publication package differently for preview and production.

The target system must turn issue production into a repeatable authored-data workflow rather than a new software project for every book.

## 23.1 Future independent-creator Press lane — LOCKED DIRECTION / LATER GATE

After Hellbox's own native production machine is mature and safe, the Press may expose a separate launch lane for outside authors/artists.

Product intent:
- outsiders may launch their own independent digital titles using supported Press deployment/Reader standards;
- supported title complexity may range from basic comics/ebooks to advanced interactive packages that conform to published interfaces;
- successful outside creators bring their existing audiences into the Hellbox Reader/Press environment instead of needing to build competing ownership/Reader infrastructure from scratch;
- Hellbox may charge for that infrastructure, but exact prerequisites, launch fees, primary-mint percentages, royalty participation, subscriptions or other commercial terms remain **OPEN**.

Authenticity boundary:
- outside titles are **not Hellbox-native titles**;
- using the Press never grants a Hellbox title stamp, Harrow authorship, Hellbox canon status, native MARK/DEFECT doctrine, native Archive rewards or any implication that Harrow created/endorsed the content;
- use separate registry/template/factory classification or equivalent machine-readable provenance so the Reader/site can distinguish `HELLBOX_NATIVE` from independent Press publications;
- third-party success must never dilute the authenticity test for an official Hellbox release.

Asset/custody boundary:
- outside creators are responsible for their canonical assets and storage;
- supported instructions may cover creator-controlled Cloudflare/R2/CDN, IPFS, Arweave or other approved durable storage;
- Hellbox may validate URIs/hashes and may use non-authoritative caches for performance, but should not become the permanent canonical host/custodian of outsider content by default;
- creators must receive packaging/storage/deployment specifications sufficient to operate without access to Harrow's private authoring machine.

Proprietary boundary:
- outsiders do **not** receive Harrow's proprietary comic-generation, interactive-authoring, prompt, compositor or internal production machinery merely because they use the Press;
- the public contract is the package/interface specification and launch workflow, not Hellbox's private creative factory.

Creator standing:
- a separate website/account-level Harrow reputation/standing system may eventually react to creator performance and repeat launch quality;
- successful creators may earn reluctant/backhanded Harrow respect;
- repeated poor-performing releases may reduce standing;
- standing should be recoverable, explainable and separate from immutable title authenticity/ownership;
- do not put creator reputation into the immutable publication kernel without a later explicit architecture decision.

This future lane belongs to later Press/Reader/account/hardening work. It is **not** a reason to widen Gate 4 V1 or expose the Hellbox-native factory to arbitrary outside publishing.

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
- accepted primary payment asset;
- primary mint price;
- mint phases;
- wallet rules;
- royalty rate/BPS;
- native mint start/deadline where applicable;
- capability policy;
- renderer/version;
- collector-facing closure/authority rules;
- the revenue-routing protocol/controller boundary disclosed for that issue.

After PUBLISH:
- no editable collector-facing release promises;
- no changing that issue's payment asset, mint price, royalty rate, rarity/copy promises or native deadline.

Operational downstream revenue routing may still evolve through the disclosed Hellbox routing authority/protocol: split percentages, destination wallets, reward-token choice and buy/burn/reward strategy are not collector-facing immutable issue fields.

Artifact state may still evolve under the frozen release rules.

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
- frozen supply/wallet/creator/issue-level royalty-rate/authority/capability config; downstream royalty routing remains outside the publication's immutable split logic;
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

Atomic companion deployment wiring is now implemented:

- `HellboxPublicationFactory.publish(...)` transports the three narrow enforcement preimages through a dedicated `BirthPolicyPreimages` structure;
- the factory constructs `HellboxPublication.BirthPolicyDeploymentContext` from its own immutable code-store address/hash plus those preimages;
- the context is constructor-only transport and is **not** part of `ReleaseConfig`, `CommitmentSet` or `HELLBOX_ABI_V1`;
- `HellboxPublication` validates the frozen release configuration/digest before using the policy deployment context;
- the publication requires a nonzero/nontrivial code store whose runtime byte `0` is `STOP`;
- the publication copies only code-store runtime bytes `[1..]` with `EXTCODECOPY`;
- the copied bytes must hash exactly to the factory-generation-approved BirthPolicy creation-code hash;
- the publication builds `HellboxBirthPolicy.PublicationBinding` only from already-validated/frozen publication values and commitment anchors;
- the publication appends the canonical BirthPolicy constructor arguments and executes ordinary `CREATE` itself;
- `birthPolicy` is an immutable publication address with no setter/replacement path;
- BirthPolicy constructor failures/revert data fail the parent publication construction atomically;
- the factory verifies the deployed policy exists and reports `publication()` as the actual publication before official provenance mappings are written.

There is no post-deployment activation setter or temporary configuration window. The `HELLBOX_ABI_V1` golden vector remains unchanged.

## BirthPolicy deployment-size experiment and code-store correction — implemented/proven

A pre-trait-consumption direct publication-constructor `new HellboxBirthPolicy(...)` experiment was compiled and then **rejected/restored without commit** because it consumed too much publication initcode runway. Its numbers are historical evidence for rejecting that topology, not current-policy size measurements:

```text
HellboxPublication runtime after direct embed = 16,411 bytes
HellboxPublication initcode after direct embed = 42,840 bytes
static EIP-3860 margin                       =  6,312 bytes
```

With the current native constructor payload included, the practical CREATE payload was estimated near **47,672 bytes**, leaving only about **1,480 bytes** below the 49,152-byte EIP-3860 ceiling before remaining Gate 4 growth. That topology is not acceptable V1 runway and must not be resurrected as production architecture.

The committed/pushed correction is `contracts/HellboxBirthPolicyCodeStore.sol`:

- immutable code store;
- deployed runtime byte `0` is `STOP`, so ordinary calls are inert;
- deployed runtime bytes `[1..]` are exactly `type(HellboxBirthPolicy).creationCode`;
- no owner, setter, initializer, proxy, `delegatecall`, CREATE2 requirement or upgrade path;
- intended publication path is `EXTCODECOPY` from offset `1`, verify the copied creation-code hash against the approved factory-generation value, append canonical constructor arguments, then have the **publication itself** execute ordinary `CREATE`;
- this preserves `HellboxBirthPolicy.publication = msg.sender` as the actual publication without embedding the policy's creation code in publication initcode.

Focused proof:
- **4/4** code-store tests pass;
- exact runtime layout proven;
- exact stop-prefixed runtime codehash proven;
- copied payload hash equals the BirthPolicy creation-code hash;
- ordinary calls are inert.

Current full post-push regression: **85/85 tests passed, 0 failed**, issuance fuzz boundary **256 runs**.

The code store is now proven **and integrated** infrastructure. Production publication/factory source contains no direct BirthPolicy creation-code embed. The measured native publication `CREATE` payload after integration is **31,665 bytes**, leaving **17,487 bytes** of EIP-3860 headroom.

---

# 26. GATE 4 FACTORY — CURRENT

`contracts/HellboxPublicationFactory.sol`

V1 remains **FULL_DEPLOYMENT**, but its deployment mechanism was corrected after an EIP-170 blocker was discovered.

## Current deployment mechanism

- ordinary EVM `CREATE`;
- no `new HellboxPublication(...)` embedded in factory runtime;
- exact reviewed `HellboxPublication` creation bytecode is supplied to `publish(...)`;
- the factory generation freezes immutable `approvedPublicationCreationCodeHash`, `birthPolicyCodeStore` and `approvedBirthPolicyCreationCodeHash`;
- supplied publication creation bytecode must hash exactly to the approved publication value or deployment reverts;
- zero approved publication hash, zero code-store address and zero approved BirthPolicy creation-code hash are rejected at factory construction;
- `publish(...)` accepts only the three narrow BirthPolicy enforcement preimages as caller transport; callers do not select the code-store address or BirthPolicy creation-code hash;
- the factory ABI-encodes the current `ReleaseConfig`, `CommitmentSet`, expected release digest and narrow `BirthPolicyDeploymentContext`, then appends those constructor arguments to the approved publication creation bytecode;
- because the factory itself executes `CREATE`, the publication constructor still observes the approved factory as `msg.sender`;
- the publication independently recomputes and validates the `HELLBOX_ABI_V1` release digest;
- the publication then verifies/copies the approved BirthPolicy creation code and creates its own immutable companion;
- the factory verifies the publication ↔ BirthPolicy relationship before provenance state becomes official.

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

After moving reviewed publication creation bytecode out of factory runtime and later adding the factory-generation BirthPolicy bindings + atomic companion wiring:

```text
HellboxPublicationFactory runtime = 9,423 bytes
EIP-170 limit                    = 24,576 bytes
runtime margin                   = +15,153 bytes
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

## Factory/publication/BirthPolicy deployment boundary — WIRED / PROVEN

Current companion facts:

- `HellboxBirthPolicy` is a non-upgradeable per-publication companion;
- it is constructor-configured only;
- its constructor permanently sets `publication = msg.sender`;
- it narrowly decodes the fixed-copy, birth-trait and randomization policy preimages and independently verifies each digest;
- it validates/stores inventory, fixed reservations and randomization-policy boundaries;
- it exposes policy/inventory/birth-identity views plus one narrow `assignBirthIdentity(tokenId, entropyWord)` enforcement endpoint callable only by its permanently bound publication;
- it has no publisher/admin setter, reroll, replacement, upgrade or generic execution surface;
- successful immediate creator, normal non-tail and Final-3 issuance consume and store immutable birth identity atomically.

Implemented deployment graph:

```text
approved factory generation
  ├─ approvedPublicationCreationCodeHash
  ├─ birthPolicyCodeStore
  └─ approvedBirthPolicyCreationCodeHash
        ↓
factory ordinary CREATE of reviewed publication
        ↓
HellboxPublication constructor
        ↓ EXTCODECOPY code-store bytes [1..]
        ↓ exact creation-code hash verification
        ↓ canonical BirthPolicy constructor args
        ↓ publication-owned ordinary CREATE
HellboxBirthPolicy
publication = msg.sender = actual HellboxPublication
```

Proven safeguards:

- code-store runtime must be nontrivial and start with inert `STOP`;
- copied BirthPolicy creation bytes must hash exactly to the factory-generation-approved value;
- the three preimages must satisfy the already-frozen policy digests or the whole publication deployment reverts;
- malformed, short, non-STOP or wrong-hash stores revert atomically;
- the publication exposes exactly one immutable companion address with no setter/replacement path;
- the factory verifies the companion exists and points back to the publication before provenance mappings are written;
- SciVive's trait-disabled shape deploys through the same reviewed publication version;
- production source does not directly embed `HellboxBirthPolicy` creation code;
- measured native publication practical initcode/payload is **31,665 bytes** with **17,487 bytes** of EIP-3860 headroom;
- `HellboxPublication` runtime is **16,411 bytes** and factory runtime is **9,423 bytes** under the current unoptimized Shanghai build.

This wiring changed only pre-deployment constructor/call transport needed for the companion. It did **not** change the frozen `ReleaseConfig`/`CommitmentSet` field order or `HELLBOX_ABI_V1` fingerprint.

Do not add a post-deploy policy setter/initializer/activation window. Do not add a generic arbitrary constructor-data escape hatch. Do not reintroduce direct BirthPolicy creation-code embedding merely for convenience.

---

# 27. GATE 4 VERIFIED BIRTH-TRAIT ENFORCEMENT + NEXT RANDOMNESS/CLOSURE FRONTIER

The deterministic internal issuance accounting core, deployment-time enforcement anchors, modular BirthPolicy, inert code store, atomic publication-owned companion deployment and one-time per-token MARK/DEFECT consumption are now implemented, tested, committed and pushed without selecting the final production randomness provider or exposing a collector mint endpoint.

## Implemented / tested

Current `HellboxPublication` proves or represents:

- frozen max-supply accounting;
- `candidatePoolRemaining` and separate `nonTailIssuanceRemaining`;
- standard native `210 / 207` initialization;
- immediate creator-copy reservation/issuance ordering;
- normal issuance blocked until the immediate allocation is complete;
- sparse remaining-candidate bookkeeping and unique in-range draws;
- #066 remains candidate-eligible until actually drawn;
- lifetime primary wallet accounting that transfer/burn cannot restore;
- true-mintout detection and literal final-three tail award;
- SciVive reuse without native-216 trait assumptions;
- deterministic entropy-word/test-double boundary without selecting production entropy;
- canonical enforcement domains/digest anchors and immutable BirthPolicy provenance;
- internal issuance-time calls into the bound BirthPolicy for immediate creator, normal non-tail and Final-3 copies;
- atomic inventory accounting: pending immediate copies plus candidate pool must equal enabled-axis remaining inventory;
- failed assignment reverts candidate removal, wallet usage, issuance counters and trait inventory together.

Current `HellboxBirthPolicy` proves or represents:

- versioned `BIRTH_POLICY_VERSION = 1` / `MODULE_ID = keccak256("HELLBOX_BIRTH_POLICY")`;
- constructor-only configuration and permanent `publication = msg.sender` binding;
- no proxy, initializer, ownership/admin or publisher mutation surface;
- one narrow publication-only `assignBirthIdentity(tokenId, entropyWord)` enforcement endpoint;
- independent verification of fixed-copy, birth-trait and randomization policy preimages;
- native MARK inventory `6 / 12 / 18 / 180` and DEFECT inventory `6 / 12 / 18 / 24 / 156`;
- exact one-time consumption of Harrow #001–#006 fixed MARK reservations;
- shared-random creator DEFECT consumption;
- #066 fixed HELLBOUND reservation protected from unrelated random draws and consumed only when #066 is drawn;
- one permanent MARK and one permanent DEFECT for each applicable native copy;
- independent MARK/DEFECT entropy derivation domain-separated by the frozen randomization-policy digest, publication, token ID and axis;
- random assignment that excludes still-reserved fixed-copy inventory;
- permanent `birthIdentityAssigned`, `birthMark` and `birthDefect` token state with duplicate/reroll rejection;
- authoritative remaining-inventory views after each successful assignment;
- trait-disabled SciVive assignment that records zero/zero identity without inventing traits.

Current verification includes:

- **85/85** full Solidity regression;
- **21/21** factory/provenance/atomic-deployment tests;
- **21/21** dedicated `HellboxBirthPolicy` tests;
- **4/4** dedicated immutable code-store tests;
- **9/9** publication policy-anchor tests;
- **13/13** deterministic issuance/atomic-trait tests;
- **16/16** publication-kernel tests;
- **1/1** Solidity↔JavaScript golden-vector test;
- issuance fuzz boundary **256 runs**;
- current unoptimized Shanghai runtimes: publication **16,411 bytes**, factory **9,423 bytes**, BirthPolicy **9,123 bytes**; actual deployed code-store runtime **20,609 bytes** with **3,967 bytes** of EIP-170 headroom (compiler-reported nominal runtime stub **62 bytes**);
- BirthPolicy initcode **20,608 bytes** and code-store creation size **20,871 bytes**;
- measured native publication `CREATE` payload **31,665 bytes** with **17,487 bytes** EIP-3860 headroom;
- `HELLBOX_ABI_V1` structure unchanged;
- production direct BirthPolicy creation-code embeds: **0**.

The on-chain remaining inventories are now authoritative state. The public Press/API presentation of those values and user-facing next-pull odds is still future interface work; it must read the enforced values rather than reconstructing an independent rarity ledger.

## Not implemented yet — do not overclaim

The current code does **not** yet complete:

- the production entropy request/fulfillment/reveal/fallback mechanism;
- manipulation-resistant unpredictability for public collector copy assignment;
- native timed-expiry closure when more than three candidates remain;
- unbiased expiry Final-3 selection and permanent extinguishment of every non-selected candidate;
- phase eligibility enforcement;
- V1 `FREE` / exact `FIXED_PLS` payment enforcement and over/underpayment behavior;
- the public collector mint endpoint;
- the stable primary-proceeds routing boundary for paid mints;
- public Press/API display of authoritative live inventory/odds;
- PulseChain Testnet V4 end-to-end collector mint acceptance.

## Exact next engineering objective

Before another major Solidity file is written, complete a focused Gate 4 architecture/research checkpoint for **production randomness + native timed closure**.

That checkpoint must:

1. compare viable PulseChain-compatible entropy mechanisms, dependencies, cost, latency, liveness and manipulation surfaces;
2. define request/fulfillment/fallback behavior for ordinary candidate assignment and native timed-expiry Final-3 selection;
3. preserve deterministic local tests while preventing caller, publisher, validator or operator choice of valuable copy IDs/traits;
4. define safe timeout/provider-failure behavior that fails closed rather than substituting timestamp, caller input or another manipulable source;
5. preserve #066 participation and actual `candidatePoolRemaining` denominators;
6. prove timed expiry awards exactly three through the approved unbiased boundary and permanently extinguishes every other unminted candidate;
7. preserve SciVive's timer/Final-3 exemption;
8. keep `HELLBOX_ABI_V1`, Archive/reward logic, Reader progress and interactive game state unchanged;
9. identify the exact first implementation file and its isolated focused/full validation plan;
10. keep collector minting closed until randomness, phase, payment and closure enforcement are all test-backed.

After that architecture checkpoint is locked, implement the remaining Gate 4 mint lifecycle **one file and one Bash at a time**.

Do not build:
- Archive rewards;
- Hellforge recipes;
- Gate 5 Press UX;
- Gate 6 renderer/interactive package pipeline;
- future creator Press leasing;
- token economics.

---

# 28. GATE 4 OPEN TECHNICAL DECISIONS

Still open:

1. production randomness/entropy request/fulfillment/reveal/fallback mechanism, including unbiased Final-3 selection at native timed expiry when more than three candidates remain;
2. exact native timed-closure transaction trigger/liveness model;
3. optimizer/runs/via-ir;
4. metadata renderer transport/interface details;
5. future external-protocol binding mechanics;
6. revenue-router implementation, authority model and gated Harrow operational controls;
7. future additional payment-token architecture beyond current V1 FREE/FIXED_PLS scope.

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
- schema-driven forms rather than duplicated freehand configuration;
- validation;
- generated risk/scope/immutability summary;
- immutable freeze preview;
- dry-run using the same package/deployment path as production;
- deliberate publish transaction;
- deployment verification;
- generated release runbook/report.

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

Later independent-creator Press work must be designed as a **separate non-native lane** after Hellbox's own Press is mature:
- separate authenticity/registry/template classification from Hellbox-native titles;
- documented package/storage/deployment requirements for outside creators;
- creator-controlled canonical asset hosting;
- Reader compatibility for conforming outside titles;
- no access to Harrow's proprietary generation/authoring machinery;
- exact fees, prerequisites and royalty/mint participation remain open;
- creator standing/reputation remains account/site-level, not publication-kernel authenticity.

## Gate 6 — ingest / package / interactive narrative / dynamic metadata / rendering

This Gate now carries the largest implementation expansion created by the interactive-comic decision.

Blueprint must define:
- package schema;
- canonical single-source issue manifest;
- solo-operator scope budget;
- reusable room/interaction component library;
- cover + Reader inputs;
- finite authored narrative-graph schema;
- story-stage/node identity;
- allowed branch transitions and reconvergence;
- escape-room manifests;
- authoritative room timer/death rules;
- choice/consequence definitions;
- ideal/alternate/death ending definitions;
- progress/run-state schema and save/restore behavior;
- trait-conditioned MARK/DEFECT interactions;
- ordinary-copy fairness validation;
- achievement/certificate inputs;
- validation that all reachable paths are authored and no canonical runtime-AI generation is required;
- validation for unreachable nodes, impossible rooms, accidental dead ends and broken transitions;
- exhaustive machine route coverage for every reachable authored path/variant combination within the issue budget;
- generated playtest matrix and coverage gaps;
- deterministic seed/fixture support for reproducing every authored variant during testing;
- MARK/DEFECT visual layer format;
- deterministic compositor;
- randomness/render boundary;
- metadata/artifact-state renderer;
- marketplace refresh;
- reproducibility;
- protected Reader ingest;
- durability/fallback.

AI-assisted authoring/build/test tools are required as practical leverage where they materially reduce Harrow's workload, but every output remains subject to schema/test/human approval and the published runtime graph remains finite and pre-authored.

Gate 6 must leave Harrow with a reusable authoring/compiler system, not a pile of issue-specific scripts that only work for Native Issue #1.

## Gate 7 — artifact protocols

Split into sub-checkpoints:
- Seal/Archive;
- rarity-weighted official Archive reward accounting;
- Harrow #001–#006 six-year reward-delay enforcement;
- ERC-6551;
- permanent experience/incident/history state;
- archived-state protection from experience marking;
- contextual traits;
- Hellforge/burn/evolution;
- explicit review of any future burn-to-reward-power interaction without changing birth rarity.

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

## Gate 9 — freeze / audit / hardening / content / operations

- content/code freeze;
- accessibility;
- localization;
- responsive/browser/device matrix;
- privacy/consent;
- performance budgets;
- analytics/SEO/legal;
- threat model;
- fuzz/invariant/static analysis;
- targeted independent security review;
- reward/token/economic specialist review if those systems are active;
- metadata/content continuity;
- publisher continuity plan;
- multi-RPC/provider failure drills;
- Cloudflare/D1/R2 outage behavior;
- key/authority separation review;
- automated backup/export schedules;
- full restore drill from documented artifacts;
- incident/maintenance runbooks;
- Native Issue #1 content/playtest readiness;
- proof that one operator can execute the release safely from the runbook.

## Gate 10 — mainnet release candidate

- exact deployment runbook;
- deterministic dry-run;
- transaction simulation;
- production versions/config;
- explicit abort points;
- monitoring/alerts;
- backup/export checkpoint;
- post-deployment verification command/report;
- SciVive production;
- Native Issue #1 only after full hard release barrier;
- no production release that requires improvised Terminal work not present in the approved runbook.

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
- V1 FREE/FIXED_PLS payment behavior and frozen per-issue PLS price;
- native `66d 6h 6m 6s` deadline/closure with SciVive exemption;
- Harrow Final 3 survive timed expiry while all other unused native capacity is permanently extinguished;
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
- finite pre-authored narrative graph with one ideal surviving ending, at least one alternate surviving ending and authored death outcomes;
- progressively harder escape-room curve validated by human playtesting;
- server-authoritative saved progress/timer behavior with an approved platform-outage policy;
- ordinary/common copies can complete the core story and ideal ending;
- intended MARK/DEFECT-specific interactions work without pay-to-win gating;
- transfer/new-owner run-state behavior is explicitly resolved;
- archived copies cannot acquire experience marks while archived;
- rarity-weighted Archive reward boundary remains external/modular;
- Harrow #001–#006 six-year zero-reward eligibility is machine-enforced if rewards are active;
- compatibility with later finite authored interactive Reader packages without embedding game logic in the publication kernel;
- deterministic issue rebuild, route coverage report and asset/hash manifest;
- accessibility/performance/device acceptance;
- documented backup/restore and solo-operator release runbook;
- successful clean-room recovery drill from documented backups;
- proof that one ordinary operator can execute the approved release runbook safely without improvised developer-only steps;
- clear irreversible warnings.

Gate 4 does **not** have to implement the narrative graph, escape rooms, timer engine, saved runs, achievements or rarity-weighted reward formula. It must preserve the clean boundaries those later systems need.

---

# 32. SECURITY / CASH-FLOW STANDARD

Hellbox cannot require a new audit for every ~$6.66 issue.

Security cost is amortized across reusable reviewed versions/modules.

Use:
- pinned OpenZeppelin;
- established ERCs;
- small custom Solidity;
- AI-assisted review as one layer, never as the sole audit;
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

Any future project-used/reward-token launch or endorsement, revenue-sharing language, buy/burn mechanics and rarity-weighted reward marketing require specialist legal/tax review when they become concrete. Token-control/launch facts and material project holdings/relationships must be described accurately. Those systems may be delayed or disabled without blocking the comic/ownership platform.

ERC-2981 expresses royalty information; it does not guarantee every marketplace will enforce or pay royalties. Do not model secondary royalties as guaranteed cash flow.

The comic/artifact must remain worth owning if:
- the future reward token has no value or never launches;
- secondary royalties are zero;
- resale liquidity is poor;
- Archive emissions are reduced or paused.

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

# 35. SOLO-OPERATOR / LOW-COST / RELIABLE OPERATIONS

Hellbox is a solo, part-time creator project and must not require a staffed studio, 24/7 operator, permanent DevOps team or a specific computer remaining online.

## 35.1 Cost discipline

Prefer:
- Cloudflare Worker/static;
- D1;
- R2;
- managed/serverless services over servers Harrow must patch;
- no always-on app server unless required;
- no expensive indexer initially;
- no CMS unless justified;
- direct-to-R2 large upload paths;
- lazy Reader delivery;
- reusable publication versions;
- event-driven automation that scales down when idle;
- one authoritative source per configuration domain.

Do not create infrastructure cost because a larger company would.

Cost savings must not remove:
- backups;
- monitoring;
- security;
- deterministic builds;
- recovery;
- authoritative ownership/progress state.

## 35.2 No daily-human-operator requirement

Normal operation must continue while Harrow is working, asleep, offline or unavailable.

Avoid systems that require:
- manual mint closure;
- daily reward calculations;
- hand-updated prices;
- manual ownership approvals;
- manual puzzle-progress correction;
- constant server supervision;
- daily dashboard maintenance;
- a specific workstation remaining online.

Time/state transitions should execute deterministically from frozen rules or be safely callable by automation/anyone where appropriate.

If a critical service is unhealthy, unsafe writes should pause/fail closed rather than require Harrow to notice immediately.

## 35.3 Required operational runbooks before mainnet

Maintain concise, executable runbooks for:

- new trusted-workstation/repository bootstrap;
- website/Worker deployment and rollback;
- contract-version deployment;
- Testnet/mainnet publication;
- publication-package build and verification;
- Reader/narrative package build and upload;
- D1 backup/export and restore;
- R2 manifest/inventory verification and restore;
- RPC/provider failover;
- publishing/treasury authority rotation;
- compromised-key response;
- Cloudflare/vendor outage;
- unsafe-write/read-only mode;
- failed mint/publication transaction;
- content/package correction before PUBLISH;
- dependency update;
- incident recording/postmortem.

A runbook must contain commands/checks and expected evidence, not merely prose saying "restore the database."

## 35.4 Backup and clean-room recovery standard

GitHub is not the only backup.

Before mainnet, Hellbox must have:
- repository mirrors/backups;
- reproducible dependency/version locks;
- D1 exports/backups;
- R2 object manifests and content hashes;
- publication/source-package backups;
- infrastructure configuration records;
- offline-secured recovery material for critical accounts/authorities;
- a written restore order.

Hard release barrier:

> **No Native Issue #1 mainnet release until a clean-room recovery drill can rebuild the public platform and recover authoritative publication/Reader data from documented backups.**

A backup that has never been restored is unproven.

## 35.5 Monitoring and bounded failure

Before mainnet establish one low-noise operational view covering:
- website/API health;
- Worker/D1/R2 health;
- RPC/provider health;
- ownership-critical paths;
- publication/mint failures;
- Reader/package delivery;
- narrative timer/progress service when interactive comics exist;
- unusual authority/configuration changes.

Alerts should identify:
- what failed;
- whether reads remain safe;
- whether writes are disabled;
- which runbook applies.

Do not create alert noise that trains a solo operator to ignore it.

## 35.6 Authority and irreversible-operation safeguards

Before mainnet:
- use hardware-backed signing for production authorities;
- separate publishing, routing/treasury and application authority where practical;
- simulate irreversible transactions before execution;
- use deliberate two-step rotations where supported;
- keep secrets out of Git, AI chats, logs and screenshots;
- preserve durable audit evidence for production changes.

AI may prepare or verify an operation. It may not receive signing secrets or unilaterally execute it.

## 35.7 Automation priority

Automate in this order:

1. correctness-critical repetition;
2. release/deployment verification;
3. graph/path/content validation;
4. backups/restores;
5. monitoring/alerts;
6. asset-production repetition;
7. convenience.

Do not automate an unstable process before its invariants are understood. Once stable, do not keep performing it manually.

## 35.8 Incident principle

When authoritative truth is unavailable:

```text
PAUSE / FAIL CLOSED / PRESERVE EVIDENCE
```

Do not guess ownership, randomness, mint eligibility, payment state, room completion or reward balances.

A known platform-wide Hellbox outage must not automatically cause mass timed-room deaths. Exact incident-clock behavior remains later Reader engineering, but the system must distinguish platform failure from an individual user's failure.

## 35.9 AI operational leverage

Use AI to:
- generate/check manifests;
- prepare focused commands;
- compare backups/inventories;
- summarize incidents;
- validate runbooks against current configuration;
- generate test cases;
- inspect graph/package inconsistencies;
- prepare model-independent handoffs.

AI must operate through explicit, reviewable artifacts/commands and cannot become a hidden always-on control plane.


## 35.10 INTERACTIVE OWNER-EXPERIENCE IMPACT ON CURRENT GATE 4

This newly locked product direction does **not** invalidate the current Gate 4 kernel/factory/BirthPolicy work.

No current reason exists to change `HELLBOX_ABI_V1` because:
- the publication/package/Reader commitment envelope can bind a later canonical narrative/package manifest;
- ownership remains ERC-721 `balanceOf`;
- MARK/DEFECT remain immutable birth inputs;
- dynamic metadata/artifact-state compatibility already exists;
- Archive/reward protocols remain modular/external;
- the publication contract does not need to execute puzzles, store branch progress or know the future reward token.

Gate 4 must therefore avoid:
- linear-page-only on-chain assumptions;
- runtime-AI dependencies;
- reward-weight formulas;
- experience-mark mutators;
- game-progress storage in the publication.

The code-store/BirthPolicy atomic deployment wiring and publication-only per-token MARK/DEFECT assignment/consumption inside the internal issuance state machine are now complete. The immediate Gate 4 frontier is the production-randomness/native-timed-closure architecture checkpoint, followed by one-file implementation of phase, V1 payment and public collector mint enforcement.

---

# 36. ACTIVE RISK REGISTER / PRE-ENGINEERED RESPONSES

These risks are not excuses to stop. They define the systems Hellbox must build so predictable failures remain contained.

## 36.1 Scope explosion / failure to ship — GUARANTEED PRESSURE

Risk:
- ideas, branches, traits, rooms and protocols expand faster than one creator can finish them.

Prevent:
- mandatory Gate/issue scope budget;
- branch reconvergence;
- reusable room/trait components;
- one ideal ending + controlled alternate/death outcomes rather than unlimited fan-out;
- explicit backlog for good ideas outside the current budget;
- one-file/one-checkpoint implementation.

Trigger:
- path/asset count exceeds declared budget;
- validation coverage becomes incomplete;
- a new feature requires new custom Solidity or issue-specific infrastructure.

Response:
- cut, reconverge, reuse or move the idea to a later issue;
- never preserve scope by lowering security, accessibility, testing or editorial quality.

## 36.2 Harrow/solo-operator bottleneck and bus factor — GUARANTEED

Risk:
- project operation depends on one person's memory, energy or uninterrupted availability.

Prevent:
- canonical manifests;
- scripts/compilers/runbooks;
- living documents;
- deterministic builds;
- generated reports;
- scheduled backups;
- no undocumented production steps.

Response:
- stop and document/automate any process that repeatedly requires memory or improvisation;
- reduce release scope before adding permanent staff-like operational burden;
- maintain a handoff package another competent engineer can execute.

## 36.3 Interactive narrative combinatorial explosion — GUARANTEED WITHOUT CONTROL

Risk:
- branch tree, room variants and MARK/DEFECT combinations become impossible to author/test.

Prevent:
- graph, not infinite tree;
- declared max branch width;
- reconvergence;
- base stage + modular trait intervention;
- exhaustive machine reachability/coverage;
- deterministic fixtures for every variant.

Response:
- reject any route set that cannot be exhaustively validated;
- consolidate branches or reduce trait interventions;
- ship fewer stronger differences.

## 36.4 AI-assisted production quality / canon / rights risk

Risk:
- AI output is inconsistent, derivative, legally unclear, visually off-model or impossible to reproduce.

Prevent:
- AI policy;
- human approval;
- canonical source package;
- asset provenance/licensing records;
- character/canon references;
- deterministic final build;
- no runtime canonical generation.

Response:
- reject/rebuild questionable assets;
- do not PUBLISH until rights/provenance and visual/canon review pass;
- treat AI conversations as disposable assistance, not authoritative source.

## 36.5 Puzzle quality and frustration risk

Risk:
- rooms are technically clever but unfair, tedious, inaccessible or not fun.

Prevent:
- progressive difficulty;
- tutorialized interaction language;
- human playtests;
- telemetry after launch where privacy-appropriate;
- authored hints/accessibility;
- timer begins only after assets load and explicit entry.

Response:
- revise before PUBLISH;
- cut a weak room rather than protect sunk cost;
- future issues improve reusable components, but a published issue's frozen puzzle package is not silently rewritten unless the publication rules explicitly permit a non-canonical operational fix.

## 36.6 Spoilers, collaboration, screenshots and datamining — GUARANTEED

Risk:
- solutions/assets leak; players share answers.

Prevent/position:
- community collaboration is intentional;
- value is ownership, authenticated progression, artifact state and experience—not impossible DRM;
- use pre-authored validated variants where they improve replay/spoiler resistance;
- do not make secrecy the only difficulty mechanism.

Response:
- do not enter an anti-cheat arms race that overwhelms a solo project;
- adjust future issues/variants and community design rather than pretending pixels cannot leak.

## 36.7 Timer, browser, device and platform-outage fairness

Risk:
- crash, suspension, latency or provider outage causes unfair death/progress loss.

Prevent:
- prefetch assets;
- explicit room entry;
- authoritative server timestamp;
- idempotent transition writes;
- saved progress;
- platform incident detection;
- documented pause/maintenance policy.

Response:
- platform-wide failure must not mass-kill runs;
- preserve evidence and resume/repair under the approved incident rule;
- individual connectivity failure follows the issue's disclosed rules.

## 36.8 Client cheating / progress forgery

Risk:
- localStorage, modified JavaScript or replayed requests claim rooms/choices were completed.

Prevent:
- Worker/D1 authoritative transitions;
- signed wallet sessions;
- one-way state transitions;
- nonce/idempotency protections;
- server validation of legal graph edges/timers;
- browser remains presentation/cache only.

Response:
- reject invalid transitions;
- revoke compromised sessions;
- preserve audit evidence;
- never let frontend flags grant ownership, rewards or completion.

## 36.9 NFT transfer / run privacy / token-history ambiguity

Risk:
- a buyer inherits spoilers/progress; private choices become public; token history and wallet run state are conflated.

Prevent:
- explicit separation of `publication + tokenId + wallet + runId` private run state from deliberately public artifact history;
- define transfer behavior before interactive Reader mainnet.

Response:
- do not ship until new-owner start/resume rules and privacy boundaries are tested;
- default to protecting private run choices unless explicitly disclosed otherwise.

## 36.10 Immutable-contract bug / code-size / deployment failure

Risk:
- non-upgradeable mainnet bug or EIP-170/EIP-3860 boundary failure.

Prevent:
- small versioned modules;
- OpenZeppelin;
- unit/fuzz/invariant/static/adversarial tests;
- exact-byte hashes;
- Testnet campaign;
- external review after freeze;
- measure sizes/payload after every major wiring change.

Response:
- pre-mint: abandon bad deployment/version and deploy reviewed successor;
- post-mint: do not seize/rewrite collector NFTs; disable only optional unsafe platform paths where possible and fix future versions.

## 36.11 Randomness / Final-3 manipulation

Risk:
- Harrow, miner/validator, publisher or attacker influences valuable copy/trait/tail assignment.

Prevent:
- production entropy abstraction;
- no timestamp/manual-wallet pseudo-randomness;
- committed failure/fallback policy;
- unbiased timed-expiry selection;
- adversarial tests.

Response:
- pause mint/closure rather than switch silently to manipulable entropy;
- do not let Harrow select Final 3 or rare copies.

## 36.12 Reward economics / regulatory / sustainability risk

Risk:
- rewards dominate the comic, become unsustainable, create self-dealing optics or trigger legal/tax problems.

Prevent:
- external versioned reward module;
- no reward token/formula in publication kernel;
- six-year zero reward for Harrow #001–#006;
- capped/adjustable operational budgets;
- specialist review when economics become concrete;
- market the artifact/experience, not guaranteed profit.

Response:
- delay, reduce, pause or redesign rewards without invalidating ownership/comics;
- launch core platform without a reward token if necessary;
- assume secondary royalties and token value may be zero.

## 36.13 Archive-versus-experience imbalance

Risk:
- reward value becomes so high that owners never unseal rare copies, wasting the interactive work.

Prevent:
- model reward magnitude before Gate 7;
- make experience/collectible meaning valuable;
- avoid APY-style promises;
- monitor sealed/archive/unseal behavior.

Response:
- adjust future external reward budgets/strategies;
- do not alter published birth rarity or force owners to unseal.

## 36.14 Burn incentive risk

Risk:
- premature burn mechanics create perverse scarcity, reward or permanence incentives.

Prevent:
- burn/reward interaction remains open;
- external modifier distinct from MARK/DEFECT;
- scenario/economic simulation before approval;
- explicit owner authorization and warnings.

Response:
- postpone burn economics;
- never use burn as a repair mechanism for bad tokenomics.

## 36.15 PulseChain / RPC / ecosystem dependency

Risk:
- RPC outages, explorer weakness, chain congestion, low NFT liquidity or limited user base.

Prevent:
- multiple RPCs/providers;
- health checks;
- bounded ownership cache/evidence;
- fail-closed writes;
- comic has standalone value beyond resale;
- no bridge dependency.

Response:
- pause unsafe writes/mints;
- use documented degraded read behavior only;
- do not guess chain truth.

## 36.16 Cloudflare / D1 / R2 / DNS vendor failure

Risk:
- managed-service outage or account loss interrupts Reader/progress/publication delivery.

Prevent:
- content hashes;
- exports/backups;
- portable source packages;
- restore drills;
- provider boundaries;
- maintenance state;
- operational continuity plan.

Response:
- restore from verified manifests/exports;
- serve durable fallback where approved;
- do not claim recovery capability until tested.

## 36.17 Content leakage / DRM expectations

Risk:
- protected comic pages, audio or puzzle assets are copied.

Prevent:
- honest ownership gating;
- no false DRM promise;
- authenticated state/experience/provenance provide value beyond hidden bytes.

Response:
- enforce access reasonably;
- investigate breaches;
- do not redesign the project around impossible perfect secrecy.

## 36.18 Wallet, secret and operational-key compromise

Risk:
- publishing, treasury/router or infrastructure credentials are stolen.

Prevent:
- hardware-backed keys;
- separate roles/authorities;
- least privilege;
- no secrets in repo/AI chat;
- short sessions;
- monitored authority changes;
- deliberate two-step rotations where supported.

Response:
- revoke/rotate compromised operational credentials;
- pause affected writes;
- preserve chain/audit evidence;
- publication contracts retain no seizure power.

## 36.19 Performance / accessibility / device fragmentation

Risk:
- experience works on Harrow's workstation but fails on phones, slow connections or assistive technology.

Prevent:
- asset/performance budgets;
- progressive loading;
- input abstraction;
- reduced-effects mode;
- captions/transcripts;
- keyboard/touch/accessibility validation;
- device/browser matrix;
- assisted completion where needed without hiding core ownership.

Response:
- reduce effects/assets before excluding owners;
- distinguish optional prestige achievements from basic accessibility.

## 36.20 Mobile app-store policy risk

Risk:
- Apple/Google rules constrain wallet, NFT or payment behavior.

Prevent:
- web remains first-class;
- native app is a client of shared APIs/state;
- mint/payment path separable from Reader/Archive;
- no mobile-only required puzzle unless explicitly sold that way.

Response:
- ship Reader/Archive capabilities within allowed policy and keep minting on web if necessary.

## 36.21 Project becomes impossible to explain

Risk:
- technical depth obscures the simple reason to care.

Prevent:
- public proposition stays simple;
- advanced systems are discovered after ownership;
- marketing leads with comics/artifacts/experience, not protocol diagrams.

Response:
- simplify public language, not the integrity of the underlying system.

## 36.22 Current technical debt / incomplete systems

- `app.js` large/monolithic;
- `src/index.js` large/monolithic;
- historical CSS overrides;
- final Press art/UX not built;
- final widescreen tuning deferred;
- positive real SciVive owner still waits for Gate 4 Testnet deployment/mint;
- public Press/API presentation of the now-authoritative on-chain MARK/DEFECT inventory/odds is not yet wired;
- production random assignment provider is unresolved, including timed-expiry Final-3 selection;
- phase eligibility, V1 FREE/FIXED_PLS payment enforcement and public collector mint endpoint are not yet implemented;
- full dynamic renderer not built;
- revenue-routing controller/gated operational split management not yet implemented;
- Archive rewards/ERC-6551/Hellforge remain later Gates;
- interactive narrative graph/runtime, room timer authority, saved-run state and path-validation tooling are not built yet;
- trait-specific Reader interaction rules/content tooling are not built yet;
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
- exact MARK/DEFECT Archive weight table and combination formula;
- reward-token identity/tokenomics/distribution and Archive reward emissions/formulas;
- exact commercial model/prerequisites for the future independent-creator Press lane, including launch fee versus mint/royalty participation;
- exact independent-creator package tiers, supported external storage providers and Reader compatibility contract;
- creator-standing/reputation signals, recovery rules and Harrow-facing presentation;
- exact facts/controls/disclosure model for any future Hellbox-endorsed ecosystem token and whether it is distinct from any Archive reward asset;
- exact burn-to-reward interaction, if any;
- exact experience-mark taxonomy and which marks are private run state versus permanent token history;
- exact interactive-comic room timers, hint system, retry/new-run behavior and anti-spoiler/variant strategy;
- exact achievement/certificate format;
- exact per-issue scope-budget values and playtest thresholds;
- exact platform-wide timed-room outage/pause policy;
- exact backup retention/export schedule and recovery target;
- exact operational authority/key separation before mainnet;
- Hellforge recipes;
- Native Issue #1 exact title/content/narrative graph/rooms/endings/frozen PLS price/royalty rate/phases.

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

Then:
- run the session-resume repository preflight;
- inspect the actual implementation files relevant to the immediate frontier;
- verify the source hash before proposing replacement bytes;
- run the mandatory internal engineering checkpoint before writing a major file.

If implementation evidence is newer than stale progress prose, preserve the working implementation and synchronize the docs; do not backtrack.

The handoff must be model-independent. No AI may require Harrow to remember what another AI meant or reconstruct state from an old conversation.

Do not ask Harrow to re-explain project architecture.

---

# 39. CONTEXT-LIMIT PROCEDURE

Do not keep coding until a chat collapses.

At a clean checkpoint:

1. stop at a file/behavior boundary rather than halfway through an unverified multi-file change;
2. run tests/validators;
3. record exact hashes/counts/sizes/evidence;
4. commit/push if appropriate;
5. record any intentionally uncommitted file names and exact hashes;
6. independently rebuild affected authoritative documents in dependency/authority order;
7. run cross-document contradiction sweeps;
8. install the finished documentation set through one atomic ZIP/Bash when safe;
9. update Harrow Bible only if canon changed;
10. preserve or generate any runbook/status artifact needed to resume without Terminal scrollback;
11. open a fresh chat using the root-document handoff order.

When a work session ends unexpectedly:
- leave no assumed background task;
- on resume rerun read-only state checks;
- never use Terminal scrollback as the only record of unfinished work.

Do not archive/replace the current Gate blueprint merely because chat context changed. Archive it only at formal Gate close.

Context exhaustion or real-world interruption is a handoff event, not a reason to lose architecture.

---

# 40. EXACT NEXT ACTION

Current committed/pushed code checkpoint:

```text
publication kernel                     implemented / passing
HELLBOX_ABI_V1 golden vector          implemented / passing
deterministic issuance core           implemented / passing
policy preimage digest anchors        implemented / passing
modular HellboxBirthPolicy            implemented / passing
immutable inert BirthPolicy code store implemented / passing
factory-generation policy store/hash binding implemented / passing
atomic publication-owned BirthPolicy CREATE implemented / passing
publication ↔ companion provenance    implemented / passing
publication-only birth assignment     implemented / passing
creator fixed-MARK consumption        implemented / passing
shared-random creator DEFECTS         implemented / passing
#066 reservation + candidate behavior implemented / passing
issuance ↔ inventory conservation     implemented / passing
immutable per-token birth identity    implemented / passing
publication runtime                   16,411 bytes
publication EIP-170 margin            +8,165 bytes
publication creation size             26,737 bytes
birth-policy runtime                   9,123 bytes
birth-policy EIP-170 margin           +15,453 bytes
birth-policy initcode                 20,608 bytes
birth-policy EIP-3860 margin          +28,544 bytes
factory runtime                        9,423 bytes
factory EIP-170 margin                +15,153 bytes
factory creation size                 10,499 bytes
code-store compiler runtime stub          62 bytes
code-store actual deployed runtime     20,609 bytes
code-store actual EIP-170 margin       +3,967 bytes
code-store creation size               20,871 bytes
code-store EIP-3860 margin            +28,281 bytes
native publication CREATE payload     31,665 bytes
native EIP-3860 payload headroom      +17,487 bytes
factory/atomic suite                    21 passed / 0 failed
BirthPolicy focused tests               21 passed / 0 failed
issuance/trait focused tests             13 passed / 0 failed
code-store focused tests                 4 passed / 0 failed
Solidity regression                    85 passed / 0 failed
issuance fuzz                          256 runs passed
```

The next action is **not to open a collector mint endpoint yet**. First complete the production-randomness/native-timed-closure architecture checkpoint required by Section 27 and the active Gate 4 blueprint.

The research/review must resolve or explicitly preserve:

- normal candidate-assignment entropy request/fulfillment/fallback;
- unbiased native-expiry Final-3 selection when more than three candidates remain;
- liveness, timeout and provider-failure behavior;
- manipulation resistance against collector, publisher, operator and validator influence;
- cost/dependency impact on PulseChain Testnet V4 and future mainnet;
- deterministic Foundry test-double compatibility;
- no timestamp/caller/manual fallback;
- exact first one-file implementation checkpoint after the architecture decision.

The already-proven trait invariants must remain intact:

```text
after Harrow immediate #001-#006:
candidatePoolRemaining   = 210
nonTailIssuanceRemaining = 207
MARK inventory remaining = 210
DEFECT inventory remaining = 210
```

and:
- Harrow #001–#006 retain their fixed MARKS and shared-random DEFECTS;
- #066 stays candidate-eligible until drawn and then receives HELLBOUND;
- each applicable token receives exactly one immutable birth identity;
- no publisher/admin rarity selection, setter or reroll exists;
- failed assignment reverts issuance/accounting atomically;
- `HELLBOX_ABI_V1` remains unchanged.

After the entropy/closure architecture is locked, continue with exactly **one implementation file and one Bash command per turn**. Collector mint remains closed until production randomness, phase eligibility, V1 payment enforcement and native closure are all test-backed.

The newly locked independent-creator Press lane, interactive Reader/Archive direction and future-token separation doctrine remain later product architecture and do not widen this Gate 4 frontier.

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
- stablecoin/dual-payment/USD-target/oracle pricing reintroduced into Gate 4 V1 without a new creator decision;
- changing an already-published issue's frozen payment asset, PLS mint price, royalty rate or native deadline;
- hard-coding today's royalty/mint downstream split percentages, destination wallets or future reward-token address into the publication;
- treating mutable revenue-routing operations as immutable collectible rarity rules;
- runtime-AI generation of canonical story pages/branches/escape-room outcomes for a published issue;
- treating every story branch as a hidden death/correct-answer test instead of allowing legitimate authored surviving routes;
- locking the ideal/core story behind rare MARK/DEFECT ownership;
- changing MARK/DEFECT birth rarity because of Reader experiences, achievements, burns or reward state;
- letting an archived/plastic-protected copy acquire handling-derived experience marks while it remains archived;
- ordinary Archive rewards accruing to Harrow #001–#006 before their six-year post-mint delay expires;
- hard-coding Archive rarity weights/emissions/burn modifiers into the Gate 4 publication kernel;
- issue production that depends on undocumented manual steps or Harrow remembering hidden state;
- per-issue custom infrastructure/scripts that bypass the canonical compiler without formal review;
- AI directly publishing, signing mainnet transactions or handling production secrets;
- accepting AI-generated code/content because it looks plausible without automated and human review;
- allowing branch/asset scope to exceed the declared issue budget without explicit rebaseline;
- claiming backups, failover or recovery readiness without a successful restore/failure drill;
- relying on one RPC/provider for ownership-critical or mint-critical truth;
- starting timed rooms before required assets are loaded and an authoritative start is recorded;
- platform-wide outages automatically causing mass timed-room deaths;
- reward economics becoming a necessary condition for the comic/artifact to have value;
- shipping an interactive issue without exhaustive reachable-path validation and human playtesting;
- normal production operation that requires daily Harrow intervention or a specific computer remaining online;
- mainnet release without a successful clean-room recovery drill and approved executable runbook;
- AI output treated as current-state evidence without repository/test verification;
- a handoff that depends on one AI's private conversation context;
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

# CURRENT GATE BLUEPRINT — GATE 4 PUBLICATION CONFIGURATION + ISSUANCE ARCHITECTURE

**Gate:** Gate 4 — HELLBOX ARTIFACT KERNEL + VERSIONED PUBLICATION FACTORY
**Status:** APPROVED / IMPLEMENTATION IN PROGRESS
**Checkpoint:** V1 kernel + `HELLBOX_ABI_V1` + deterministic issuance core + size-safe V1 full-deployment factory + versioned enforcement-preimage anchors + modular `HellboxBirthPolicy` foundation implemented; verified post-push regression **65 passed / 0 failed**; current unoptimized Shanghai runtimes: publication **16,334 bytes**, factory **8,020 bytes**, birth-policy module **5,561 bytes**
**Next frontier:** atomically wire the three enforcement preimages and immutable per-publication `HellboxBirthPolicy` companion through publication/factory deployment, prove combined EIP-170/EIP-3860 headroom, then wire permanent per-token MARK/DEFECT consumption without selecting production randomness prematurely
**Target chain:** PulseChain Testnet V4 only
**Mainnet:** prohibited in Gate 4
**Repository destination:** `CURRENT_GATE_BLUEPRINT.md`
**Gate 4 archive target at formal close:** `docs/architecture/gates/GATE_04_PUBLICATION_CONFIGURATION.md`
**Authority:** Detailed implementation contract for the current Gate. `HELLBOX_PROJECT_STATE.md` governs durable cross-project architecture/handoff; `HARROW_CHARACTER_BIBLE.md` governs creative canon; verified source/tests/terminal evidence govern implementation progress.
**Purpose:** Preserve the complete field-by-field release configuration Harrow's private Press must collect, validate, preview, cryptographically commit and freeze before `PUBLISH`, while defining the current Gate 4 implementation, issuance invariants, open technical boundaries and acceptance path.

**Root lifecycle rule:** this complete Gate 4 blueprint remains at repo root while Gate 4 is active. At formal Gate 4 close, archive this finalized file under `docs/architecture/gates/` before `CURRENT_GATE_BLUEPRINT.md` is repurposed for Gate 5. Never overwrite the only detailed copy of a completed Gate.

---

# 0. GATE 4 BOUNDARY

This blueprint was creator-approved before Gate 4 implementation began and now remains the implementation-facing architecture contract for the Gate.

Current proven Gate 4 implementation constraints:

- Solidity source lives in `contracts/`; existing `src/` remains Cloudflare Worker territory;
- Foundry `1.8.1` is verified by creator terminal output for the current Gate 4 environment;
- Foundry directories are `contracts/`, `test/`, `script/`, `lib/`, and generated `out/`;
- dependencies are pinned, never floating;
- Solidity compiler is exactly `0.8.36` for Hellbox-authored Solidity;
- Hellbox-authored Solidity uses exact `pragma solidity 0.8.36;`;
- EVM target is explicitly `shanghai` for PulseChain Testnet V4 compatibility;
- optimizer settings, optimizer runs, and `via_ir` remain deliberately **OPEN** pending test-backed evaluation;
- OpenZeppelin Contracts is pinned to `v5.1.0` at commit `69c8def5f222ff96f2b5beff05dfba996368aa79`;
- OpenZeppelin `v5.7.0` is **SUPERSEDED for Gate 4** because its `Bytes.sol` uses `MCOPY`, which does not compile for the locked Shanghai EVM target;
- OpenZeppelin source is consumed as installed and is not copied, modified, or replaced with custom implementations of solved primitives;
- `HellboxPublication V1` uses **FULL_DEPLOYMENT** with constructor initialization;
- V1 uses no initializer, no proxy, no delegatecall architecture, and no upgrades;
- "immutable release configuration" means no post-freeze mutation path; not every frozen field must use Solidity's `immutable` keyword;
- release-specific Solidity `immutable` values may produce different runtime bytecode hashes between publications without changing the reviewed V1 logic architecture;
- `HELLBOX_ABI_V1` release-fingerprint encoding is implemented independently in Solidity and JavaScript and verified by a shared golden vector;
- `HellboxPublicationFactory V1` is implemented as an owner-gated, size-safe full-deployment manufacturer using OpenZeppelin `Ownable2Step`;
- factory ownership renunciation is disabled; two-step authority rotation remains available;
- each factory generation freezes an immutable `approvedPublicationCreationCodeHash`;
- `publish(...)` accepts the exact reviewed publication creation bytecode, verifies its hash against that immutable approval, appends canonical constructor arguments, and deploys the fresh publication through ordinary EVM `CREATE`;
- the former embedded `new HellboxPublication(...)` factory path is superseded because it pushed factory runtime above the EIP-170 limit once the issuance core landed;
- current verified unoptimized Shanghai sizes: `HellboxPublicationFactory` runtime **8,020 bytes** with **16,556 bytes** EIP-170 headroom; `HellboxPublication` runtime **16,334 bytes** with **8,242 bytes** EIP-170 headroom and **24,855-byte** initcode; standalone `HellboxBirthPolicy` runtime **5,561 bytes** with **19,015 bytes** EIP-170 headroom and **17,018-byte** initcode with **32,134 bytes** EIP-3860 headroom;
- official factory provenance is append-only: no `registerExisting()`, no arbitrary provenance setters, and no post-deployment path that can manufacture authenticity for an external contract;
- factory V1 rejects zero approved publication creation-code hash, unapproved supplied creation bytecode, duplicate `publicationKey` hashes, and duplicate release-config digests within that official factory/chain generation;
- factory V1 records only minimal authenticity state (`isPublication`, release-digest lookup, publication-key lookup, ordered publication addresses) and emits richer provenance evidence in `PublicationPublished`;
- instance runtime code hash is forensic evidence for that exact deployment, not a universal V1 equality fingerprint;
- after deployment, the factory defensively verifies reported factory, chain, template, publication version, release digest, and publication key before recording provenance;
- an arbitrary self-declared factory is not automatically official: Hellbox's chain/version registry remains the root that designates which factory address/version + approved publication creation-code hash is official;
- the deterministic issuance core is implemented behind a deterministic entropy-word/test-double boundary without selecting production randomness;
- versioned fixed-copy, birth-trait and randomization-policy enforcement domains/typed preimage hashes are implemented and permanently anchored to the corresponding `CommitmentSet` digests without changing `HELLBOX_ABI_V1`;
- `HellboxBirthPolicy V1` is implemented as a standalone non-upgradeable per-publication companion foundation with constructor-only configuration, permanent `publication = msg.sender` binding, independent digest verification, native MARK/DEFECT inventory + fixed reservations, #066 HELLBOUND/random-pool eligibility enforcement, SciVive trait-disabled support, and no external mutation/admin surface at this checkpoint;
- the companion is **not yet deployment-wired**: the publication does not yet create/store it and the factory does not yet transport the three policy preimages; no collector mint may be exposed on the assumption that this missing wiring already exists;
- current Gate 4 post-push regression checkpoint passes **65 Solidity tests total, 0 failed**:
  - 16 `HellboxPublication` kernel tests;
  - 11 `HellboxPublicationFactory` provenance/deployability tests;
  - 12 deterministic issuance tests, including a 256-run fuzz boundary;
  - 9 `HellboxPublicationPolicy` enforcement-anchor tests;
  - 16 dedicated `HellboxBirthPolicy` module tests;
  - 1 Solidity↔JavaScript golden-vector test;
- no publication has been deployed to mainnet; Gate 4 remains PulseChain Testnet V4 only;
- do **not** use HairyLabs Byte pages for acceptance/regression testing until the creator explicitly clears the Byte lane.

If implementation discovers a material conflict with this blueprint, stop and synchronize/re-review this file before silently changing the architecture.

---

# 1. THE CENTRAL RULE

> **THE RULES ARE IMMUTABLE. THE ARTIFACT IS ALIVE.**

A Hellbox publication has two different kinds of truth:

1. **Release configuration** — the rules/promises Harrow approves before publication. These freeze.
2. **Artifact/release state** — ownership, mint counts, assigned copies, seal/archive/evolution/history/context that may change only according to the frozen rules.

The existence of dynamic metadata does **not** make the release rules mutable.

---

# 2. WHAT `PUBLISH` MEANS

For this blueprint, `PUBLISH` is the irreversible private-Press action that:

1. locks the resolved release configuration;
2. locks the exact package/art/renderer commitments;
3. selects the approved chain + factory + template version;
4. produces the final cryptographic release/configuration digest(s);
5. deploys the fresh non-upgradeable publication instance through the approved factory;
6. records deployment provenance in durable Hellbox data;
7. makes the frozen release eligible to open its public Press according to its already-frozen schedule.

**The public Press does not have to open in the same block or minute as `PUBLISH`.**

That distinction is deliberate:

- `PUBLISH` freezes the edition.
- phase start conditions determine when collectors can pull copies.

There is no post-`PUBLISH` editor for immutable release promises.

---

# 3. CLASSIFICATION LEGEND

Every blueprint field is classified using the following homes.

| Code | Home | Meaning |
|---|---|---|
| `C` | Publication contract | Stored/enforced by the individual release contract or directly derivable from its immutable state. |
| `F` | Factory/version registry | Factory, Hellbox chain/version registry, template/version metadata, capability support, approved-factory provenance, and deployment provenance. |
| `X` | External protocol | Oracle, treasury router, reward protocol, Archive protocol, ERC-6551/TBA infrastructure, Hellforge, randomness provider, renderer adapter, or other modular system. |
| `P` | D1/package | Durable Hellbox database and/or publication package/manifests. May include operational delivery pointers that are not release promises. |
| `D` | Private draft | Harrow-only builder state, uploads, notes, previews, temporary paths, validation results, and pre-`PUBLISH` choices. |
| `U` | Public Press/display | Field must be exposed to collectors when relevant, or is a public runtime display derived from frozen config/state. |
| `I` | Immutable release configuration | Part of the resolved release promise that freezes at `PUBLISH`. |
| `A` | Artifact/release state | State that changes after `PUBLISH` only according to the frozen rules. |

Commitment notation:

- `ROOT` — field is covered by the canonical release configuration digest.
- `SUB` — field also has an independently inspectable sub-digest/root.
- `DIRECT` — a value/root/address is stored directly on-chain.
- `NO` — intentionally not part of the immutable release commitment.

Mutability notation:

- `FREEZE` — resolved before `PUBLISH`; never editable afterward for that release.
- `SET-ONCE` — created/assigned later but permanently fixed once created, such as a birth trait.
- `RULED` — may change only through the release's frozen state machine.
- `EXTERNAL` — mutable in an external protocol according to that protocol's rules.
- `DERIVED` — computed from immutable config/runtime state; not independently editable.
- `DRAFT` — private builder state discarded or archived after `PUBLISH`.
- `REGISTRY` — factory/version-registry state; future registry changes must not rewrite an already deployed release.

---

# 4. AUTHORITATIVE RESOLVED CONFIGURATION SHAPE

The private Press should ultimately compile one normalized object with this conceptual shape:

```text
publication
chain
template
collection
credits
supply
creatorAllocation
fixedCopyRules
birthTraits
randomization
contentPackage
renderer
reader
pricingPolicies[]
paymentRoutes[]
mintPhases[]
walletRules
royalty
treasury
capabilities
metadataPolicy
protocolCompatibility
closurePolicy
eventPolicy
commitments
```

Separate non-authoritative/operational objects exist for:

```text
privateDraft
validationReport
previewReport
deliveryLocations
deploymentRecord
publicPressRuntime
artifactState
externalProtocolState
```

A builder preset may populate the resolved object, but **the preset name is never a substitute for the fully expanded frozen fields**.

Example:

- `NATIVE_STANDARD_216` may be a convenient builder preset.
- the contract/package still commit the explicit `216`, all counts, all copy rules, all phase rules, etc.

---

# 5. PUBLICATION IDENTITY

| Field | Type / examples | Author | Home | Mutability | Commit | Public | Validation / rule |
|---|---|---|---|---|---|---|---|
| `publication.publicationKey` | stable string, e.g. `scivive` | Harrow | `C P D U I` | `FREEZE` | `ROOT/DIRECT-or-hash` | yes | Required; chain-independent conceptual publication identity; must match Hellbox durable publication record. |
| `publication.title` | canonical publication title | Harrow | `P D U I` | `FREEZE` | `ROOT` | yes | Required before public release. |
| `publication.subtitle` | optional string | Harrow | `P D U I` | `FREEZE` | `ROOT` | if set | Optional; empty is different from later silent rewrite. |
| `publication.seriesKey` | optional stable series identifier | Harrow | `P D I` | `FREEZE` | `ROOT` | optional | Used for series/contextual set logic; must not be invented for standalone publications. |
| `publication.issueLabel` | optional, e.g. issue/volume label | Harrow | `P D U I` | `FREEZE` | `ROOT` | if set | Display identity; not a second token/copy number system. |
| `publication.editionLabel` | optional edition wording | Harrow | `P D U I` | `FREEZE` | `ROOT` | if set | Must not imply rarity unsupported by the configured trait system. |
| `publication.publicationClass` | `BOOK`, `COMIC`, future class | Harrow | `P D I` | `FREEZE` | `ROOT` | yes | Must agree with Reader/package configuration. |
| `publication.contentLanguage` | canonical publication content language | Harrow | `P D U I` | `FREEZE` | `ROOT` | useful | Independent of site UI localization. |
| `publication.maturityNotice` | optional adult/content notice | Harrow | `P D U I` | `FREEZE` | `ROOT` | if applicable | Package/public copy field; does not replace actual legal/rights review. |
| `publication.publisherName` | canonical `Hellbox Comics`/approved publisher credit | Harrow | `P D U I` | `FREEZE` | `ROOT` | yes | Must preserve actual publishing role. |

### Identity rule

`publicationKey` identifies the conceptual publication.

The deployed release identity is later:

```text
(chainId, contractAddress)
```

The individual collectible identity is:

```text
(chainId, contractAddress, tokenId)
```

For native Hellbox collectibles:

```text
tokenId = collector-facing copy number
```

No second independent copy-number field is created.

---

# 6. CREDITS, SOURCE, RIGHTS & RELEASE COPY

Harrow's arrogance cannot create false authorship. The private Press must freeze accurate credit metadata.

| Field | Type / examples | Author | Home | Mutability | Commit | Public | Validation / rule |
|---|---|---|---|---|---|---|---|
| `credits.creatorDisplay` | Harrow or actual creator credit | Harrow | `P D U I` | `FREEZE` | `ROOT` | yes | Must reflect actual role. |
| `credits.writer` | one or more credited writers | Harrow | `P D U I` | `FREEZE` | `ROOT` | yes when applicable | Do not assign Harrow authorship he did not perform. |
| `credits.artist` | one or more credited artists | Harrow | `P D U I` | `FREEZE` | `ROOT` | yes when applicable | Accurate credit required. |
| `credits.publisher` | publisher/presenter | Harrow | `P D U I` | `FREEZE` | `ROOT` | yes | For SciVive, Harrow/Hellbox are publisher/presenter, not source-book author/editor. |
| `credits.adapter` | optional adaptation credit | Harrow | `P D U I` | `FREEZE` | `ROOT` | if applicable | Only when an adaptation actually exists. |
| `credits.sourceWork` | source title/author/reference | Harrow | `P D U I` | `FREEZE` | `ROOT` | if applicable | Required for adapted/archival/licensed/public-domain source material where needed. |
| `credits.rightsStatement` | rights/license statement or internal rights reference | Harrow | `P D I` | `FREEZE` | `ROOT` | package-dependent | Must be reviewed before public release. |
| `credits.sourceIntegrityRule` | e.g. `PRESERVE_SOURCE` | Harrow | `P D I` | `FREEZE` | `ROOT` | optional | Useful for releases such as SciVive where source editing is explicitly prohibited. |
| `publication.description` | canonical collector-facing description | Harrow | `P D U I` | `FREEZE` | `ROOT` | yes | Harrow-facing public copy; no generic NFT rarity soup. |
| `publication.releaseTermsCopy` | canonical release-terms/edition-promise copy | Harrow | `P D U I` | `FREEZE` | `ROOT` | yes when used | Freeze copy that states edition promises; ordinary Harrow jokes, layout copy, translations, and non-contractual presentation wording may evolve so long as they do not contradict the frozen release. |

Operational social/marketing copy outside the canonical release/package is not part of the contract configuration.

---

# 7. CHAIN, FACTORY & TEMPLATE VERSION

## 7.1 Release-selected chain fields

| Field | Type / examples | Author | Home | Mutability | Commit | Public | Validation / rule |
|---|---|---|---|---|---|---|---|
| `chain.chainId` | `369`, Gate 4 test `943` | Harrow selects from registry | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Must equal actual deployment chain. |
| `chain.chainKey` | e.g. `pulsechain`, testnet key | registry | `P D U I` | `FREEZE` | `ROOT` | yes | Human/config identity; must map one-to-one to `chainId`. |
| `chain.environment` | `testnet` / `mainnet` | registry | `P D` | `DRAFT/FREEZE-as-record` | `ROOT` | useful | Gate 4 deployments are Testnet V4 only. |
| `chain.nativeCurrencySymbol` | e.g. `PLS`, registry display | registry | `P D U` | `DERIVED` | `NO` | yes | Display only; not trusted for payment math. |
| `chain.factoryAddress` | approved factory on target chain | registry | `F C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes/proof | Must contain expected code on target chain. |
| `chain.factoryRegistryRef` | Hellbox chain/version registry reference for the approved factory generation | registry | `F P D U` | `REGISTRY/SET-ONCE deployment record` | `NO` | proof | This is a Hellbox registry reference, **not an implied on-chain registry contract address**. The actual `chain.factoryAddress` is what HELLBOX_ABI_V1 binds. |

## 7.2 Operational chain fields — intentionally not frozen release promises

| Field | Home | Mutability | Commit | Rule |
|---|---|---|---|---|
| `chain.rpcEndpointRef` | `P D` | operational | `NO` | RPCs may rotate/fail without changing the publication. |
| `chain.explorerBaseUrl` | `P U` | operational | `NO` | Display convenience only. |
| `chain.walletChainMetadata` | `P U` | operational | `NO` | Can be updated for wallet UX without mutating release economics. |

Never commit a fragile RPC URL as an edition promise.

---

# 8. FACTORY / VERSION REGISTRY FIELDS

These are not arbitrary per-publication values. Harrow selects an approved registered version; the registry defines what it means.

| Field | Type | Home | Mutability | Commit into release | Rule |
|---|---|---|---|---|---|
| `template.templateId` | stable identifier, e.g. `HELLBOX_PUBLICATION` | `F P D U I` | `REGISTRY/FREEZE selection` | `ROOT/DIRECT` | Each release records the exact template identity. |
| `template.templateVersion` | explicit immutable version | `F C P D U I` | `REGISTRY/FREEZE selection` | `ROOT/DIRECT` | Never silently redefine an old version. |
| `template.factoryVersion` | factory generation | `F P D U` | `REGISTRY/SET-ONCE deployment record` | `NO — derived from approved factory` | Registry/deployment metadata only. **It is not a caller-supplied `ReleaseConfig` field.** HELLBOX_ABI_V1 binds the actual factory address instead. |
| `template.approvedFactoryCodeHash` | expected runtime code hash for the approved factory address | `F P D` | `REGISTRY` | `NO` | Pre-PUBLISH validation evidence for the factory itself. It is not a universal publication-instance hash and is not added to `ReleaseConfig`. |
| `template.approvedPublicationCreationCodeHash` | exact `keccak256` of reviewed `HellboxPublication` creation bytecode approved for this factory generation | `F P D U` | `REGISTRY/FREEZE generation` | `NO — factory/version provenance` | Must equal the factory's immutable `approvedPublicationCreationCodeHash`; supplied publish bytecode must hash to this value. It is not a `ReleaseConfig` field and does not alter `HELLBOX_ABI_V1`. |
| `template.configSchemaVersion` | blueprint/config schema version | `F P D I` | `REGISTRY/FREEZE selection` | `ROOT` | Defines exact normalized config field/encoding expectations. |
| `template.commitmentSchemeVersion` | commitment/encoding generation | `F P D I` | `REGISTRY/FREEZE selection` | `ROOT` | Prevents hash ambiguity across future versions. |
| `template.deploymentMode` | `FULL_DEPLOYMENT` for V1 | `F P D I` | `REGISTRY/FREEZE selection` | `ROOT` | **LOCKED for HellboxPublication V1:** constructor initialization; no initializer, proxy, delegatecall architecture, or upgrades. V2/V3 may reconsider ERC-1167 only as an explicitly new reviewed version with demonstrated benefit. |
| `template.supportedCapabilityMask` | machine-readable capability set | `F P D` | `REGISTRY` | selected capabilities in `ROOT` | Builder must prevent selecting unsupported capabilities. |
| `template.supportedInterfaces` | ERC/interface IDs | `F P D` | `REGISTRY` | support proof | Includes required publication/metadata/protocol interfaces. |
| `template.activeForNewDeployments` | bool | `F D` | `REGISTRY` | `NO` | Can be disabled for future releases without affecting old releases. |
| `template.deprecatedAt` | optional registry state | `F` | `REGISTRY` | `NO` | Historical releases remain valid. |

A registry may change what is approved for **future** releases. It must not change the code/version a deployed publication already records.

For V1, there is **no shared publication implementation endpoint and no universal publication-instance code hash** to validate or preview. V1 is ordinary full deployment. The exact runtime code hash of a deployed publication becomes available only after deployment and is instance-specific forensic evidence.

## 8.1 V1 factory provenance / authenticity rule — LOCKED

For `HellboxPublicationFactory V1`:

- `FACTORY_VERSION = 1`;
- `PUBLICATION_VERSION = 1`;
- `TEMPLATE_ID = keccak256("HELLBOX_PUBLICATION")`;
- deployment mode is `FULL_DEPLOYMENT`;
- only the current factory owner/publisher authority may call `publish(...)`;
- ownership rotates through `Ownable2Step`; accidental ownership renunciation is disabled;
- each successful publication must be unique by both `publicationKey` hash and `releaseConfigDigest` within that factory generation;
- the factory generation freezes immutable `approvedPublicationCreationCodeHash` and records only publications it physically creates from supplied creation bytecode whose `keccak256` exactly matches that approved value;
- the factory appends the canonical V1 constructor arguments and executes ordinary EVM `CREATE`, so the child still observes the approved factory as `msg.sender` during construction;
- there is no embedded `new HellboxPublication(...)` publication bytecode in factory runtime, no arbitrary implementation registry, no generic constructor-data escape hatch, no `registerExisting()`, no `setOfficial(...)`, no provenance repair setter, no proxy, initializer, clone, `delegatecall`, CREATE2 requirement, or upgrade path in V1;
- before provenance is recorded, the deployed publication must report the expected factory, chain ID, template ID, publication version, release-config digest, and publication key;
- the publication's exact runtime code hash is emitted as instance-specific forensic evidence but is not treated as a universal V1 bytecode hash;
- the factory cannot prove its own social legitimacy. Hellbox's chain/version registry must designate the factory address/version as `ACTIVE / OFFICIAL` for a target chain;
- D1 may index richer deployment metadata, but the chain remains the proof of deployment provenance.

Canonical authenticity chain:

```text
KNOWN APPROVED HELLBOX FACTORY GENERATION
+ exact approved publication creation-code hash
→ factory verifies supplied creation bytecode and physically deploys publication X through ordinary CREATE
→ publication reports that factory + chain + V1 template/version + frozen digest/key
→ authentic publication from that approved factory generation
```

A deliberate same-chain reissue must use a new publication/edition identity rather than reusing an already-canonical `publicationKey`.

### 8.2 V1 factory EIP-170 correction — VERIFIED

The earlier embedded Solidity `new HellboxPublication(...)` path caused the factory runtime to include publication creation bytecode. After the deterministic issuance core landed, the verified unoptimized Shanghai build measured:

```text
old HellboxPublicationFactory runtime = 32,116 bytes
EIP-170 runtime limit                 = 24,576 bytes
old runtime margin                    = -7,540 bytes
```

That factory was structurally undeployable under EIP-170.

At the factory-correction checkpoint, the approved creation-code-hash + ordinary-`CREATE` correction produced:

```text
HellboxPublication runtime           = 15,564 bytes
HellboxPublication initcode          = 24,016 bytes
HellboxPublicationFactory runtime    = 8,020 bytes
HellboxPublicationFactory initcode   = 8,804 bytes
factory EIP-170 runtime margin       = +16,556 bytes
```

That table is historical evidence for the factory correction, not the current publication size after later policy-anchor work. Current verified unoptimized Shanghai sizes are:

```text
HellboxPublication runtime           = 16,334 bytes
HellboxPublication initcode          = 24,855 bytes
HellboxPublicationFactory runtime    = 8,020 bytes
HellboxPublicationFactory initcode   = 8,804 bytes
HellboxBirthPolicy runtime           = 5,561 bytes
HellboxBirthPolicy initcode          = 17,018 bytes
```

The publication-created companion topology has **not** yet been compiled as one deployment graph. EIP-3860 proof therefore remains required after wiring; simple addition of the two standalone initcode sizes is not deployment proof.

This remains `FULL_DEPLOYMENT`; it is not a clone/proxy/upgrade model.

Do **not** reintroduce embedded publication creation bytecode into factory runtime. Do **not** silently enable optimizer/via-IR merely to hide a structural size regression.

Because no V1 factory had been deployed before this correction, this remains the pre-deployment V1 implementation rather than a post-release upgrade.


---

# 9. COLLECTION CONTRACT IDENTITY

| Field | Type | Author | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|---|
| `collection.name` | ERC-721 collection name | Harrow | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Required. |
| `collection.symbol` | ERC-721 symbol | Harrow | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Required; validate length/charset policy. |
| `collection.contractURIProfile` | collection metadata profile/version | Harrow selects | `C P D I` | `FREEZE` | `ROOT` | indirect | Must resolve to committed collection metadata. |
| `collection.tokenStandard` | `ERC-721` | template | `F C P U I` | `FREEZE` | `ROOT` | yes | Native Hellbox release model. |
| `collection.copyNumberRule` | `TOKEN_ID_IS_COPY_NUMBER` | template/release | `C P U I` | `FREEZE` | `ROOT` | yes | Core collector identity rule. |
| `collection.tokenIdStart` | normally `1` | template/release | `C P I` | `FREEZE` | `ROOT/DIRECT` | proof | Copy numbering should be contiguous unless an explicit future release says otherwise. |
| `collection.tokenIdEnd` | equals `maxSupply` for normal releases | derived | `C P U I` | `DERIVED/FREEZE` | `ROOT/DIRECT-or-derived` | yes | Must match supply. |

Contract address, deployment tx, and deployment block are not known until `PUBLISH`; they are deployment provenance, not author-entered configuration.

---

# 10. SUPPLY & COPY NUMBERING

| Field | Type / standard | Author | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|---|
| `supply.maxSupply` | standard native `216`; SciVive `5555` | Harrow | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | > 0; can never increase after publish. |
| `supply.mintableCapacity` | derived | builder | `P D U I` | `DERIVED` | `ROOT` | yes | Equals max supply before burns/closure; exact phase/tail math shown separately. |
| `supply.copyIds` | `1..maxSupply` | builder | `C P I` | `FREEZE` | `ROOT/SUB` | not list-required | IDs unique, in range, tokenId=copy number. |
| `supply.initialCandidatePoolSize` | derived after immediate creator issuance | builder | `P D U I` | `DERIVED` | `ROOT` | yes | Standard native: `216 - 6 = 210`. These are the random candidates physically left in the machine after #001–#006. The future tail copies are **not** preselected or removed. |
| `supply.nonTailIssuanceCapacity` | derived non-tail primary issuance limit | builder | `P D U I` | `DERIVED` | `ROOT` | yes | Standard native: `216 - 6 - 3 = 207`. This limits all normal non-tail primary issuances across reserved/free/allowlist/early/public phases; it is **not** the initial randomness/odds denominator. |
| `supply.capCanIncrease` | hard `false` | template invariant | `F C I` | `FREEZE` | implicit/template | proof | Not configurable to true. |
| `supply.burnMayReduceSurvivingSupply` | capability bool | Harrow/template | `C P I` | `FREEZE` | `ROOT` | yes if enabled | Burn only through owner-authorized frozen protocols. |
| `supply.earlyCloseSupported` | bool | Harrow/template | `C P D U I` | `FREEZE` | `ROOT` | yes | If enabled, exact closure effects must freeze before publish. |

No publisher action can increase `maxSupply` after `PUBLISH`.

---

# 11. CREATOR ALLOCATION

## 11.1 Immediate creator pull

| Field | Standard native value | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|
| `creatorAllocation.immediate.enabled` | `true` | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Required for standard native profile. |
| `creatorAllocation.immediate.count` | `6` | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Must equal configured assignment rows. |
| `creatorAllocation.immediate.recipient` | Harrow creator/treasury-owned recipient address | `C P D I` | `FREEZE` | `ROOT/DIRECT` | transparent | Must be nonzero and explicit. |
| `creatorAllocation.immediate.execution` | `PUBLISH_INITIALIZATION / BEFORE_NON_TAIL_ISSUANCE` | `C F P I` | `FREEZE` | `ROOT` | yes conceptually | #001–#006 are removed from candidate eligibility and committed to the immediate creator recipient before any normal non-tail primary issuance can open. This does **not** require an unapproved synchronous randomness provider. |
| `creatorAllocation.immediate.defectPolicy` | `SHARED_RANDOM_PROCESS` | `C P U I` | `FREEZE` | `ROOT` | yes | No guaranteed creator defect. |

### Standard immediate copies

| Copy ID | Required PRESS MARK | Intended Harrow path | Owner allocation |
|---:|---|---|---|
| `#001` | `HELLBOUND` | open / break seal | immediate creator |
| `#002` | `HELLBOUND` | preserve sealed | immediate creator |
| `#003` | `PRESS PROOF` | open / break seal | immediate creator |
| `#004` | `PRESS PROOF` | preserve sealed | immediate creator |
| `#005` | `GOLD` | open / break seal | immediate creator |
| `#006` | `GOLD` | preserve sealed | immediate creator |

The intended sealed/open path is Harrow's intent, not a forced contract action at birth unless a future explicit release config says otherwise. The token begins under the configured initial seal rule.

### Immediate-allocation timing invariant

"Immediate" is a **priority/order promise**, not a requirement that every random birth attribute be finalized inside the same constructor transaction.

Before any normal non-tail primary issuance may open:

1. copy IDs `#001–#006` are permanently excluded from candidate eligibility;
2. allocation is committed to the configured immediate creator recipient;
3. their fixed PRESS MARK assignments are locked;
4. their PRESS DEFECT assignments come from the same approved shared random process;
5. all six birth assignments are complete.

If the approved production randomness mechanism is asynchronous, the publication may remain in a non-public initialization/finalization state while entropy is fulfilled. **The public Press cannot open during that gap.** This preserves Harrow's first-six promise without silently choosing synchronous entropy.


## 11.2 True-mintout tail reserve

| Field | Standard native value | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|
| `creatorAllocation.tail.enabled` | `true` | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Standard native. |
| `creatorAllocation.tail.count` | `3` | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Collector issuance stops when this many random candidates remain. These copies are not predetermined and are not removed from the candidate pool at the start. |
| `creatorAllocation.tail.recipient` | Harrow recipient address | `C P D I` | `FREEZE` | `ROOT/DIRECT` | transparent | Explicit. |
| `creatorAllocation.tail.trigger` | `TRUE_MINT_OUT_ONLY` | `C P U I` | `FREEZE` | `ROOT` | yes | Cannot be claimed merely because Harrow closes early. |
| `creatorAllocation.tail.selection` | `FINAL_THREE_REMAINING_IN_RANDOM_POOL` | `C P U I` | `FREEZE` | `ROOT` | yes | Harrow does not know IDs/MARKS/DEFECTS beforehand. |
| `creatorAllocation.tail.earlyCloseEffect` | `FORFEIT_TAIL` | `C P U I` | `FREEZE` | `ROOT` | yes | Early permanent close does not hand Harrow the final three. |
| `creatorAllocation.tail.awarded` | runtime bool | `C P U A` | `RULED` | `NO` | yes | Becomes true only on actual mint-out trigger. |
| `creatorAllocation.tail.awardedCopyIds` | runtime 3 IDs | `C P U A` | `SET-ONCE` | state/event | yes after award | Must be the actual last three remaining copies. |

---

# 12. FIXED COPY RULES

Fixed copy rules constrain a copy without necessarily reserving its ownership.

Generic row shape:

```text
copyId
allocationClass
requiredMark
requiredDefect (optional)
recipient (optional)
publicRandomPoolEligible
reasonCode
```

| Field | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|
| `fixedCopyRules[]` | `C P D U I` | `FREEZE` | `ROOT/SUB/DIRECT-as-needed` | yes/proof | IDs unique; all within supply; assignments must fit trait totals. |
| `fixedCopyRules[].copyId` | `C P I` | `FREEZE` | sub-root/direct | yes when disclosed | Token ID/copy number. |
| `fixedCopyRules[].allocationClass` | `C P I` | `FREEZE` | sub-root | yes | `CREATOR_IMMEDIATE`, `PUBLIC_RANDOM_POOL`, future explicit class. |
| `fixedCopyRules[].requiredMark` | `C P I` | `FREEZE` | sub-root | yes after/if disclosed | Must consume configured distribution. |
| `fixedCopyRules[].requiredDefect` | `C P I` | `FREEZE` | sub-root | only if set | Standard creator copies do not preset defects. |
| `fixedCopyRules[].recipient` | `C P I` | `FREEZE` | sub-root | transparent when allocation fixed | Only when ownership is actually fixed. |
| `fixedCopyRules[].publicRandomPoolEligible` | `C P I` | `FREEZE` | sub-root | yes | #066 remains `true`. |
| `fixedCopyRules[].reasonCode` | `P D I` | `FREEZE` | root | optional | Human/audit explanation. |

### Standard public grail

```text
copyId: 66
requiredMark: HELLBOUND
allocationClass: PUBLIC_RANDOM_POOL
publicRandomPoolEligible: true
recipient: null
```

#066 must not become snipable merely because its birth MARK is known.

---

# 13. BIRTH TRAIT AXES

Birth traits have two levels:

1. **Release-level immutable vocabulary/counts/rules.**
2. **Per-token assignment**, which becomes permanent birth identity once assigned.

## 13.1 Generic trait-axis fields

| Field | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|
| `birthTraits.axes[]` | `C P D U I` | `FREEZE` | `ROOT/SUB` | yes | Each enabled axis has unique stable ID. |
| `birthTraits.axes[].axisId` | `C P I` | `FREEZE` | sub-root | yes | Internal stable ID. |
| `birthTraits.axes[].publicLabel` | `P D U I` | `FREEZE` | root | yes | Harrow-facing canonical English label. |
| `birthTraits.axes[].assignmentMode` | `C P I` | `FREEZE` | root | proof | e.g. fixed + randomized remaining. |
| `birthTraits.axes[].overlapPolicy` | `C P U I` | `FREEZE` | root | yes | Defines whether axes are independent/allowed to overlap. |
| `birthTraits.axes[].values[]` | `C P D U I` | `FREEZE` | sub-root | yes | Exact value vocabulary and totals. |
| `birthTraits.axes[].values[].code` | `C P I` | `FREEZE` | sub-root | metadata | Stable machine code. |
| `birthTraits.axes[].values[].publicValue` | `P D U I` | `FREEZE` | root | yes | Canonical collector-facing value. |
| `birthTraits.axes[].values[].count` | `C P D U I` | `FREEZE` | sub-root/direct | yes | Sum must equal max supply for a full-population birth axis. |
| `birthTraits.axes[].values[].layerFamilyRef` | `P D I` | `FREEZE` | root/sub-manifest | preview/public art | Must resolve to committed art/render rules. |
| `birthTraits.axes[].values[].metadataAttributes` | `P D I` | `FREEZE` | root | yes through metadata | Must match public grammar. |

## 13.2 Standard native `PRESS MARK`

| Value | Count |
|---|---:|
| `HELLBOUND` | `6` |
| `PRESS PROOF` | `12` |
| `GOLD` | `18` |
| `STANDARD` | `180` |

Total: `216`.

## 13.3 Standard native `PRESS DEFECT`

| Value | Count |
|---|---:|
| `REDACTED` | `6` |
| `CORRUPTED PLATE` | `12` |
| `BLED OUT` | `18` |
| `OFF REGISTER` | `24` |
| `NONE` | `156` |

Total: `216`.

## 13.4 Standard relationship between axes

For standard native issues:

- `PRESS MARK` and `PRESS DEFECT` are separate axes.
- They may overlap on the same copy.
- Neither is a generic overall rarity score.
- Harrow's #001–#006 have fixed MARKS but **random DEFECTS**.
- Remaining configured counts must be honored exactly.
- A MARK/DEFECT assignment follows the original token across owners.
- The birth assignment does not change because of wallet context.
- If the original token is later consumed by an owner-authorized transformation, the successor artifact/history rules come from the frozen Hellforge protocol configuration.

SciVive does **not** automatically enable either native 216-copy axis.

---

# 14. RANDOMIZATION, ALLOCATION & REVEAL POLICY

The exact provider/mechanism is still an engineering choice to research/prove during Gate 4. The **fields and guarantees are not optional**.

| Field | Type / purpose | Home | Mutability | Commit | Public | Validation / invariant |
|---|---|---|---|---|---|---|
| `randomization.policyId` | stable policy identifier | `C P D U I` | `FREEZE` | `ROOT` | yes | Required if any hidden/random assignment exists. |
| `randomization.schemeVersion` | algorithm/version | `C F P I` | `FREEZE` | `ROOT/SUB` | proof | Exact shuffle/assignment semantics must be versioned. |
| `randomization.providerMode` | oracle/VRF/commit-reveal/etc. | `C X P D U I` | `FREEZE` | `ROOT` | yes | Exact Gate 4 choice remains open until tested. |
| `randomization.providerRef` | provider/adapter/registry address or ID | `C X P D I` | `FREEZE` if bound | `ROOT/DIRECT` | proof | Must be validated on target chain. |
| `randomization.entropyCommitment` | optional pre-reveal commitment | `C P I` | `FREEZE/SET-ONCE` | `SUB/DIRECT` | proof | Must not expose hidden map to Harrow. |
| `randomization.revealTrigger` | mint count/time/provider fulfillment | `C P U I` | `FREEZE` | `ROOT` | yes | Collector-visible. |
| `randomization.revealDeadline` | optional deadline | `C P U I` | `FREEZE` | `ROOT` | yes | Required if mechanism can stall. |
| `randomization.failurePolicy` | frozen fallback/recovery behavior | `C X P U I` | `FREEZE` | `ROOT` | yes | No secret publisher reroll. |
| `randomization.copyShuffleMode` | randomized non-sequential copy IDs | `C P U I` | `FREEZE` | `ROOT` | yes | Public mint cannot simply issue next numeric tokenId. |
| `randomization.fixedIdExclusions` | fixed/reserved rules digest/ref | `C P I` | `FREEZE` | `ROOT/SUB` | proof | Creator/fixed rules removed or constrained correctly. |
| `randomization.traitPoolMode` | normally `GLOBAL_SHARED` | `C P U I` | `FREEZE` | `ROOT` | yes | All normal non-Harrow phases use same remaining pool unless explicitly disclosed otherwise. |
| `randomization.markDefectIndependence` | standard `true` | `C P U I` | `FREEZE` | `ROOT` | yes | Prevents accidental hidden rank coupling. |
| `randomization.creatorDefectFairness` | standard `SHARED_RANDOM` | `C P U I` | `FREEZE` | `ROOT` | yes | Harrow receives no guaranteed defect. |
| `randomization.publisherMapKnowledgePolicy` | `NO_FULL_PREKNOWN_MAP` | `P U I` | `FREEZE` | `ROOT` | yes/proof | System design must make full hidden map difficult for Harrow to know/manipulate. |
| `randomization.assignmentProofMode` | post-reveal verification artifacts | `C X P U I` | `FREEZE` | `ROOT` | yes | Must support public audit. |
| `randomization.assignmentManifestDigest` | optional once final assignment exists | `P C I/A` | `SET-ONCE` | `SUB/DIRECT-or-event` | proof | May be absent at `PUBLISH` if the approved randomness scheme cannot know the final map yet; once produced it is immutable. |

### Randomness invariants

The selected Gate 4 implementation must prove that it:

- preserves fixed IDs;
- prevents sequential public copy sniping;
- does not give allowlist/free/early phases secret better odds unless explicitly configured and publicly disclosed;
- does not rely on a secret publisher-controlled rarity map;
- is auditable;
- can be reproduced/verified after reveal;
- does not expose #066 as an easily targetable next token.

The blueprint deliberately does **not** hard-code an untested randomness provider.

---

# 15. CANONICAL CONTENT PACKAGE

The release freezes **content identity**, not a fragile storage URL.

## 15.1 Canonical package fields

| Field | Type | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|
| `contentPackage.packageSchemaVersion` | manifest version | `P D I` | `FREEZE` | `ROOT` | proof | Required. |
| `contentPackage.packageId` | stable internal package identity | `P D I` | `FREEZE` | `ROOT` | proof | Must match publication. |
| `contentPackage.packageDigest` | cryptographic root | `C P U I` | `FREEZE` | `ROOT/SUB/DIRECT` | yes/proof | Binds exact committed package. |
| `contentPackage.digestAlgorithm` | explicit algorithm/version | `F P I` | `FREEZE` | `ROOT` | proof | No ambiguous hashing. |
| `contentPackage.sourceAssetManifestDigest` | source-file manifest root | `P I` | `FREEZE` | `SUB` | proof | Includes canonical source files. |
| `contentPackage.readerManifestDigest` | protected Reader manifest digest | `P C I` | `FREEZE` | `SUB` | proof | Reader pointer may move; bytes/manifest identity may not silently change. |
| `contentPackage.readerObjectManifestDigest` | page/object list root | `P I` | `FREEZE` | `SUB` | proof | Covers protected output objects when applicable. |
| `contentPackage.baseArtManifestDigest` | canonical cover/base art root | `P C I` | `FREEZE` | `SUB` | proof | Required when NFT art exists. |
| `contentPackage.markLayerManifestDigest` | MARK art/layer root | `P I` | `FREEZE` | `SUB` | proof | Required only when MARK rendering enabled. |
| `contentPackage.defectLayerManifestDigest` | DEFECT art/layer root | `P I` | `FREEZE` | `SUB` | proof | Required only when DEFECT rendering enabled. |
| `contentPackage.fixedAssignmentManifestDigest` | fixed copy rules root | `P C I` | `FREEZE` | `SUB` | proof | Mirrors resolved config constraints. |
| `contentPackage.distributionManifestDigest` | trait distribution root | `P C I` | `FREEZE` | `SUB` | proof | Exact counts/vocabulary. |
| `contentPackage.metadataTemplateDigest` | metadata template/schema root | `P C I` | `FREEZE` | `SUB` | proof | Dynamic output rules, not one static token JSON. |
| `contentPackage.rendererRulesDigest` | compositor/render rules root | `P C I` | `FREEZE` | `SUB` | proof | Required for deterministic output. |
| `contentPackage.creditsManifestDigest` | credits/source/rights root | `P I` | `FREEZE` | `SUB` | proof | Prevents silent credit rewrite. |
| `contentPackage.eligibilityManifestDigests[]` | optional allowlist/source snapshot roots | `P C I` | `FREEZE` | `SUB/DIRECT root per phase` | proof | Full list may remain off-chain/private; root is authoritative. |
| `contentPackage.renderedVariantManifestDigest` | optional pre-rendered asset root | `P I` | `FREEZE/SET-ONCE` | `SUB` | proof | Required only if final variants are pre-rendered rather than dynamically composited. |

## 15.2 Per-file manifest entry

Every committed file/object should have at least:

```text
logicalId
role
mediaType
byteLength
digestAlgorithm
digest
sourceVisibility
```

Optional media-specific derived facts:

```text
width
height
pageCount
duration
frameCount
```

Derived facts must be validated against the actual file.

## 15.3 Content identity vs delivery location

These are **not the same thing**.

Frozen:

- Reader manifest bytes/digest;
- canonical page/object manifest;
- canonical cover/base art bytes/digest;
- renderer rules;
- package root.

Operational and movable without changing the edition **only if the moved object still matches the frozen digest**:

- R2 bucket/key;
- CDN URL;
- Reader `private_prefix`;
- Reader manifest storage key;
- cache location.

A storage migration is allowed.

A silent content rewrite is not.

---

# 16. CANONICAL COVER & ART INPUTS

| Field | Type | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|
| `contentPackage.baseCover.logicalId` | stable package ID | `P D I` | `FREEZE` | root/sub | yes | Required for collectible art. |
| `contentPackage.baseCover.sourceFileRef` | local/upload temp ref | `D` | `DRAFT` | `NO` | no | Replaced by committed manifest identity. |
| `contentPackage.baseCover.digest` | hash | `P I` | `FREEZE` | sub | proof | Must match bytes. |
| `contentPackage.baseCover.mediaType` | MIME/type | `P I` | `FREEZE` | root | proof | Valid supported type. |
| `contentPackage.baseCover.width/height` | derived dimensions | `P I` | `FREEZE` | root | preview | Validate. |
| `contentPackage.markLayerFamilies[]` | Harrow-authored layers/masks/rules | `P D I` | `FREEZE` | sub-manifest | preview | Only if MARK enabled. |
| `contentPackage.defectLayerFamilies[]` | Harrow-authored layers/masks/rules | `P D I` | `FREEZE` | sub-manifest | preview | Only if DEFECT enabled. |
| `contentPackage.sharedRenderAssets[]` | fonts/textures/masks/etc. | `P D I` | `FREEZE` | sub-manifest | indirect | Every dependency needed for deterministic reproduction must be committed. |
| `contentPackage.artRightsRefs[]` | license/source references | `P D I` | `FREEZE` | root | package | Required where applicable. |

Default art production is deterministic/reproducible compositing from Harrow-approved source art, **not AI image generation**.

---

# 17. RENDERER / COMPOSITOR

| Field | Type | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|
| `renderer.rendererId` | stable renderer family | `F X P D U I` | `FREEZE` | `ROOT` | `PRESS VERSION`/proof | Required. |
| `renderer.rendererVersion` | exact version | `F X C P U I` | `FREEZE` | `ROOT/DIRECT-or-ref` | yes/proof | No silent version replacement. |
| `renderer.interfaceVersion` | metadata/render interface generation | `F C X P I` | `FREEZE` | `ROOT` | proof | Gate 4 kernel must establish compatibility point. |
| `renderer.rendererRef` | address/registry ID/adapter | `C X P I` | `FREEZE` if bound | `ROOT/DIRECT` | proof | Exact V1 transport is engineering work; release must record selection. |
| `renderer.rulesDigest` | committed compositor rules | `C P I` | `FREEZE` | `SUB/DIRECT` | proof | Must match package. |
| `renderer.renderEnvironmentVersion` | reproducibility environment/tool version | `P I` | `FREEZE` | `ROOT` | proof | Prevents "same inputs, different undocumented renderer." |
| `renderer.canvasSpec` | dimensions/color/profile | `P I` | `FREEZE` | `ROOT` | preview | Explicit. |
| `renderer.layerOrder` | deterministic order | `P I` | `FREEZE` | rules digest | preview | Must not be nondeterministic. |
| `renderer.blendRuleSet` | compositor behavior | `P I` | `FREEZE` | rules digest | preview | Explicit. |
| `renderer.variantMode` | dynamic composite / pre-rendered | `P C I` | `FREEZE` | `ROOT` | proof | Determines required asset commitments. |
| `renderer.reproducibilityReportDigest` | build proof/report | `P D I` | `FREEZE` | `ROOT/SUB` | optional proof | Builder must demonstrate representative outputs reproduce. |

Representative outputs are previewed before `PUBLISH`; Harrow does not manually author every token combination.

---

# 18. READER / PUBLICATION PACKAGE

| Field | Type | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|
| `reader.enabled` | bool | `C P D U I` | `FREEZE` | `ROOT` | yes | Native collectible may enable protected Reader. |
| `reader.presentationClass` | `BOOK`, `COMIC`, future `ENHANCED` | `P D U I` | `FREEZE` | `ROOT` | yes | Must match package. |
| `reader.accessPolicy` | e.g. `OWNERSHIP` | `C P D U I` | `FREEZE` | `ROOT` | yes | Gate 3 ownership authority remains source of Reader permission. |
| `reader.sourcePackageDigest` | source package/file root | `P I` | `FREEZE` | `SUB` | proof | Exact content identity. |
| `reader.manifestDigest` | generated Reader manifest | `P C I` | `FREEZE` | `SUB` | proof | Exact Reader presentation identity. |
| `reader.pageCount` | derived integer | `P D U I` | `FREEZE` | `ROOT` | yes/useful | Validate against manifest. |
| `reader.deliveryProvider` | `r2_private` etc. | `P D` | operational | `NO` unless part of package policy | no | Can migrate if bytes remain identical and access remains protected. |
| `reader.manifestStorageKey` | R2 key | `P` | operational | `NO` | no | D1 delivery pointer. |
| `reader.privatePrefix` | R2 prefix | `P` | operational | `NO` | no | D1 delivery pointer. |
| `reader.publicRetrievable` | normal protected release `false` | `P D` | policy | access rule in `ROOT`; operational state separate | no | Private Reader assets must not become public to simplify testing. |

Protected Reader content does not have to be made publicly downloadable/on-chain merely to prove integrity.

---

# 19. PRICING POLICY MODEL

A release may contain one or more frozen pricing policies so different phases can reference different predeclared economics.

Required supported policy modes:

```text
FREE
FIXED_STABLE
FIXED_PLS
USD_TARGET_DUAL
```

## 19.1 Pricing policy fields

| Field | Type | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|
| `pricingPolicies[].pricingPolicyId` | stable release-local ID | `C P D U I` | `FREEZE` | `ROOT` | yes | Unique. |
| `pricingPolicies[].mode` | required enum | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Must be supported by template. |
| `pricingPolicies[].displayTarget` | human display amount | `P D U I` | `FREEZE` | `ROOT` | yes | Must correspond to machine amount. |
| `pricingPolicies[].usdTargetAmount` | normalized USD target | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes when applicable | Required for `FIXED_STABLE`/`USD_TARGET_DUAL` as designed. |
| `pricingPolicies[].fixedNativeAmount` | wei amount | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Required for `FIXED_PLS`. |
| `pricingPolicies[].stableAmountRules` | per accepted stable route | `C P D U I` | `FREEZE` | `ROOT` | yes | Exact token units/normalization. |
| `pricingPolicies[].priceAdapterRef` | oracle/adapter address/ID | `C X P D U I` | `FREEZE` if required | `ROOT/DIRECT` | yes/proof | Required for `USD_TARGET_DUAL` native quote. |
| `pricingPolicies[].quoteMaxAgeSeconds` | freshness bound | `C X P D U I` | `FREEZE` | `ROOT` | yes | Prevent stale quote. |
| `pricingPolicies[].defaultToleranceBps` | Press default quote tolerance | `C P D U I` | `FREEZE` | `ROOT` | yes | Collector still approves transaction-specific maximum. |
| `pricingPolicies[].oracleFailurePolicy` | `REVERT` or approved frozen behavior | `C X P U I` | `FREEZE` | `ROOT` | yes | Must never silently substitute Harrow-entered live prices. |
| `pricingPolicies[].excessNativePolicy` | explicit refund/revert handling | `C P D U I` | `FREEZE` | `ROOT` | yes | Must be tested. |
| `pricingPolicies[].roundingPolicy` | deterministic rounding | `C X P I` | `FREEZE` | `ROOT` | proof | Avoid quote mismatches. |

### Mode validation

#### `FREE`
- no primary payment required;
- paid route amounts must be zero/disabled.

#### `FIXED_STABLE`
- accepted stable route(s) explicitly frozen;
- token address and exact unit math validated;
- no native PLS price drift logic.

#### `FIXED_PLS`
- fixed native PLS amount frozen;
- does not float with USD.

#### `USD_TARGET_DUAL`
- frozen USD target;
- one or more fixed stable route(s);
- current native PLS equivalent obtained from the frozen approved pricing-adapter architecture;
- quote freshness and tolerance enforced;
- collector sees exact current quote and maximum authorization before signing.

The exact PulseChain price source remains an open Gate 4 research/test item. The field boundary is already fixed by this blueprint.

---

# 20. ACCEPTED PAYMENT ROUTES

| Field | Type | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|
| `paymentRoutes[].routeId` | stable release-local ID | `C P D U I` | `FREEZE` | `ROOT` | yes | Unique. |
| `paymentRoutes[].pricingPolicyId` | reference | `C P I` | `FREEZE` | `ROOT` | yes | Must exist. |
| `paymentRoutes[].assetKind` | `NATIVE`, `ERC20` | `C P U I` | `FREEZE` | `ROOT/DIRECT` | yes | Supported type only. |
| `paymentRoutes[].assetAddress` | token address or native sentinel | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | ERC-20 code/metadata validated on target chain. |
| `paymentRoutes[].assetDecimals` | verified decimals | `P D U I` | `FREEZE` | `ROOT` | yes | Must match token contract where applicable. |
| `paymentRoutes[].assetDisplaySymbol` | display symbol | `P D U I` | `FREEZE` | `ROOT` | yes | Display only; address is authority. |
| `paymentRoutes[].enabled` | bool | `C P D U I` | `FREEZE` | `ROOT` | yes | Accepted routes cannot be silently added after publish. |
| `paymentRoutes[].settlementRouterRef` | treasury/payment adapter if needed | `C X P I` | `FREEZE` | `ROOT/DIRECT` | proof | Must support required asset. |

No bridged Hellbox NFT architecture is introduced by payment routing.

---

# 21. WALLET & TRANSACTION LIMITS

| Field | Standard native | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|
| `walletRules.primaryLifetimeCap` | `6` | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Cumulative primary issuance per wallet/publication. |
| `walletRules.maxPerTransaction` | `1` | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Contract-enforced; no batch public mint. |
| `walletRules.batchMintEnabled` | `false` | `C P U I` | `FREEZE` | template/root | yes | Standard native. |
| `walletRules.capSubject` | signing/claiming wallet | `C P U I` | `FREEZE` | `ROOT` | yes/proof | Contract accounting subject must be explicit; frontend identity cannot substitute for chain accounting. |
| `walletRules.mintRecipientPolicy` | V1 engineering default: `SELF_ONLY`; gift/alternate-recipient support requires an explicit frozen policy | `C P D U I` | `FREEZE` | `ROOT` | yes | Prevents implementation from silently choosing whether allowance applies to payer, claimant, or recipient. |
| `walletRules.sybilProtectionClaim` | hard `false` as product claim | `P U I` | `FREEZE` | `ROOT` | yes in docs/copy as needed | Wallet cap is not represented as Sybil protection. |

SciVive:

```text
primaryLifetimeCap = 1
maxPerTransaction = 1
```

Phase-specific wallet allowances may be lower than the release lifetime cap but may not create a path that exceeds the frozen release cap unless an explicit future release config changes that rule before publication.

---

# 22. MINT PHASES

The builder must support a general ordered phase model, including:

- creator pull;
- reserved/partner claims;
- free claims;
- allowlist/whitelist;
- early Press access;
- public Press.

Creator immediate allocation is modeled separately from collector phases, but its supply effect is included in phase math.

## 22.1 Phase fields

| Field | Type | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|
| `mintPhases[].phaseId` | stable ID | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Unique. |
| `mintPhases[].publicLabel` | Harrow-facing label | `P D U I` | `FREEZE` | `ROOT` | yes | Canonical English meaning frozen. |
| `mintPhases[].order` | integer | `C P I` | `FREEZE` | `ROOT` | yes/derived | No ambiguous ordering. |
| `mintPhases[].phaseType` | reserved/free/allowlist/early/public/etc. | `C P D U I` | `FREEZE` | `ROOT` | yes | Internal type separate from Harrow copy. |
| `mintPhases[].activationMode` | time/supply/condition/predeclared manual | `C P D U I` | `FREEZE` | `ROOT` | yes | Exact transition rule must be visible. |
| `mintPhases[].startAt` | timestamp/block if used | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Optional based on mode. |
| `mintPhases[].endAt` | timestamp/block if used | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Optional based on mode. |
| `mintPhases[].startCondition` | explicit condition object | `C P I` | `FREEZE` | `ROOT` | yes | Must be objectively evaluable or visibly designated manual. |
| `mintPhases[].endCondition` | explicit condition object | `C P I` | `FREEZE` | `ROOT` | yes | Same. |
| `mintPhases[].allocationMode` | `SHARED_POOL` / dedicated predeclared pool | `C P U I` | `FREEZE` | `ROOT` | yes | Standard non-Harrow direction uses shared remaining randomized pool. |
| `mintPhases[].phaseCap` | max claims/mints in phase | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Must fit issuance simulation. |
| `mintPhases[].phaseWalletCap` | per-wallet phase allowance | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Must not violate publication lifetime cap. |
| `mintPhases[].eligibilityMode` | none/Merkle/reserved proof/etc. | `C P D U I` | `FREEZE` | `ROOT` | yes | Proof type required where gated. |
| `mintPhases[].eligibilityRoot` | Merkle/root commitment | `C P D U I` | `FREEZE` | `ROOT/SUB/DIRECT` | root can be public | Required for Merkle-style phase. |
| `mintPhases[].eligibilityLeafSchemaVersion` | exact leaf encoding | `C F P I` | `FREEZE` | `ROOT` | proof | Prevents root ambiguity. |
| `mintPhases[].eligibilityManifestDigest` | off-chain source list/snapshot root | `P I` | `FREEZE` | `SUB` | proof | Full private list need not be public. |
| `mintPhases[].pricingPolicyId` | referenced policy | `C P D U I` | `FREEZE` | `ROOT` | yes | Allows free and paid phases without mutating policy later. |
| `mintPhases[].allowedPaymentRouteIds[]` | accepted routes in phase | `C P D U I` | `FREEZE` | `ROOT` | yes | Subset of frozen payment routes. |
| `mintPhases[].rolloverPolicy` | none/to-next/to-shared/etc. | `C P D U I` | `FREEZE` | `ROOT` | yes | Must be explicit. |
| `mintPhases[].traitPoolPolicy` | normally `GLOBAL_SHARED` | `C P U I` | `FREEZE` | `ROOT` | yes | Prevents secret privileged birth odds. |
| `mintPhases[].enabled` | bool in final config | `C P I` | `FREEZE` | `ROOT` | yes | Omitted phases should not exist as hidden future switches. |

### Phase math validation

The private Press must simulate the entire ordered issuance path.

It must reject configurations where any possible allowed collector sequence can exceed:

```text
nonTailIssuanceCapacity
=
maxSupply
- immediateCreatorCount
- tailReserveCount
```

That limit controls **how many normal non-tail primary issuances may occur**. It does not describe the random candidate pool.

For the standard native profile:

```text
initialCandidatePoolSize = 216 - 6 = 210
nonTailIssuanceCapacity    = 216 - 6 - 3 = 207
```

The final three are whichever candidates remain after the 207th normal non-tail primary issuance; they are not excluded before random assignment.

For shared-pool phases, simple sum-of-phase-caps may overstate actual capacity because rollover/reuse is possible. Validation must use the actual frozen allocation/rollover state machine, not naive arithmetic.

---

# 23. LIVE ODDS / RANDOM CANDIDATE POOL POLICY

The edition freezes **how odds are calculated**; the actual numbers change after each issuance.

| Field | Standard native | Home | Mutability | Commit | Public |
|---|---|---|---|---|---|
| `metadataPolicy.liveOddsEnabled` | `true` when birth traits randomized | `P D U I` | `FREEZE` | `ROOT` | yes |
| `metadataPolicy.oddsDenominator` | `ACTUAL_CANDIDATE_POOL_REMAINING` | `C/P U I` | `FREEZE` | `ROOT` | yes |
| `metadataPolicy.oddsTraitAxes[]` | `PRESS MARK`, `PRESS DEFECT` | `P U I` | `FREEZE` | `ROOT` | yes |
| `metadataPolicy.exhaustedTraitCopy` | canonical Harrow wording such as `GONE.` | `P U I` | `FREEZE` | `ROOT` | yes |
| `publicPressRuntime.candidatePoolRemaining` | integer | `C/P U A` | `DERIVED/RULED` | `NO` | yes |
| `publicPressRuntime.nonTailIssuanceRemaining` | integer | `C/P U A` | `DERIVED/RULED` | `NO` | yes |
| `publicPressRuntime.markRemaining` | counts | `C/P U A` | `DERIVED/RULED` | `NO` | yes |
| `publicPressRuntime.defectRemaining` | counts | `C/P U A` | `DERIVED/RULED` | `NO` | yes |
| `publicPressRuntime.markOdds` | percentages | `U A` | `DERIVED` | `NO` | yes |
| `publicPressRuntime.defectOdds` | percentages | `U A` | `DERIVED` | `NO` | yes |

Conceptual next-pull formula:

```text
candidate copies remaining that carry trait
--------------------------------------------
candidatePoolRemaining
```

`nonTailIssuanceRemaining` is the separate remaining non-tail primary issuance capacity and is **never** substituted for the candidate-pool denominator.

Standard native example after Harrow receives #001–#006:

```text
candidatePoolRemaining = 210
nonTailIssuanceRemaining = 207

if HELLBOUND remaining = 4:
next-pull HELLBOUND odds = 4 / 210 = 1.9047619...%
```

Near true mint-out:

```text
candidatePoolRemaining = 4
nonTailIssuanceRemaining = 1
```

After that final non-tail primary issuance:

```text
candidatePoolRemaining = 3
nonTailIssuanceRemaining = 0
→ award those exact three remaining copies to Harrow
```

Public odds are not decorative marketing numbers.

---

# 24. ROYALTY

| Field | Type | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|
| `royalty.enabled` | bool | `C P D U I` | `FREEZE` | `ROOT` | yes | Can be false/0. |
| `royalty.standard` | `ERC-2981` or selected supported mode | `C F P I` | `FREEZE` | `ROOT` | proof | Gate 4 baseline should support marketplace-readable royalty data. |
| `royalty.bps` | integer 0..10000 | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | SciVive = `369`. |
| `royalty.routerRef` | routing contract address | `C X P I` | `FREEZE` | `ROOT/DIRECT` | proof | Preferred over hard-wiring an operational wallet when routing rotation is needed. |
| `royalty.routeId` | immutable route identifier | `C X P I` | `FREEZE` | `ROOT` | proof | Route economic meaning must be clear. |
| `royalty.routePolicyDigest` | optional split/policy root | `X P I` | `FREEZE` | `SUB` | proof | If percentages/splits are promised, freeze them. |

Operational recipient wallet rotation may occur behind an approved routing system **only if it does not rewrite the frozen economic promise**.

`ERC-2981` communicates royalty information to compatible marketplaces. It does **not** guarantee that every marketplace, transfer or secondary sale will enforce or pay that royalty. Hellbox must not model secondary royalty revenue as guaranteed cash flow.


---

# 25. PRIMARY TREASURY / PROCEEDS ROUTING

| Field | Type | Home | Mutability | Commit | Public | Validation |
|---|---|---|---|---|---|---|
| `treasury.primaryRouterRef` | routing contract | `C X P D I` | `FREEZE` | `ROOT/DIRECT` | proof | Nonzero/code verified when paid. |
| `treasury.primaryRouteId` | route identifier | `C X P D I` | `FREEZE` | `ROOT` | proof | Must exist. |
| `treasury.primaryRoutePolicyDigest` | economic split/policy root | `X P I` | `FREEZE` | `SUB` | proof | Required when route has contractual split meaning. |
| `treasury.refundReceiverPolicy` | purchaser/refund behavior | `C P I` | `FREEZE` | `ROOT` | yes as needed | Must be explicit/tested. |

A routing module may support wallet rotation without giving Harrow authority to rewrite price, royalty percentage, supply, or collector ownership.

---

# 26. DYNAMIC METADATA POLICY

Dynamic metadata is mandatory architecture for native Hellbox artifacts and permitted for SciVive's narrower dynamic-cover/seal path.

| Field | Type | Home | Mutability | Commit | Public | Rule |
|---|---|---|---|---|---|---|
| `metadataPolicy.dynamicMetadataEnabled` | bool | `C P D U I` | `FREEZE` | `ROOT` | yes | Native standard: true. |
| `metadataPolicy.birthIdentityStable` | bool | `C P U I` | `FREEZE` | `ROOT` | yes | Copy ID/MARK/DEFECT do not drift. |
| `metadataPolicy.dynamicCoverEnabled` | bool | `C P D U I` | `FREEZE` | `ROOT` | yes | Cover may react only to enabled states/protocols. |
| `metadataPolicy.sealAttributeEnabled` | bool | `C P D U I` | `FREEZE` | `ROOT` | yes | If sealing enabled. |
| `metadataPolicy.archiveAttributeEnabled` | bool | `C P D U I` | `FREEZE` | `ROOT` | yes | If artifact Archive state supported. |
| `metadataPolicy.historyAttributeEnabled` | bool | `C P D U I` | `FREEZE` | `ROOT` | yes | Permanent history support. |
| `metadataPolicy.contextualTraitsEnabled` | bool | `C P D U I` | `FREEZE` | `ROOT` | yes | Current-wallet context may appear/disappear. |
| `metadataPolicy.archiveBalanceAttributeEnabled` | bool | `X P D U I` | `FREEZE` | `ROOT` | yes if reward system enabled | Official balance separate from arbitrary TBA assets. |
| `metadataPolicy.hellforgeStateEnabled` | bool | `C X P D U I` | `FREEZE` | `ROOT` | yes if compatible | Does not grant publisher transform power. |
| `metadataPolicy.pressVersionVisible` | bool | `P U I` | `FREEZE` | `ROOT` | yes | Canonical metadata can expose `PRESS VERSION`. |
| `metadataPolicy.refreshSignaling` | e.g. ERC-4906-compatible event support | `C F P I` | `FREEZE` | `ROOT/template` | proof | Marketplace refresh/update signaling required. |

### Canonical collector-facing vocabulary

Stable/locked:

```text
PRESS MARK
PRESS DEFECT
SEAL
ARCHIVE
ARCHIVE BALANCE
SET STATUS
PRESS VERSION
```

Current strong direction, still not final canon:

```text
LIVED THROUGH
INCIDENT LOG
```

The internal state field names can remain stable even if a future release chooses a different approved public label. Once a release is published, its canonical metadata label/value mapping is part of that release's frozen configuration.

---

# 27. SEALED / ARCHIVE / UNSEALED CAPABILITY

These are capability rules, not merely UI labels.

## 27.1 Seal

| Field | Type / standard direction | Home | Mutability | Commit | Public |
|---|---|---|---|---|---|
| `capabilities.seal.enabled` | bool | `C P D U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.seal.initialState` | `SEALED` | `C P U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.seal.breakIsPermanent` | `true` | `C P U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.seal.resealAllowed` | `false` | `C P U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.seal.breakRequiresOwnerAuthorization` | `true` | `C P U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.seal.breakRequiresUnarchived` | `true` when Archive enabled | `C X P U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.seal.breakRewardFinalizationRule` | configured if official rewards enabled | `C X P U I` | `FREEZE` | `ROOT` | yes |

## 27.2 Archive compatibility

| Field | Type / standard direction | Home | Mutability | Commit | Public |
|---|---|---|---|---|---|
| `capabilities.archive.enabled` | bool | `C X P D U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.archive.onlyWhileSealed` | `true` | `C X P U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.archive.reversibleWhileSealed` | `true` | `C X P U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.archive.transferLockWhileArchived` | `true` | `C X P U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.archive.visualSleeveEnabled` | bool | `P U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.archive.officialRewardsEnabled` | bool | `X P D U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.archive.unclaimedBalanceFollowsToken` | configured when rewards enabled | `X P U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.archive.thirdPartyListingGuarantee` | hard `NO_OFFCHAIN_LISTING_GUARANTEE` | `P U I` | `FREEZE` | `ROOT` | yes/honesty | Contract can block transfer execution, not third-party signed-listing display. |

The later Gate 7 Archive protocol implements full behavior. Gate 4 must not choose a kernel shape that makes this impossible.

---

# 28. ERC-6551 / TOKEN-BOUND ACCOUNT COMPATIBILITY

| Field | Type | Home | Mutability | Commit | Public | Rule |
|---|---|---|---|---|---|---|
| `capabilities.erc6551.compatible` | bool | `C F X P D U I` | `FREEZE` | `ROOT` | yes/proof | Required for Native Issue #1 capability. |
| `capabilities.erc6551.registryRef` | standard registry reference if chain-specific binding needed | `X P I` | `FREEZE` if bound | `ROOT` | proof | Exact integration can be external. |
| `capabilities.erc6551.accountImplementationRef` | optional approved account implementation/version | `X P I` | frozen if release binds | `ROOT` | proof | Do not give Hellbox sweep authority. |
| `capabilities.erc6551.publisherSweepAuthority` | hard `false` | `F C I` | `FREEZE` | template invariant | proof | Non-configurable security invariant. |

Arbitrary assets placed in a token-bound account are not the same thing as Hellbox official Archive rewards.

---

# 29. OFFICIAL ARCHIVE REWARD PROTOCOL COMPATIBILITY

| Field | Type | Home | Mutability | Commit | Public | Rule |
|---|---|---|---|---|---|---|
| `capabilities.rewards.compatible` | bool | `C X P D U I` | `FREEZE` | `ROOT` | yes | Native Issue #1 must preserve compatibility; SciVive full reward path remains off unless explicitly reopened. |
| `capabilities.rewards.protocolClass` | stable interface/class ID | `F X P I` | `FREEZE` | `ROOT` | proof | Allows modular protocol versions. |
| `capabilities.rewards.protocolBindingMode` | direct/registry/generic-compatible | `C X P I` | `FREEZE` | `ROOT` | proof | Exact Gate 7 protocol binding remains open. |
| `capabilities.rewards.accrualEligibilityRule` | Archive + sealed rule | `X P U I` | `FREEZE` | `ROOT` | yes | Frozen before release if enabled. |
| `capabilities.rewards.claimRule` | owner/current-token-holder rules | `X P U I` | `FREEZE` | `ROOT` | yes | Final protocol later. |
| `capabilities.rewards.unsealFinalizationRule` | clear/finalize/claim policy | `X P U I` | `FREEZE` | `ROOT` | yes | Must be explicit before any reward-enabled release. |
| `capabilities.rewards.publicTokenName` | neutral before reward launch | `P U I` | `FREEZE per release` | `ROOT` | yes | Do not expose future `$SIN` by name before approved launch. |

---

# 30. HELLFORGE / BURN / EVOLUTION COMPATIBILITY

| Field | Type | Home | Mutability | Commit | Public | Rule |
|---|---|---|---|---|---|---|
| `capabilities.hellforge.compatible` | bool | `C X P D U I` | `FREEZE` | `ROOT` | yes | Native Issue #1 required compatibility. |
| `capabilities.hellforge.protocolClass` | interface/class ID | `F X P I` | `FREEZE` | `ROOT` | proof | Prefer modular external machinery. |
| `capabilities.hellforge.ownerAuthorizationRequired` | hard `true` | `C X P U I` | `FREEZE` | `ROOT/template` | yes | Harrow cannot transform/burn owner's artifact unilaterally. |
| `capabilities.hellforge.publisherForcedBurn` | hard `false` | `F C I` | `FREEZE` | template invariant | proof | Non-configurable. |
| `capabilities.hellforge.permanentEvolutionSupported` | bool | `C X P D U I` | `FREEZE` | `ROOT` | yes | Later protocol can write permitted permanent state. |
| `capabilities.hellforge.hiddenTraitsSupported` | bool | `C X P D U I` | `FREEZE` | `ROOT` | yes | Exact hidden-trait recipe not required at Gate 4. |
| `capabilities.hellforge.burnToTransformSupported` | bool | `C X P D U I` | `FREEZE` | `ROOT` | yes | Any burn must produce a direct compelling participant result, not exist only to reduce supply. |
| `capabilities.hellforge.historyRecordingSupported` | bool | `C X P D U I` | `FREEZE` | `ROOT` | yes | Permanent incident/history integration. |

Recipes can be introduced by compatible protocols later if the release's frozen compatibility policy allows them; the publication contract must never gain a secret publisher burn path.

---

# 31. CONTEXTUAL TRAIT COMPATIBILITY

| Field | Type | Home | Mutability | Commit | Public |
|---|---|---|---|---|---|
| `capabilities.contextualTraits.enabled` | bool | `C X P D U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.contextualTraits.seriesSetStatusEnabled` | bool | `X P D U I` | `FREEZE` | `ROOT` | yes |
| `capabilities.contextualTraits.contextSourcePolicy` | on-chain/current-wallet verified sources | `X P I` | `FREEZE` | `ROOT` | proof |
| `metadataPolicy.setStatusLabel` | canonical `SET STATUS` | `P U I` | `FREEZE` | `ROOT` | yes |
| `artifactState.contextualSetStatus` | e.g. `COMPLETE` / `MISSING PIECES` | `X/P U A` | `EXTERNAL/DERIVED` | `NO` | yes |

Contextual state may disappear when current circumstances stop being true. It must not be confused with permanent artifact history.

---

# 32. PUBLICATION CLOSURE / FINALIZATION POLICY

A standard native release may permanently close before max supply, but that power cannot be vague.

| Field | Type | Home | Mutability | Commit | Public | Rule |
|---|---|---|---|---|---|---|
| `closurePolicy.earlyCloseAllowed` | bool | `C P D U I` | `FREEZE` | `ROOT` | yes | If false, only configured terminal conditions close minting. |
| `closurePolicy.closeAuthority` | explicit narrow authority endpoint/reference if enabled | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes/proof | Must not imply seizure authority. For real releases with early close enabled, do not freeze a fragile personal EOA as the permanent endpoint; use the approved rotation-safe `publisherAuthority` strategy once that strategy is proven. |
| `closurePolicy.closeIsPermanent` | `true` | `C P U I` | `FREEZE` | `ROOT` | yes | No reopen after permanent close. |
| `closurePolicy.unmintedCapacityEffect` | destroy/retire according to final design | `C P U I` | `FREEZE` | `ROOT` | yes | Exact implementation must be fixed before real release. |
| `closurePolicy.tailReserveOnEarlyClose` | standard `FORFEIT_TAIL` | `C P U I` | `FREEZE` | `ROOT` | yes | Harrow does not confiscate final three. |
| `closurePolicy.closeEventRequired` | true | `C P I` | `FREEZE` | template/root | proof | Indexable permanent event. |
| `artifactState.primaryMintClosed` | bool | `C P U A` | `RULED` | `NO` | yes |
| `artifactState.closedAt` | block/time | `C P U A` | `SET-ONCE` | event | yes |
| `artifactState.trueMintOutReached` | bool | `C P U A` | `RULED/SET-ONCE` | event | yes |

The exact early-close mechanics are an implementation detail to prove in Gate 4; the blueprint requires the policy to be explicit and frozen.

---

# 32A. RELEASE FINALIZATION / FREEZE STATE

These fields make the `PUBLISH` boundary machine-verifiable rather than merely procedural.

| Field | Type | Home | Mutability | Commit | Public | Rule |
|---|---|---|---|---|---|---|
| `finalization.configFrozen` | bool | `C F P U A` | `SET-ONCE` | event/direct | yes | Must become true atomically with successful publish/deployment or through a one-way finalization step that precedes any collector mint. |
| `finalization.releaseConfigDigest` | bytes32/root | `C F P U I` | `SET-ONCE` | `DIRECT` | yes | Exact digest approved in the private Press. |
| `finalization.packageDigest` | bytes32/root | `C F P U I` | `SET-ONCE` | `DIRECT` | yes | Exact committed package identity. |
| `finalization.templateVersion` | version | `C F P U I` | `SET-ONCE` | `DIRECT` | yes | Must match selected registry version. |
| `finalization.frozenAtBlock` | block number | `C/P U A` | `SET-ONCE` | event | yes/proof | Chain fact. |
| `finalization.frozenAtTimestamp` | timestamp | `C/P U A` | `SET-ONCE` | event | yes/proof | Chain fact. |
| `finalization.collectorMintEnabledOnlyAfterFreeze` | hard `true` | `F C I` | `FREEZE` | template invariant | proof | No collector can mint against an editable release. |
| `finalization.postPublishConfigMutationAllowed` | hard `false` | `F C I` | `FREEZE` | template invariant | proof | Non-configurable. |

Preferred Gate 4 direction is an atomic factory publish/deploy flow that receives the already-resolved immutable configuration and leaves no editable post-deployment configuration window. If Gate 4 testing requires a separate one-way finalize step, the contract must prohibit collector minting before finalization and prohibit every frozen setter afterward.

---

# 32B. RELEASE AUTHORITY FIELDS

A publication may need a known publisher authority for narrowly defined lifecycle actions such as an explicitly configured permanent early close. The address and its powers must be explicit.

| Field | Type | Home | Mutability | Commit | Public | Rule |
|---|---|---|---|---|---|---|
| `authority.publisherAuthority` | narrow operational authority endpoint | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes/proof | This is **not publisher identity and not generic ownership**. It is the endpoint authorized only for explicitly frozen lifecycle actions. For a real release that enables a long-lived action such as early close, the resolved endpoint must use a rotation-safe control strategy rather than freezing a fragile personal EOA forever. |
| `authority.allowedPublisherActions[]` | explicit action codes | `C P D U I` | `FREEZE` | `ROOT` | yes | Must be a narrow whitelist; no implicit owner superpowers. |
| `authority.closeAuthority` | role/address reference | `C P D U I` | `FREEZE` | `ROOT/DIRECT` | yes | Required only if early close is enabled. It must resolve to `publisherAuthority` or another explicitly approved narrow, rotation-safe endpoint; it must never imply generic ownership/seizure power. |
| `authority.randomnessRequestAuthority` | contract/provider/publisher as required by approved scheme | `C X P I` | `FREEZE` | `ROOT` | proof | Must not permit publisher reroll/manipulation. |
| `authority.metadataMutationAuthority` | hard rule: state transitions/approved renderer only, not arbitrary publisher edits | `C F X I` | `FREEZE` | template/root | proof | Dynamic metadata must follow state, not a publisher text/image override switch. |

If no publisher-authorized action is needed, the safest resolved configuration is to expose no generic publication-owner mutation role at all.

The V1 kernel field name is `publisherAuthority`. Harrow/Hellbox publisher identity belongs in credits and public presentation; the operational authority endpoint is a separate concept. Gate 4 does **not** invent a new controller contract merely to solve rotation. Before a mainnet release enables a persistent publisher-authorized lifecycle action, the endpoint strategy must be explicitly proven rotation-safe.

---

# 33. PUBLISHER / ADMIN POWER BOUNDARIES

These are **template invariants**, not toggles Harrow can turn on per release.

A released publication must not support:

```text
publisher seizure
forced transfer
arbitrary confiscation
wallet blacklist ownership override
publisher-only arbitrary token burn
post-PUBLISH max-supply increase
post-PUBLISH price rewrite
post-PUBLISH trait-count rewrite
post-PUBLISH fixed-copy rewrite
post-PUBLISH creator-allocation rewrite
post-PUBLISH package/content digest rewrite
post-PUBLISH renderer-rule rewrite
post-PUBLISH royalty-bps rewrite
post-PUBLISH phase-rule rewrite
post-PUBLISH wallet-limit rewrite
silent template implementation replacement
```

Any operational safety feature introduced later, such as a mint pause, must be separately architecture-reviewed, narrowly scoped, publicly disclosed, and incapable of rewriting ownership or release economics. It is **not** silently assumed by this blueprint.

---

# 34. EVENT / INDEXING REQUIREMENTS

These are part of the template/version contract and package expectations, not arbitrary frontend behavior.

At minimum Gate 4 architecture must support indexable evidence for:

| Event concept | Required source | Purpose |
|---|---|---|
| publication deployed/published | factory | `(chainId, contractAddress)`, template/version, config digest |
| release config frozen | factory/publication | proves immutable release boundary |
| creator immediate pull | publication | supply/provenance transparency |
| copy pressed/minted | publication | tokenId/copy, phase, payer/recipient as appropriate |
| payment route used | publication/router | auditable primary economics |
| random assignment/reveal | publication/randomness adapter | prove hidden assignment lifecycle without leaking early |
| trait assignment finalized | publication/renderer state | permanent birth identity |
| tail reserve awarded | publication | prove true-mintout final three |
| publication permanently closed | publication | supply finality |
| seal broken | publication/protocol | permanent state |
| archived/unarchived | publication/protocol | transfer-lock state |
| metadata update signal | publication/renderer | marketplace refresh |
| Hellforge/evolution event | external protocol/publication | permanent artifact history |
| burn/consume event | publication/protocol | owner-authorized terminal/transformation path |

If a reveal model intentionally keeps traits hidden until later, mint events must not accidentally leak the hidden assignment.

---

# 35. METADATA REFRESH SIGNALING

Gate 4 must establish a metadata refresh interface/event baseline compatible with dynamic metadata.

Engineering default direction:

- support ERC-4906-style `MetadataUpdate` / `BatchMetadataUpdate` signaling where practical;
- also emit Hellbox-specific state events when useful;
- never assume every marketplace will refresh perfectly;
- public Press/Archive/Reader remain authoritative Hellbox presentations even if a third-party marketplace caches metadata.

The exact renderer implementation lands later, but the Gate 4 kernel must not block this signaling.

---

# 36. CRYPTOGRAPHIC COMMITMENT MODEL

The private Press must not merely display a summary and hope the deployment matches it.

## 36.1 Required commitment hierarchy

At `PUBLISH`, produce at least:

```text
releaseConfigDigest
packageDigest
template/version provenance
```

Recommended inspectable sub-commitments:

```text
baseArtManifestDigest
readerManifestDigest
readerObjectManifestDigest
markLayerManifestDigest
defectLayerManifestDigest
distributionManifestDigest
fixedAssignmentManifestDigest
rendererRulesDigest
metadataTemplateDigest
creditsManifestDigest
eligibilityManifestDigest(s)
treasury/royalty route policy digest(s) when applicable
```

## 36.2 Root coverage rule

`releaseConfigDigest` must cover **every field marked `I`**, directly or by including the sub-digest that binds that field set.

If a field is part of a public release promise but exists only in D1/package form, it still must be covered by the frozen root.

## 36.3 Encoding/version rule — HELLBOX_ABI_V1 LOCKED

Gate 4 implementation has now frozen the first release-fingerprint encoding as **`HELLBOX_ABI_V1`**.

Protocol constants:

```text
COMMITMENT_SCHEME_VERSION = 1
CONFIG_SCHEMA_VERSION     = 1
PUBLICATION_VERSION       = 1
TEMPLATE_ID               = keccak256("HELLBOX_PUBLICATION")
RELEASE_CONFIG_DOMAIN     = keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG")
```

`CommitmentSet` contains the exact ordered 18 `bytes32` sub-commitments defined by the V1 kernel. Reordering, omitting, or reinterpreting those fields requires a new version.

Aggregate commitment digest:

```text
commitmentsDigest = keccak256(abi.encode(commitments))
```

Frozen release fingerprint:

```text
releaseConfigDigest = keccak256(
  abi.encode(
    RELEASE_CONFIG_DOMAIN,
    COMMITMENT_SCHEME_VERSION,
    CONFIG_SCHEMA_VERSION,
    PUBLICATION_VERSION,
    TEMPLATE_ID,
    chainId,
    factoryAddress,
    releaseConfig,
    commitments
  )
)
```

Rules:

- use standard ABI encoding; **never packed encoding** for this V1 fingerprint;
- constructor deployment uses the actual `block.chainid` and actual deploying factory address (`msg.sender`);
- `template.factoryVersion` is registry/deployment metadata and **does not become a field inside `ReleaseConfig`**; the actual factory address cryptographically binds the factory generation selected for V1;
- the private Press computes the expected digest before deployment;
- constructor validation recomputes the digest and reverts on mismatch;
- Press-side JavaScript uses pinned `viem` `2.55.19` to reproduce the exact Solidity ABI encoding;
- JavaScript does not silently normalize or rewrite release text at fingerprint time; canonicalization belongs to earlier Press validation;
- existing per-file SHA-256 evidence may remain useful for package/file integrity, but the V1 release fingerprint is the versioned EVM-verifiable `keccak256(abi.encode(...))` scheme above.

### 36.3.1 Cross-language golden-vector proof

The committed golden vector independently verifies that the JavaScript and Solidity encoders agree on:

```text
chainId                 = 943
golden factory          = 0x5555555555555555555555555555555555555555
TEMPLATE_ID             = 0xa90f1cffe90023915c9a1a9852bcc46202522e86f77973f82c4235e837abdfba
RELEASE_CONFIG_DOMAIN   = 0x2bc593326bff52216bd201a52f68bc01b8a51a43c6b742788d138a7abe94ca25
commitmentsDigest       = 0xb6a0722a62b0309c6a082152ddff7e1ffc544669e8d690047a7516799081ecf6
releaseConfigDigest     = 0x66e6697d8fde60531eebed0882030a1c6beecf086b04926599a39878d4e0d15d
```

Current proof status: `testJavascriptAndSolidityGoldenVectorMatch()` passes. The verified post-push Gate 4 regression is **65 passed / 0 failed** across kernel, factory, deterministic issuance, publication policy-anchor, modular birth-policy and cross-language golden-vector suites. The issuance fuzz boundary passes 256 runs.

## 36.4 Deployment-time enforcement preimages — LOCKED BOUNDARY

`HELLBOX_ABI_V1` intentionally binds a `CommitmentSet` containing policy digests rather than placing every rich policy field directly inside `ReleaseConfig`.

When a committed policy must also be enforced on-chain, Gate 4 may pass a canonical **deployment-time enforcement payload/preimage** to the publication/factory without adding that payload as a new release-fingerprint field, provided:

1. its canonical encoding hashes to the already-bound corresponding commitment digest;
2. the publication validates that hash before activating issuance;
3. no uncommitted value can influence collector behavior;
4. the resolved enforcement payload is immutable for that release;
5. a mismatch reverts before collector issuance;
6. no post-deployment setter/configuration window is created.

Policy families that may need enforcement preimages include:

```text
fixedCopyRulesDigest
birthTraitsDigest
randomizationPolicyDigest
pricingPoliciesDigest
paymentRoutesDigest
mintPhasesDigest
closurePolicyDigest
authorityPolicyDigest
```

Current implementation boundary:

- `HellboxPublication` now implements versioned canonical typed preimage hashing for `fixedCopyRulesDigest`, `birthTraitsDigest`, and `randomizationPolicyDigest`, permanently anchors those three commitment digests, and exposes mismatch-verification helpers/tests without changing `ReleaseConfig`, `CommitmentSet`, or the `HELLBOX_ABI_V1` fingerprint;
- `HellboxBirthPolicy V1` uses the same canonical enforcement domains/typed structures and independently verifies all three supplied preimages against the frozen digest anchors while loading inventory/reservation/randomization-policy state;
- the size-safe factory still appends only ABI-encoded `ReleaseConfig`, `CommitmentSet`, and `expectedReleaseConfigDigest` to the exact approved publication creation bytecode;
- the publication constructor does **not yet receive** the three enforcement preimages, does **not yet create/store** its companion, and the factory does **not yet transport** those preimages;
- therefore the next implementation may deliberately evolve the pre-deployment factory/publication call/constructor ABI to carry those narrow typed preimages, but it must not change the frozen release-fingerprint field order/meaning merely for convenience;
- the preferred topology to test is atomic `HellboxPublication` constructor creation of exactly one `HellboxBirthPolicy`, because the companion's constructor can then bind `publication = msg.sender` with no setter/initializer/predicted-address trick;
- that topology is conditional on exact combined compile/deployability evidence, including EIP-170 runtime and EIP-3860 initcode headroom; if it fails a chain boundary, stop and redesign rather than adding an upgrade/configuration escape hatch;
- it must not use a post-deploy setter, uncommitted collector-affecting value, generic arbitrary constructor-data execution surface, proxy, clone, `delegatecall`, or arbitrary implementation registry;
- any publication source/constructor change changes the exact creation bytecode and therefore requires recalculating the approved creation-code hash used by the factory generation;
- no V1 factory/publication has been deployed yet, so a coherent pre-deployment V1 interface correction is allowed without pretending a deployed V1 was upgraded.

This preserves the proven `HELLBOX_ABI_V1` golden vector while moving already-committed policy toward real atomic EVM enforcement.

**If implementation would require changing the release-fingerprint field order or field meaning instead, STOP.**

## 36.5 No plaintext secret-map requirement

The root commitment must not require Harrow's browser to possess the entire future hidden trait-to-ID map before reveal.

The randomness scheme may commit the algorithm/pools/provider and later publish an immutable assignment proof/root when the map becomes legitimately known.

---

# 37. DEPLOYMENT / PROVENANCE RECORD

These fields are system-generated at `PUBLISH` and stored durably.

| Field | Home | Mutability | Commit | Public |
|---|---|---|---|---|
| `deploymentRecord.chainId` | `C F P U` | `SET-ONCE` | config provenance | yes |
| `deploymentRecord.factoryAddress` | `F P U` | `SET-ONCE` | config provenance | yes |
| `deploymentRecord.approvedPublicationCreationCodeHash` | `F P U` | `SET-ONCE factory-generation provenance` | registry/factory immutable evidence | yes/proof |
| `deploymentRecord.templateId` | `F P U` | `SET-ONCE` | config provenance | yes |
| `deploymentRecord.templateVersion` | `F C P U` | `SET-ONCE` | config provenance | yes |
| `deploymentRecord.instanceRuntimeCodeHash` | `F P U` | `SET-ONCE` | event/chain forensic evidence | yes/proof |
| `deploymentRecord.contractAddress` | `C F P U` | `SET-ONCE` | event | yes |
| `deploymentRecord.deploymentTxHash` | `P U` | `SET-ONCE` | external chain fact | yes/proof |
| `deploymentRecord.deploymentBlock` | `P U` | `SET-ONCE` | external chain fact | yes/proof |
| `deploymentRecord.releaseConfigDigest` | `C F P U` | `SET-ONCE` | `DIRECT` | yes |
| `deploymentRecord.packageDigest` | `C F P U` | `SET-ONCE` | `DIRECT` | yes |
| `deploymentRecord.publishedAt` | `C/P U` | `SET-ONCE` | event | yes |
| `deploymentRecord.publisherAuthority` | factory publishing authority endpoint observed for deployment | `F/P` | `SET-ONCE` | event/chain fact | proof |

D1 may cache/display this record, but the chain is authoritative for deployed contract address and transaction facts.

For V1, there is no shared publication implementation field in the deployment record. `approvedPublicationCreationCodeHash` identifies the exact reviewed creation bytecode authorized by that factory generation; `instanceRuntimeCodeHash` is captured only after deployment and proves the exact deployed instance. Neither changes `HELLBOX_ABI_V1`, and the instance runtime hash is not compared against a universal publication hash. The recorded publishing authority may be a Safe or controller contract; it represents the authority endpoint that performed the deployment, not an asserted individual human identity.

---

# 38. PRIVATE PRESS DRAFT STATE

These fields are necessary for the builder but are **not** immutable release promises.

| Field | Home | Mutability | Commit | Public |
|---|---|---|---|---|
| `privateDraft.draftId` | `D P` | `DRAFT` | `NO` | no |
| `privateDraft.createdAt` | `D P` | `DRAFT` | `NO` | no |
| `privateDraft.updatedAt` | `D P` | `DRAFT` | `NO` | no |
| `privateDraft.createdBySession` | `D P` | `DRAFT` | `NO` | no |
| `privateDraft.builderPresetId` | `D` | `DRAFT` | `NO` | no |
| `privateDraft.notes` | `D` | `DRAFT` | `NO` | no |
| `privateDraft.uploadTempRefs[]` | `D` | `DRAFT` | `NO` | no |
| `privateDraft.previewSeed` | `D` | `DRAFT` | `NO` | no; must not become hidden authoritative rarity seed accidentally |
| `privateDraft.validationStatus` | `D P` | `DRAFT` | `NO` | no |
| `privateDraft.validationErrors[]` | `D P` | `DRAFT` | `NO` | no |
| `privateDraft.validationWarnings[]` | `D P` | `DRAFT` | `NO` | no |
| `privateDraft.lastValidatedDigest` | `D P` | `DRAFT` | `NO` | no |
| `privateDraft.previewReportRef` | `D P` | `DRAFT` | `NO` | no |
| `privateDraft.publishReady` | `D P` | `DRAFT` | `NO` | no |
| `privateDraft.unsavedChanges` | `D` | `DRAFT` | `NO` | no |

Changing any committed field after validation invalidates the previous validation/preview and requires a new full validation before `PUBLISH`.

---

# 39. D1 / PACKAGE LIFECYCLE STATE

D1 is durable application state, not ownership authority and not a substitute for chain-enforced release rules.

Suggested publication-compiler lifecycle:

```text
DRAFT
VALIDATING
VALIDATED
COMMIT_READY
PUBLISHED
PRESS_SCHEDULED
PRESS_OPEN
PRESS_CLOSED
```

The exact database enum can be implemented later, but the semantics must preserve:

- private draft can change;
- validated snapshot is not yet published;
- `PUBLISH` is irreversible for release config;
- public Press open/closed state follows chain/frozen schedule;
- D1 cannot pretend a chain deployment happened when it did not.

Key D1/compiler fields:

| Field | Home | Authority |
|---|---|---|
| `publicationKey` | `P` | Hellbox conceptual identity; must match release config |
| package status | `P` | operational compiler state |
| public/private visibility | `P` | site/catalog state |
| publishing enabled | `P` | operational gate; cannot override contract rules |
| target chain | `P` | must match frozen config/deployment |
| contract address | `P` cache/reference | chain deployment is authoritative |
| template/version | `P` | must match factory/contract |
| config digest | `P` | must match chain |
| package digest | `P` | must match chain |
| Reader manifest key | `P` | movable operational pointer |
| Reader private prefix | `P` | movable operational pointer |
| validation report | `P` | builder evidence |
| deployment tx/block | `P` | chain-derived evidence |
| press visibility | `P` | UI state; cannot mint outside contract rules |
| catalog visibility | `P` | UI state |
| last chain verification | `P` | cache/evidence only |

---

# 40. PUBLIC PRESS DISPLAY CONTRACT

The public Press must communicate both frozen promises and live machine state.

## 40.1 Frozen/static display

The Press should expose as applicable:

- publication title/cover;
- chain;
- `PRESS VERSION`;
- total run/max supply;
- Harrow immediate pull;
- Harrow tail reserve and its true-mintout condition;
- fixed public grails/rules Harrow has chosen to disclose;
- pricing mode(s);
- accepted payment assets/routes;
- phase schedule/rules;
- publication lifetime wallet allowance;
- `1 COPY PER TRANSACTION`;
- royalty;
- seal/archive capabilities;
- relevant irreversible state warnings;
- release/config proof digest(s);
- package/renderer/version proof where appropriate.

Public Harrow jokes, localization wording, layout, and explanatory presentation copy may evolve without changing the edition **only when they do not alter or contradict a frozen promise**. The immutable configuration and its proof digest remain the authority.

## 40.2 Live runtime display

| Field | Source | Mutability |
|---|---|---|
| `publicPressRuntime.publication` | frozen config | `DERIVED` |
| `publicPressRuntime.currentPhase` | contract/config/time | `DERIVED/RULED` |
| `publicPressRuntime.phaseAllocation` | frozen config | `DERIVED` |
| `publicPressRuntime.phaseClaimed` | chain state | `RULED` |
| `publicPressRuntime.totalMinted` | chain state | `RULED` |
| `publicPressRuntime.totalRemaining` | chain state | `DERIVED` |
| `publicPressRuntime.candidatePoolRemaining` | chain random-pool state | `DERIVED` |
| `publicPressRuntime.nonTailIssuanceRemaining` | chain issuance-limit state | `DERIVED` |
| `publicPressRuntime.creatorImmediateTaken` | chain state, standard `6` after publish | `SET-ONCE` |
| `publicPressRuntime.tailStillInMachine` | chain state | `RULED` |
| `publicPressRuntime.connectedWallet` | wallet/browser | session/runtime |
| `publicPressRuntime.walletVerified` | Gate 3 wallet authority | runtime |
| `publicPressRuntime.walletEligibility` | contract/proof + Gate 3 identity as needed | runtime |
| `publicPressRuntime.walletLifetimeUsed` | chain state | `RULED` |
| `publicPressRuntime.walletLifetimeRemaining` | derived | `DERIVED` |
| `publicPressRuntime.phaseWalletUsed` | chain state | `RULED` |
| `publicPressRuntime.phaseWalletRemaining` | derived | `DERIVED` |
| `publicPressRuntime.freeStatus` | eligibility/config | runtime |
| `publicPressRuntime.reserveStatus` | eligibility/config | runtime |
| `publicPressRuntime.allowlistStatus` | eligibility/config | runtime |
| `publicPressRuntime.paymentRoutes` | frozen config | `DERIVED` |
| `publicPressRuntime.currentNativeQuote` | approved pricing adapter | `EXTERNAL/DERIVED` |
| `publicPressRuntime.quoteTimestamp` | adapter | `EXTERNAL` |
| `publicPressRuntime.quoteExpiresAt` | frozen freshness rule + quote | `DERIVED` |
| `publicPressRuntime.collectorMaxAuthorizedNative` | collector transaction input | per transaction |
| `publicPressRuntime.markRemaining` | random pool state | `RULED` |
| `publicPressRuntime.markOdds` | derived | `DERIVED` |
| `publicPressRuntime.defectRemaining` | random pool state | `RULED` |
| `publicPressRuntime.defectOdds` | derived | `DERIVED` |
| `publicPressRuntime.machineState` | ready/pressing/reveal/fault/closed | runtime |
| `publicPressRuntime.transactionState` | wallet/chain | runtime |
| `publicPressRuntime.lastEjectedCopyId` | confirmed mint | `SET-ONCE per transaction view` |
| `publicPressRuntime.lastEjectedMark` | confirmed assignment | `SET-ONCE per token` |
| `publicPressRuntime.lastEjectedDefect` | confirmed assignment | `SET-ONCE per token` |
| `publicPressRuntime.lastEjectedSealState` | token state | `RULED` |
| `publicPressRuntime.faultCode` | chain/adapter/Worker | runtime |

After every confirmed single-copy issuance the UI must refresh authoritative state before enabling/quoting the next pull.

---

# 41. ARTIFACT STATE MODEL

The artifact can change after `PUBLISH`, but only inside this boundary.

## 41.1 Permanent birth identity

| State | Home | Mutability | Rule |
|---|---|---|---|
| `artifactState.tokenId` | `C A U` | `SET-ONCE` | tokenId is copy number. |
| `artifactState.birthMark` | `C/P A U` | `SET-ONCE` | Permanent after assignment. |
| `artifactState.birthDefect` | `C/P A U` | `SET-ONCE` | Permanent after assignment. |
| `artifactState.mintedAt` | `C/P A` | `SET-ONCE` | Chain fact. |
| `artifactState.originalMinter` | `C/P A` | `SET-ONCE` if tracked | Historical evidence only; current owner remains ERC-721 authority. |

## 41.2 Ordinary ERC-721 state

| State | Home | Mutability | Rule |
|---|---|---|---|
| `artifactState.owner` | `C A` | `RULED` | Normal owner transfer except frozen Archive transfer lock. |
| `artifactState.approvals` | `C A` | `RULED` | Standard ERC-721 behavior subject to transfer lock rules. |
| `artifactState.exists` | `C A` | `RULED/terminal` | Can become false only through allowed owner-authorized burn/consume behavior. |

## 41.3 Seal state

```text
SEALED -> UNSEALED
```

No reverse transition.

| State | Home | Mutability |
|---|---|---|
| `artifactState.seal` | `C A U` | `RULED; irreversible once broken` |
| `artifactState.unsealedAt` | `C/P A` | `SET-ONCE` |

## 41.4 Archive state

While seal remains intact:

```text
AVAILABLE <-> ARCHIVED
```

After unseal:

```text
INELIGIBLE
```

| State | Home | Mutability |
|---|---|---|
| `artifactState.archive` | `C/X A U` | `RULED` |
| `artifactState.archivedAt` | `C/X/P A` | `RULED/history` |
| `artifactState.transferLocked` | `C/X A U` | `DERIVED/RULED` |
| `artifactState.officialArchiveBalance` | `X A U` | `EXTERNAL` |
| `artifactState.archiveEligibility` | `C/X A U` | `DERIVED/RULED` |

## 41.5 Permanent history / incidents

| State | Home | Mutability |
|---|---|---|
| `artifactState.permanentIncidentCount` | `C/X/P A U` | monotonically `RULED` |
| `artifactState.incidentLogRef/root` | `X/P A U` | append-only/per protocol |
| `artifactState.hellforgeState` | `C/X A U` | irreversible/ruled per protocol |
| `artifactState.transformationHistory` | `X/P A U` | append-only/per protocol |

## 41.6 Contextual state

| State | Home | Mutability |
|---|---|---|
| `artifactState.setStatus` | `X/P A U` | `EXTERNAL/DERIVED` |
| `artifactState.currentOwnerContextTraits[]` | `X/P A U` | `EXTERNAL/DERIVED` |
| `artifactState.currentCoverVariant` | renderer output | `DERIVED` |
| `artifactState.tokenBoundAccount` | `X A U` | deterministic/derived |
| `artifactState.tokenBoundAssets` | `X A` | externally mutable by account owner/users |

Contextual traits can disappear without erasing permanent artifact history.

---

# 42. IRREVERSIBLE ACTION WARNING POLICY

The release freezes which actions are irreversible; the private/public Press must render an explicit warning pattern.

For any configured irreversible action:

```text
BREAK THE SEAL
HELLFORGE TRANSFORMATION
OWNER-AUTHORIZED BURN
PERMANENT CLOSE (publisher release action, if allowed)
```

the interface must state:

1. exactly what changes;
2. exactly what cannot be undone;
3. what eligibility/state/reward path is permanently lost;
4. what asset/result is created or preserved;
5. which wallet/token is affected;
6. the final transaction or signature the user is about to authorize;
7. an obvious cancel/retreat path before final confirmation.

Humor can surround the warning. Humor cannot obscure permanence.

---

# 43. PRIVATE PRESS VALIDATION — BLOCKING RULES

`PUBLISH` must be disabled while any blocking validation error exists.

## 43.1 Identity

- `publicationKey` exists and matches the intended D1 publication.
- title/collection name/symbol required fields are present.
- chain-independent identity does not collide with an unintended publication.
- credits are complete enough for the source/rights model.
- SciVive source-credit rule is preserved.

## 43.2 Chain/template

- target chain is enabled for the intended environment;
- Gate 4 implementation deploys only to PulseChain Testnet V4;
- factory address is the chain/version registry's approved factory for the selected generation;
- code currently present at that factory address matches the registry's approved factory-code evidence;
- factory immutable `approvedPublicationCreationCodeHash` matches the registry's exact approved publication creation-bytecode hash for that generation;
- the creation bytecode supplied for simulated/final `publish(...)` hashes exactly to that approved value;
- selected template/version is approved for new deployment;
- template version supports every selected capability;
- V1 deployment mode is `FULL_DEPLOYMENT`;
- no validation assumes a shared publication implementation endpoint or universal publication runtime hash.

## 43.3 Supply

- `maxSupply > 0`;
- token ID range is exact;
- no duplicate fixed IDs;
- every fixed ID is within range;
- immediate creator count matches assignment rows;
- tail reserve count fits supply;
- `initialCandidatePoolSize = maxSupply - immediateCreatorCount`;
- `nonTailIssuanceCapacity = maxSupply - immediateCreatorCount - tailReserveCount`;
- both derived values are non-negative and internally consistent;
- the tail is not pre-removed from `initialCandidatePoolSize`;
- no phase path can exceed `nonTailIssuanceCapacity`;
- cap can never increase.

## 43.4 Trait distribution

For every enabled full-population birth axis:

```text
sum(value.count) == maxSupply
```

Also:

- fixed MARK assignments do not exceed MARK counts;
- fixed DEFECT assignments do not exceed DEFECT counts;
- creator #001–#006 standard marks are satisfied;
- standard creator DEFECT remains randomized;
- standard #066 HELLBOUND is satisfied and remains in public randomized pool;
- all layer families referenced by trait values exist;
- any disabled trait axis contributes no hidden metadata/art assumptions.

## 43.5 Randomization

- selected scheme supports fixed/reserved IDs;
- public issuance is not sequential/snippable;
- randomness provider/adapter exists on target chain if required;
- failure/reveal policy is complete;
- no builder plaintext full secret map is required before publish;
- all normal non-Harrow phases use the disclosed trait pool rule;
- assignment proof/reveal path is defined;
- provider choice passes testnet adversarial testing before mainnet use.

## 43.6 Content/package

- every committed file exists;
- byte length matches manifest;
- cryptographic digest matches bytes;
- source PDF/package facts match actual source;
- Reader manifest references only intended page/object paths;
- Reader object count/page count matches manifest;
- no protected Reader binary accidentally enters public delivery;
- base cover dimensions/type valid;
- every render dependency is included in committed manifest;
- package root recalculates exactly;
- no temp path/local username/private secret is committed.

## 43.7 Renderer

- exact renderer/version supported by template;
- rules digest matches package;
- representative output is reproducible from committed assets/rules;
- no missing layer/mask/font dependency;
- no nondeterministic step unless explicitly part of approved randomness stage;
- metadata output validates against expected schema;
- birth traits and dynamic state render with correct public vocabulary.

## 43.8 Pricing/payment

For each pricing policy:

- mode-specific required fields complete;
- forbidden/inapplicable fields are absent/zero;
- accepted asset address exists on chain when ERC-20;
- token decimals verified;
- price adapter supports target chain/asset pair when needed;
- current quote sanity tested;
- quote freshness rule enforced;
- tolerance/maximum authorization behavior simulated;
- overpayment/refund/revert behavior tested;
- free phase cannot accidentally collect payment.

## 43.9 Mint phases

- unique phase IDs/order;
- all referenced pricing policies/routes exist;
- all Merkle/eligibility roots match exact leaf schema;
- phase wallet cap does not violate lifetime cap;
- phase state machine has no impossible/ambiguous transition;
- allocation/rollover simulation cannot exceed available supply;
- tail reserve remains protected until true mint-out;
- trait pool rule is transparent;
- manual transition authority, if ever configured, is explicitly shown as such.

## 43.10 Royalty/treasury

- bps valid;
- router addresses contain expected code;
- route IDs exist;
- economic route policy digest matches intended splits;
- operational wallet rotation cannot mutate bps/supply/price/ownership.

## 43.11 Artifact capabilities

- selected capability is supported by template;
- disabled capabilities do not leave misleading metadata fields;
- seal invariants coherent;
- Archive cannot apply after unseal;
- transfer lock semantics are compatible with ERC-721 transfers;
- ERC-6551 compatibility does not add sweep authority;
- Hellforge/burn requires owner authorization;
- reward system is not conflated with TBA assets;
- future classified reward token name is not leaked.

## 43.12 Freeze preview

Before the final `PUBLISH` action:

- normalized config is generated;
- all sub-digests generated;
- root config digest generated;
- package digest generated;
- exact target chain/factory/template shown;
- exact approved publication creation-code hash shown and matched to the deployment bytecode;
- exact admin/close powers shown;
- exact irreversible capability rules shown;
- exact deployment call simulated;
- D1/package resolved snapshot matches the digest;
- there are zero blocking validation errors.

---

# 44. PRIVATE PRESS PREVIEW REQUIREMENTS

The builder must preview more than a cover image.

## 44.1 Identity preview

Show:

- title;
- publicationKey;
- collection name/symbol;
- credits/source;
- chain;
- template/version;
- max supply;
- Reader class;
- canonical description.

## 44.2 Supply / creator preview

Show:

- total run;
- #001–#006 creator rules;
- #066 public HELLBOUND rule;
- 3-copy true-mintout tail;
- initial random candidate pool size (`210` for the standard native profile);
- maximum non-tail primary issuance capacity (`207` for the standard native profile);
- explanation that the final three are whatever remains after non-tail primary issuances, not a predetermined removed set;
- consequences of early close.

## 44.3 Trait preview

Show:

- exact MARK counts;
- exact DEFECT counts;
- percentages at initial state;
- fixed assignments;
- independent-axis overlap examples;
- creator defects shown as random, not guaranteed;
- representative combined art variants.

## 44.4 Randomization preview

Show:

- selected randomness scheme/version;
- what Harrow knows before reveal;
- what collectors know;
- fixed IDs;
- reveal trigger;
- failure policy;
- public verification method.

Do **not** preview the actual full hidden token map to Harrow if the selected scheme is designed to keep it unknown.

## 44.5 Package/Reader preview

Show:

- source file identity/digest;
- page/object count;
- Reader presentation;
- representative Reader page;
- protected/public delivery classification;
- manifest digest;
- package root;
- warning if a private object is about to be made public.

## 44.6 Renderer preview

Show representative outputs for:

- STANDARD + no defect;
- each MARK family;
- each DEFECT family;
- at least several MARK + DEFECT overlaps;
- SEALED;
- ARCHIVED visual sleeve if enabled;
- UNSEALED;
- one contextual state example if enabled;
- one future permanent-history/Hellforge state example when protocol is available.

## 44.7 Pricing preview

For every phase/policy:

- free/paid status;
- accepted asset(s);
- fixed amount or USD target;
- current PLS quote where applicable;
- quote timestamp/freshness;
- tolerance;
- maximum collector authorization;
- refund/revert behavior.

## 44.8 Phase simulation

The Press must simulate at least:

- first collector;
- allowlisted collector;
- ineligible collector;
- wallet at cap;
- phase sold out;
- phase rollover;
- near mint-out with `candidatePoolRemaining = 4` and `nonTailIssuanceRemaining = 1`;
- true mint-out transition where final 3 go to Harrow;
- early close before true mint-out.

## 44.9 Metadata preview

Show exact representative metadata for:

- freshly minted SEALED copy;
- SEALED + ARCHIVED copy where supported;
- UNSEALED copy;
- birth MARK/DEFECT;
- permanent history example;
- contextual set-status example;
- `PRESS VERSION`;
- Archive balance only when official reward protocol is enabled.

## 44.10 Final freeze preview

The final screen must show the exact immutable resolved configuration, not a simplified marketing summary.

Minimum final proof panel:

```text
publicationKey
chainId
approved factory
factoryVersion
factory approval/registry reference
approved factory code evidence
approved publication creation-code hash
templateId
templateVersion
deploymentMode = FULL_DEPLOYMENT
collection name/symbol
max supply
creator immediate/tail rules
fixed copy rules
trait counts
randomization scheme
package digest
renderer version/rules digest
pricing policies
payment routes
mint phases
wallet rules
royalty
treasury route
artifact capabilities
external protocol bindings/classes
closure policy
releaseConfigDigest
```

Then the private Press must present a deliberate irreversible `PUBLISH` confirmation.

---

# 45. `PUBLISH` FREEZE PROCEDURE

Required conceptual sequence:

```text
1. resolve all draft fields
2. normalize config
3. validate
4. generate package manifests
5. hash/commit package + sub-manifests
6. preview representative art/metadata/Reader/Press states
7. simulate phase/supply/pricing state machines
8. produce exact immutable final config
9. produce releaseConfigDigest
10. show Harrow final freeze preview
11. obtain deliberate publish authorization
12. submit exact approved creation bytecode + frozen constructor inputs through the approved factory; factory hash-verifies and deploys through ordinary `CREATE`
13. verify emitted/stored digests, factory/template/version provenance and approved creation-code-hash evidence
14. record deployment provenance in D1
15. verify contract bytecode/config against intended release
16. only then allow the public Press to open when its frozen phase rules say it may
```

If the deployed contract/digest does not match the approved snapshot, the release is not allowed to open.

---

# 46. STANDARD NATIVE 216 PROFILE — RESOLVED BASELINE

A builder preset may populate the following values, but the resolved fields still freeze individually.

```text
maxSupply: 216

tokenId:
  tokenId = copy number
  range = 1..216
  public assignment = randomized/non-sequential

creator immediate:
  count: 6
  #001 HELLBOUND
  #002 HELLBOUND
  #003 PRESS PROOF
  #004 PRESS PROOF
  #005 GOLD
  #006 GOLD
  defects: shared random process

public grail:
  #066 HELLBOUND
  stays in randomized collector pool

creator tail:
  count: 3
  trigger: true mint-out only
  identities: final three remaining in machine
  early close: tail forfeited; not awarded to Harrow

PRESS MARK:
  HELLBOUND: 6
  PRESS PROOF: 12
  GOLD: 18
  STANDARD: 180

PRESS DEFECT:
  REDACTED: 6
  CORRUPTED PLATE: 12
  BLED OUT: 18
  OFF REGISTER: 24
  NONE: 156

wallet:
  max primary copies: 6
  max per transaction: 1
  batch mint: false

trait pool:
  normal non-Harrow phases share same remaining randomized pool
  no secret phase rarity boost by default

metadata:
  dynamic: true
  birth identity stable
  PRESS MARK
  PRESS DEFECT
  SEAL
  ARCHIVE
  ARCHIVE BALANCE where protocol enabled
  SET STATUS where contextual system enabled
  PRESS VERSION

native-issue compatibility target:
  seal/unseal
  Archive transfer lock
  dynamic covers
  permanent history
  contextual traits
  ERC-6551
  official reward protocol
  Hellforge / owner-authorized burn/evolution
```

Price, royalty, phase schedule, treasury route, exact randomness provider, and exact price adapter remain publication-specific choices.

---

# 47. SCIVIVE EXCEPTION PROFILE — BLUEPRINT COMPATIBILITY PROOF

The blueprint must support SciVive without pretending it is Native Issue #1.

Known SciVive resolved direction:

```text
publicationKey: scivive
chain: PulseChain
token standard: ERC-721
maxSupply: 5,555
primary pricing: FREE
primary wallet cap: 1
max per transaction: 1
royalty: 369 bps
Reader: enabled
Reader access: ownership
source package: existing protected SciVive source/Reader package
Harrow role: publisher/presenter
Harrow does not rewrite/edit/finish the source book
```

SciVive **may** use:

```text
dynamic covers
SEALED / UNSEALED
later contextual response to holding SciVive + SciVive Graphic Novel
```

SciVive does **not automatically** enable:

```text
native 216-copy PRESS MARK grammar
native 216-copy PRESS DEFECT grammar
full Archive reward system
full Hellforge economy
broad burn/evolution catalog
future reward-token exposure
```

This exception proves the factory/template/config system must be configurable rather than hard-coding the native-216 profile into every publication.

---

# 48. OPEN TECHNICAL DECISIONS THIS BLUEPRINT MUST PRESERVE

These are explicitly not silently resolved as creator canon by this file.

## Gate 4 research/test decisions

1. **Randomness/oracle/reveal mechanism**
   - exact provider;
   - exact entropy source;
   - exact reveal timing;
   - exact fallback behavior;
   - anti-sniping proof.

2. **PulseChain USD/PLS pricing source**
   - oracle / adapter / TWAP design;
   - stable assets accepted;
   - quote freshness;
   - manipulation/failure behavior.

3. **Optimizer/compiler optimization policy**
   - Solidity `0.8.36` and EVM `shanghai` are locked;
   - optimizer on/off, optimizer runs, `via_ir`, deployment bytecode size and gas behavior remain open;
   - lock only after test-backed comparison on the actual Hellbox kernel/factory path.

4. **Metadata renderer transport**
   - exact Gate 4 interface and test renderer;
   - Gate 6 implements full deterministic package/render engine.

5. **External protocol binding strategy**
   - direct binding vs compatible external protocol/registry model;
   - must preserve non-upgradeable release rules while allowing later compatible Archive/reward/Hellforge systems.

6. **Early-close implementation and authority endpoint**
   - exact on-chain unminted-capacity finalization mechanism;
   - tail reserve must still be forfeited on early close;
   - if a real release enables early close or another persistent publisher-authorized lifecycle action, the `publisherAuthority` endpoint must be rotation-safe;
   - do not freeze Harrow's current personal EOA forever and do not invent a new authority/controller contract until the need and design are explicitly proven.

## Later-gate product/canon decisions already known to be open

7. Final permanent-history public labels beyond the currently strong `LIVED THROUGH` / `INCIDENT LOG` direction.
8. Exact permanent incident taxonomy.
9. Exact official Archive reward formulas.
10. Exact Hellforge recipes/catalog.
11. Exact Native Issue #1 publication price/royalty/phases/title/cast.

None of these gaps permits Gate 4 to build an architecture that makes the future capability impossible.

## Strong pre-mainnet durability requirement

> **dynamic when alive; durable when dead**

This is a **strong pre-mainnet architecture requirement**, not a selected implementation mechanism.

Gate 4 must not paint later Gates into a corner that requires Hellbox infrastructure to remain online forever merely for an owned publication to retain meaningful identity. The exact continuity/fallback mechanism remains OPEN for later research/hardening and must not be invented from this phrase alone.


---

# 49. GATE 4 IMPLEMENTATION BOUNDARY — ACTIVE

This blueprint is approved. Gate 4 may continue to implement/test:

- the versioned `HellboxPublication` kernel/template;
- Hellbox chain/version registry configuration and approved-factory reference;
- `HellboxPublicationFactory`;
- immutable configuration/finalization boundary;
- supply/copy-number enforcement;
- creator immediate/tail rules;
- fixed-copy constraints;
- token/copy assignment architecture;
- phase/config representation;
- pricing-policy representation/interface;
- royalty baseline;
- dynamic metadata renderer interface;
- metadata refresh signaling;
- seal/archive-compatible primitives/interfaces;
- external-protocol compatibility points;
- package/content commitment;
- SciVive Testnet V4 deployment;
- second dummy publication deployment;
- a real Testnet V4 mint that reaches Gate 3 ownership → Archive/library recognition → protected Reader.

Already proven at this synchronization checkpoint:

- Foundry layout and generated-output boundaries;
- Solidity `0.8.36` + explicit Shanghai target;
- PulseChain-compatible OpenZeppelin Contracts `v5.1.0` pin;
- constructor-frozen `HellboxPublication V1` kernel checkpoint;
- ERC-721 + ERC-2981 baseline/interface support;
- release-config validation and digest-mismatch rejection;
- Native 216 configuration shape acceptance;
- SciVive configuration shape acceptance;
- Press-side release-fingerprint calculator using pinned `viem`;
- JavaScript golden vector;
- Solidity golden-vector test proving identical HELLBOX_ABI_V1 digest output;
- `HellboxPublicationFactory V1` size-safe full deployment through exact approved creation bytecode + ordinary EVM `CREATE`;
- immutable per-factory-generation `approvedPublicationCreationCodeHash`, with zero/unapproved bytecode rejection;
- factory runtime reduced from the structurally undeployable 32,116-byte embedded-creation-code path to **8,020 bytes** with **+16,556 bytes EIP-170 margin**;
- factory-only publishing authority with `Ownable2Step` rotation and disabled renunciation;
- duplicate publication-key and release-digest rejection;
- append-only minimal factory provenance state with no external-registration/admin authenticity setter;
- defensive post-deployment factory/chain/template/version/digest/key verification;
- approved-factory root-of-trust boundary preserved outside the factory itself;
- deterministic issuance accounting core:
  - immediate creator allocation ordering;
  - `candidatePoolRemaining = 210` / `nonTailIssuanceRemaining = 207` native initialization;
  - sparse candidate-pool bookkeeping;
  - unique in-range deterministic candidate draws;
  - #066 remains candidate-eligible until actually drawn;
  - lifetime primary wallet accounting survives transfer/burn;
  - true-mintout final-three tail transition;
  - SciVive reuse without native-216 assumptions;
- versioned publication-side enforcement-preimage anchors for fixed-copy, birth-trait and randomization policy, preserving `HELLBOX_ABI_V1`;
- standalone `HellboxBirthPolicy V1` companion foundation:
  - constructor-only permanent `publication = msg.sender` binding;
  - independent verification of all three enforcement preimages;
  - native MARK/DEFECT inventory validation;
  - Harrow #001–#006 fixed MARK reservations;
  - creator fixed DEFECT prohibition;
  - #066 fixed HELLBOUND while random-pool eligible;
  - randomization-policy boundary validation;
  - SciVive trait-disabled shape;
  - read-only external surface at this checkpoint and no publisher/admin mutation path;
- current unoptimized Shanghai runtime sizes: publication **16,334 bytes**, factory **8,020 bytes**, birth-policy module **5,561 bytes**;
- current standalone initcode sizes: publication **24,855 bytes**, birth-policy module **17,018 bytes**; combined deployment graph still unproven until wiring is compiled;
- **65 total Solidity tests passing, 0 failed**:
  - 16 kernel;
  - 11 factory;
  - 12 deterministic issuance;
  - 9 publication policy-anchor;
  - 16 dedicated birth-policy;
  - 1 cross-language golden vector;
- issuance fuzz boundary: **256 runs passed**.

Gate 4 must **not** pretend to finish:

- final Press V2 UX — Gate 5;
- full ingest/render/package automation — Gate 6;
- full Archive reward/Hellforge/ERC-6551 product protocols — Gate 7;
- Hellion system — Gate 8;
- final audit/content/localization hardening — Gate 9;
- mainnet Native Issue #1 — Gate 10.

---

# 49A. INTERNAL ENGINEERING CHECKPOINT — ATOMIC BIRTH-POLICY WIRING + TRAIT CONSUMPTION

The deterministic issuance accounting core, publication-side enforcement digest anchors, and standalone modular birth-policy foundation are now implemented and test-backed. This section is the required architecture ledger for the next Gate 4 Solidity work: **atomically bind the existing `HellboxBirthPolicy` to each publication deployment before adding mutable per-token trait consumption or exposing collector minting.**

## 49A.1 Blueprint sections implemented / carried forward

The implemented issuance/policy work and next wiring derive primarily from:

- §8 factory/authenticity/deployability;
- §10 supply & copy numbering;
- §11 creator immediate/tail allocation;
- §12 fixed copy rules;
- §13 birth trait axes;
- §14 randomness/allocation/reveal boundary;
- §21 wallet/transaction limits;
- §22 mint-phase compatibility;
- §23 live odds;
- §32 / §32A / §32B closure/finalization/authority;
- §33 prohibited publisher powers;
- §34 issuance/indexing events;
- §36 / §36.4 commitment + enforcement-preimage boundary;
- §40 public Press runtime state;
- §43–45 validation/preview/PUBLISH constraints;
- §46 standard native 216 profile.

## 49A.2 Standard-native issuance state machine — implemented accounting, trait consumption pending

### PUBLISH / initialization semantics

The release freezes `maxSupply = 216`.

Before normal non-tail issuance opens:

```text
#001 HELLBOUND       → immediate creator
#002 HELLBOUND       → immediate creator
#003 PRESS PROOF     → immediate creator
#004 PRESS PROOF     → immediate creator
#005 GOLD            → immediate creator
#006 GOLD            → immediate creator
```

Their DEFECTS remain random under the approved shared random process.

`#066` is fixed HELLBOUND but stays in the normal random candidate pool.

After the six immediate creator copies are removed from candidate eligibility:

```text
candidatePoolRemaining   = 210
nonTailIssuanceRemaining = 207
```

The three future Harrow tail copies are still inside those 210 candidates. They are not known, removed or reserved by ID.

Known remaining MARK inventory after **future issuance-time consumption** of the six creator reservations must be:

```text
HELLBOUND       4
PRESS PROOF    10
GOLD           16
STANDARD      180
```

Remaining DEFECT inventory depends on the six actual randomized creator DEFECT results.

### Reservation math before creator-trait consumption is wired

At companion construction time the full MARK inventory still totals 216 and all configured fixed MARK rules are reserved:

```text
creator #001/#002 HELLBOUND      = 2 reserved
creator #003/#004 PRESS PROOF    = 2 reserved
creator #005/#006 GOLD           = 2 reserved
#066 HELLBOUND                   = 1 reserved
----------------------------------------------
total fixed MARK reservations    = 7
```

Therefore the construction-time HELLBOUND state is:

```text
HELLBOUND inventory remaining          = 6
HELLBOUND reserved remaining           = 3
HELLBOUND random-assignable remaining  = 3
```

Across all MARK values, construction-time random-assignable total is `209`, because seven MARK positions are fixed/reserved.

This does **not** change the collector next-copy probability after the creator six are actually consumed. At that future point:

```text
candidatePoolRemaining = 210
HELLBOUND remaining    = 4
#066 remains a random candidate and carries 1 reserved HELLBOUND
other random-assignable HELLBOUND = 3
```

So the next-copy HELLBOUND probability is still exactly `4 / 210`. The implementation must preserve this by consuming creator reservations/inventory when the six creator copies receive their permanent birth identities; it must not pre-remove #066 from candidate selection.

### Every successful normal non-tail primary issuance — required behavior after trait wiring

Exactly one token is issued.

A successful issuance must:

1. validate the frozen phase/eligibility rules;
2. enforce wallet lifetime primary usage;
3. select one still-eligible candidate copy ID through the approved randomness boundary;
4. preserve fixed-copy constraints;
5. consume valid remaining MARK/DEFECT inventory;
6. bind permanent tokenId/copy-number + birth identity;
7. increment lifetime primary usage;
8. decrement `candidatePoolRemaining` by exactly one;
9. decrement `nonTailIssuanceRemaining` by exactly one;
10. emit/index authoritative state needed for Press/D1 refresh.

Reserved, free, allowlist, early and public phases may differ in eligibility/economics, but unless the frozen release explicitly says otherwise they consume the same global non-tail issuance capacity and same random trait/copy pool.

Transfer or burn does not restore primary allowance or primary issuance capacity.

### True mint-out

Immediately before the final normal non-tail issuance:

```text
candidatePoolRemaining   = 4
nonTailIssuanceRemaining = 1
```

After that issuance:

```text
candidatePoolRemaining   = 3
nonTailIssuanceRemaining = 0
```

Those exact three remaining candidate IDs are awarded to the configured tail recipient. They are not preselected. `tailAwarded` becomes true once.

### Early permanent close

If early close is enabled and invoked before true mint-out:

- primary issuance closes permanently;
- no reopen;
- no cap increase;
- unminted non-tail capacity is retired;
- Harrow gets no final-three tail;
- `tailAwarded` remains false;
- remaining unissued IDs cannot later be swept or reassigned by an admin escape hatch.

Exact early-close implementation remains open and is not part of the immediate atomic-wiring checkpoint.

## 49A.3 `HellboxBirthPolicy V1` — current module contract

The standalone companion currently implements/validates:

```text
BIRTH_POLICY_VERSION = 1
MODULE_ID             = keccak256("HELLBOX_BIRTH_POLICY")
publication           = msg.sender at construction
```

Its constructor receives:

- a narrow `PublicationBinding` containing already-frozen supply/creator/tail/digest anchors;
- encoded fixed-copy policy preimage;
- encoded birth-trait policy preimage;
- encoded randomization-policy preimage.

It independently verifies the three canonical enforcement digests using the same domains as the publication anchors.

Current module semantics include:

- native MARK inventory `6 / 12 / 18 / 180`;
- native DEFECT inventory `6 / 12 / 18 / 24 / 156`;
- fixed MARK reservations for #001–#006;
- creator DEFECT fixed assignment prohibited;
- #066 HELLBOUND while public-random-pool eligible;
- duplicate axis/value/fixed-rule rejection;
- reservation-over-inventory rejection;
- randomization boundary requiring random non-sequential copy shuffle, global shared trait pool, independent MARK/DEFECT axes, shared-random creator DEFECT semantics, and no full preknown publisher rarity map;
- trait-disabled reusable shape for SciVive;
- read-only inventory/reservation inspection surfaces.

At this checkpoint it has **no external mutation/admin surface**. It does not have `Ownable`, initializer, proxy, upgrade, `delegatecall`, mint, burn, transfer, rarity setter, or publisher configuration function.

Its current `*Remaining` values are construction-time policy/reservation state only. They are **not yet live post-mint Press odds** because per-token consumption has not been implemented.

## 49A.4 Atomic deployment topology — exact next checkpoint

Current committed deployment graph is still:

```text
reviewed HellboxPublication creation bytecode
        ↓ exact hash approved by factory generation
HellboxPublicationFactory ordinary CREATE
        ↓
HellboxPublication
```

The module exists independently but is not connected to that graph.

Preferred topology to test next:

```text
HellboxPublicationFactory ordinary CREATE
        ↓
HellboxPublication constructor
        ↓  atomic constructor-time CREATE
HellboxBirthPolicy companion
```

Reasons for preferring publication-created companion:

- `HellboxBirthPolicy` can permanently bind `publication = msg.sender` to the actual publication;
- no setter/initializer/configuration window is needed;
- no predicted publication address or CREATE2 requirement is needed;
- factory remains the publication deployer/provenance root;
- publication + companion deployment succeeds or reverts atomically.

This is a **preferred topology to prove, not yet a proven implementation fact**.

Critical chain-size evidence before wiring:

```text
HellboxPublication runtime                = 16,334 bytes
HellboxPublication EIP-170 margin         =  8,242 bytes
HellboxPublication initcode               = 24,855 bytes

HellboxBirthPolicy runtime                =  5,561 bytes
HellboxBirthPolicy EIP-170 margin         = 19,015 bytes
HellboxBirthPolicy initcode               = 17,018 bytes
HellboxBirthPolicy EIP-3860 margin        = 32,134 bytes

EIP-3860 publication-initcode limit       = 49,152 bytes
```

The simple standalone initcode sum (`24,855 + 17,018`) is below 49,152, but **that is not combined deployment proof**. Solidity may embed companion creation bytecode plus constructor/payload handling differently. Compile and measure the actual wired publication before accepting the topology.

If the actual graph exceeds EIP-3860, EIP-170, or leaves unacceptable deployment headroom, stop and re-review topology. Do **not** solve the problem with a post-deploy setter, proxy, initializer, arbitrary implementation registry, `delegatecall`, or unbound companion.

## 49A.5 Exact deployment-wiring requirements

The next implementation checkpoint must:

1. transport exactly the three narrow fixed-copy/birth-trait/randomization enforcement preimages through the factory/publication deployment path;
2. leave `ReleaseConfig`, `CommitmentSet`, their field order/meaning and the `HELLBOX_ABI_V1` release fingerprint unchanged;
3. build `HellboxBirthPolicy.PublicationBinding` only from already-validated publication config/commitment anchors;
4. create exactly one companion during construction if the preferred topology passes exact compile/deployability tests;
5. permanently store/expose the companion address in the publication with no setter/replacement path;
6. prove malformed/decode-invalid/digest-mismatched policy data reverts the entire publication deployment;
7. prove `birthPolicy.publication()` equals the deployed publication, not factory/publisher authority;
8. preserve factory ordinary `CREATE`, immutable approved publication creation-code hash checking and post-deploy provenance checks;
9. recalculate the approved publication creation-code hash because reviewed publication creation bytecode changes when constructor/module wiring lands;
10. measure exact publication runtime/initcode and factory runtime/initcode after wiring, under the existing unoptimized Shanghai build baseline;
11. keep SciVive's trait-disabled configuration deployable through the same reviewed publication version;
12. introduce no generic arbitrary constructor-data execution surface;
13. introduce no generic owner, rarity setter, activation window, proxy, clone, upgrade, arbitrary transfer/burn, seizure, or publisher reroll;
14. keep production randomness/provider selection outside this deterministic deployment work.

The factory may change its **pre-deployment call ABI** to transport these typed policy preimages. That is not permission to change the frozen release fingerprint or collector-facing promise schema.

## 49A.6 On-chain vs committed data

Must be on-chain or deterministically derivable on-chain when required for enforcement:

- capacity/candidate state;
- lifetime wallet use;
- copy assignment/existence;
- fixed-rule enforcement;
- runtime trait inventory once consumption is wired;
- closure/tail state;
- immutable companion binding;
- narrow authority endpoint when an enabled action requires one.

May remain rich committed package/D1 data when the EVM does not need it to enforce collector promises:

- human descriptions;
- art manifests;
- preview reports;
- rich phase copy;
- renderer assets;
- publication content;
- audit explanations.

If rich committed policy is needed by the EVM, use the §36.4 canonical preimage rule.

## 49A.7 Authority / ABI / reuse boundaries

Atomic wiring and later trait consumption must not add:

```text
generic publication owner
generic birth-policy owner
supply setter
trait/rarity setter
token seizure
arbitrary transfer
arbitrary burn
publisher rarity reroll
external authenticity registration
proxy/admin upgrade
post-PUBLISH config editor
companion replacement setter
```

Future birth-policy mutation needed for actual issuance must be narrowly callable only by the permanently bound publication state machine. That is an internal enforcement relationship, not a publisher/admin authority surface.

The work must not change:

```text
HELLBOX_ABI_V1 ReleaseConfig field order/meaning
CommitmentSet order/meaning
golden-vector semantics
tokenId = copy number
frozen collector promises
```

Deployment-time policy preimages are allowed because their digests are already bound by `CommitmentSet`.

An unchanged reviewed V1 must remain reusable for future issues through configuration rather than per-issue Solidity changes.

## 49A.8 Foundry proof ledger — current + remaining

Current verified post-push regression:

```text
HellboxPublication kernel tests         16
HellboxPublicationFactory tests        11
deterministic issuance tests           12
HellboxPublicationPolicy tests          9
HellboxBirthPolicy tests               16
cross-language golden vector            1
-----------------------------------------
TOTAL                                  65 passed / 0 failed

issuance fuzz boundary                 256 runs passed
```

Current `HellboxBirthPolicy` dedicated suite proves, among other things:

- module identity/version and permanent constructor binding;
- canonical legacy enforcement preimages remain compatible;
- all three independent digest mismatch paths revert;
- native MARK/DEFECT inventory validation;
- Harrow creator MARK reservation shape;
- creator fixed DEFECT prohibition;
- #066 HELLBOUND reservation/random-pool eligibility shape;
- duplicate fixed-copy rule rejection;
- fixed reservation cannot exceed inventory;
- birth inventory must equal frozen supply;
- randomization requires global shared trait pool;
- creator immediate rule count must match frozen binding;
- SciVive-style trait-disabled reusable publication shape.

Still required before the atomic deployment-wiring checkpoint is complete:

- exact factory/publication transport encoding for the three policy preimages;
- atomic companion construction from the publication constructor;
- immutable publication companion address;
- deployment-level malformed/mismatch reverts;
- actual publication binding proof;
- combined unoptimized Shanghai EIP-170/EIP-3860 size proof;
- factory size/provenance regression after the wiring;
- SciVive trait-disabled deployment through the wired graph;
- full regression and adversarial tests.

After atomic wiring is proven, the next deterministic module slice must implement/test:

### Trait conservation / permanent birth identity
- consuming #001–#006 fixed MARK reservations exactly once;
- creator DEFECT uses the approved shared random process and consumes actual DEFECT inventory;
- #066 remains HELLBOUND while staying candidate-random until drawn;
- MARK totals remain exact;
- DEFECT totals remain exact;
- fixed assignments consume reservations + inventory correctly;
- random assignments cannot consume reserved inventory needed by an undrawn fixed copy;
- no underflow/over-allocation;
- every issued/awarded copy gets exactly one value from each enabled birth axis;
- permanent token MARK/DEFECT values cannot be rerolled by publisher/admin action;
- authoritative remaining inventory produces correct public next-copy odds using the actual candidate denominator.

Still required later in Gate 4:

### Authority / close / phases / public mint
- unauthorized close fails;
- early close is permanent and never awards tail;
- no post-close mint succeeds;
- no caller can mint over frozen lifetime/phase rules;
- changing phases cannot reset lifetime usage;
- no caller can force #066;
- no caller can preselect tail IDs;
- no publisher reroll exists;
- no supply/trait/fixed-rule rewrite exists.

### Production randomness + Testnet acceptance
- production entropy source/provider and fallback are selected through research/test evidence;
- collector cannot predict or snipe the next copy under the production mechanism;
- real PulseChain Testnet V4 mint path passes factory → ownership → Gate 3 → Archive/library → Reader;
- same reviewed factory/template/version deploys a second dummy publication without bespoke Solidity.

Use fuzz/invariant tests as each remaining deterministic transition becomes concrete.

---

# 50. ACCEPTANCE TESTS THIS BLUEPRINT REQUIRES OF GATE 4

## Factory/template proof

```text
same approved factory/template/version
→ deploy SciVive config
→ deploy second dummy publication config
→ no bespoke Solidity rewrite between publications
```

## Ownership/Reader proof

```text
SciVive Testnet V4 collection
→ one-copy mint
→ Gate 3 authenticated wallet
→ publication balanceOf(wallet) = owned
→ Archive/library shows owned
→ protected Reader opens
```

## Immutability proof

After `PUBLISH`, attempts to mutate frozen fields must fail or be impossible:

- max supply;
- collection identity;
- creator allocation;
- fixed copy rules;
- trait totals;
- pricing policy;
- payment routes;
- phase rules;
- wallet limits;
- royalty bps;
- package digest;
- renderer rules/version;
- capability policy;
- external protocol compatibility binding/class;
- closure policy;
- template/version.

## State-machine proof

Allowed runtime state still works:

- mint count changes;
- phase progresses according to frozen rule;
- wallet usage changes;
- random pool shrinks;
- odds recalculate;
- copy assignment becomes permanent;
- tail awards only on true mint-out;
- early close does not hand tail to Harrow;
- dynamic metadata can signal refresh;
- later-compatible seal/archive/evolution state is not structurally blocked.

---

# 51. PUBLICATION COMPILER OUTPUTS

The approved private Press builder should ultimately emit a reproducible release bundle containing at least:

```text
resolved publication configuration
publication package manifest
Reader manifest + delivery manifest/pointers
contract deployment configuration
trait distribution manifest
fixed assignment manifest
renderer/compositor manifest
metadata template/schema
allowlist/eligibility commitments
pricing policy set
payment route set
mint phase configuration
royalty/treasury route configuration
capability/protocol compatibility configuration
cryptographic digests/roots
validation report
preview report
deployment verification report
```

No future release should require:

- manual frontend edits just to define the edition;
- bespoke Solidity per issue;
- hand-writing every metadata JSON;
- manually juggling R2 objects;
- Harrow manually selecting every random trait combination;
- editable release promises after `PUBLISH`.

---

# 52. BLUEPRINT REVIEW — ARCHITECTURE CONCLUSIONS

This blueprint intentionally resolves the following architecture boundaries before Solidity:

## A. `PUBLISH` is the freeze boundary

The final resolved config/package is immutable at `PUBLISH`; Press opening can happen later under the frozen schedule.

## B. Contract storage and release truth are not identical

Not every immutable release field needs expensive dedicated on-chain storage.

The contract should:

- directly store/enforce the fields needed for on-chain behavior;
- store the root/sub-digests needed to bind the rest;
- let D1/package hold rich metadata/art/content that is cryptographically committed.

## C. Content bytes are immutable; storage pointers may migrate

Moving an identical committed Reader object from one R2 key to another is operational maintenance, not a new edition.

Changing the committed bytes is a different matter and cannot happen silently.

## D. Dynamic metadata is not mutable publication policy

The release freezes the renderer/version/state rules.

Metadata output changes because the artifact changes under those rules.

## E. Birth traits are two-level state

- vocabulary/counts/fixed rules freeze at release level;
- each token's actual assigned MARK/DEFECT becomes permanent birth state once assigned.

## F. Randomness is a required release policy even though the provider is still open

The blueprint can be complete without pretending an untested randomness provider has already been approved.

## G. Pricing can vary by frozen phase without becoming editable economics

A release may contain multiple predeclared pricing policies; each phase references one. Harrow cannot rewrite them after publish.

## H. Treasury routing can be operationally maintainable without changing historical economics

The release freezes the router/route/policy. Operational destination rotation must not rewrite royalty bps, price, ownership, or promised splits.

## I. Later protocols remain external/modular

Archive rewards, ERC-6551 account behavior, Hellforge, permanent incidents and contextual traits can mature in later Gates while Native V1 preserves the compatibility boundary now.

## J. SciVive and Native 216 both fit one factory/config system

That is mandatory proof that Hellbox is building a publishing platform, not one hard-coded NFT contract.

---

# 53. CREATOR APPROVAL / IMPLEMENTATION-SYNC CHECKLIST

The blueprint was approved before Foundry/Solidity implementation began. This checklist now records the approved architecture plus unresolved technical items that remain intentionally open:

- [x] `PUBLISH` is the irreversible release-config freeze/deploy boundary.
- [x] Public Press opening may occur later under the frozen phase schedule.
- [x] One publication/release deploys one native ERC-721 collection per chain.
- [x] `tokenId = copy number`.
- [x] Native standard supply baseline = `216`.
- [x] Harrow immediate #001–#006 rules are correct.
- [x] Harrow true-mintout final-three tail rule is correct.
- [x] #066 remains a public randomized HELLBOUND grail.
- [x] PRESS MARK counts/vocabulary are correct.
- [x] PRESS DEFECT counts/vocabulary are correct.
- [x] MARK/DEFECT are independent overlapping birth axes.
- [x] Creator DEFECT remains random.
- [x] Standard wallet lifetime cap = `6`.
- [x] Standard max per transaction = `1`.
- [x] Mint phases can use different predeclared frozen pricing policies.
- [x] Public live odds use the actual `candidatePoolRemaining`; standard native starts at 210 candidates after Harrow's immediate six, while non-tail primary issuance capacity is separately 207.
- [ ] Exact randomness provider remains Gate 4 technical research/testing.
- [ ] Exact PulseChain price adapter/oracle remains Gate 4 technical research/testing.
- [x] Canonical content/art/renderer bytes/rules are committed by digest.
- [x] Storage delivery pointers may migrate only when committed bytes remain identical.
- [x] Release config can be partly on-chain + partly committed package data, but the root binds all immutable promises.
- [x] Dynamic metadata remains allowed under frozen renderer/state rules.
- [x] SEALED/ARCHIVED/UNSEALED boundaries are preserved.
- [x] ERC-6551 compatibility is preserved without publisher sweep authority.
- [x] Official Archive rewards remain separate from arbitrary TBA assets.
- [x] Hellforge/burn/evolution always requires owner authorization.
- [x] No publisher seizure/forced transfer/arbitrary burn/blacklist ownership override exists.
- [x] Early permanent close forfeits Harrow's unearned tail reserve.
- [x] SciVive remains a narrower proving exception.
- [x] Gate 4 stays Testnet V4 only.
- [x] HairyLabs Byte pages remain excluded from testing until the creator explicitly clears the Byte lane.

Additional implementation decisions now synchronized here:

- [x] Solidity source is isolated in `contracts/`; Worker `src/` remains untouched by Foundry source layout.
- [x] Solidity `0.8.36`, exact Hellbox pragma `0.8.36`, and EVM `shanghai` are locked.
- [x] OpenZeppelin Contracts `v5.1.0` is pinned at commit `69c8def5f222ff96f2b5beff05dfba996368aa79` for Shanghai compatibility.
- [x] OpenZeppelin `v5.7.0` is superseded for Gate 4 because its `MCOPY` use requires Cancun-compatible compilation.
- [x] V1 uses full deployment + constructor initialization; no proxy/initializer/delegatecall/upgrades.
- [x] HELLBOX_ABI_V1 exact commitment encoding is implemented and cross-language golden-vector verified.
- [ ] Optimizer / runs / `via_ir` policy remains open pending test-backed comparison.
- [x] V1 factory provenance is locked and test-backed: approved-factory root of trust, physical factory deployment only, key+digest uniqueness, defensive mutual provenance verification, and instance-specific runtime code-hash event evidence.
- [x] V1 factory generation immutably approves the exact `HellboxPublication` creation-bytecode hash; `publish(...)` hash-verifies supplied bytecode and uses ordinary `CREATE` while remaining `FULL_DEPLOYMENT`.
- [x] Factory EIP-170 blocker is structurally resolved: runtime **8,020 bytes**, margin **+16,556 bytes**; embedded `new HellboxPublication(...)` deployment is superseded.
- [x] Deterministic issuance accounting core is implemented/tested, including `210 / 207`, immediate-six ordering, #066 candidate eligibility, lifetime wallet accounting, sparse candidate draws, and true-mintout final-three behavior.
- [x] Publication-side versioned enforcement-preimage anchors for fixed-copy, birth-trait and randomization policy are implemented/tested without changing `HELLBOX_ABI_V1`.
- [x] Standalone non-upgradeable `HellboxBirthPolicy V1` companion foundation is implemented/tested with constructor-only binding, native inventory/reservations, #066 rule shape, SciVive trait-disabled support and no external mutation/admin surface at this checkpoint.
- [ ] Publication/factory → `HellboxBirthPolicy` atomic deployment wiring and exact combined EIP-170/EIP-3860 proof are not yet complete.
- [ ] Per-token MARK/DEFECT consumption/assignment and authoritative live post-mint odds are not yet complete.
- [x] Current verified Solidity regression = **65 passed / 0 failed** with issuance fuzz boundary **256 runs passed**.
- [x] `template.factoryVersion` remains registry/deployment metadata and is not a caller-supplied `ReleaseConfig` field.
- [x] Publication-level operational authority uses the canonical `publisherAuthority` name throughout.
- [ ] Rotation-safe `publisherAuthority` endpoint strategy remains open before any mainnet release enables persistent publisher-authorized lifecycle actions.

After this synchronization is committed, the next implementation frontier is **atomic publication/factory deployment wiring for the existing `HellboxBirthPolicy` companion and its three enforcement preimages**. Only after that graph is compile/size/provenance tested should Gate 4 add publication-only per-token MARK/DEFECT consumption and live odds. Do not expose a collector mint before both layers are real EVM enforcement.

That implementation must preserve the already-proven standard native distinction:

```text
after Harrow immediate #001-#006:
candidatePoolRemaining   = 210
nonTailIssuanceRemaining = 207
```

Production random assignment logic must not be frozen until the still-open Gate 4 randomness mechanism has been researched and test-backed. Whatever randomness mechanism is selected, it must draw from the actual candidate pool; the three-copy tail is determined by what remains after the final non-tail primary issuance, not by pre-removing three candidates.

---

# 54. CHANGE CONTROL FOR THIS BLUEPRINT

Throughout Gate 4, this file is the approved living architecture artifact for publication configuration and implementation synchronization.

After creator approval:

- implementation should derive schemas/config structs/validation from this blueprint;
- an implementation discovery that requires a blueprint change must stop and update/re-review this file before silently changing the model;
- Gate 4 close must reconcile durable conclusions into `HELLBOX_PROJECT_STATE.md`, update `HARROW_CHARACTER_BIBLE.md` only if creative canon changed, and update `README.md`;
- at formal Gate close, review/recalculate the **overall Hellbox public completion percentage**; it measures overall project completeness, not current-Gate completion, and ordinary commits do not automatically change it;
- a mid-Gate public percentage change is reserved for a genuinely material project-wide expansion, setback, or rebaseline;
- the finalized complete Gate 4 blueprint must then be archived as `docs/architecture/gates/GATE_04_PUBLICATION_CONFIGURATION.md` **before** root `CURRENT_GATE_BLUEPRINT.md` is repurposed for Gate 5;
- the archived Gate 4 blueprint remains historical architecture reference, not competing root authority;
- if future Gates add a new artifact capability, they should extend the versioned configuration/protocol model rather than mutate old release promises.

**Do not let a material publication rule exist only in chat history.**

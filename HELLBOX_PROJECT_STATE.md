# HELLBOX PROJECT STATE

Last updated: 2026-08-30
Current production branch: `main`
Current live checkpoint: Gate 3 COMPLETE — identity/ownership/Archive/Reader authority, SEALED PRESS, permanent 30-machine first-introduction routing, completion/replay flow, and Harrow private bypass are live-proven
Current roadmap position: Gate 4 NEXT — PulseChain Testnet publication contract + factory
Public repository identity: `Harrow <noreply@hellboxcomics.com>`
Repository privacy status: scrubbed and verified after Gate 2; no personal identity references remain in commit identity, tracked content, commit messages, or historical paths
Checkpoint-reference rule: use Gate/checkpoint names plus live validation results; do not treat commit hashes as durable handoff identifiers
Broken Gate 0.2 backup branch: `backup-broken-gate02-20260828`

---

## 1. PURPOSE

This is the living handoff document for Hellbox Comics.

Any future ChatGPT thread, Claude session, human developer, or other assistant should read this file before changing the project.

It records:
- current live state
- locked product decisions
- architecture
- known bugs
- workflow rules
- completed work
- deferred work
- exact next step
- files that must not be changed casually

If an old chat conflicts with this file, prefer the most recent explicit decision recorded here or in the current repository.

---

## 2. DEVELOPMENT WORKFLOW — LOCKED

This repository is developed incrementally and must remain recoverable at every checkpoint.

Do not use giant multi-file replacement packages by default.

Work one file at a time.

For every code/config change:
1. Explain why that exact file is next.
2. Provide the complete replacement file, never a patch requiring manual splicing.
3. User places that one file in the exact repository path.
4. Validate that only the expected file changed before committing when appropriate.
5. User commits/deploys that one file.
6. Verify the live result and/or backend behavior.
7. Only then move to the next file.

Interaction cadence is also locked:
- give the user one immediate terminal action/validation step at a time
- do not dump long batches of future commands
- wait for the result of the current step before giving the next
- if a deployment can lag, verify the actual live version rather than assuming the push has propagated

For backend/API work:
- test changed backend behavior immediately
- isolate failures to the specific file/change that caused them
- do not stack unverified backend changes
- temporary test mechanisms must be explicitly removed after proof and their secrets deleted

For static assets/runtime files:
- if CSS/JS URLs are versioned, bump the cache version when the asset changes
- do not assume a deployed file is active until the live page is confirmed to request the new version
- Cloudflare edge cache can temporarily serve an older unversioned asset even after deployment; verify the versioned path and then verify the normal path after propagation

Gate-close documentation procedure — mandatory:
1. Finish technical acceptance for the Gate.
2. Update `HELLBOX_PROJECT_STATE.md` as the authoritative project/engineering/product handoff.
3. Review and update `HARROW_CHARACTER_BIBLE.md` as the authoritative Harrow creative-canon handoff. If no Harrow canon changed during the Gate, still advance its Gate maintenance record.
4. Update `README.md` as the concise project-facing overview/setup/status document.
5. Keep all three living documents mutually consistent and remove superseded/contradictory statements rather than merely appending new ones.
6. Commit and verify each documentation file incrementally.
7. Give the user a short macro-progress report that reflects actual project effort and risk, not simple gate-count percentages.
8. Only then begin the next Gate.

Living-document authority:
- `HELLBOX_PROJECT_STATE.md` = exhaustive project, product, architecture, infrastructure, workflow, validation, risk, and exact-next-action authority
- `HARROW_CHARACTER_BIBLE.md` = exhaustive Harrow visual, psychological, verbal, narrative, environmental, satire, social, and creative-canon authority
- `README.md` = concise repository orientation and current operating status
- important product/Harrow intersections must be reflected in both relevant authority documents so either handoff path preserves the decision
- chat history is not an acceptable substitute for any of these files

`HELLBOX_PROJECT_STATE.md` must be comprehensive enough that a new ChatGPT thread, Claude session, or competent human developer can continue immediately without asking the user to re-explain:
- what Hellbox Comics is
- product purpose and end goal
- enough Harrow identity/voice/visual direction to understand the product, with full creative canon delegated to `HARROW_CHARACTER_BIBLE.md`
- architecture and infrastructure
- publication/Reader/Press/Archive model
- locked decisions and non-goals
- workflow and file-handoff rules
- current production state
- completed proofs
- known risks/debt
- exact next engineering action

`HARROW_CHARACTER_BIBLE.md` maintenance:
- it is a mandatory living repository document, not a one-time creative brief
- review it at every Gate close
- update it immediately when a meaningful Harrow canon, visual-reference, voice, lore, satire, social, website-host, environmental, or rejected/superseded creative decision changes
- authoritative supplied visual references outrank older generated variations
- preserve `LOCKED`, `STRONG DIRECTION`, `OPEN`, `CLASSIFIED`, `SUPERSEDED`, and `REJECTED` distinctions
- do not let creative canon survive only in conversation history

README maintenance:
- keep `README.md` current between Gates
- it is not a substitute for either living bible
- README should stay concise enough for repository orientation while the two bibles carry exhaustive project and creative handoff context

Repository privacy workflow — locked:
- public Git identity is `Harrow <noreply@hellboxcomics.com>`
- never expose the user's personal/legal identity in tracked project material, commit metadata, committed terminal logs, example paths, or public documentation
- when copying terminal output into documentation, remove local usernames/hostnames and any private tokens/secrets
- commit hashes are not durable handoff anchors; privacy/history maintenance can invalidate them
- prefer Gate/checkpoint names, commit subjects, filenames, migrations, durable data state, and live acceptance results
- old pre-privacy clones/history must never be merged back into `main`

Living-document maintenance between formal Gate closes:
- update this file immediately for major architecture, tokenomics, publication-rule, platform, security, ownership, deployment, or product-direction changes
- update `HARROW_CHARACTER_BIBLE.md` immediately for meaningful Harrow canon, visual, voice, lore, environment, satire, social, or creative-direction changes
- when a Harrow decision changes product behavior, record the consequence here as well
- do NOT interrupt implementation to document every minor CSS/file change

Localization workflow:
- every new user-visible interaction/text added during development gets a canonical English locale key when created
- secondary languages may temporarily fall back to English while English copy is still changing
- after English copy freeze, run a full locale delta and final cross-language QA across every hotspot, button, link, state, drawer, error, announcement, Reader/Press/Archive state, metadata field and accessibility string

Avoid unnecessary repository restructuring.

Creative-canon handoff rule — locked:
- `HARROW_CHARACTER_BIBLE.md` is the canonical creative reference for Harrow
- do not reconstruct Harrow from chat memory when the bible or authoritative supplied reference assets answer the question
- if a new explicit creator decision conflicts with the bible, the new decision wins and the bible must be updated
- generated art does not silently create or change canon

File handoff rules:
- every replacement artifact/file must be delivered in **both** forms: a direct file and a ZIP copy
- direct `.js` downloads have been unreliable for the user, so the ZIP is especially important for JavaScript, but still provide both
- the user normally drops delivered items into the repository root
- if the destination folder already exists in the repository, the ZIP contains only the replacement file(s) being handed off; do not recreate/nest the existing folder structure inside the archive
- if the destination folder is new, include only the folder structure required so extraction from the repository root creates the correct new path
- always state the exact destination path for every delivered file
- always print the complete current terminal/deploy/verification command needed for the immediate step
- never tell the user to look back at an earlier message for required commands

Do not modify `src/index.js`, `wrangler.jsonc`, `.assetsignore`, or deployment structure casually.

## 3. CURRENT REPOSITORY / DEPLOYMENT STATE

The repository was recovered after a broken all-at-once Gate 0.2 deployment, then rebuilt incrementally.

Current production state:
- branch: `main`
- Cloudflare deployment is live
- Gate 0 foundation is complete
- Gate 1 publication platform/data model is complete
- Gate 2 SciVive Reader vertical slice is complete
- Gate 2 closeout state bible and README are complete
- Gate 3 identity, ownership authority, Archive integration, Reader authority wiring, sealed Press, and permanent first-introduction routing are complete
- outside first-time document navigation to `hellboxcomics.com` now redirects to `https://hairylabs.io/page/6`
- `/campaign-complete` sets only non-authoritative onboarding completion state and returns to the current Hellbox public experience
- `/campaign-reset` clears only onboarding completion state and redirects to Byte #6
- the sealed Press contains an accessible native replay link: `START ANOTHER INCIDENT`
- valid Harrow `/__harrow` private access bypasses both campaign completion requirements and the sealed surface so development work can continue directly on the real site
- Gate 3 introduced the permanent repo-root `HARROW_CHARACTER_BIBLE.md` creative-canon authority
- Gate closeout now requires all three living documents: `HELLBOX_PROJECT_STATE.md`, `HARROW_CHARACTER_BIBLE.md`, and `README.md`
- public Git history was privacy-rewritten after Gate 2; old pre-rewrite SHAs are intentionally obsolete
- identify implementation checkpoints by commit subject/Gate rather than hard-coded SHA in handoff documentation
- public site works in English and Spanish
- current main frontend runtime query version: `20260829-gate3-archive-09d20a8`
- current Gate 0.2 layout stylesheet cache generation remains `gate0-2-04`
- GA4 is installed with Measurement ID `G-5E9EX1RE0Z`
- GA4 Realtime was verified; Brave Shields can block the user's own Analytics requests
- public/backend multi-chain foundation is live
- production D1 database `hellbox-production` is bound to the Worker as `DB`
- production R2 buckets remain `hellbox-public` and `hellbox-private`
- SciVive protected Reader delivery is stored in `hellbox-private`
- Worker publication APIs read D1 rather than a hardcoded publication registry
- Worker Reader delivery pointers (`reader_manifest_key` and `private_prefix`) come from D1
- Worker wallet authentication authority is D1-backed (`wallet-signature-d1-session`)
- live health reports publication engine `publication-key-d1-v1`, registry source `d1`, `readerConfiguredCount: 1`, authentication engine `wallet-signature-d1-session`, and ownership engine `publication-contract-balance-d1-cache-v1`
- SciVive remains intentionally private and not publicly enumerable
- normal unauthenticated/public `/api/reader/scivive` returns HTTP `404` by design
- the temporary Gate 2 preview route was removed after testing
- temporary Cloudflare secret `HELLBOX_GATE2_READER_KEY` was permanently deleted after testing
- Press prototype is usable enough to defer, but is not final

### Gate 3.1 — SEALED PRESS — COMPLETE

The launched-but-incomplete site is intentionally hidden behind a Harrow-themed prelaunch surface while development continues.

Current sealed-surface facts:
- public document navigation is intercepted Worker-first and serves `prelaunch.html`
- `wrangler.jsonc` uses `assets.run_worker_first: true` so the Worker wins before static `index.html`
- `HELLBOX_PRELAUNCH_MODE` is `sealed`
- public sealed document responses use no-store/cache-eviction headers so stale Cloudflare/browser HTML cannot expose the old homepage
- private owner/developer entry is `/__harrow`
- reseal route is `/__harrow/reseal`
- public status route is `/api/prelaunch/status`
- private access uses Cloudflare secret `HELLBOX_PRELAUNCH_ACCESS_KEY`
- the bypass cookie is secure/HttpOnly/SameSite=Strict and separate from all wallet/Reader/ownership authority
- the secret is never placed in URLs, localStorage, tracked files, or public HTML
- `.assetsignore` was tightened after static deployment was found capable of exposing repository internals
- live `/.git/config` was verified HTTP `404`
- a fresh outside mobile visit was verified to see `THE PRESS IS CLOSED`
- a valid Harrow bypass session was verified to see the real development site
- resealing was verified to restore the closed surface
- this private Harrow bypass must remain higher-priority than any future public onboarding redirect

### THE 30-MACHINE PROBLEM — CAMPAIGN COMPLETE; PERMANENT ONBOARDING INTEGRATION PENDING

The marketing campaign is complete as a 30-transmission linear interactive comic distributed across thirty Pulse Bytes owned/controlled for the project. HairyLabs page caching/propagation is expected before the public-entry redirect is enabled.

Permanent product decision:
- **THE 30-MACHINE PROBLEM is Hellbox Comics' permanent first-introduction medium, not a disposable prelaunch stunt**
- while the site is in development, first-time/outside visitors will be sent to Byte #6 before they see the sealed Press screen
- after the full site launches, the same first-introduction path remains; its story is revised over time to reflect Hellbox's current status and the completion destination becomes the live Hellbox experience
- visitors who have completed it can deliberately replay it as many times as they want
- the sealed screen must gain an in-world replay control that clears only the campaign-completion marker and returns to Byte #6
- campaign completion/replay state is **not authorization** and must never grant wallet identity, ownership, Reader access, Harrow bypass, or other privileged state

Locked transmission sequence:

`#6 → #11 → #13 → #19 → #20 → #23 → #27 → #39 → #41 → #44 → #55 → #62 → #64 → #67 → #77 → #82 → #84 → #85 → #100 → #103 → #104 → #122 → #145 → #149 → #219 → #223 → #237 → #238 → #282 → #333 → Hellbox`

Campaign production rules:
- TX01 / Byte #6, beginning `ONE OF MINE FOUND YOU.`, is the canonical creative/technical template
- every transmission is introduced/created/narrated by Harrow from inside his world
- every Byte is a distinct subordinate machine/servant/accomplice carrying a real Hellbox job
- the actual Byte art is loaded from HairyLabs using the chain/contract/token thumbnail endpoint
- each page is a comic page/panel experience, not a generic campaign landing page
- every transmission explicitly inherits a consequence/clue/order from the prior Byte and routes to the next actual Byte
- humor is mandatory; clues, riddles, lore and project explanation are delivered through Harrow/Byte behavior rather than brochure copy
- HairyLabs Byte pages currently use **zero JavaScript** as the deployment-safe baseline; interactivity uses native HTML such as `<details>/<summary>` plus CSS
- HairyLabs page payload ceiling is approximately `32,768` bytes; canonical campaign pages were kept comfortably below it
- Byte #333 is the final reveal/exit and must route through Hellbox campaign completion rather than merely linking to `/`

Campaign day architecture:
- Day 1 / TX01–06 — **BREACH**: what are these machines and why did one find me?
- Day 2 / TX07–12 — **PROOF**: Hellbox is a comics-first publisher; Reader/Archive/finite publication proof
- Day 3 / TX13–18 — **MACHINERY**: pooled Byte infrastructure, RPC, Chain ID 369, identity, provenance, native-chain discipline
- Day 4 / TX19–24 — **OPERATOR**: Harrow himself; sleepless obsession, outlaw posture, music, bike, earned recognition
- Day 5 / TX25–30 — **IGNITION**: artifact history, Press, detail/calibration, manifest, final distributed-comic reveal

Locked final narrative principle:
> **DO NOT MARKET HELLBOX. DEMONSTRATE WHAT HELLBOX DOES. MAKE THE MACHINERY TELL THE STORY.**

Rejected/superseded campaign work:
- the earlier generic 29-page package that treated transmissions as loosely related marketing pages is invalid and must never be reused
- the canonical remaining 29 pages were rebuilt from TX01's approved Byte #6 grammar
- JavaScript-dependent campaign buttons are not the baseline while HairyLabs deployment behavior remains unreliable

### Permanent first-visit flow — LIVE / LOCKED

Current public behavior:

`new visitor → hellboxcomics.com → Byte #6 → linear 30-Byte story → Byte #333 → /campaign-complete → current Hellbox experience`

During development, the current Hellbox experience after completion is `THE PRESS IS CLOSED`.

Replay behavior:

`current Hellbox experience → START ANOTHER INCIDENT → /campaign-reset → Byte #6`

Live routing/security facts:
- ordinary outside document navigation without campaign-completion state redirects to `https://hairylabs.io/page/6`
- `/campaign-complete` sets a secure HttpOnly SameSite=Lax, non-authoritative completion cookie and redirects to `/`
- `/campaign-reset` clears that completion state and redirects to Byte #6
- campaign redirect/completion/reset responses use no-store/no-cache semantics
- APIs are handled before public onboarding routing; static assets remain available and are not trapped in the story
- Harrow's valid `/__harrow` bypass is independent and takes priority over campaign completion and the sealed surface
- campaign state grants no wallet identity, ownership, Reader access, Hellion status, or private Harrow privilege
- Byte #333's final Hellbox exits now route through `https://hellboxcomics.com/campaign-complete`
- `prelaunch.html` now contains an accessible normal link to `/campaign-reset`
- after main launch, completion will return to the live Hellbox site while the first-introduction story remains permanent and is revised to reflect current project status

### HairyLabs cache/history dependency — EXTERNAL / NON-BLOCKING

The campaign code/content work is complete, but several HairyLabs Byte pages may temporarily display older inscribed/cached versions until HairyLabs refreshes or provides a history-clear/update control.

Known pages awaiting external refresh when last checked:
- Byte #6
- Byte #11
- Byte #13
- Byte #19
- Byte #20
- Byte #23
- Byte #104
- Byte #223
- Byte #333

Locked testing rule while this external state remains:
- **do not use any Byte page in acceptance/regression testing**
- public-gated testing goes directly to Hellbox completion/prelaunch endpoints as appropriate
- real-site/application testing uses the Harrow private bypass and the actual index/application
- stale HairyLabs behavior is not a Hellbox failure
- resume full `#6 → #333` end-to-end acceptance only after the creator explicitly confirms the Byte lane is fully refreshed/clear
- at the end of every upcoming Gate, explicitly ask whether HairyLabs has refreshed the affected pages
- do not reopen Hellbox code merely to compensate for HairyLabs cache/history lag unless an actual Hellbox defect is discovered

Production D1 migrations applied:
- `0001_publication_platform.sql`
- `0002_refine_asset_location_identity.sql`
- `0003_seed_scivive.sql`
- `0004_connect_scivive_reader.sql`
- `0005_wallet_identity.sql`
- `0006_ownership_index.sql`

Gate 3 durable wallet identity checkpoint:
- wallet signing challenges are stored in D1 (`wallet_auth_challenges`)
- challenges are single-use via durable `consumed_at`
- wallet sessions are stored in D1 (`wallet_sessions`)
- sessions are chain-aware, expiring, and revocable
- live production test proved challenge → `personal_sign` → verify → D1 session → session restore → revocation → HTTP `401`
- challenge replay returned HTTP `409`
- live browser acceptance proved the real homepage can reach `VERIFIED` using a throwaway wallet and real production auth endpoints
- identity remains separate from ownership (`VERIFIED` identity did not create an owned publication)
- account/chain changes clear browser-side authenticated state
- throwaway challenge/session records were deleted after testing
- live browser acceptance tool: `tools/test_wallet_auth_ui.py`

Gate 3 ownership/Archive/Reader authority checkpoint:
- `wallet_publication_holdings` exists in production D1
- `ownership_verification_events` exists in production D1
- `active_wallet_publication_ownerships` view exists in production D1
- D1 ownership records are evidence/cache only; blockchain state remains authoritative
- one native ERC-721 collection contract per publication/release is the locked model
- publication-level ownership is verified with that publication contract's `balanceOf(wallet)`
- successful owned/not-owned observations are cached in D1 only for a bounded freshness window
- RPC errors create audit/error evidence and must never silently rewrite a prior owner as `not_owned`
- `/api/wallet-status` requires an authenticated D1-backed wallet session; unauthenticated calls return HTTP `401`
- verified frontend Archive state comes from authenticated `/api/wallet-status`, never localStorage or browser claims
- Reader manifest/page authorization and Archive ownership both call the same Worker ownership authority
- browser/localStorage poisoning was explicitly tested and could not create an owned publication or enable Reader access
- Reader regression acceptance passes at laptop, tablet, and mobile sizes using an authoritative owned fixture
- live wallet identity acceptance passes after Archive integration
- SciVive still has no deployed contract by design; therefore no positive on-chain owner can exist until Gate 4
- because SciVive remains private, normal public Archive does not enumerate it and normal Reader requests continue to return HTTP `404`

SciVive durable Reader binding:
- package status: `draft`
- private page prefix: `comics/scivive/001/reader/pages/`
- Reader manifest key: `comics/scivive/001/reader/manifest.json`
- validation errors: `0`
- validation warnings: `1`
- publishing enabled: `0`
- Reader manifest registered as `reader-manifest`
- Reader manifest access class: `reader_gated`
- Reader manifest provider: `r2_private`
- Reader manifest public retrievable: `0`

Gate 2 private Reader storage:
- canonical source PDF bytes: `8,433,084`
- canonical source PDF SHA-256: `d105e16e991944b63d8e696c8236f5b4497d3c959119a87e580f46f2181bc548`
- canonical source PDF page count: `461`
- Reader presentation format: WebP facsimile pages
- generated Reader pages: `461`
- generated Reader page bytes: `156,576,522`
- private objects in delivery plan: `462` total (manifest + 461 pages)
- all `462/462` objects were downloaded back from remote R2 and matched local byte size + SHA-256
- page `0001` was subsequently fetched through the production Worker and matched the local generated WebP byte-for-byte

Gate 2 browser acceptance:
- laptop `1440x900`: PASS
- tablet `820x1180`: PASS
- mobile `390x844`: PASS
- browser acceptance test: `tools/test_reader_ui.py`
- production publication/ownership data is not modified by that browser test
- laptop/tablet verify the full web Reader control surface
- compact phone layout verifies protected image display, next/previous navigation, close, page-fit presentation, and viewport containment
- protected page transport uses authenticated `fetch` → Blob → `URL.createObjectURL(...)`, not direct protected URLs in `<img src>`
- Reader is not implemented as an embedded PDF viewer

Recovery history remains:
- the repository was restored from the last known-good Gate 0 baseline after a broken all-at-once Gate 0.2 deployment
- `main` was rebuilt incrementally from that recovered baseline
- broken backup branch: `backup-broken-gate02-20260828`
- the later privacy rewrite intentionally changed historical commit hashes across both branches

The broken branch is forensic history only.
Do not merge it wholesale into `main`.
Do not restore or merge an old pre-privacy clone, bundle, or branch snapshot back into the live repository, because doing so could reintroduce scrubbed identity metadata.

## 4. ACTIVE VISUAL / DEVICE TARGETS

Website priority:
1. exceptional PC/Mac browser experience
2. polished and genuinely usable tablet/mobile web experience
3. dedicated native mobile/tablet app later

The website must be dialed in before native-app development begins.

Current web acceptance sizes established in Gate 2:
- laptop: `1440x900`
- tablet: `820x1180`
- phone: `390x844`

Reader product rule:
- laptop/desktop web is allowed the richest control surface
- tablet web should retain strong Reader functionality
- compact phone web may simplify controls when necessary, but must remain polished, readable, navigable, contained within the viewport, and ownership-safe
- do not require desktop-control parity on compact phone layouts merely to claim responsiveness
- long-term app-store mobile/tablet experience will be purpose-built after the website is mature

Until dedicated widescreen monitors are available again:
- optimize standard laptop/desktop
- optimize tablet/mobile

Deferred:
- vertical widescreen
- horizontal widescreen

Widescreen-specific tuning resumes separately; do not force one breakpoint to serve every display.

## 5. HELLBOX CORE PRODUCT — LOCKED

Hellbox Comics is an underground digital publishing house.

Priority:
1. comics
2. collecting
3. ownership
4. interaction
5. blockchain

The blockchain is infrastructure underneath the publishing experience.

Hellbox is PulseChain-rooted but not permanently PulseChain-only.

Future EVM expansion must be configuration-driven and use native deployments per chain.

Never bridge Hellbox NFTs.

One conceptual publication is identified by a chain-independent `publicationKey`.

A specific blockchain asset is identified by:
`(chainId, contractAddress, tokenId)`

A collector-facing copy number is separate from token ID.

---

## 6. HARROW — LOCKED CORE

Harrow is:
- writer
- artist
- publisher
- operator
- narrator
- host
- problem

Harrow is manic, sleepless, perfectionistic, paranoid, narcissistic, reckless, brilliant, funny, suspicious, highly productive, promiscuous, and convinced he is normal.

He behaves like a 1%er:
- does not ask permission
- does not seek approval
- does not beg people to buy
- assumes people return because the work is the best
- treats fascination as inevitable

Emotional target:
- first reaction: “this dude is fucked”
- then: “he is disturbingly observant”
- then: “he is absolutely right”
- eventually: “why is he my favorite person?”

Harrow must not become:
- a generic Web3 founder
- a community manager
- a Joker knockoff
- a random edgelord
- a detective/cop character
- a superhero
- a fantasy demon king

He lives in the audience’s real world and should feel like someone who could appear at the next crypto convention.

Core art-direction rule:
**The machinery is disciplined. The operator is not.**

Private lore:
- Harrow is secretly a career fireman
- never state this publicly
- only extremely subtle clues are allowed

Motorcycle:
- black Harley-Davidson Road King Special / heavy bagger identity
- Harrow hates cars: “Cars are cages.”
- old bike name `DEADLINE` is rejected permanently
- bike currently remains unnamed

---

## 7. HARROW ART STYLE DIRECTION

Working artistic identity:
**Infernal Outlaw Editorial Realism**

Primary study influences:
- David Mann — biker authenticity, machine identity, outlaw atmosphere
- Geof Darrow — obsessive machinery and dense visual storytelling
- Bill Sienkiewicz — psychological instability and expressive mixed media
- Dave McKean — artifacts, collage, typography, documents, memory
- Ralph Steadman — manic marks, satirical aggression, handwritten disruption
- Eduardo Risso — noir clarity, silhouettes, readable darkness

Secondary influences:
- Richard Corben
- Simon Bisley
- Harvey Kurtzman / MAD
- South Park satire logic
- Norman Rockwell staging, inverted into Hellbox
- Hieronymus Bosch micro-stories
- David Fincher visual discipline

Do not imitate any single artist directly.

---

## 8. HERO — CURRENT STATE

Canonical hero asset URL:
`https://cdn.hellboxcomics.com/assets/brand/hellbox/banners/hellbox-hero-production.png`

Latest hero master is approved for production.

Important hero rules:
- no fake CSS pencil
- no visible plus-sign hotspots
- environmental discoveries should be invisible
- `PUT THAT BACK` belongs on the production folder marked NOT FOR RELEASE
- bike remains unnamed
- Pulse Byte / infrastructure hotspot maps to actual infrastructure
- Harrow, comic pages, bike, production folder, cabal/wall, infrastructure are meaningful discoverables

Current recovered Gate 0.1 may not yet contain every later intended refinement.
Reapply later changes incrementally, one file at a time, and verify.

---

## 9. ENVIRONMENTAL DISCOVERY PHILOSOPHY

Do not show:
- plus signs
- map pins
- bouncing icons
- “click here”
- persistent hotspot circles

Interactive objects should be discovered.

Desktop:
- subtle local lighting/contrast when approached
- cursor/environment reaction
- keyboard focus remains visible

Mobile:
- no hover dependency
- subtle environmental disturbance
- large invisible tap regions
- no cheesy tutorial overlays

Accessibility:
- every hidden interaction still needs a useful accessible name
- keyboard and screen reader access remain intact

---

## 10. HELLION SYSTEM — LOCKED DIRECTION

HELLION is not a cheap return-user badge.

Hellion is the top-tier initiatory class.

The relationship system should feel like a school the user did not know they enrolled in.

Structural inspiration:
- deep secret-degree / Masonic-style progression
- hidden internal degrees
- never publicly presented as XP or a normal loyalty program

No public:
- progress bar
- score
- leaderboard
- “Hellion Level 4”
- recipe for becoming Hellion

A useful internal structure is 33 hidden degrees, with Hellion beginning only in the highest band.

Hellion recognition should be rare, approximately top 1–5% of meaningful users once real behavior exists.

Relationship model distinguishes:
- permanent history
- current standing
- volatile favor

Money matters but cannot fully buy status.

Top hidden Hellion status should require balanced depth:
- ownership
- reading
- participation
- time
- discoveries
- release history
- current relevance
- collection completeness

Hellion certificate:
- sarcastic award made by Harrow
- Harrow keeps custody
- can be ripped/VOID/revoked later
- history still records that the person once earned it
- restored status can result in the certificate being taped back together

Alias behavior:
- Harrow may learn wallet alias/name
- usually deliberately gets it slightly wrong
- correct-name usage should be rare and emotionally meaningful

Current local prototype must NOT cheaply award Hellion from localStorage interactions.

---

## 11. COMIC / PUBLICATION FORMAT

`NO CONSENSUS` is NOT canon.
It was only a placeholder title during early format work.

Current standard ordinary Hellbox comic issue format:
- 14 story pages
- 64 chronological frames
- frame numbering never resets within an issue
- repeated production template

Harrow may:
- create one issue and leave that title dormant for a year
- rotate among multiple titles
- publish one-shots
- obsessively make many issues in one title
- revisit dormant stories later

Future titles, flagship series, main characters, and casts are still open.

Editorial focus:
- approximately 80–90% crypto / blockchain / real-world satire
- factual blockchain happenings, culture, projects, tokens, NFT collections, community behavior
- mature South Park-like satire
- fictional stories grounded in recognizable real-world truths
- no generic superhero fiction disconnected from the community

Hellbox is mature/adult-oriented, not for children.

---

## 12. NFT ARCHITECTURE — LOCKED

Preferred standard:
- ERC-721 / PRC-721 style individual copies
- each copy is a unique token

### Publication-contract model — LOCKED

Each Hellbox publication/release gets its own native ERC-721 collection contract per chain.

Examples:
- SciVive → its own SciVive ERC-721 collection
- Comic Issue A → its own finite ERC-721 collection
- Comic Issue B → its own finite ERC-721 collection
- one-shots/special releases → their own publication collections

Reason:
- every release should feel like a finished collectible object, not another token added forever to one giant Hellbox collection
- each release gets its own marketplace collection identity, owners, volume, floor/history, finite supply, and contract address
- Hellbox.com is the publisher/library that unifies these separate release collections

The old "one master Hellbox NFT collection contract per chain" rule is retired and must not be reintroduced.

### Standardized deployment — LOCKED

Do NOT hand-code a unique smart-contract implementation for every release.

Use:
- one standardized/audited `HellboxPublication` implementation
- one `HellboxPublicationFactory` per supported chain
- fresh publication contracts deployed from that common factory/template
- minimal-proxy/clone deployment is preferred if security, tooling, and marketplace compatibility remain appropriate after Gate 4 testing

Each publication contract owns its release-specific configuration, including as applicable:
- publication key
- collection name/symbol
- max supply
- mint price/payment mode
- wallet/transaction mint limits
- royalty configuration
- metadata/base URI/configuration
- lifecycle/publishing controls

For a normal finite issue, max supply must become immutable once the publication contract is initialized/configured.
Burns may reduce surviving supply; nothing may increase the cap afterward.

### Identity across Hellbox / chains

Conceptual publication identity remains:
`publicationKey`

A native blockchain edition is identified by:
`(chainId, contractAddress)`

An individual collectible is identified by:
`(chainId, contractAddress, tokenId)`

A publication may later have a separate native deployment on another supported EVM chain, but Hellbox NFTs are never bridged.

### Ownership/indexing

Because one contract maps to one publication on a given chain:
- `balanceOf(wallet)` is a valid fast on-chain answer to "does this wallet own at least one copy of this publication?"
- D1 may cache that successful on-chain observation for a short bounded freshness window
- D1 can never create/grant ownership by database insertion; chain state remains authoritative

Token-level indexing is still required for collectible detail and advanced publication mechanics:
- index `Transfer` events
- verify specific token ownership with `ownerOf(tokenId)` where token-level certainty is required
- maintain token/copy provenance and history
- support copy-number mapping
- support future sealed/unsealed state, special copies, burns, Hellforge/evolution, and other token-specific behavior

Do not use ERC721Enumerable as the core ownership index.

Publication lifecycle:
`private → announced → mint_live → circulating`

Standard future paid Hellbox edition:
- max supply: 216
- 6 × 6 × 6
- supply never increases above 216
- surviving supply may only decrease through burns
- general target primary price: ~$6.66 equivalent
- general planned royalty: 666 bps
- general future primary limit: max 6 lifetime primary mints per wallet/publication

SciVive is the exception.

---

## 13. COPY NUMBER ASSIGNMENT

Human copy numbers should ideally be shuffled/unpredictable.

Reason:
- reduce sniping of lore-relevant copy numbers
- separate mint order from collectible copy identity

Lore-relevant numbers may include:
- 13
- 23
- 33
- 66
- other intentionally selected numbers

Special copies may differ by:
- NFT cover/plate
- metadata
- Reader content
- environmental behavior
- temporary effects
- permanent state
- future Hellforge eligibility

Do not convert this into generic rarity tiers.

Perfect anti-sniping is not a launch blocker.

---

## 14. SEALED / UNSEALED — LOCKED DIRECTION

For publications that support sealing:

SEALED:
- unread
- may participate in future sealed $SIN reward path
- cannot burn
- may have transfer restrictions while actively locked in future reward system

UNSEAL:
- one-way permanent state change
- becomes readable/experiential
- can never earn $SIN again from sealed reward path
- any accrued $SIN should be forced/withdrawn to owner wallet on unseal
- sealed-related transfer restrictions end according to final implementation
- unsealed copies may burn
- sealed copies may not burn

SciVive does NOT use sealing.

---

## 15. BURN — LOCKED PHILOSOPHY

Burning must create a direct compelling benefit to the burner.

It cannot exist only to reduce supply or enrich surviving holders.

Strong future direction:
- burn one or more eligible unsealed copies
- transform a surviving copy
- record consumed copy history
- unlock meaningful state, cover, Reader path, proof, or future Hellforge result

Burn rules are publication-specific.

No universal public burn button.

SciVive has no burn feature.

---

## 16. FUTURE $SIN

$SIN is future/classified.

Do not front-run it publicly.

Expected launch route:
- PUMP.tires

Do not build a bespoke SIN ERC-20 unless strategy changes.

Future conceptual revenue routing:
- 1/3 Hellbox/project
- 1/3 market-buy $SIN + burn
- 1/3 market-buy $SIN + rewards

Keep this private until intentionally revealed.

Future NFT/token-bound direction:
- eligible comics may act like token-bound wallets/accounts
- sealed eligible copies may participate in future reward systems
- unsealing permanently ends sealed SIN earning eligibility

Exact reward formulas remain open.

---

## 17. HELLFORGE / SINVAULT

Hellforge:
- future transformation/evolution machinery
- publication-specific recipes
- exact rules NOT locked

SinVault:
- future economic/reward component
- exact mechanics NOT locked
- do not turn it into generic staking by assumption

ERC-6551/token-bound architecture:
- optional future capability
- not a launch blocker

---

## 18. SCIVIVE — LOCKED TEST PUBLICATION

`publicationKey: scivive`

SciVive:
- standalone publication
- not Issue #1
- PulseChain
- ERC-721
- max supply 5,555
- free primary mint
- max 1 primary mint per wallet
- max 1 per transaction
- royalty 369 bps
- Reader enabled

SciVive does NOT use:
- Hellforge
- $SIN
- sealing
- vault
- evolution
- burn gimmicks
- easter-egg token transformations

SciVive source:
- existing open-source ebook package
- EPUB exists
- PDF cover/source exists
- source is rough/unfinished
- Harrow will NOT rewrite, edit, restore, sanitize, or finish Richard Heart’s book
- Harrow is publisher, not co-author/editor

Purpose:
- prove mint → ownership → Archive → protected Reader

About one year after initial Hellbox SciVive release:
- planned graphic-novel adaptation
- follows standard 14-page Hellbox comic rules
- exact supply/price not yet locked
- may cost more because it requires significant Harrow production work

---

## 19. READER — PRODUCT PRIORITY

The Reader is the heart of the product.

It must not feel like an embedded PDF viewer.

Reader presentation classes:
- BOOK
- COMIC
- future ENHANCED

BOOK:
- prose/facsimile, e.g. SciVive
- Gate 2 proves BOOK via page-based WebP facsimile delivery from a verified source PDF

COMIC:
- fixed page/spread reading
- later work can add comic-specific spread behavior without replacing the Reader architecture

ENHANCED:
- future artist-authored sound, timing, depth, lighting, frame effects
- deliberate and restrained
- no automatic gimmick animation

Reader principles:
- artwork/content is the star
- UI disappears when not needed
- fit page
- fit width
- paged
- continuous
- keyboard
- touch/swipe
- preloading
- accessibility
- optional sound with captions/transcripts where needed
- ownership gate
- protected assets
- no dishonest DRM claims
- protected pages must not rely on raw private URLs that can be dropped directly into `<img src>`
- authenticated browser delivery should fetch protected bytes, convert them to Blob/object URLs, and revoke them when no longer needed

Gate 2 implemented BOOK Reader foundation:
- SciVive Reader manifest: `publications/scivive/reader/manifest.json`
- manifest page count: `461`
- deterministic page storage keys: `page-0001.webp` through `page-0461.webp`
- reproducible source/render tool: `tools/build_scivive_reader.py`
- reproducible private R2 upload/verification tool: `tools/upload_scivive_reader.py`
- browser acceptance tool: `tools/test_reader_ui.py`
- private R2 manifest: `comics/scivive/001/reader/manifest.json`
- private R2 pages: `comics/scivive/001/reader/pages/page-0001.webp` through `page-0461.webp`
- D1 is authoritative for Reader manifest key and private page prefix
- Worker validates private manifest publication identity, page prefix, and page count before serving it
- frontend uses authenticated blob transport for protected page images
- adjacent page preloading is implemented
- continuous mode lazy-loads protected blob images
- normal public SciVive Reader request remains HTTP `404`

Gate 2 authorization proof:
- a narrowly scoped temporary Gate 2 preview session was created solely to prove production private delivery before Gate 3 ownership exists
- the session loaded the real private 461-page manifest from production R2 through the Worker
- page 1 returned HTTP `200`
- Worker-delivered page 1 SHA-256: `822feb5e0b165ae9ba395d7eb1a8821a631951a80cafaae5b9604f2800c94171`
- it matched the locally generated source page byte-for-byte
- the temporary preview routes were then removed
- `HELLBOX_GATE2_READER_KEY` was deleted from Cloudflare
- public Reader protection was re-verified as HTTP `404`

Browser acceptance at Gate 2 close:
- laptop `1440x900`: PASS
- tablet `820x1180`: PASS
- mobile `390x844`: PASS
- laptop/tablet exercise full fit/layout controls
- phone intentionally hides desktop-only FIT PAGE / FIT WIDTH / CONTINUOUS controls below the compact breakpoint while preserving page display, previous/next, close, page-fit, and no horizontal overflow

Important current boundary:
- Gate 2 proves Reader delivery and UI
- Gate 3 now proves production wallet identity plus shared Archive/Reader ownership authority
- SciVive still has no deployed publication contract, so positive real ownership cannot exist until Gate 4
- SciVive remains private/non-public and cannot be considered a production collector-access release until the testnet/mainnet publication path is deliberately advanced

## 20. PRESS — CURRENT / FUTURE

Current Press artwork/interface is a prototype.

Gate 0.2 status:
- desktop/laptop overlap regression was repaired enough to continue
- `HARROW // MACHINE` is structurally separated from the left publication/wallet card in tested standard desktop widths
- current Press formatting is tolerable, not polished
- Press formatting/art is intentionally back-burnered until the dedicated Press Gate unless a regression makes the site unusable

The production Press must be redesigned around real functions before final art/layout approval.

Future Press zones should intentionally support:
- ingest
- publication display
- wallet/collector recognition
- chain/RPC
- release/payment terms
- QC
- signing
- Press core
- copy counter
- release gate
- fault board
- classified future bay

The physical real lever should be the activation control.
Do not add fake CSS levers.

Next Press art must contain clean dynamic screen regions for live HTML data.

Target state sequence:
- ASLEEP
- LOADED
- IDENTIFYING
- RECOGNIZED
- READY
- ARMED
- SIGNING
- PRESSING
- CONFIRMING
- NUMBERING
- RELEASED
- YOURS

Fault states must be clear and honest.

---

## 21. PUBLICATION ENGINE — TARGET END STATE

Desired workflow for a new issue:
1. prepare finished publication package
2. upload it
3. review automatic validation
4. preview Press/Archive/Reader/metadata
5. approve
6. sign one factory deployment/configuration transaction that creates the release's standardized publication contract
7. choose when Press goes live

A fresh contract per release is expected.
What is forbidden is bespoke contract development/deployment ceremony for every issue.

No:
- manual site code edits
- hand-coded one-off contract implementation per issue
- manual R2 file juggling
- hand-written metadata for every launch
- complicated deployment ceremony

---

## 22. MULTI-CHAIN — LOCKED

PulseChain is Hellbox's root and first chain.

Gate 0 foundation now includes a tested multi-chain backend registry.

Configured networks:
- PulseChain mainnet — chain ID 369 — enabled/root
- PulseChain Testnet V4 — chain ID 943 — development/testing configuration
- Ethereum — configured, disabled
- Base — configured, disabled
- Base Sepolia — configured, disabled
- Robinhood Chain — configured, disabled
- Robinhood Chain Testnet — configured, disabled

Verified backend behavior:
- `/api/health` reports multi-chain-ready architecture
- `/api/chains` returns seven configured networks
- `/api/chain-status?chain=pulsechain` returns a live PulseChain block
- `/api/chain-status?chain=base` correctly refuses Base because it is configured but inactive
- publishing is disabled on all chains until a real Hellbox contract deployment is recorded

Public `config/chains.js` exists as a dormant frontend foundation.
It is intentionally NOT loaded by the current page because the first loader integration caused regressions.
Do not re-enable it casually.

Future chain activation should mean:
- enable/add chain config
- configure RPC
- deploy/record that chain's standardized `HellboxPublication` implementation + `HellboxPublicationFactory`
- deploy each publication as its own native release contract through the factory
- record each publication's `(chainId, contractAddress)` deployment
- enable publishing only for configured/validated native publication deployments

No frontend fork.
No new Reader.
No new Archive.
No NFT bridging.

Do not display a chain selector when only one chain is active.
The loaded publication determines the chain.

Before multi-chain launch, eliminate frontend/backend registry drift with a shared/generated source of truth or automated parity validation.

---

## 23. LOCALIZATION — LOCKED DIRECTION

Localization covers the entire website experience, not just menus.

Gate 0 implementation:
- English is canonical
- canonical English catalog currently contains 815 semantic keys
- Spanish contains matching 815 approved keys
- Spanish is the Gate 0 proof/test secondary locale
- desktop `ACCESS // LANGUAGE` control is live
- `?lang=es` and persisted locale selection work
- dynamic Harrow/dialogue/Press/Archive/Reader/interaction copy is keyed
- no live Google translation runs in the visitor browser
- no DOM-scraping translation engine
- no arbitrary JavaScript-string extraction into locale JSON
- deferred locales are hidden from the selector

Google-assisted production workflow:
- canonical English source
- Google Cloud Translation machine draft
- protected Hellbox terminology
- Harrow voice/editorial adaptation
- layout/accessibility QA
- approved static JSON pack

Build tool:
- `tools/google_translate_locale.py`
- API key comes from environment only
- Google key is never stored in site/repo files
- hard local source-character safety cap: 50,000 characters per run

Current Google Cloud note:
- temporary account has $300 trial credit / 90-day trial
- use only for useful temporary/build-time work that remains free or explicitly approved
- do not move production Hellbox infrastructure onto Google merely to consume trial credit
- verify current free-tier/pricing again before future paid-capable use

Deferred until canonical English wording is near final:
- Brazilian Portuguese
- Vietnamese
- Indonesian
- Hindi
- Urdu
- Ukrainian
- Turkish
- Simplified Chinese
- Korean
- Japanese
- French
- Arabic

Every new user-visible string introduced after Gate 0 must receive a canonical English locale key when created.

After English copy freeze:
1. run a locale delta against existing packs
2. translate only added/changed keys where practical
3. perform Harrow voice adaptation
4. perform full interaction QA
5. test every hotspot, button, link, drawer, state, error, notification, metadata field, Reader state, Press state, Archive state and accessibility announcement
6. add RTL support before Urdu/Arabic launch

Publication language remains independent.
A publication is translated only when an intentional localized edition exists.

---

## 24. ACCESSIBILITY — LOCKED IMPORTANCE

Accessibility is a first-class product requirement.

Target practical standard:
- WCAG 2.2 AA

Important support:
- screen readers
- keyboard navigation
- visible keyboard focus
- semantic dialogs
- focus trapping/restoration
- reduced motion
- high contrast
- larger text
- safe touch targets
- captions/transcripts for sound-dependent experiences
- no progression/discovery requiring hearing
- language metadata for assistive technology
- future Reader accessibility

Do not destroy environmental mystery to achieve accessibility.
Use invisible semantic controls plus keyboard/screen-reader access.

---

## 25. LOW-COST OPERATING REQUIREMENT

Hellbox is operated by a solo, part-time creator.

Recurring infrastructure costs should remain as low as practical.

Preferred architecture:
- Cloudflare Worker/static assets
- R2 public/private storage
- D1 database
- no always-on application server unless needed
- no expensive indexer initially
- no CMS unless justified
- direct-to-R2 uploads for large publication packages
- lazy Reader delivery
- event indexing + `ownerOf` verification

Google Cloud:
- temporary trial has $300 credit and a 90-day window
- use for temporary/build-time work only when useful and free
- current example: machine-draft localization
- do not create a permanent production dependency on expiring trial resources
- do not activate/upgrade paid Google Cloud use without explicit user decision

Mainnet contract deployment belongs after product/testnet validation.
PulseChain Testnet V4 should be used first when tPLS is available.

---

## 26. CURRENT RESPONSIVE STATUS

Current live checkpoint: Gate 3 COMPLETE — the authority system, sealed Press, permanent first-introduction routing, completion/replay flow, and private Harrow bypass are live-proven; Gate 4 is next.

Verified:
- standard laptop/desktop remains usable
- tablet Reader acceptance passes at `820x1180`
- compact mobile Reader acceptance passes at `390x844`
- full-screen standard desktop Press no longer falls back to the original overlap after removing the arbitrary 1699px Gate 0.2 ceiling
- hidden hero/theory interactions function
- English/Spanish switching functions
- Gate 2 Reader UI passes browser acceptance at laptop, tablet, and phone sizes
- compact phone Reader remains viewport-contained with working previous/next/close controls
- versioned frontend runtime is live as `/app.js?v=20260829-gate3-archive-09d20a8`

Known visual debt intentionally deferred:
- Press prototype composition is tolerable but far from final
- direct section anchors can land close to the fixed header
- hero top is still partially sacrificed to fixed-header composition
- hero copy still competes with `PUT THAT BACK`
- transient Harrow response cards can cover nearby content
- Harrow → Keep Up transition has excess vertical space
- horizontal/vertical widescreen tuning remains outstanding
- compact phone Reader intentionally has a reduced control surface compared with laptop/tablet; native mobile/tablet app comes later after website maturity

Do not reopen cosmetic Press work until the dedicated Press Gate unless a regression makes the prototype unusable.

## 27. CURRENT KNOWN RISKS

- Broken historical Gate 0.2 branch remains preserved and must never be merged wholesale.
- CSS contains many historical overrides; future cleanup must be incremental.
- Frontend `app.js` is large and monolithic.
- Worker/backend `src/index.js` is large and monolithic.
- D1 publication/Reader delivery, wallet identity, and shared Archive/Reader ownership authority are live; positive minted-owner proof remains legitimately unavailable because SciVive has no deployed contract until Gate 4.
- SciVive package remains intentionally `draft` with 0 validation errors and 1 non-blocking warning.
- SciVive remains intentionally private/non-public until real ownership authorization exists.
- Real minting is not implemented.
- NFT contract is not deployed.
- Archive ownership logic is production-authoritative and chain-backed by design; it currently returns no positive SciVive ownership because Gate 4 has not yet supplied a real publication contract/mint.
- Gate 2 used a temporary preview authorization solely for proof; it has been removed and its Cloudflare secret deleted. Do not resurrect it as production auth.
- Reader browser transport now consumes the same Gate 3 wallet/session/ownership authority as Archive; positive collector access awaits Gate 4's first real contract/mint.
- Current relationship/Hellion system is not server-authoritative.
- Hidden hotspots make exhaustive manual QA difficult; build an internal hotspot inventory/debug mode before release candidate.
- Frontend and backend chain registries can drift until a shared source/parity check exists.
- Final internationalization is incomplete by design until English copy freezes.
- GA4 can be blocked by privacy browsers/extensions; blocker behavior is not a site failure.
- Current Press is only a visual/interaction prototype and must not dictate final Press architecture.
- Current hero composition contains temporary hotspot-coordinate workarounds.
- Cloudflare static-asset edge cache may briefly serve an older unversioned asset after deployment. Keep versioned JS/CSS references and verify the normal path after propagation.
- Browser acceptance currently validates the Reader UI with mocked publication/Reader API responses so it cannot mutate production ownership state. Production private-byte delivery is separately proven through the Worker/R2 Gate 2 verification.
- Public first-visit campaign routing is **not yet implemented**; the live site currently still goes directly to the sealed Press surface for outside visitors.
- HairyLabs campaign pages require their platform-side cache/propagation before Hellbox should begin redirecting first-time public traffic to Byte #6.
- The campaign-completion marker must remain non-authoritative and isolated from Harrow bypass, wallet session, ownership, Reader, and publication security state.
- HairyLabs may temporarily serve stale historical Byte-page inscriptions for campaign pages; this is an external cache/history issue, not a Hellbox routing defect. Bytes are excluded from testing until the creator confirms the lane is clear.

## 28. FILES THAT MUST NOT BE CHANGED CASUALLY

`src/index.js`
- Cloudflare Worker entrypoint / backend
- test after every change

`wrangler.jsonc`
- deployment configuration
- edit only for a specific binding/runtime requirement

`.assetsignore`
- controls public static deployment
- do not alter casually

`index.html`
- public DOM structure
- changes affect many frontend systems

`style.css`
- large historical cascade
- test layout after every change

`app.js`
- main frontend runtime
- test interactions after every change

---

## 29. EXACT NEXT STEP

Gate status:
- Gate 0 COMPLETE
- Gate 1 COMPLETE
- Gate 2 COMPLETE
- **Gate 3 COMPLETE**
- **Gate 4 NEXT**

Gate 3 is closed on every Hellbox-controlled acceptance criterion.

One external item remains tracked outside the Gate blocker model:
- full HairyLabs `#6 → #333` traversal acceptance waits for HairyLabs cache/history refresh
- do not include Bytes in testing until the creator explicitly says the lane is clear
- prompt for HairyLabs refresh status at the end of every upcoming Gate

### Immediate Gate 4 objective

Begin **Gate 4 — PulseChain Testnet Publication Contract + Factory**.

Before creating Solidity or introducing contract tooling, inspect the current repository to determine:
- whether a Solidity/Foundry/Hardhat toolchain already exists
- whether `package.json`, `foundry.toml`, `hardhat.config.*`, `contracts/`, or equivalent contract-test structure already exists
- what existing dependency/tooling constraints must be preserved
- whether PulseChain Testnet V4 access/faucet state is currently sufficient for later deployment

Then choose the smallest single-file Gate 4 implementation step.

Gate 4 must preserve all Gate 3 authority boundaries:
- Archive and Reader continue to consume the same Worker ownership verifier
- publication ownership remains blockchain-authoritative
- D1 remains bounded evidence/cache only
- one native ERC-721 collection per publication/release
- standardized implementation/factory, not bespoke contracts
- no NFT bridging
- no mainnet deployment yet

## 31. PRODUCTION GATE SYSTEM — REBASED 2026-08-29

The previous decimal sub-gates were useful during recovery but are no longer the right planning model.

The production roadmap is now ten gates total: Gate 0 through Gate 9.

This follows the practical progression for a real digital publishing product:
foundation → durable publication platform → Reader vertical slice → identity/ownership → testnet contract → real Press/mint experience → publisher operations → relationship depth → experience/content freeze → release candidate/mainnet.

### GATE 0 — STABILIZATION & PLATFORM FOUNDATION — COMPLETE

Delivered:
- recovered deployable baseline
- safe one-file-at-a-time workflow
- standard laptop/mobile responsive baseline
- hidden environmental discovery system
- accessibility baseline
- English/Spanish localization architecture
- Google-assisted offline translation tooling
- GA4 integration/verification
- backend multi-chain registry/status APIs
- PulseChain live status
- future chains configured but disabled
- Press prototype made usable enough to defer
- living source-of-truth handoff

Gate 0 means the foundation is stable enough to build the actual product.
It does NOT mean the Hellbox product loop is complete.

### GATE 1 — PUBLICATION PLATFORM & DATA MODEL — COMPLETE

Goal:
Make a Hellbox publication a real first-class durable data object rather than hardcoded prototype data.

Delivered:
- D1-backed publication model
- lifecycle records
- chain-independent `publicationKey`
- per-chain deployment/token identity fields
- release/payment/supply configuration
- public/private publication visibility
- R2 public/private package-location model
- publication package manifest/schema
- validation rules
- SciVive as the first real private publication package
- verified SciVive PDF/EPUB SHA-256 fingerprints and IPFS CIDs
- refined asset-location identity supporting primary delivery, source, and mirror locations
- production `DB` binding to D1 database `hellbox-production`
- Worker publication APIs read durable D1 data rather than a hardcoded array

Gate 1 production migrations:
- `0001_publication_platform.sql`
- `0002_refine_asset_location_identity.sql`
- `0003_seed_scivive.sql`

SciVive durable checkpoint:
- `publicationKey`: `scivive`
- lifecycle: `private`
- public visible: `false`
- presentation class: `book`
- Reader enabled: `true`
- Reader access policy: `ownership`
- PulseChain chain ID: `369`
- max supply: `5555`
- payment: `free`
- max primary mints per wallet: `1`
- max per transaction: `1`
- royalty: `369` bps
- publishing enabled: `false`
- contract address: `null`
- package status: `draft`
- package validation: `0` errors, `2` non-blocking warnings

Live verification at Gate 1 close:
- `/api/health` reports `publicationEngine: publication-key-d1-v1`
- `/api/health` reports registry source `d1`
- D1 registry counts: total `1`, public `0`, private `1`
- `/api/publications` returns an empty public list while SciVive is private
- `/api/publications/scivive` returns HTTP `404` to a normal unauthenticated/public request
- all expected bindings report configured, including database/public bucket/private bucket/assets
- repository working tree was clean after production verification

Exit criteria status:
- SciVive exists as a real private publication record: PASS
- package validates without blocking errors: PASS
- public/private asset locations are defined: PASS
- Worker returns publication metadata from durable storage: PASS
- no contract required yet: PASS
- no manual public-site edit required merely to represent the publication: PASS

### GATE 2 — READER VERTICAL SLICE — COMPLETE

Goal:
Make SciVive genuinely readable inside Hellbox while keeping protected delivery independent from yet-unbuilt NFT ownership.

Delivered:
- SciVive BOOK Reader manifest with 461 deterministic pages
- verified canonical SciVive PDF source
- reproducible PDF → WebP Reader build tool
- 461 generated WebP presentation pages
- protected `hellbox-private` Reader delivery
- reproducible remote R2 upload + byte/hash verification tool
- 462/462 private Reader objects remotely verified
- D1 Reader binding migration
- D1-backed `reader_manifest_key` and `private_prefix`
- private Reader manifest registered as a durable package asset
- Worker loads Reader delivery configuration from D1
- Worker loads/validates the protected manifest from private R2
- authenticated protected page delivery through the Worker
- production byte-for-byte page verification
- frontend protected image transport using authenticated fetch + Blob/object URL
- adjacent-page preloading
- continuous-mode lazy protected-image loading
- versioned frontend asset deployment
- browser Reader acceptance test
- laptop, tablet, and compact-phone responsive acceptance
- temporary preview authorization added only for production proof, then removed
- temporary `HELLBOX_GATE2_READER_KEY` Cloudflare secret deleted after proof
- normal public SciVive Reader protection re-verified as HTTP `404`

Gate 2 production artifacts:
- `publications/scivive/reader/manifest.json`
- `tools/build_scivive_reader.py`
- `tools/upload_scivive_reader.py`
- `tools/test_reader_ui.py`
- `migrations/0004_connect_scivive_reader.sql`

Gate 2 implementation checkpoints (identify by commit subject; hashes were intentionally rewritten during the privacy scrub):
- `Gate 2: define SciVive Reader manifest`
- `Gate 2: add SciVive Reader asset builder`
- `Gate 2: add private Reader R2 uploader`
- `Gate 2: bind SciVive Reader delivery`
- `Gate 2: read Reader delivery from D1`
- `Gate 2: add protected Reader preview session` — temporary proof mechanism only
- `Gate 2: remove temporary Reader preview`
- `Gate 2: add protected Reader frontend transport`
- `Gate 2: version protected Reader frontend`
- `Gate 2: add Reader browser acceptance test`
- `Close Gate 2 project state`
- `Close Gate 2 README`

Production acceptance proof:
- authorized temporary Gate 2 test session opened the real production SciVive private manifest
- manifest reported 461 pages
- real protected page 1 returned HTTP `200`
- page 1 matched the locally generated WebP byte-for-byte
- unauthorized normal app Reader request returned HTTP `404`
- after preview cleanup, preview endpoint returned HTTP `404`
- after secret deletion, normal Worker remained healthy
- browser acceptance: laptop `1440x900` PASS
- browser acceptance: tablet `820x1180` PASS
- browser acceptance: mobile `390x844` PASS
- Reader is not an embedded PDF viewer

Exit criteria status:
- authorized test session opens SciVive: PASS
- unauthorized normal app request cannot fetch protected reading assets: PASS
- Reader works on laptop: PASS
- Reader works on tablet/mobile web: PASS
- Reader does not feel/behave like an embedded PDF viewer: PASS
- temporary test authorization removed after proof: PASS

Important boundary:
Gate 2 proves delivery and Reader UX. Gate 3 now proves wallet identity plus shared Archive/Reader ownership authority. Positive real collector ownership remains impossible until Gate 4 deploys and mints the first publication contract.

### GATE 3 — IDENTITY, OWNERSHIP, ARCHIVE & PUBLIC ENTRY — COMPLETE

Goal:
Make wallet identity and publication ownership authoritative without allowing client claims, localStorage, or arbitrary database insertion to grant collector access.

Delivered:
- D1-backed wallet-signature challenge model
- durable single-use challenge consumption
- short D1-backed wallet sessions
- chain-aware identity
- session expiration/revocation boundary
- live wallet browser flow against production challenge/verify/session endpoints
- browser reload restores identity only after server session validation
- challenge replay rejection
- durable D1 publication-ownership verification/cache schema
- immutable ownership-verification event audit layer
- locked one-publication-contract-per-release ownership model
- publication-level ownership verifier using the publication contract's `balanceOf(wallet)`
- bounded D1 ownership-evidence freshness window
- explicit unconfigured/error states rather than fabricated `not_owned`
- authenticated `/api/wallet-status` Archive authority
- Archive frontend wired to server-authoritative ownership
- Reader manifest/page authorization wired to the exact same Worker ownership function as Archive
- browser/localStorage ownership claims proven unable to grant ownership or Reader access
- Reader regression acceptance updated for authoritative ownership and passing on laptop/tablet/mobile

Production proofs:
- live challenge creation persisted in D1
- live EVM `personal_sign` verification succeeded
- challenge was durably consumed exactly once
- replay returned HTTP `409`
- D1 session existed as chain `369`, active and unexpired
- live `/api/auth/session` accepted the D1-backed bearer session
- D1 revocation immediately made the same bearer token return HTTP `401`
- throwaway challenge/session rows were deleted after tests
- live browser acceptance reached `VERIFIED` using a throwaway wallet and real production auth endpoints
- verified identity did not create ownership
- chain/account changes cleared browser auth state
- unauthenticated `/api/wallet-status` returned HTTP `401`
- browser/localStorage fake ownership claims left owned count at `00` and could not enable Reader access
- Reader regression test passed at laptop `1440x900`, tablet `820x1180`, and mobile `390x844`
- production ownership tables contained no fabricated ownership rows before the ownership Worker was enabled

Locked ownership authority:
- each publication/release has its own native ERC-721 collection contract
- blockchain state is authoritative
- `balanceOf(wallet)` is the fast publication-level ownership check because one contract maps to one publication
- D1 stores only bounded, auditable evidence/cache of successful on-chain observations
- RPC errors do not prove non-ownership
- token-level `Transfer` + `ownerOf(tokenId)` remain the future copy/provenance authority for copy number, transfers, special copies, sealed/unsealed state, burn/Hellforge history, etc.
- Archive and Reader must never use different ownership authorities

Gate 3 exit criteria:
- wallet connects/signs through server-authoritative identity: PASS
- short server session is D1-backed, expiring, single-use-challenge protected, and revocable: PASS
- chain-aware wallet identity: PASS
- localStorage/client claims cannot grant identity or ownership: PASS
- ownership authority/cache model is durable and chain-backed by design: PASS
- Archive consumes authenticated server ownership state: PASS
- Reader consumes the exact same ownership authority: PASS
- no-contract/private SciVive cannot falsely grant ownership or Reader access: PASS
- public first-visit redirect to Byte #6: PASS
- campaign completion → current sealed experience: PASS
- replay/reset → Byte #6 redirect: PASS
- Harrow private bypass ignores campaign completion and sealed screen: PASS
- APIs/Reader/repository-private paths remain protected and unaffected: PASS
- full HairyLabs 30-Byte traversal: EXTERNAL CACHE PENDING / NON-BLOCKING
- positive minted-owner proof: intentionally belongs to Gate 4, because Gate 3 correctly does not deploy or fabricate a contract

Important Gate boundary:
Gate 3 is formally closed. Identity/ownership/Archive/Reader authority, SEALED PRESS, permanent first-introduction routing, completion/replay behavior, and Harrow's private bypass are all live-proven. The remaining HairyLabs cache/history refresh is an external non-blocking dependency and must not prevent Gate 4.

#### Gate 3.1 / final-addition status

**SEALED PRESS — COMPLETE**
- public incomplete site is blinded behind `THE PRESS IS CLOSED`
- Harrow has a private secure bypass/reseal path
- static deployment leakage was hardened
- cache-resistant sealed delivery was live-proven

**THE 30-MACHINE PROBLEM — HELLBOX-SIDE INTEGRATION COMPLETE**
- thirty owned Pulse Bytes carry one continuous Harrow-hosted comic/story
- TX01 Byte #6 is the approved standard
- all remaining transmissions were rebuilt to follow that standard
- campaign remains the permanent first introduction to Hellbox after launch
- first-visit redirect, completion, replay, and private-Harrow bypass plumbing are deployed and live-proven
- full Byte-to-Byte end-to-end acceptance is externally cache-pending and is explicitly non-blocking

**FINAL GATE 3 LIVE ACCEPTANCE — 2026-08-30**
- fresh public root request: HTTP `302` to `https://hairylabs.io/page/6` — PASS
- root redirect: `Cache-Control: no-store, max-age=0` — PASS
- root redirect marker: `X-Hellbox-Campaign: first-introduction` — PASS
- `/campaign-complete` followed to `/`: final HTTP `200` sealed Press — PASS
- completion landing visibly contained `THE PRESS`, `START ANOTHER INCIDENT`, and `Experience the 30-machine problem again` — PASS
- `/campaign-reset`: HTTP `303` to `https://hairylabs.io/page/6` — PASS
- reset clears `__Host-hellbox_campaign_complete` with `Max-Age=0` — PASS
- reset response no-store/no-cache — PASS
- valid `/__harrow` session showed `PRIVATE ACCESS // HELD` and entered the real development/index site without Byte redirect or sealed Press — PASS
- `/api/health`: `ok: true` — PASS
- authentication engine remains `wallet-signature-d1-session` — PASS
- ownership engine remains `publication-contract-balance-d1-cache-v1` — PASS
- `/api/prelaunch/status`: `mode: sealed`, campaign start Byte #6, unauthenticated `completed: false` — PASS
- unauthenticated `/api/reader/scivive`: HTTP `404` — PASS
- `/.git/config`: HTTP `404` — PASS
- repository working tree was clean after deployed routing/prelaunch commits — PASS
- full HairyLabs `#6 → #333` traversal: **DEFERRED / EXTERNAL CACHE PENDING; not a Gate 3 blocker**

### GATE 4 — PULSECHAIN TESTNET PUBLICATION CONTRACT + FACTORY

Goal:
Prove the standardized one-contract-per-publication on-chain model before mainnet.

Build/deploy on PulseChain Testnet V4:
- standardized/auditable `HellboxPublication` ERC-721 implementation
- `HellboxPublicationFactory`
- fresh native contract deployment per publication/release
- immutable max-supply enforcement after initialization/configuration
- publication lifecycle rules
- royalty configuration
- mint/payment limits
- event model
- copy-number assignment baseline
- SciVive test publication contract deployed through the factory
- factory/deployment metadata recorded back into Hellbox durable publication configuration

Exit criteria:
- factory deploys a fresh SciVive publication collection
- real testnet mint succeeds
- publication-level `balanceOf` ownership reaches the Gate 3 ownership authority
- token-level Transfer/`ownerOf` evidence can identify the minted copy
- ownership reaches Archive
- minted ownership opens Reader
- a second dummy/test publication can be deployed from the same standard without bespoke Solidity changes
- native future-chain deployment model is proven without bridging

### GATE 5 — PRESS V2 / REAL MINT EXPERIENCE

Goal:
Turn the Press from prototype art into the real publishing/mint machine.

This is when current Press formatting/art debt is intentionally revisited.

Build:
- final Press functional map
- new/final Press art only after functions are known
- real lever activation
- wallet recognition
- publication display
- transaction preparation/signing
- confirmation
- numbering
- clear failure states
- copy counter
- dynamic screen regions
- testnet mint integration

Exit criteria:
Press → wallet transaction → token → Archive → Reader works end-to-end.

### GATE 6 — PUBLISHER / INGEST OPERATIONS

Goal:
Make new publications plug-and-play.

Build:
- publication package upload
- validation
- asset ingest
- metadata generation
- preview
- release configuration
- Press/Archive/Reader preview
- one publication configuration transaction
- controlled go-live

Exit criteria:
A second test publication can be onboarded without frontend code edits, manual R2 juggling, or bespoke contract development; onboarding may deploy a fresh standardized publication contract through the factory as part of the normal release workflow.

### GATE 7 — RELATIONSHIP / HELLION PRODUCT DEPTH

Goal:
Replace the local prototype with the real long-term relationship system.

Build:
- permanent history
- current standing
- volatile favor
- server-authoritative events
- discovery history
- reading/ownership/release history
- rare Hellion thresholding
- certificate custody/revocation/restoration
- alias/name behavior
- privacy controls

Exit criteria:
Hellion cannot be cheaply earned through local clicks and persists according to real behavior.

### GATE 8 — EXPERIENCE FREEZE, CONTENT FREEZE & HARDENING

Goal:
Freeze the product experience before launch.

Resolve deferred work here:
- final hero composition
- show full hero below fixed header
- move copy off `PUT THAT BACK`
- restore true hotspot mapping
- stripper-pole hotspot
- `WHO'S NEXT?` hotspot
- woman/crypto obsession-wall thread
- final Press visual polish
- widescreen/vertical layouts
- final English wording
- final Harrow voice pass
- final locale delta
- remaining languages generated/reviewed
- accessibility audit
- performance audit
- privacy/consent
- analytics event taxonomy
- SEO/social metadata
- legal/contact/privacy surfaces as required
- internal hotspot inventory/test mode
- browser/device matrix

Exit criteria:
feature freeze + content freeze + visual freeze.

### GATE 9 — RELEASE CANDIDATE / MAINNET LAUNCH

Goal:
Turn the frozen product into production.

Build/verify:
- PulseChain mainnet contract deployment
- production publication configuration
- production secrets/bindings
- monitoring/logging
- rate limiting/abuse handling
- backup/recovery plan
- Analytics verification
- rollback procedure
- launch rehearsal
- SciVive production mint
- ownership/Archive/Reader full-path validation
- post-launch checklist

Exit criteria:
SciVive is live and the complete Hellbox publishing loop works in production.

### CURRENT CRITICAL PATH

`Gate 4 testnet publication factory/contracts → Gate 5 Press → Gate 6 publisher operations → Gate 7 relationship depth`

Do not spend weeks polishing prototype surfaces before the ownership → testnet mint → Archive → Reader loop works.

---

## 32. GATE 0 COMPLETION / DEFERRED BACKLOG

Gate 0 was intentionally closed with known non-blocking visual debt.

Deferred to later appropriate gates:
- final Press formatting/art → Gate 5
- hero structural composition/hotspot truth → Gate 8
- stripper pole / `WHO'S NEXT?` / woman-crypto obsession-wall additions → Gate 8
- widescreen/vertical layouts → Gate 8
- all languages beyond Spanish → Gate 8 after English copy freeze
- privacy/consent layer and final Analytics event taxonomy → Gate 8
- mainnet contracts → Gate 9

Localization permanent rule:
Every future user-visible interaction must enter the English catalog at creation time and be included in final locale delta/QA.

---

## 33. EXACT NEXT ENGINEERING ACTION

**GATE 4 IS OPEN.**

Goal:
Build and prove the standardized one-contract-per-publication model on PulseChain Testnet V4.

### First action — inspect before adding files

Do not guess which Solidity framework the repository already uses.

Inspect the repo root and likely contract-tooling paths first. Determine whether the repository already contains:
- `package.json`
- lockfiles
- `foundry.toml`
- `hardhat.config.js` / `hardhat.config.ts`
- `contracts/`
- `test/` / `tests/`
- Solidity compiler/dependency configuration

After that inspection, choose the smallest one-file setup/implementation step.

### Locked Gate 4 contract architecture

Build:
- standardized/auditable `HellboxPublication` ERC-721 implementation
- `HellboxPublicationFactory`
- fresh native publication collection deployed per release
- immutable publication identity/configuration where appropriate
- max supply that cannot increase after initialization/configuration
- burns may reduce surviving supply but never raise the cap
- royalty configuration
- mint/payment limits
- events sufficient for Gate 3 ownership and future token-level indexing/provenance
- SciVive test publication deployed through the factory

SciVive test configuration:
- chain: PulseChain Testnet V4 / chain ID `943`
- max supply: `5555`
- free primary mint
- max 1 primary mint per wallet
- max 1 per transaction
- royalty: `369` bps
- Reader enabled
- no sealing, Hellforge, $SIN, vault, evolution, or burn gimmicks

### Gate 4 acceptance path

`factory deploys SciVive test collection → test wallet mints → Gate 3 balanceOf ownership authority sees owned → Archive shows owned → Reader opens → Transfer/ownerOf identifies the copy`

Also deploy a second dummy/test publication from the same standard without bespoke Solidity changes.

Do not:
- deploy mainnet
- make SciVive public/mainnet-ready merely because testnet works
- bridge Hellbox NFTs
- create one endlessly growing master collection
- hand-code a different implementation per publication
- let max supply increase after configuration
- bypass Gate 3 ownership authority with frontend contract reads
- split Archive and Reader into different ownership sources
- include stale HairyLabs Byte pages in Gate 4 testing

At Gate 4 close:
- update all three living documents
- give a weighted macro-progress report
- ask whether HairyLabs has refreshed the pending Byte pages so the full permanent-introduction traversal can finally be accepted

## 30. RECOVERY AND PRIVACY RECORD

### Recovery

The repository was recovered after a broken all-at-once Gate 0.2 deployment.

Locked recovery facts:
- backup branch: `backup-broken-gate02-20260828`
- the last known-good production tree was restored to `main`
- recovery was validated by matching the recovered tree to the known-good tree before incremental development resumed
- Gate 0, Gate 1, and Gate 2 were then rebuilt/advanced incrementally under the one-file-at-a-time workflow
- exact pre-privacy commit/tree hashes are intentionally no longer recorded here because the later privacy rewrite changed the public history

The broken backup branch is forensic history only.
Do not merge it wholesale into `main`.

### Repository privacy hardening — completed after Gate 2

Public identity rule:
- all Hellbox Git author/committer identity must be `Harrow <noreply@hellboxcomics.com>`
- the user's personal/legal name, personal email, local machine username/hostname, or other directly identifying strings must not be introduced into tracked files, commit messages, examples, screenshots/logs committed to Git, or handoff documentation
- use Harrow/project-level identifiers in public repository material

Completed privacy work:
- all historical commit author and committer identities were rewritten to Harrow
- tracked-file identity references were scrubbed across historical snapshots
- commit messages were scanned
- historical filenames/paths were scanned
- verification result: `0` non-Harrow commit identities
- verification result: `0` historical commits containing the scrubbed personal identity strings
- verification result: `0` historical paths containing those strings
- both `main` and `backup-broken-gate02-20260828` were force-updated to the scrubbed histories using guarded `--force-with-lease`
- GitHub remote branch refs were verified to match the scrubbed local branches
- the local pre-scrub Git bundle was deleted
- `.git/filter-repo` temporary rewrite data was deleted
- temporary Gate 2 shell credentials were cleared

Important consequence:
- every pre-scrub commit hash is obsolete
- do not use old chat logs or old documentation SHAs as authoritative repository checkpoints
- do not resurrect an old clone/bundle without first ensuring it cannot reintroduce pre-scrub history
- durable handoff references should use Gate names, commit subjects, file paths, schema/migration names, production state, and explicit validation evidence rather than SHA values

---

END OF CURRENT PROJECT STATE

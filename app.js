/* ============================================================
   HELLBOX COMICS
   FRONTEND APPLICATION V5
   HARROW'S NERVOUS SYSTEM
   ============================================================ */

(() => {
    "use strict";


    /* =========================================================
       CONSTANTS
       ========================================================= */

    const PULSECHAIN = {
        chainId: 369,
        chainIdHex: "0x171",
        name: "PulseChain"
    };

    const STORAGE_KEYS = {
        discoveries: "hellbox:discoveries:v1",
        visits: "hellbox:visits:v1",
        pressTouches: "hellbox:press-touches:v1"
    };


    /* =========================================================
       SMALL HELPERS
       ========================================================= */

    const $ = (selector, root = document) => {
        return root.querySelector(selector);
    };

    const $$ = (selector, root = document) => {
        return Array.from(root.querySelectorAll(selector));
    };

    const sleep = (ms) => {
        return new Promise((resolve) => {
            window.setTimeout(resolve, ms);
        });
    };

    const clamp = (value, min, max) => {
        return Math.min(Math.max(value, min), max);
    };

    const randomItem = (items) => {
        return items[Math.floor(Math.random() * items.length)];
    };

    const truncateAddress = (address) => {
        if (!address || typeof address !== "string") {
            return "NOT SHOWN";
        }

        return `${address.slice(0, 6)}...${address.slice(-4)}`;
    };

    const safeText = (value, fallback = "") => {
        if (
            value === null ||
            value === undefined ||
            value === ""
        ) {
            return fallback;
        }

        return String(value);
    };

    const safeNumber = (value, fallback = 0) => {
        const parsed = Number(value);

        if (!Number.isFinite(parsed)) {
            return fallback;
        }

        return parsed;
    };

    const normalizeChainId = (value) => {
        if (typeof value === "number") {
            return value;
        }

        if (typeof value === "string") {
            if (value.startsWith("0x")) {
                return parseInt(value, 16);
            }

            return parseInt(value, 10);
        }

        return 0;
    };

    const escapeHtml = (value) => {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;");
    };


    /* =========================================================
       APPLICATION STATE
       ========================================================= */

    const state = {
        wallet: {
            provider: null,
            address: null,
            chainId: null,
            connected: false
        },

        publications: [],

        collection: {
            known: 0,
            owned: 0,
            missing: 0,
            evolved: 0
        },

        discoveries: new Set(),

        press: {
            awake: false,
            busy: false,
            touchCount: 0,
            state: "idle"
        },

        reader: {
            open: false,
            publicationKey: null,
            title: "",
            pages: [],
            pageIndex: 0,
            mode: "paged",
            fit: "page",
            objectUrls: []
        },

        whisperTimer: null,
        responseTimer: null
    };


    /* =========================================================
       DOM REFERENCES
       ========================================================= */

    const dom = {
        body: document.body,

        cursorBurn: $("#cursorBurn"),

        whisper: $("#harrowWhisper"),
        whisperText: $("#harrowWhisperText"),

        discoveryCounter: $("#discoveryCounter"),
        discoveryCount: $("#discoveryCount"),

        harrowOrb: $("#harrowOrb"),

        harrowResponse: $("#harrowResponse"),
        harrowResponseTitle: $("#harrowResponseTitle"),
        harrowResponseText: $("#harrowResponseText"),
        harrowResponseClose: $("#harrowResponseClose"),

        drawer: $("#lairDrawer"),
        drawerBackdrop: $("#lairDrawerBackdrop"),
        drawerClose: $("#lairDrawerClose"),
        drawerCode: $("#drawerCode"),
        drawerEyebrow: $("#drawerEyebrow"),
        drawerTitle: $("#drawerTitle"),
        drawerCopy: $("#drawerCopy"),
        drawerFootnote: $("#drawerFootnote"),

        walletButton: $("#walletButton"),

        heroLogoButton: $("#heroLogoButton"),
        heroTransmission: $("#heroTransmission"),
        heroTransmissionSub: $("#heroTransmissionSub"),

        therapyNote: $("#therapyNote"),

        publicationCount: $("#publicationCount"),
        collectionWallet: $("#collectionWallet"),
        collectionNetwork: $("#collectionNetwork"),
        collectionAccessState: $("#collectionAccessState"),
        terminalTitle: $("#terminalTitle"),
        terminalMessage: $("#terminalMessage"),
        terminalAction: $("#terminalAction"),
        archiveSticky: $("#archiveSticky"),
        archiveHarrowNote: $("#archiveHarrowNote"),
        collectionList: $("#collectionList"),
        collectionStatus: $("#collectionStatus"),

        summaryKnown: $("#summaryKnown"),
        summaryOwned: $("#summaryOwned"),
        summaryMissing: $("#summaryMissing"),
        summaryEvolved: $("#summaryEvolved"),

        archiveEmblem: $("#archiveEmblem"),

        theorySingular: $("#theorySingular"),
        theoryCorrection: $("#theoryCorrection"),
        theoryCenter: $("#theoryCenter"),

        pressSection: $("#press"),
        pressMachineZone: $("#pressMachineZone"),
        pressMachine: $("#pressMachine"),
        pressMachineStatus: $("#pressMachineStatus"),
        pressMachineState: $("#pressMachineState"),

        pressMiniTerminal: $("#pressMiniTerminal"),
        pressMiniStatus: $("#pressMiniStatus"),
        pressPublication: $("#pressPublication"),
        pressSupply: $("#pressSupply"),
        pressWallet: $("#pressWallet"),

        pressConsoleLabel: $("#pressConsoleLabel"),
        pressConsoleTitle: $("#pressConsoleTitle"),
        pressConsoleText: $("#pressConsoleText"),
        pressPowerValue: $("#pressPowerValue"),
        pressInkValue: $("#pressInkValue"),
        pressRpcValue: $("#pressRpcValue"),
        pressIdeaValue: $("#pressIdeaValue"),
        machineConsoleLight: $("#machineConsoleLight"),

        pressLever: $("#pressLever"),
        pressWarning: $("#pressWarning"),
        pressStateRail: $("#pressStateRail"),

        roadmapObject: $("#roadmapObject"),
        manualObject: $("#manualObject"),

        harrowPortrait: $("#harrowPortrait"),
        harrowProfileCard: $("#harrowProfileCard"),
        harrowWordmark: $("#harrowWordmark"),
        selfReview: $("#selfReview"),

        lockedSignal: $("#lockedSignal"),
        classifiedMainObject: $("#classifiedMainObject"),

        exitAfterthought: $("#exitAfterthought"),

        reader: $("#hellboxReader"),
        readerTitle: $("#readerTitle"),
        readerPageNumber: $("#readerPageNumber"),
        readerPageCount: $("#readerPageCount"),
        readerSessionStatus: $("#readerSessionStatus"),
        readerPaged: $("#readerPaged"),
        readerPageImage: $("#readerPageImage"),
        readerPrevious: $("#readerPrevious"),
        readerNext: $("#readerNext"),
        readerPreviousBottom: $("#readerPreviousBottom"),
        readerNextBottom: $("#readerNextBottom"),
        readerFirst: $("#readerFirst"),
        readerLast: $("#readerLast"),
        readerBottomLabel: $("#readerBottomLabel"),
        readerContinuous: $("#readerContinuous"),
        readerLayoutToggle: $("#readerLayoutToggle"),
        readerFitPage: $("#readerFitPage"),
        readerFitWidth: $("#readerFitWidth"),
        readerClose: $("#readerClose"),
        readerLoading: $("#readerLoading"),
        readerLoadingText: $("#readerLoadingText"),
        readerError: $("#readerError"),
        readerErrorText: $("#readerErrorText"),
        readerErrorClose: $("#readerErrorClose")
    };


    /* =========================================================
       HARROW VOICE
       ========================================================= */

    const HERO_THOUGHTS = [
        {
            title: "I HAVE EXCELLENT JUDGMENT.",
            sub: "Everyone eventually says something embarrassing."
        },
        {
            title: "DO NOT TAKE FINANCIAL ADVICE FROM ME.",
            sub: "Take aesthetic advice exclusively."
        },
        {
            title: "I HAD AN IDEA.",
            sub: "Historically, this is where the trouble starts."
        },
        {
            title: "WAIT. THAT'S ACTUALLY FUNNY.",
            sub: "Write that down before I improve it."
        },
        {
            title: "THE CHAIN REMEMBERS.",
            sub: "Unfortunately, so do screenshots."
        },
        {
            title: "I'M BUSY BEING RIGHT.",
            sub: "It's basically a full-time position."
        },
        {
            title: "SOMEBODY PUT ADULTS IN CHARGE.",
            sub: "Terrible design decision."
        },
        {
            title: "I DON'T NEED A ROADMAP.",
            sub: "I know exactly where I'm going. Mostly."
        },
        {
            title: "THIS IS FINE.",
            sub: "The definition of fine remains under review."
        }
    ];

    const ORB_LINES = [
        [
            "YES?",
            "I was in the middle of admiring my own work."
        ],
        [
            "WHAT?",
            "You keep clicking me like this is going to improve your judgment."
        ],
        [
            "STILL HERE?",
            "Interesting. Questionable. But interesting."
        ],
        [
            "GOOD.",
            "You noticed the thing I absolutely did not put there for you to notice."
        ],
        [
            "DON'T WORRY.",
            "Everything is under control by the broadest possible definition."
        ],
        [
            "HARROW.",
            "Yes. Still me."
        ]
    ];

    const PRESS_TOUCH_LINES = [
        [
            "I SAID DON'T TOUCH IT.",
            "That's usually interpreted as an invitation around here."
        ],
        [
            "OH GOOD.",
            "You touched the expensive machine."
        ],
        [
            "IT LIKES YOU.",
            "I don't. Yet."
        ],
        [
            "NOW YOU'VE WOKEN IT UP.",
            "Congratulations on your first measurable contribution."
        ],
        [
            "YOU'RE VERY HANDSY.",
            "Fine. Look at the lights."
        ]
    ];


    /* =========================================================
       HARROW WHISPERS
       ========================================================= */

    function whisper(message, duration = 2500) {
        if (!dom.whisper || !dom.whisperText) {
            return;
        }

        window.clearTimeout(state.whisperTimer);

        dom.whisperText.textContent = message;

        dom.whisper.classList.add("active");
        dom.whisper.setAttribute("aria-hidden", "false");

        state.whisperTimer = window.setTimeout(() => {
            dom.whisper.classList.remove("active");
            dom.whisper.setAttribute("aria-hidden", "true");
        }, duration);
    }


    /* =========================================================
       HARROW RESPONSE PANEL
       ========================================================= */

    function showHarrowResponse(title, text, duration = 5200) {
        if (
            !dom.harrowResponse ||
            !dom.harrowResponseTitle ||
            !dom.harrowResponseText
        ) {
            return;
        }

        window.clearTimeout(state.responseTimer);

        dom.harrowResponseTitle.textContent = title;
        dom.harrowResponseText.textContent = text;

        dom.harrowResponse.classList.add("active");
        dom.harrowResponse.setAttribute("aria-hidden", "false");

        state.responseTimer = window.setTimeout(() => {
            closeHarrowResponse();
        }, duration);
    }

    function closeHarrowResponse() {
        if (!dom.harrowResponse) {
            return;
        }

        dom.harrowResponse.classList.remove("active");
        dom.harrowResponse.setAttribute("aria-hidden", "true");
    }


    /* =========================================================
       DISCOVERY SYSTEM
       ========================================================= */

    function loadDiscoveries() {
        try {
            const raw = window.sessionStorage.getItem(
                STORAGE_KEYS.discoveries
            );

            if (!raw) {
                return;
            }

            const parsed = JSON.parse(raw);

            if (!Array.isArray(parsed)) {
                return;
            }

            state.discoveries = new Set(parsed);
        } catch (error) {
            state.discoveries = new Set();
        }

        renderDiscoveryCounter();
    }

    function saveDiscoveries() {
        try {
            window.sessionStorage.setItem(
                STORAGE_KEYS.discoveries,
                JSON.stringify(
                    Array.from(state.discoveries)
                )
            );
        } catch (error) {
            // Session persistence is decorative.
        }
    }

    function discover(key, message = null) {
        if (!key) {
            return false;
        }

        const alreadyFound = state.discoveries.has(key);

        state.discoveries.add(key);

        saveDiscoveries();
        renderDiscoveryCounter();

        if (!alreadyFound && message) {
            whisper(message, 3000);
        }

        return !alreadyFound;
    }

    function renderDiscoveryCounter() {
        if (!dom.discoveryCount) {
            return;
        }

        const count = state.discoveries.size;

        dom.discoveryCount.textContent = String(count).padStart(2, "0");

        document.body.classList.toggle(
            "has-discoveries",
            count > 0
        );
    }


    /* =========================================================
       VISIT MEMORY
       ========================================================= */

    function registerVisit() {
        try {
            const current = safeNumber(
                window.localStorage.getItem(
                    STORAGE_KEYS.visits
                ),
                0
            );

            const next = current + 1;

            window.localStorage.setItem(
                STORAGE_KEYS.visits,
                String(next)
            );

            if (next === 1) {
                dom.exitAfterthought.textContent =
                    "you'll be back.";
            } else if (next < 5) {
                dom.exitAfterthought.textContent =
                    "See? Back already.";
            } else {
                dom.exitAfterthought.textContent =
                    "At this point you live here.";
            }
        } catch (error) {
            // Nothing important relies on this.
        }
    }


    /* =========================================================
       CURSOR ATMOSPHERE
       ========================================================= */

    function initCursorBurn() {
        if (!dom.cursorBurn) {
            return;
        }

        document.addEventListener(
            "pointermove",
            (event) => {
                document.documentElement.style.setProperty(
                    "--cursor-x",
                    `${event.clientX}px`
                );

                document.documentElement.style.setProperty(
                    "--cursor-y",
                    `${event.clientY}px`
                );
            },
            {
                passive: true
            }
        );
    }


    /* =========================================================
       HERO TRANSMISSION
       ========================================================= */

    function rotateHeroTransmission() {
        if (
            !dom.heroTransmission ||
            !dom.heroTransmissionSub
        ) {
            return;
        }

        const thought = randomItem(HERO_THOUGHTS);

        dom.heroTransmission.textContent = thought.title;
        dom.heroTransmissionSub.textContent = thought.sub;
    }

    function initHeroTransmission() {
        rotateHeroTransmission();

        window.setInterval(() => {
            rotateHeroTransmission();
        }, 11000);
    }


    /* =========================================================
       DRAWER
       ========================================================= */

    function openDrawer({
        code = "OBJECT // UNKNOWN",
        eyebrow = "HARROW // NOTE",
        title = "DON'T TOUCH THAT.",
        html = "",
        footnote = ""
    }) {
        if (!dom.drawer) {
            return;
        }

        dom.drawerCode.textContent = code;
        dom.drawerEyebrow.textContent = eyebrow;
        dom.drawerTitle.textContent = title;
        dom.drawerCopy.innerHTML = html;
        dom.drawerFootnote.innerHTML = footnote;

        dom.drawer.classList.add("active");
        dom.drawer.setAttribute("aria-hidden", "false");

        document.body.classList.add("drawer-open");
    }

    function closeDrawer() {
        if (!dom.drawer) {
            return;
        }

        dom.drawer.classList.remove("active");
        dom.drawer.setAttribute("aria-hidden", "true");

        document.body.classList.remove("drawer-open");
    }


    /* =========================================================
       HERO HOTSPOTS
       ========================================================= */

    const HOTSPOT_CONTENT = {
        cabal: {
            code: "WALL // THREAD 0047",
            eyebrow: "HARROW // THEORY",
            title: "THE CABAL.",
            html: `
                <p>
                    First rule of investigative journalism:
                    decide what happened and then buy enough red string
                    to make it look researched.
                </p>

                <p>
                    The board changes constantly.
                    Mostly because I keep remembering people.
                </p>
            `,
            footnote:
                "STATUS // DEFINITELY A THEORY. DO NOT RUIN IT WITH FACT CHECKING."
        },

        monitor: {
            code: "TERMINAL // 369",
            eyebrow: "HARROW // CHAIN",
            title: "PULSECHAIN.",
            html: `
                <p>
                    Cheap enough to make bad ideas economically viable.
                </p>

                <p>
                    Fast enough that I can make another one
                    before anyone talks me out of the first.
                </p>
            `,
            footnote:
                "CHAIN // 369 // CODE IS SPEECH."
        },

        harrow: {
            code: "SUBJECT // OBVIOUS",
            eyebrow: "HARROW // HARROW",
            title: "YES. ME.",
            html: `
                <p>
                    You've found the most important object in the room.
                </p>

                <p>
                    I placed myself here for scale.
                </p>
            `,
            footnote:
                "INDEPENDENT ASSESSMENT // HARROW REMAINS VERY IMPRESSED."
        },

        pages: {
            code: "DESK // IN PROGRESS",
            eyebrow: "HARROW // PANELS",
            title: "THAT'S THE POINT.",
            html: `
                <p>
                    Every bad idea eventually becomes a panel.
                </p>

                <p>
                    Then enough panels become a comic.
                    Then somebody mints it.
                    Then suddenly everyone pretends the whole process
                    was deliberate.
                </p>
            `,
            footnote:
                "WORKFLOW // THINK → DRAW → REGRET → PUBLISH."
        },

        redacted: {
            code: "FOLDER // REDACTED",
            eyebrow: "HARROW // NONE OF YOUR BUSINESS",
            title: "PUT THAT BACK.",
            html: `
                <p>
                    If it were ready for you,
                    it would not be under a folder labeled REDACTED.
                </p>

                <p>
                    Good instincts though.
                </p>
            `,
            footnote:
                "██ ███████ // NOT YET."
        }
    };

    function initHotspots() {
        $$(".lair-hotspot").forEach((button) => {
            button.addEventListener("click", () => {
                const key = button.dataset.hotspot;
                const content = HOTSPOT_CONTENT[key];

                if (!content) {
                    return;
                }

                discover(
                    `hero:${key}`,
                    "There you go. You found one."
                );

                openDrawer(content);
            });
        });
    }


    /* =========================================================
       THEORY WALL
       ========================================================= */

    const THEORY_CONTENT = {
        richard: {
            code: "THEORY // RH-369",
            eyebrow: "HARROW // CURRENTLY THINKING",
            title: "RICHARD.",
            html: `
                <p>
                    Build a chain.
                    Make everybody argue about it.
                    Disappear into the most expensive game
                    of Where's Waldo ever attempted.
                </p>

                <p>
                    Incredible narrative discipline.
                </p>
            `,
            footnote:
                "SATIRE // PUBLIC EVENTS REARRANGED FOR COMEDIC DAMAGE."
        },

        sec: {
            code: "THEORY // GOV-004",
            eyebrow: "HARROW // REGULATORY FAN CLUB",
            title: "VERY SERIOUS PEOPLE.",
            html: `
                <p>
                    I respect institutions deeply.
                </p>

                <p>
                    That's why I draw them with such flattering proportions.
                </p>
            `,
            footnote:
                "THIS IS SATIRE. RELAX."
        },

        cabal: {
            code: "THEORY // █████",
            eyebrow: "HARROW // DIAGRAM INCOMPLETE",
            title: "THE CABAL.",
            html: `
                <p>
                    Membership remains fluid.
                </p>

                <p>
                    Current qualification appears to be:
                    somebody Harrow dislikes,
                    somebody Harrow distrusts,
                    or somebody who used the phrase
                    “industry best practices.”
                </p>
            `,
            footnote:
                "THE CABAL, AS DEPICTED HERE, IS A FICTIONAL SATIRICAL DEVICE."
        },

        interpol: {
            code: "THEORY // INT-???",
            eyebrow: "HARROW // PLEASE RELAX",
            title: "INTERPOL.",
            html: `
                <p>
                    No.
                </p>

                <p>
                    I am not elaborating.
                </p>

                <p>
                    I draw comic books.
                </p>
            `,
            footnote:
                "MOSTLY."
        },

        you: {
            code: "THEORY // YOU",
            eyebrow: "HARROW // OBSERVATION",
            title: "YOU'RE STILL HERE.",
            html: `
                <p>
                    You could have closed the tab.
                </p>

                <p>
                    Instead you started clicking the red string.
                </p>

                <p>
                    Excellent instincts.
                </p>
            `,
            footnote:
                "DIAGNOSIS // CURIOUS ENOUGH TO BE A PROBLEM."
        },

        harrow: {
            code: "THEORY // HARROW",
            eyebrow: "HARROW // PRIMARY SOURCE",
            title: "FINALLY. ME.",
            html: `
                <p>
                    Reliable.
                    Objective.
                    Beautifully formatted.
                </p>

                <p>
                    I see no reason to seek a second source.
                </p>
            `,
            footnote:
                "PEER REVIEWED BY // HARROW."
        }
    };

    function initTheoryWall() {
        $$(".case-file[data-theory]").forEach((button) => {
            button.addEventListener("click", () => {
                const key = button.dataset.theory;
                const content = THEORY_CONTENT[key];

                if (!content) {
                    return;
                }

                discover(
                    `theory:${key}`,
                    "See? Everything touches everything."
                );

                openDrawer(content);
            });
        });

        if (dom.theoryCenter) {
            dom.theoryCenter.addEventListener(
                "click",
                () => {
                    discover(
                        "theory:center",
                        "Wait. I had a point."
                    );

                    if (dom.theorySingular) {
                        dom.theorySingular.classList.add(
                            "crossed-out"
                        );
                    }

                    if (dom.theoryCorrection) {
                        dom.theoryCorrection.classList.add(
                            "active"
                        );
                    }

                    showHarrowResponse(
                        "FORTY-SEVEN.",
                        "A theory sounded dishonest."
                    );
                }
            );
        }
    }


    /* =========================================================
       GENERAL HARROW INTERACTIONS
       ========================================================= */

    function initHarrowInteractions() {
        if (dom.harrowOrb) {
            dom.harrowOrb.addEventListener(
                "click",
                () => {
                    const [title, text] =
                        randomItem(ORB_LINES);

                    discover("harrow:orb");

                    showHarrowResponse(
                        title,
                        text
                    );
                }
            );
        }

        if (dom.harrowResponseClose) {
            dom.harrowResponseClose.addEventListener(
                "click",
                closeHarrowResponse
            );
        }

        if (dom.heroLogoButton) {
            let clicks = 0;

            dom.heroLogoButton.addEventListener(
                "click",
                async () => {
                    clicks += 1;

                    discover("logo:hellbox");

                    if (clicks === 1) {
                        whisper(
                            "Yes. I made the logo too."
                        );
                        return;
                    }

                    if (clicks === 2) {
                        whisper(
                            "You can stop touching it."
                        );
                        return;
                    }

                    document.body.classList.add(
                        "logo-disobedience"
                    );

                    showHarrowResponse(
                        "GOOD JOB.",
                        "You broke the website aesthetically."
                    );

                    await sleep(900);

                    document.body.classList.remove(
                        "logo-disobedience"
                    );

                    clicks = 0;
                }
            );
        }

        if (dom.therapyNote) {
            dom.therapyNote.addEventListener(
                "click",
                () => {
                    discover("note:therapy");

                    showHarrowResponse(
                        "MEDICAL OPINION.",
                        "Do not ask where I went to medical school."
                    );
                }
            );
        }

        if (dom.archiveSticky) {
            dom.archiveSticky.addEventListener(
                "click",
                () => {
                    discover("note:archive");

                    showHarrowResponse(
                        "I LEFT YOU A NOTE.",
                        "Do you know how exhausting personalization is?"
                    );
                }
            );
        }

        if (dom.archiveEmblem) {
            dom.archiveEmblem.addEventListener(
                "click",
                () => {
                    discover("archive:emblem");

                    whisper(
                        "The box remembers what belongs to you."
                    );
                }
            );
        }

        if (dom.harrowPortrait) {
            dom.harrowPortrait.addEventListener(
                "click",
                () => {
                    discover("harrow:portrait");

                    showHarrowResponse(
                        "YES, THAT'S ME.",
                        "I picked the picture. Obviously."
                    );
                }
            );
        }

        if (dom.harrowProfileCard) {
            dom.harrowProfileCard.addEventListener(
                "click",
                () => {
                    discover("harrow:profile");

                    showHarrowResponse(
                        "SELF APPOINTED.",
                        "Waiting for recognition is terribly inefficient."
                    );
                }
            );
        }

        if (dom.harrowWordmark) {
            dom.harrowWordmark.addEventListener(
                "click",
                () => {
                    discover("harrow:wordmark");

                    whisper(
                        "Autographs usually cost more."
                    );
                }
            );
        }

        if (dom.selfReview) {
            dom.selfReview.addEventListener(
                "click",
                () => {
                    discover("harrow:review");

                    showHarrowResponse(
                        "UNBIASED.",
                        "Every reviewer agreed with me."
                    );
                }
            );
        }

        if (dom.lockedSignal) {
            dom.lockedSignal.addEventListener(
                "click",
                () => {
                    discover("signal:locked");

                    showHarrowResponse(
                        "NO.",
                        "Not every button exists for your benefit."
                    );
                }
            );
        }
    }


    /* =========================================================
       CLASSIFIED AREA
       ========================================================= */

    const CLASSIFIED_OBJECTS = {
        fuel: {
            code: "SYSTEM // FUEL",
            eyebrow: "HARROW // CLASSIFIED",
            title: "WRONG DRAWER.",
            html: `
                <p>
                    The machine eats something.
                </p>

                <p>
                    You do not currently need to know what.
                </p>
            `,
            footnote:
                "FUEL SOURCE // █████████ // ACCESS DENIED BY HARROW."
        },

        relay: {
            code: "SYSTEM // RELAY",
            eyebrow: "HARROW // SECONDARY PATH",
            title: "NOT CONNECTED.",
            html: `
                <p>
                    Another door exists.
                </p>

                <p>
                    That is the entire amount of information
                    I am giving you.
                </p>
            `,
            footnote:
                "REMOTE RELAY // REDACTED."
        },

        machine: {
            code: "SYSTEM // INPUT",
            eyebrow: "HARROW // HARDWARE",
            title: "NO INPUT.",
            html: `
                <p>
                    The machine is waiting for something
                    that does not exist publicly yet.
                </p>
            `,
            footnote:
                "DO NOT INVENT THE REST. HARROW HASN'T."
        }
    };

    function initClassified() {
        $$("[data-classified-object]").forEach(
            (button) => {
                button.addEventListener(
                    "click",
                    () => {
                        const key =
                            button.dataset.classifiedObject;

                        const content =
                            CLASSIFIED_OBJECTS[key];

                        if (!content) {
                            return;
                        }

                        discover(
                            `classified:${key}`,
                            "You really don't listen."
                        );

                        openDrawer(content);
                    }
                );
            }
        );

        if (dom.classifiedMainObject) {
            let taps = 0;

            dom.classifiedMainObject.addEventListener(
                "click",
                () => {
                    taps += 1;

                    discover("classified:main");

                    if (taps === 1) {
                        whisper("No.");
                    } else if (taps === 2) {
                        whisper("Still no.");
                    } else if (taps === 3) {
                        whisper(
                            "Persistence is not clearance."
                        );
                    } else {
                        showHarrowResponse(
                            "YOU'RE ANNOYING.",
                            "I respect it."
                        );

                        taps = 0;
                    }
                }
            );
        }
    }


    /* =========================================================
       ROADMAP OBJECT
       ========================================================= */

    function openRoadmapObject() {
        discover(
            "object:roadmap",
            "Fine. Here's the part you're allowed to see."
        );

        openDrawer({
            code: "OBJECT // WHAT NEXT",
            eyebrow: "HARROW // CURRENT OBSESSIONS",
            title: "THE PLAN*",
            html: `
                <p>
                    I hate roadmaps.
                    They make unfinished ideas look like appointments.
                </p>

                <div class="roadmap-object">
                    <div>
                        <span>NOW</span>
                        <strong>BUILD THE BOX.</strong>
                        <p>
                            Publishing system. Archive.
                            Wallet identity. The Press.
                            Reader. Make the place feel alive.
                        </p>
                    </div>

                    <div>
                        <span>NEXT</span>
                        <strong>MAKE THE COMICS HIT HARDER.</strong>
                        <p>
                            The reader becomes part theater,
                            part comic engine,
                            part terrible decision.
                        </p>
                    </div>

                    <div>
                        <span>AFTER THAT</span>
                        <strong>PUT THINGS ONCHAIN.</strong>
                        <p>
                            Native collectible editions.
                            Ownership-gated reading.
                            Supply that means something.
                        </p>
                    </div>

                    <div>
                        <span>LATER</span>
                        <strong>THE PART I'M NOT SHOWING YOU.</strong>
                        <p>
                            No.
                        </p>
                    </div>
                </div>

                <p>
                    *This is not a promise.
                    It's a glimpse at what I was thinking
                    before you interrupted me.
                </p>
            `,
            footnote:
                "ROADMAP STATUS // SUBJECT TO HARROW HAVING ANOTHER IDEA."
        });
    }


    /* =========================================================
       MANUAL / WHITEPAPER OBJECT
       ========================================================= */

    function openManualObject() {
        discover(
            "object:manual",
            "I call it a manual because whitepaper sounds like homework."
        );

        openDrawer({
            code: "OBJECT // MANUAL",
            eyebrow: "HARROW // HOW THE BOX WORKS",
            title: "THE MANUAL.",
            html: `
                <p>
                    Eventually this is where the boring questions
                    get answers without making the rest of the site boring.
                </p>

                <div class="roadmap-object">
                    <div>
                        <span>PUBLICATIONS</span>
                        <strong>THE THING YOU ACTUALLY WANT.</strong>
                        <p>
                            Comics and graphic novels exist as publications
                            inside Hellbox.
                        </p>
                    </div>

                    <div>
                        <span>OWNERSHIP</span>
                        <strong>YOUR WALLET IS THE RECEIPT.</strong>
                        <p>
                            The box can recognize which onchain artifacts
                            belong to an address.
                        </p>
                    </div>

                    <div>
                        <span>THE PRESS</span>
                        <strong>THIS MAKES THEM.</strong>
                        <p>
                            Minting eventually happens here.
                            Not in a generic ecommerce widget
                            wearing a crypto costume.
                        </p>
                    </div>

                    <div>
                        <span>THE READER</span>
                        <strong>THIS IS WHY ANY OF IT MATTERS.</strong>
                        <p>
                            Ownership gets you into the work.
                            The reading experience does the rest.
                        </p>
                    </div>
                </div>

                <p>
                    Token mechanics, economics and deeper system documentation
                    belong in objects like this.
                    They do not get to hijack the front door.
                </p>
            `,
            footnote:
                "DOCUMENT STATUS // STILL BEING WRITTEN BY SOMEONE WHO HATES DOCUMENTATION."
        });
    }


    /* =========================================================
       PRESS MACHINE
       ========================================================= */

    function readStoredPressTouches() {
        try {
            state.press.touchCount = safeNumber(
                window.sessionStorage.getItem(
                    STORAGE_KEYS.pressTouches
                ),
                0
            );
        } catch (error) {
            state.press.touchCount = 0;
        }
    }

    function storePressTouches() {
        try {
            window.sessionStorage.setItem(
                STORAGE_KEYS.pressTouches,
                String(state.press.touchCount)
            );
        } catch (error) {
            // Decorative state only.
        }
    }

    function setPressRail(activeState) {
        $$(".press-state").forEach((item) => {
            item.classList.toggle(
                "active",
                item.dataset.state === activeState
            );
        });
    }

    function setPressState(nextState) {
        state.press.state = nextState;

        if (!dom.pressSection) {
            return;
        }

        dom.pressSection.classList.remove(
            "machine-awake",
            "machine-alert",
            "machine-pulling"
        );

        let miniStatus = "IDLE";
        let machineState = "ASLEEP";
        let consoleLabel = "STATUS";
        let consoleTitle = "DON'T TOUCH IT.";
        let consoleText = "I mean it.";
        let power = "00";
        let ink = "??";

        switch (nextState) {
            case "awake":
                dom.pressSection.classList.add(
                    "machine-awake"
                );

                miniStatus = "AWAKE";
                machineState = "AWAKE";
                consoleLabel = "HARROW // YOU DID THIS";
                consoleTitle = "NOW IT'S AWAKE.";
                consoleText =
                    "Try pretending this wasn't exactly what you wanted.";
                power = "37";
                ink = "??";
                break;

            case "wallet":
                dom.pressSection.classList.add(
                    "machine-awake"
                );

                miniStatus = "IDENTIFY";
                machineState = "WAITING";
                consoleLabel = "IDENTIFICATION";
                consoleTitle = "SHOW ME THE WALLET.";
                consoleText =
                    "I can't make something yours if you refuse to tell me who you are.";
                power = "62";
                ink = "??";
                break;

            case "ready":
                dom.pressSection.classList.add(
                    "machine-awake"
                );

                miniStatus = "READY";
                machineState = "READY";
                consoleLabel = "PRESS // READY";
                consoleTitle = "DON'T GET EXCITED.";
                consoleText =
                    "The machine is ready. The publication isn't.";
                power = "91";
                ink = "OK";
                break;

            case "pressing":
                dom.pressSection.classList.add(
                    "machine-awake",
                    "machine-pulling",
                    "machine-alert"
                );

                miniStatus = "WORKING";
                machineState = "WORKING";
                consoleLabel = "PRESS // ACTIVE";
                consoleTitle = "SEE WHAT YOU DID?";
                consoleText =
                    "Now the machine thinks it has a job.";
                power = "99";
                ink = "RUN";
                break;

            case "confirmed":
                dom.pressSection.classList.add(
                    "machine-awake"
                );

                miniStatus = "YOURS";
                machineState = "DONE";
                consoleLabel = "PRESS // COMPLETE";
                consoleTitle = "THERE. HAPPY?";
                consoleText =
                    "This state is reserved for a real confirmed mint.";
                power = "44";
                ink = "OK";
                break;

            case "error":
                dom.pressSection.classList.add(
                    "machine-awake",
                    "machine-alert"
                );

                miniStatus = "NO";
                machineState = "NO";
                consoleLabel = "HARROW // NO";
                consoleTitle = "THERE'S NOTHING TO MINT.";
                consoleText =
                    "I'm building it. Stop standing over my shoulder.";
                power = "13";
                ink = "--";
                break;

            case "idle":
            default:
                miniStatus = "IDLE";
                machineState = "ASLEEP";
                consoleLabel = "STATUS";
                consoleTitle = "DON'T TOUCH IT.";
                consoleText = "I mean it.";
                power = "00";
                ink = "??";
                break;
        }

        if (dom.pressMiniStatus) {
            dom.pressMiniStatus.textContent = miniStatus;
        }

        if (dom.pressMachineState) {
            dom.pressMachineState.textContent = machineState;
        }

        if (dom.pressConsoleLabel) {
            dom.pressConsoleLabel.textContent = consoleLabel;
        }

        if (dom.pressConsoleTitle) {
            dom.pressConsoleTitle.textContent = consoleTitle;
        }

        if (dom.pressConsoleText) {
            dom.pressConsoleText.textContent = consoleText;
        }

        if (dom.pressPowerValue) {
            dom.pressPowerValue.textContent = power;
        }

        if (dom.pressInkValue) {
            dom.pressInkValue.textContent = ink;
        }

        if (dom.pressRpcValue) {
            dom.pressRpcValue.textContent = "369";
        }

        setPressRail(
            nextState === "awake"
                ? "idle"
                : nextState
        );
    }

    function wakePress() {
        if (state.press.awake) {
            state.press.touchCount += 1;

            storePressTouches();

            const [title, text] =
                PRESS_TOUCH_LINES[
                    state.press.touchCount %
                    PRESS_TOUCH_LINES.length
                ];

            showHarrowResponse(title, text);

            return;
        }

        state.press.awake = true;
        state.press.touchCount += 1;

        storePressTouches();

        setPressState("awake");

        discover(
            "press:wake",
            "You woke it up."
        );

        showHarrowResponse(
            "OH GOOD.",
            "You touched the expensive machine."
        );
    }

    async function pullPressLever() {
        if (state.press.busy) {
            showHarrowResponse(
                "WAIT.",
                "You pull elevator buttons twice too, don't you?"
            );

            return;
        }

        state.press.busy = true;

        if (!state.press.awake) {
            wakePress();

            await sleep(650);
        }

        if (!state.wallet.connected) {
            setPressState("wallet");

            showHarrowResponse(
                "SHOW ME THE WALLET.",
                "The machine needs an address before it can eventually make bad decisions in your name."
            );

            state.press.busy = false;

            return;
        }

        setPressState("ready");

        await sleep(500);

        setPressState("pressing");

        whisper(
            "This would be the dramatic part."
        );

        await sleep(1300);

        /*
         * IMPORTANT:
         *
         * There is deliberately NO fake transaction here.
         *
         * When a publication has a deployed contract and the backend
         * can prepare a verified transaction, this is where the real
         * mint flow will connect.
         *
         * Until then, the machine tells the truth.
         */

        setPressState("error");

        showHarrowResponse(
            "NOTHING FOR YOU YET.",
            "There is no public release loaded into the Press. I refuse to fake one just because the lever is satisfying."
        );

        await sleep(2200);

        if (state.wallet.connected) {
            setPressState("ready");
        } else {
            setPressState("wallet");
        }

        state.press.busy = false;
    }

    function updatePressFromWallet() {
        if (dom.pressWallet) {
            dom.pressWallet.textContent =
                state.wallet.connected
                    ? truncateAddress(
                        state.wallet.address
                    )
                    : "NOT SHOWN";
        }

        if (!state.press.awake) {
            return;
        }

        if (state.wallet.connected) {
            setPressState("ready");
        } else {
            setPressState("wallet");
        }
    }

    function updatePressPublication() {
        const publicPublication =
            state.publications[0] || null;

        if (!dom.pressPublication || !dom.pressSupply) {
            return;
        }

        if (!publicPublication) {
            dom.pressPublication.textContent = "NONE";
            dom.pressSupply.textContent = "-- / --";
            return;
        }

        dom.pressPublication.textContent =
            safeText(
                publicPublication.title,
                safeText(
                    publicPublication.publicationKey,
                    "UNKNOWN"
                )
            );

        const minted =
            publicPublication.minted ??
            publicPublication.mintedSupply ??
            null;

        const maxSupply =
            publicPublication.maxSupply ??
            publicPublication.supply ??
            null;

        if (
            minted !== null &&
            maxSupply !== null
        ) {
            dom.pressSupply.textContent =
                `${minted} / ${maxSupply}`;
        } else if (maxSupply !== null) {
            dom.pressSupply.textContent =
                `-- / ${maxSupply}`;
        } else {
            dom.pressSupply.textContent =
                "-- / --";
        }
    }

    function initPress() {
        readStoredPressTouches();

        setPressState("idle");

        if (dom.pressMachine) {
            dom.pressMachine.addEventListener(
                "click",
                wakePress
            );
        }

        if (dom.pressLever) {
            dom.pressLever.addEventListener(
                "click",
                pullPressLever
            );
        }

        if (dom.roadmapObject) {
            dom.roadmapObject.addEventListener(
                "click",
                openRoadmapObject
            );
        }

        if (dom.manualObject) {
            dom.manualObject.addEventListener(
                "click",
                openManualObject
            );
        }
    }


    /* =========================================================
       WALLET
       ========================================================= */

    function getEthereumProvider() {
        if (
            typeof window.ethereum !== "undefined"
        ) {
            return window.ethereum;
        }

        return null;
    }

    async function readWalletState() {
        const provider = getEthereumProvider();

        state.wallet.provider = provider;

        if (!provider) {
            renderWalletState();
            return;
        }

        try {
            const accounts = await provider.request({
                method: "eth_accounts"
            });

            const chainId = await provider.request({
                method: "eth_chainId"
            });

            if (
                Array.isArray(accounts) &&
                accounts.length > 0
            ) {
                state.wallet.address =
                    accounts[0];

                state.wallet.connected = true;
            } else {
                state.wallet.address = null;
                state.wallet.connected = false;
            }

            state.wallet.chainId =
                normalizeChainId(chainId);
        } catch (error) {
            state.wallet.address = null;
            state.wallet.chainId = null;
            state.wallet.connected = false;
        }

        renderWalletState();
    }

    async function connectWallet() {
        const provider = getEthereumProvider();

        if (!provider) {
            showHarrowResponse(
                "NO WALLET.",
                "Install an EVM wallet first. I'm talented, not supernatural."
            );

            return;
        }

        try {
            if (dom.walletButton) {
                dom.walletButton.disabled = true;
                dom.walletButton.textContent =
                    "LOOKING...";
            }

            const accounts =
                await provider.request({
                    method: "eth_requestAccounts"
                });

            if (
                !Array.isArray(accounts) ||
                accounts.length === 0
            ) {
                throw new Error(
                    "No account returned"
                );
            }

            const chainId =
                await provider.request({
                    method: "eth_chainId"
                });

            state.wallet.provider = provider;
            state.wallet.address = accounts[0];
            state.wallet.chainId =
                normalizeChainId(chainId);

            state.wallet.connected = true;

            renderWalletState();

            discover(
                "wallet:connected",
                "There you are."
            );

            if (
                state.wallet.chainId !==
                PULSECHAIN.chainId
            ) {
                showHarrowResponse(
                    "WRONG CHAIN.",
                    "I can see you. You're just standing in the wrong neighborhood."
                );
            } else {
                showHarrowResponse(
                    "THERE YOU ARE.",
                    "Public blockchain. Very private moment."
                );
            }

            await loadPublications();

        } catch (error) {
            showHarrowResponse(
                "NEVER MIND.",
                "You either rejected it or your wallet decided today was its day to become art."
            );
        } finally {
            if (dom.walletButton) {
                dom.walletButton.disabled = false;
            }

            renderWalletState();
        }
    }

    function renderWalletState() {
        const connected =
            state.wallet.connected &&
            Boolean(state.wallet.address);

        const onPulseChain =
            state.wallet.chainId ===
            PULSECHAIN.chainId;

        if (dom.walletButton) {
            dom.walletButton.textContent =
                connected
                    ? truncateAddress(
                        state.wallet.address
                    )
                    : "SHOW HARROW";
        }

        if (dom.collectionWallet) {
            dom.collectionWallet.textContent =
                connected
                    ? truncateAddress(
                        state.wallet.address
                    )
                    : "NOT SHOWN";
        }

        if (dom.collectionNetwork) {
            if (!connected) {
                dom.collectionNetwork.textContent =
                    "PULSECHAIN // 369";
            } else if (onPulseChain) {
                dom.collectionNetwork.textContent =
                    "PULSECHAIN // 369";
            } else {
                dom.collectionNetwork.textContent =
                    `CHAIN // ${
                        state.wallet.chainId ??
                        "UNKNOWN"
                    }`;
            }
        }

        if (dom.collectionAccessState) {
            dom.collectionAccessState.textContent =
                connected
                    ? (
                        onPulseChain
                            ? "SEEN"
                            : "WRONG CHAIN"
                    )
                    : "WAITING";
        }

        if (dom.terminalAction) {
            dom.terminalAction.textContent =
                connected
                    ? "LOOK AGAIN"
                    : "SHOW HARROW";
        }

        if (!connected) {
            if (dom.terminalTitle) {
                dom.terminalTitle.textContent =
                    "DON'T BE SHY.";
            }

            if (dom.terminalMessage) {
                dom.terminalMessage.textContent =
                    "Show me the wallet.";
            }

            if (dom.archiveHarrowNote) {
                dom.archiveHarrowNote.textContent =
                    "let's see the damage.";
            }
        }

        updatePressFromWallet();
    }

    function initWalletEvents() {
        if (dom.walletButton) {
            dom.walletButton.addEventListener(
                "click",
                connectWallet
            );
        }

        if (dom.terminalAction) {
            dom.terminalAction.addEventListener(
                "click",
                async () => {
                    if (!state.wallet.connected) {
                        await connectWallet();
                        return;
                    }

                    await loadPublications();

                    showHarrowResponse(
                        "I LOOKED AGAIN.",
                        "The chain did not become more interesting because you refreshed it."
                    );
                }
            );
        }

        const provider = getEthereumProvider();

        if (
            provider &&
            typeof provider.on === "function"
        ) {
            provider.on(
                "accountsChanged",
                async (accounts) => {
                    if (
                        !Array.isArray(accounts) ||
                        accounts.length === 0
                    ) {
                        state.wallet.address = null;
                        state.wallet.connected = false;

                        renderWalletState();
                        renderCollection();
                        return;
                    }

                    state.wallet.address =
                        accounts[0];

                    state.wallet.connected = true;

                    renderWalletState();

                    await loadPublications();
                }
            );

            provider.on(
                "chainChanged",
                async (chainId) => {
                    state.wallet.chainId =
                        normalizeChainId(chainId);

                    renderWalletState();

                    await loadPublications();
                }
            );
        }
    }


    /* =========================================================
       PUBLICATIONS API
       ========================================================= */

    async function apiJson(
        url,
        options = {}
    ) {
        const response = await fetch(
            url,
            {
                ...options,
                headers: {
                    Accept: "application/json",
                    ...(options.headers || {})
                }
            }
        );

        let body = null;

        try {
            body = await response.json();
        } catch (error) {
            body = null;
        }

        if (!response.ok) {
            const message =
                body?.error ||
                body?.message ||
                `Request failed: ${response.status}`;

            const apiError = new Error(message);

            apiError.status = response.status;
            apiError.body = body;

            throw apiError;
        }

        return body;
    }

    function normalizePublicationList(payload) {
        if (Array.isArray(payload)) {
            return payload;
        }

        if (Array.isArray(payload?.publications)) {
            return payload.publications;
        }

        if (Array.isArray(payload?.items)) {
            return payload.items;
        }

        if (Array.isArray(payload?.comics)) {
            return payload.comics;
        }

        return [];
    }

    async function loadPublications() {
        if (dom.publicationCount) {
            dom.publicationCount.textContent =
                "CHECKING";
        }

        if (dom.collectionStatus) {
            dom.collectionStatus.textContent =
                "LOOKING AT THE PUBLIC LEDGER...";
        }

        try {
            const payload =
                await apiJson(
                    "/api/publications"
                );

            state.publications =
                normalizePublicationList(
                    payload
                );

            renderCollection();
            updatePressPublication();

        } catch (error) {
            state.publications = [];

            renderCollection({
                error: true
            });

            updatePressPublication();

            if (dom.publicationCount) {
                dom.publicationCount.textContent =
                    "ARCHIVE UNAVAILABLE";
            }

            if (dom.collectionStatus) {
                dom.collectionStatus.textContent =
                    "THE ARCHIVE INDEX DID NOT ANSWER.";
            }
        }
    }


    /* =========================================================
       COLLECTION RENDERING
       ========================================================= */

    function publicationIdentity(publication) {
        return (
            publication.publicationKey ||
            publication.key ||
            publication.slug ||
            publication.id ||
            "unknown"
        );
    }

    function publicationTitle(publication) {
        return (
            publication.title ||
            publication.name ||
            publicationIdentity(publication)
        );
    }

    function publicationLifecycle(publication) {
        return (
            publication.lifecycle ||
            publication.status ||
            "circulating"
        );
    }

    function publicationReaderEnabled(publication) {
        if (
            publication.reader === true ||
            publication.readerEnabled === true
        ) {
            return true;
        }

        if (
            publication.reader &&
            typeof publication.reader === "object"
        ) {
            return publication.reader.enabled !== false;
        }

        return false;
    }

    function calculateCollectionSummary() {
        const known =
            state.publications.length;

        /*
         * We do NOT pretend to know wallet ownership merely because
         * a wallet is connected.
         *
         * Ownership must eventually come from verified backend /
         * contract state.
         */
        const owned = 0;
        const evolved = 0;

        const missing =
            state.wallet.connected
                ? known
                : 0;

        state.collection = {
            known,
            owned,
            missing,
            evolved
        };
    }

    function renderCollection(options = {}) {
        calculateCollectionSummary();

        const {
            error = false
        } = options;

        if (dom.summaryKnown) {
            dom.summaryKnown.textContent =
                String(
                    state.collection.known
                ).padStart(2, "0");
        }

        if (dom.summaryOwned) {
            dom.summaryOwned.textContent =
                String(
                    state.collection.owned
                ).padStart(2, "0");
        }

        if (dom.summaryMissing) {
            dom.summaryMissing.textContent =
                String(
                    state.collection.missing
                ).padStart(2, "0");
        }

        if (dom.summaryEvolved) {
            dom.summaryEvolved.textContent =
                String(
                    state.collection.evolved
                ).padStart(2, "0");
        }

        if (dom.publicationCount) {
            if (error) {
                dom.publicationCount.textContent =
                    "ARCHIVE UNAVAILABLE";
            } else if (
                state.publications.length === 0
            ) {
                dom.publicationCount.textContent =
                    "NOTHING PUBLIC YET";
            } else {
                dom.publicationCount.textContent =
                    `${state.publications.length} PUBLIC`;
            }
        }

        if (!dom.collectionList) {
            return;
        }

        dom.collectionList.innerHTML = "";

        if (error) {
            if (dom.terminalTitle) {
                dom.terminalTitle.textContent =
                    "THE ARCHIVE ISN'T ANSWERING.";
            }

            if (dom.terminalMessage) {
                dom.terminalMessage.textContent =
                    "This is a technical problem, not mysterious lore.";
            }

            if (dom.archiveHarrowNote) {
                dom.archiveHarrowNote.textContent =
                    "fine. i'll fix it.";
            }

            return;
        }

        if (
            state.publications.length === 0
        ) {
            if (dom.terminalTitle) {
                dom.terminalTitle.textContent =
                    state.wallet.connected
                        ? "NOTHING?"
                        : "DON'T BE SHY.";
            }

            if (dom.terminalMessage) {
                dom.terminalMessage.textContent =
                    state.wallet.connected
                        ? "Huh. That's actually impressive."
                        : "Show me the wallet.";
            }

            if (dom.archiveHarrowNote) {
                dom.archiveHarrowNote.textContent =
                    state.wallet.connected
                        ? "we'll fix this."
                        : "let's see the damage.";
            }

            if (dom.collectionStatus) {
                dom.collectionStatus.textContent =
                    state.wallet.connected
                        ? "NOTHING PUBLIC TO BRING HOME YET."
                        : "SHOW ME SOMETHING INTERESTING.";
            }

            return;
        }

        if (dom.terminalTitle) {
            dom.terminalTitle.textContent =
                state.wallet.connected
                    ? "THERE'S SOMETHING HERE."
                    : "THE BOX HAS THINGS.";
        }

        if (dom.terminalMessage) {
            dom.terminalMessage.textContent =
                state.wallet.connected
                    ? "Ownership verification comes next."
                    : "Connect a wallet and I'll tell you which ones followed you home.";
        }

        state.publications.forEach(
            (publication, index) => {
                const key =
                    publicationIdentity(
                        publication
                    );

                const title =
                    publicationTitle(
                        publication
                    );

                const lifecycle =
                    publicationLifecycle(
                        publication
                    );

                const readerEnabled =
                    publicationReaderEnabled(
                        publication
                    );

                const item =
                    document.createElement("div");

                item.className =
                    "collection-item";

                item.innerHTML = `
                    <span class="collection-item-index">
                        ${String(index + 1).padStart(2, "0")}
                    </span>

                    <div class="collection-item-main">
                        <span class="collection-item-type">
                            PUBLICATION // ${escapeHtml(lifecycle)}
                        </span>

                        <strong>
                            ${escapeHtml(title)}
                        </strong>

                        <small>
                            ${escapeHtml(key)}
                        </small>
                    </div>

                    <div class="collection-item-state">
                        <span>WALLET</span>
                        <strong>
                            ${
                                state.wallet.connected
                                    ? "UNVERIFIED"
                                    : "NOT SHOWN"
                            }
                        </strong>
                    </div>

                    <button
                        type="button"
                        class="collection-item-action"
                        data-publication-key="${escapeHtml(key)}"
                        ${
                            readerEnabled
                                ? ""
                                : "disabled"
                        }
                    >
                        ${
                            readerEnabled
                                ? "TRY READER"
                                : "NOT READY"
                        }
                    </button>
                `;

                dom.collectionList.appendChild(
                    item
                );
            }
        );

        $$(
            ".collection-item-action[data-publication-key]",
            dom.collectionList
        ).forEach((button) => {
            button.addEventListener(
                "click",
                () => {
                    openPublicationReader(
                        button.dataset.publicationKey
                    );
                }
            );
        });

        if (dom.collectionStatus) {
            dom.collectionStatus.textContent =
                "PUBLIC INDEX LOADED.";
        }
    }


    /* =========================================================
       READER
       ========================================================= */

    function clearReaderObjectUrls() {
        state.reader.objectUrls.forEach(
            (url) => {
                try {
                    URL.revokeObjectURL(url);
                } catch (error) {
                    // Ignore.
                }
            }
        );

        state.reader.objectUrls = [];
    }

    function showReaderLoading(
        message = "The machine is doing something expensive."
    ) {
        if (!dom.readerLoading) {
            return;
        }

        dom.readerLoading.classList.add(
            "active"
        );

        if (dom.readerLoadingText) {
            dom.readerLoadingText.textContent =
                message;
        }
    }

    function hideReaderLoading() {
        if (!dom.readerLoading) {
            return;
        }

        dom.readerLoading.classList.remove(
            "active"
        );
    }

    function showReaderError(message) {
        hideReaderLoading();

        if (!dom.readerError) {
            return;
        }

        if (dom.readerErrorText) {
            dom.readerErrorText.textContent =
                message;
        }

        dom.readerError.classList.add(
            "active"
        );
    }

    function hideReaderError() {
        if (!dom.readerError) {
            return;
        }

        dom.readerError.classList.remove(
            "active"
        );
    }

    function normalizeReaderPages(payload) {
        if (Array.isArray(payload?.pages)) {
            return payload.pages;
        }

        if (
            Array.isArray(
                payload?.reader?.pages
            )
        ) {
            return payload.reader.pages;
        }

        if (
            Array.isArray(
                payload?.manifest?.pages
            )
        ) {
            return payload.manifest.pages;
        }

        return [];
    }

    function pageUrlFromEntry(page) {
        if (typeof page === "string") {
            return page;
        }

        if (!page || typeof page !== "object") {
            return null;
        }

        return (
            page.url ||
            page.src ||
            page.assetUrl ||
            page.asset ||
            null
        );
    }

    async function openPublicationReader(
        publicationKey
    ) {
        if (!publicationKey) {
            return;
        }

        const publication =
            state.publications.find(
                (item) => {
                    return (
                        publicationIdentity(item) ===
                        publicationKey
                    );
                }
            );

        state.reader.publicationKey =
            publicationKey;

        state.reader.title =
            publication
                ? publicationTitle(publication)
                : publicationKey;

        state.reader.pageIndex = 0;
        state.reader.pages = [];

        clearReaderObjectUrls();

        if (dom.readerTitle) {
            dom.readerTitle.textContent =
                state.reader.title;
        }

        if (dom.reader) {
            dom.reader.classList.add("active");
            dom.reader.setAttribute(
                "aria-hidden",
                "false"
            );
        }

        document.body.classList.add(
            "reader-open"
        );

        hideReaderError();

        showReaderLoading(
            "Checking whether the box is going to let you in."
        );

        try {
            const payload =
                await apiJson(
                    `/api/reader/${encodeURIComponent(publicationKey)}`
                );

            const pages =
                normalizeReaderPages(payload)
                    .map(pageUrlFromEntry)
                    .filter(Boolean);

            if (pages.length === 0) {
                throw new Error(
                    "The reader returned no pages."
                );
            }

            state.reader.pages = pages;

            renderReader();
            hideReaderLoading();

            discover(
                `reader:${publicationKey}`,
                "There. Now read it."
            );

        } catch (error) {
            const status =
                error?.status || 0;

            if (
                status === 401 ||
                status === 403
            ) {
                showReaderError(
                    "The box doesn't recognize this wallet as an owner yet."
                );
            } else {
                showReaderError(
                    error?.message ||
                    "The reader refused to cooperate."
                );
            }
        }
    }

    function closeReader() {
        if (!dom.reader) {
            return;
        }

        dom.reader.classList.remove("active");
        dom.reader.setAttribute(
            "aria-hidden",
            "true"
        );

        document.body.classList.remove(
            "reader-open"
        );

        state.reader.open = false;

        clearReaderObjectUrls();
        hideReaderError();
        hideReaderLoading();
    }

    function renderReader() {
        const pageCount =
            state.reader.pages.length;

        if (pageCount === 0) {
            return;
        }

        state.reader.pageIndex =
            clamp(
                state.reader.pageIndex,
                0,
                pageCount - 1
            );

        const humanPage =
            state.reader.pageIndex + 1;

        if (dom.readerPageNumber) {
            dom.readerPageNumber.textContent =
                String(humanPage).padStart(
                    2,
                    "0"
                );
        }

        if (dom.readerPageCount) {
            dom.readerPageCount.textContent =
                String(pageCount).padStart(
                    2,
                    "0"
                );
        }

        if (dom.readerBottomLabel) {
            dom.readerBottomLabel.textContent =
                `${String(humanPage).padStart(
                    2,
                    "0"
                )} / ${String(pageCount).padStart(
                    2,
                    "0"
                )}`;
        }

        if (
            state.reader.mode === "paged"
        ) {
            renderPagedReader();
        } else {
            renderContinuousReader();
        }
    }

    function renderPagedReader() {
        if (
            !dom.readerPageImage ||
            state.reader.pages.length === 0
        ) {
            return;
        }

        const pageUrl =
            state.reader.pages[
                state.reader.pageIndex
            ];

        dom.readerPageImage.src = pageUrl;

        dom.readerPageImage.classList.toggle(
            "fit-page",
            state.reader.fit === "page"
        );

        dom.readerPageImage.classList.toggle(
            "fit-width",
            state.reader.fit === "width"
        );

        if (dom.readerPaged) {
            dom.readerPaged.style.display =
                "flex";
        }

        if (dom.readerContinuous) {
            dom.readerContinuous.classList.remove(
                "active"
            );
        }
    }

    function renderContinuousReader() {
        if (!dom.readerContinuous) {
            return;
        }

        dom.readerContinuous.innerHTML = "";

        state.reader.pages.forEach(
            (url, index) => {
                const wrapper =
                    document.createElement(
                        "div"
                    );

                wrapper.className =
                    "reader-continuous-page";

                const label =
                    document.createElement(
                        "div"
                    );

                label.textContent =
                    `PAGE ${String(
                        index + 1
                    ).padStart(2, "0")}`;

                const image =
                    document.createElement(
                        "img"
                    );

                image.src = url;
                image.alt =
                    `${state.reader.title} page ${
                        index + 1
                    }`;

                wrapper.appendChild(label);
                wrapper.appendChild(image);

                dom.readerContinuous.appendChild(
                    wrapper
                );
            }
        );

        if (dom.readerPaged) {
            dom.readerPaged.style.display =
                "none";
        }

        dom.readerContinuous.classList.add(
            "active"
        );
    }

    function readerPrevious() {
        if (state.reader.pageIndex <= 0) {
            return;
        }

        state.reader.pageIndex -= 1;
        renderReader();
    }

    function readerNext() {
        if (
            state.reader.pageIndex >=
            state.reader.pages.length - 1
        ) {
            return;
        }

        state.reader.pageIndex += 1;
        renderReader();
    }

    function initReaderControls() {
        if (dom.readerPrevious) {
            dom.readerPrevious.addEventListener(
                "click",
                readerPrevious
            );
        }

        if (dom.readerPreviousBottom) {
            dom.readerPreviousBottom.addEventListener(
                "click",
                readerPrevious
            );
        }

        if (dom.readerNext) {
            dom.readerNext.addEventListener(
                "click",
                readerNext
            );
        }

        if (dom.readerNextBottom) {
            dom.readerNextBottom.addEventListener(
                "click",
                readerNext
            );
        }

        if (dom.readerFirst) {
            dom.readerFirst.addEventListener(
                "click",
                () => {
                    state.reader.pageIndex = 0;
                    renderReader();
                }
            );
        }

        if (dom.readerLast) {
            dom.readerLast.addEventListener(
                "click",
                () => {
                    state.reader.pageIndex =
                        Math.max(
                            state.reader.pages.length -
                            1,
                            0
                        );

                    renderReader();
                }
            );
        }

        if (dom.readerFitPage) {
            dom.readerFitPage.addEventListener(
                "click",
                () => {
                    state.reader.fit = "page";
                    renderReader();
                }
            );
        }

        if (dom.readerFitWidth) {
            dom.readerFitWidth.addEventListener(
                "click",
                () => {
                    state.reader.fit = "width";
                    renderReader();
                }
            );
        }

        if (dom.readerLayoutToggle) {
            dom.readerLayoutToggle.addEventListener(
                "click",
                () => {
                    state.reader.mode =
                        state.reader.mode ===
                        "paged"
                            ? "continuous"
                            : "paged";

                    dom.readerLayoutToggle.textContent =
                        state.reader.mode ===
                        "paged"
                            ? "CONTINUOUS"
                            : "PAGED";

                    renderReader();
                }
            );
        }

        if (dom.readerClose) {
            dom.readerClose.addEventListener(
                "click",
                closeReader
            );
        }

        if (dom.readerErrorClose) {
            dom.readerErrorClose.addEventListener(
                "click",
                closeReader
            );
        }

        document.addEventListener(
            "keydown",
            (event) => {
                if (
                    dom.drawer?.classList.contains(
                        "active"
                    )
                ) {
                    if (event.key === "Escape") {
                        closeDrawer();
                    }

                    return;
                }

                if (
                    !dom.reader?.classList.contains(
                        "active"
                    )
                ) {
                    return;
                }

                if (event.key === "Escape") {
                    closeReader();
                    return;
                }

                if (
                    state.reader.mode !== "paged"
                ) {
                    return;
                }

                if (
                    event.key === "ArrowLeft"
                ) {
                    readerPrevious();
                }

                if (
                    event.key === "ArrowRight"
                ) {
                    readerNext();
                }
            }
        );
    }


    /* =========================================================
       DRAWER EVENTS
       ========================================================= */

    function initDrawerEvents() {
        if (dom.drawerClose) {
            dom.drawerClose.addEventListener(
                "click",
                closeDrawer
            );
        }

        if (dom.drawerBackdrop) {
            dom.drawerBackdrop.addEventListener(
                "click",
                closeDrawer
            );
        }
    }


    /* =========================================================
       SCROLL BEHAVIOR
       ========================================================= */

    function initScrollObservers() {
        if (
            !("IntersectionObserver" in window)
        ) {
            return;
        }

        const seenZones = new Set();

        const observer =
            new IntersectionObserver(
                (entries) => {
                    entries.forEach((entry) => {
                        if (
                            !entry.isIntersecting ||
                            entry.intersectionRatio <
                                0.45
                        ) {
                            return;
                        }

                        const zone =
                            entry.target.dataset.zone;

                        if (
                            !zone ||
                            seenZones.has(zone)
                        ) {
                            return;
                        }

                        seenZones.add(zone);

                        switch (zone) {
                            case "box":
                                whisper(
                                    "This is where the problem starts."
                                );
                                break;

                            case "archive":
                                if (
                                    !state.wallet.connected
                                ) {
                                    whisper(
                                        "Show me what you brought."
                                    );
                                }
                                break;

                            case "theory":
                                whisper(
                                    "I can explain all of this. Probably."
                                );
                                break;

                            case "press":
                                whisper(
                                    "Don't touch the machine."
                                );
                                break;

                            case "harrow":
                                whisper(
                                    "Finally. The important section."
                                );
                                break;

                            case "classified":
                                whisper(
                                    "Keep scrolling. It still says no."
                                );
                                break;

                            case "exit":
                                whisper(
                                    "Good. Go do something irresponsible."
                                );
                                break;

                            default:
                                break;
                        }
                    });
                },
                {
                    threshold: [
                        0.45,
                        0.6
                    ]
                }
            );

        $$("[data-zone]").forEach(
            (section) => {
                observer.observe(section);
            }
        );
    }


    /* =========================================================
       INITIALIZE
       ========================================================= */

    async function init() {
        loadDiscoveries();
        registerVisit();

        initCursorBurn();
        initHeroTransmission();

        initDrawerEvents();
        initHotspots();
        initTheoryWall();
        initHarrowInteractions();
        initClassified();

        initPress();
        initWalletEvents();
        initReaderControls();

        initScrollObservers();

        await readWalletState();
        await loadPublications();

        updatePressPublication();

        window.setTimeout(() => {
            whisper(
                "Try not to make this weird."
            );
        }, 1800);
    }


    /* =========================================================
       START
       ========================================================= */

    if (
        document.readyState === "loading"
    ) {
        document.addEventListener(
            "DOMContentLoaded",
            init,
            {
                once: true
            }
        );
    } else {
        init();
    }

})();

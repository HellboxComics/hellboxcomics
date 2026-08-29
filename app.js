/* ============================================================
   HELLBOX COMICS
   FRONTEND APPLICATION V9 — GATE 0.1 ACCESSIBLE MOBILE/LAPTOP
   HARROW'S NERVOUS SYSTEM
   ------------------------------------------------------------
   - Relationship / Hellion memory
   - Contextual Harrow dialogue engine
   - Repetition suppression
   - Press interaction state machine
   - Wallet awareness
   - Publication archive
   - Reader shell
   - Hidden discovery system
   - Private diagnostic mode
   ============================================================ */

(() => {
    "use strict";


    /* =========================================================
       CONSTANTS
       ========================================================= */

    const PULSECHAIN = new Proxy(
        {},
        {
            get(_target, property) {
                const chainKey =
                    document.body?.dataset?.chainKey ||
                    window.HellboxChains?.DEFAULT_CHAIN_KEY ||
                    "pulsechain";

                const chain =
                    window.HellboxRuntime?.getActiveChain?.() ||
                    window.HellboxChains?.getChainByKey(
                        chainKey
                    ) || {
                        key: "pulsechain",
                        chainId: 369,
                        chainIdHex: "0x171",
                        name: "PulseChain",
                        shortName: "PulseChain",
                        currency: {
                            name: "Pulse",
                            symbol: "PLS",
                            decimals: 18
                        },
                        explorerUrl:
                            "https://scan.pulsechain.com",
                        rpcUrls: [
                            "https://rpc.pulsechain.com"
                        ]
                    };

                return chain[property];
            }
        }
    );


    const STORAGE_KEYS = {
        discoveries: "hellbox:discoveries:v2",
        visits: "hellbox:visits:v3",
        pressTouches: "hellbox:press-touches:v2",
        relationship: "hellbox:relationship:v3",
        lastSeen: "hellbox:last-seen:v3",
        dialogueHistory: "hellbox:dialogue-history:v1",
        accessibility: "hellbox:accessibility:v1",
        uiLocale: "hellbox:ui-locale:v1"
    };

    /*
     * Local recognition is presentation-only.
     * Real HELLION standing will be issued by the future server-side
     * history/standing engine and can never be earned by button farming.
     */
    const PROTOTYPE_RELATIONSHIP_THRESHOLDS = {
        noticed: 5,
        familiar: 14
    };

    const MESSAGE_TIMINGS = {
        whisper: 5200,
        normal: 10500,
        important: 18000,
        sticky: 0
    };

    const MAX_DIALOGUE_HISTORY = 18;


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

    const safeNumber = (value, fallback = 0) => {
        const parsed = Number(value);

        return Number.isFinite(parsed)
            ? parsed
            : fallback;
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

    const truncateAddress = (address) => {
        if (
            !address ||
            typeof address !== "string"
        ) {
            return "NOT SHOWN";
        }

        return `${address.slice(0, 6)}...${address.slice(-4)}`;
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

    const randomItem = (items = []) => {
        if (!Array.isArray(items) || items.length === 0) {
            return null;
        }

        return items[
            Math.floor(
                Math.random() * items.length
            )
        ];
    };

    const storageAvailable = (type) => {
        try {
            const storage = window[type];
            const key = "__hellbox_storage_test__";

            storage.setItem(key, key);
            storage.removeItem(key);

            return true;

        } catch (error) {
            return false;
        }
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

        dialogueHistory: [],

        relationship: {
            visits: 0,
            interactions: 0,
            pressTouches: 0,
            discoveriesEver: 0,

            stage: "visitor",
            lastStage: "visitor",

            promotedThisVisit: false
        },

        press: {
            awake: false,
            busy: false,
            touchCount: 0,
            leverPulls: 0,
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
        responseTimer: null,

        diagnostics: {
            enabled: false
        },

        ui: {
            locale: "en",
            translations: {},
            heroTransmissionInterval: null,
            lastFocusedElement: null,
            mobileMenuOpen: false,
            accessPanelOpen: false,
            tickerPaused: false,
            mobileScrollTimer: null,
            lastScrollY: 0
        }
    };


    /* =========================================================
       DOM REFERENCES
       ========================================================= */

    const dom = {
        body: document.body,
        main: $("#mainContent"),
        a11yStatus: $("#a11yStatus"),

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

        accessPanel: $("#accessPanel"),
        accessPanelBackdrop: $("#accessPanelBackdrop"),
        accessPanelClose: $("#accessPanelClose"),
        accessTextToggle: $("#accessTextToggle"),
        accessContrastToggle: $("#accessContrastToggle"),
        accessMotionToggle: $("#accessMotionToggle"),
        interfaceLanguage: $("#interfaceLanguage"),

        mobileMenuButton: $("#mobileMenuButton"),
        mobileNav: $("#mobileNav"),

        walletButton: $("#walletButton"),

        heroLogoButton: $("#heroLogoButton"),
        heroTransmission: $("#heroTransmission"),
        heroTransmissionSub: $("#heroTransmissionSub"),
        heroTransmissionPanel: $(".hero-transmission"),
        transmissionToggle: $("#transmissionToggle"),

        tickerToggle: $("#tickerToggle"),
        obsessionTrack: $("#obsessionTrack"),

        heroSceneViewport: $("#heroSceneViewport"),
        obsessionWallViewport: $("#obsessionWallViewport"),
        pressMachineViewport: $("#pressMachineViewport"),

        therapyNote: $("#therapyNote"),

        publicationCount: $("#publicationCount"),
        readerDormantObject: $("#readerDormantObject"),

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

        bytesInfrastructureObject: $("#bytesInfrastructureObject"),

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
       DIALOGUE LIBRARY
       ========================================================= */

    const DIALOGUE = {
        orb: {
            visitor: [
                {
                    title: "YES?",
                    text: "I was busy admiring a decision nobody approved."
                },
                {
                    title: "WHAT?",
                    text: "You clicked my face. Excellent opening argument."
                },
                {
                    title: "STILL HERE?",
                    text: "You have the internet and this is what you chose to do with it."
                },
                {
                    title: "HELLO.",
                    text: "Don't make this emotional."
                },
                {
                    title: "CAN I HELP YOU?",
                    text: "Wrong question. Obviously I can."
                },
                {
                    title: "HMM.",
                    text: "You look like someone who reads terms after clicking agree."
                },
                {
                    title: "OH GOOD.",
                    text: "An audience."
                },
                {
                    title: "YOU FOUND ME.",
                    text: "The enormous portrait was subtle."
                }
            ],

            noticed: [
                {
                    title: "YOU AGAIN.",
                    text: "I recognize that poor judgment."
                },
                {
                    title: "BACK ALREADY?",
                    text: "I knew the rest of the internet would disappoint you."
                },
                {
                    title: "YOU'RE LEARNING.",
                    text: "Slowly. But statistically it had to happen."
                },
                {
                    title: "I NOTICED.",
                    text: "Most people don't inspect the furniture."
                },
                {
                    title: "THERE YOU ARE.",
                    text: "I wasn't looking for you. That's different."
                },
                {
                    title: "GOOD.",
                    text: "Now click something you were clearly told not to."
                },
                {
                    title: "YOU HAVE QUESTIONS.",
                    text: "Keep them. Mine are better."
                },
                {
                    title: "INTERESTING.",
                    text: "You've moved from visitor to recurring symptom."
                }
            ],

            familiar: [
                {
                    title: "I KNOW YOU.",
                    text: "Not legally. Relax."
                },
                {
                    title: "THERE YOU ARE.",
                    text: "I was beginning to think you developed impulse control."
                },
                {
                    title: "KEEP UP.",
                    text: "The joke was three bad decisions ago."
                },
                {
                    title: "YOU GETTING COMFORTABLE?",
                    text: "Dangerous."
                },
                {
                    title: "YOU'RE BACK.",
                    text: "Predictability is adorable when it's useful."
                },
                {
                    title: "YES, YES.",
                    text: "You've seen my face before. Try surviving the personality."
                },
                {
                    title: "DON'T START.",
                    text: "I already had twelve ideas since your last click."
                },
                {
                    title: "GOOD TIMING.",
                    text: "I just finished agreeing with myself."
                }
            ],

            hellion: [
                {
                    title: "HELLION.",
                    text: "There you are."
                },
                {
                    title: "WELCOME BACK.",
                    text: "I assume everything outside the box was boring again."
                },
                {
                    title: "YOU KNOW BETTER.",
                    text: "That's what makes this charming."
                },
                {
                    title: "STILL MY FAVORITE.",
                    text: "Statistically impossible. Emotionally accurate."
                },
                {
                    title: "YOU GET IT.",
                    text: "Which means we're both probably in trouble."
                },
                {
                    title: "HELLION.",
                    text: "Don't stand there looking responsible. It's unsettling."
                },
                {
                    title: "I KNEW YOU'D COME BACK.",
                    text: "Not faith. Pattern recognition."
                },
                {
                    title: "GOOD.",
                    text: "Everyone else was beginning to annoy me."
                },
                {
                    title: "YOU MISSED ME.",
                    text: "Obviously. Keep your dignity and don't answer."
                },
                {
                    title: "LOOK WHO SURVIVED.",
                    text: "Barely recognizable with all that personal growth."
                },
                {
                    title: "HELLION.",
                    text: "Go touch something expensive."
                },
                {
                    title: "BACK IN THE BOX.",
                    text: "Now the room has standards again."
                }
            ]
        },

        pressTouch: {
            visitor: [
                {
                    title: "I SAID DON'T TOUCH IT.",
                    text: "Apparently literacy remains optional."
                },
                {
                    title: "OH GOOD.",
                    text: "You found the machine with the giant lever and immediately became a scientist."
                },
                {
                    title: "HANDS OFF.",
                    text: "Actually, never mind. This is funnier."
                },
                {
                    title: "YOU TOUCHED IT.",
                    text: "I owe myself money."
                },
                {
                    title: "BRILLIANT.",
                    text: "Nothing says technical competence like pressing the glowing thing."
                },
                {
                    title: "IT'S A PRESS.",
                    text: "Not an emotional support appliance."
                }
            ],

            familiar: [
                {
                    title: "AGAIN?",
                    text: "The machine remembers you. Unfortunately."
                },
                {
                    title: "YOU'RE VERY HANDSY.",
                    text: "Fine. At least buy it dinner first."
                },
                {
                    title: "YOU KNOW WHAT THAT COSTS?",
                    text: "Neither do I. That's why we're calm."
                },
                {
                    title: "THIS IS WHY WE CAN'T HAVE NICE THINGS.",
                    text: "Also why I keep building nicer things."
                },
                {
                    title: "PLEASE CONTINUE.",
                    text: "I'm documenting your decline."
                },
                {
                    title: "I WATCHED YOU DO THAT.",
                    text: "No hesitation. Beautiful."
                }
            ],

            hellion: [
                {
                    title: "HELLION.",
                    text: "You know exactly why that says don't touch."
                },
                {
                    title: "OF COURSE YOU DID.",
                    text: "I didn't raise you correctly, but apparently I raised you somehow."
                },
                {
                    title: "BACK TO THE MACHINE?",
                    text: "The moth has discovered industrial equipment."
                },
                {
                    title: "GOOD.",
                    text: "I was worried you were becoming sensible."
                },
                {
                    title: "KEEP TOUCHING IT.",
                    text: "Eventually one of us learns something."
                },
                {
                    title: "HELLION.",
                    text: "If it explodes, you're explaining it."
                },
                {
                    title: "YOU HAVE A PROBLEM.",
                    text: "Luckily I built it a lever."
                },
                {
                    title: "THIS AGAIN.",
                    text: "Repetition is the foundation of ritual and most software bugs."
                },
                {
                    title: "I LIKE YOUR COMMITMENT.",
                    text: "Your judgment remains indefensible."
                },
                {
                    title: "THAT'S MY HELLION.",
                    text: "Zero self-preservation. Very on-brand."
                }
            ]
        },

        pressLever: {
            noWallet: [
                {
                    title: "SHOW ME THE WALLET.",
                    text: "The machine can't make a terrible decision in your name without your name."
                },
                {
                    title: "WHO ARE YOU?",
                    text: "Philosophically irrelevant. Cryptographically useful."
                },
                {
                    title: "WALLET FIRST.",
                    text: "Even chaos has paperwork."
                },
                {
                    title: "IDENTIFY YOURSELF.",
                    text: "Relax. It's a public blockchain, not a confession booth."
                }
            ],

            empty: [
                {
                    title: "NOTHING FOR YOU YET.",
                    text: "There is no public release loaded. I refuse to fabricate blockchain theater just because the lever is satisfying."
                },
                {
                    title: "YOU PRESSED IT ANYWAY.",
                    text: "No publication. No transaction. Excellent form though."
                },
                {
                    title: "EMPTY.",
                    text: "The machine worked perfectly. Your expectations were defective."
                },
                {
                    title: "NOT YET.",
                    text: "You cannot mint an idea I haven't finished weaponizing."
                },
                {
                    title: "IMPATIENT.",
                    text: "Good trait. Bad timing."
                },
                {
                    title: "NOTHING CAME OUT.",
                    text: "That's what happens when the input is literally nothing."
                },
                {
                    title: "AGAIN?",
                    text: "Pulling harder does not deploy a contract."
                },
                {
                    title: "STILL EMPTY.",
                    text: "I checked. The blockchain remains stubbornly literal."
                }
            ]
        },

        wrongChain: [
            {
                title: "WRONG CHAIN.",
                text: "I can see you. You're just standing in the wrong neighborhood."
            },
            {
                title: "YOU'RE LOST.",
                text: "PulseChain is 369. Please try to keep up with the giant purple monitors."
            },
            {
                title: "NOT HERE.",
                text: "Nice wallet. Wrong universe."
            },
            {
                title: "CHAIN 369.",
                text: "This should not be the hardest puzzle in the building."
            }
        ],

        walletConnected: {
            visitor: [
                {
                    title: "THERE YOU ARE.",
                    text: "Public blockchain. Very private moment."
                },
                {
                    title: "FOUND YOU.",
                    text: "That sounded more threatening than intended. Keep it."
                },
                {
                    title: "GOOD.",
                    text: "Now the box knows which bad decisions are yours."
                }
            ],

            hellion: [
                {
                    title: "WELCOME BACK, HELLION.",
                    text: "Same wallet. Same suspiciously consistent instincts."
                },
                {
                    title: "THERE YOU ARE.",
                    text: "The chain remembered you. So did I."
                },
                {
                    title: "HELLION IDENTIFIED.",
                    text: "Try not to look proud."
                },
                {
                    title: "FOUND YOU AGAIN.",
                    text: "Immutability is romantic when you stop thinking about it."
                }
            ]
        },

        classified: {
            visitor: [
                {
                    title: "NO.",
                    text: "That was unusually clear."
                },
                {
                    title: "PUT IT BACK.",
                    text: "You have the manners of a raccoon with Wi-Fi."
                },
                {
                    title: "CLASSIFIED.",
                    text: "Which part of the black bars inspired confidence?"
                },
                {
                    title: "ABSOLUTELY NOT.",
                    text: "Excellent instincts though."
                }
            ],

            hellion: [
                {
                    title: "HELLION. NO.",
                    text: "Your title does not come with clearance."
                },
                {
                    title: "YOU KNOW THIS ONE.",
                    text: "Still redacted. Still none of your business."
                },
                {
                    title: "PERSISTENT.",
                    text: "Not the same thing as authorized."
                },
                {
                    title: "NICE TRY.",
                    text: "I almost admired it enough to tell you something."
                },
                {
                    title: "STOP.",
                    text: "Actually don't. Your inability to listen is becoming useful."
                }
            ]
        },

        harrowVanity: [
            {
                title: "YES, THAT'S ME.",
                text: "I picked the picture. Obviously."
            },
            {
                title: "GOOD ANGLE.",
                text: "There are no bad ones. Still, good angle."
            },
            {
                title: "HARROW.",
                text: "Favorite artist. Favorite writer. Favorite Harrow."
            },
            {
                title: "SELF PORTRAIT.",
                text: "Technically somebody else made the pixels. Spiritually, me."
            },
            {
                title: "LOOK CLOSER.",
                text: "It's expensive being this tastefully unstable."
            },
            {
                title: "YES.",
                text: "You may admire quietly."
            }
        ]
    };


    /* =========================================================
       DIALOGUE MEMORY
       ========================================================= */

    function loadDialogueHistory() {
        if (!storageAvailable("sessionStorage")) {
            state.dialogueHistory = [];
            return;
        }

        try {
            const raw =
                window.sessionStorage.getItem(
                    STORAGE_KEYS.dialogueHistory
                );

            const parsed =
                raw
                    ? JSON.parse(raw)
                    : [];

            state.dialogueHistory =
                Array.isArray(parsed)
                    ? parsed
                    : [];

        } catch (error) {
            state.dialogueHistory = [];
        }
    }

    function saveDialogueHistory() {
        if (!storageAvailable("sessionStorage")) {
            return;
        }

        try {
            window.sessionStorage.setItem(
                STORAGE_KEYS.dialogueHistory,
                JSON.stringify(
                    state.dialogueHistory.slice(
                        -MAX_DIALOGUE_HISTORY
                    )
                )
            );

        } catch (error) {
            // Non-critical.
        }
    }

    function dialogueKey(entry) {
        return `${entry?.title || ""}|${entry?.text || ""}`;
    }

    function chooseDialogue(pool) {
        if (
            !Array.isArray(pool) ||
            pool.length === 0
        ) {
            return {
                title: "HMM.",
                text: "I had something for this."
            };
        }

        const recent =
            new Set(
                state.dialogueHistory.slice(-8)
            );

        let candidates =
            pool.filter((entry) => {
                return !recent.has(
                    dialogueKey(entry)
                );
            });

        if (candidates.length === 0) {
            candidates = pool;
        }

        const chosen =
            randomItem(candidates);

        const key =
            dialogueKey(chosen);

        state.dialogueHistory.push(key);

        if (
            state.dialogueHistory.length >
            MAX_DIALOGUE_HISTORY
        ) {
            state.dialogueHistory.shift();
        }

        saveDialogueHistory();

        return chosen;
    }


    /* =========================================================
       RESPONSE PRESENTATION
       ========================================================= */

    function whisper(
        message,
        duration = MESSAGE_TIMINGS.whisper
    ) {
        if (
            !dom.whisper ||
            !dom.whisperText
        ) {
            return;
        }

        window.clearTimeout(
            state.whisperTimer
        );

        dom.whisperText.textContent =
            message;

        dom.whisper.classList.add(
            "active"
        );

        dom.whisper.setAttribute(
            "aria-hidden",
            "false"
        );

        state.whisperTimer =
            window.setTimeout(() => {
                dom.whisper.classList.remove(
                    "active"
                );

                dom.whisper.setAttribute(
                    "aria-hidden",
                    "true"
                );

            }, duration);
    }

    function showHarrowResponse(
        title,
        text,
        options = {}
    ) {
        if (
            !dom.harrowResponse ||
            !dom.harrowResponseTitle ||
            !dom.harrowResponseText
        ) {
            return;
        }

        const {
            importance = "normal",
            sticky = false
        } = options;

        window.clearTimeout(
            state.responseTimer
        );

        dom.harrowResponseTitle.textContent =
            title;

        dom.harrowResponseText.textContent =
            text;

        dom.harrowResponse.inert = false;

        dom.harrowResponse.classList.add(
            "active"
        );

        dom.harrowResponse.classList.toggle(
            "important",
            importance === "important"
        );

        dom.harrowResponse.classList.toggle(
            "sticky",
            sticky
        );

        dom.harrowResponse.setAttribute(
            "aria-hidden",
            "false"
        );

        const duration =
            sticky
                ? MESSAGE_TIMINGS.sticky
                : (
                    MESSAGE_TIMINGS[importance] ??
                    MESSAGE_TIMINGS.normal
                );

        if (duration > 0) {
            state.responseTimer =
                window.setTimeout(() => {
                    closeHarrowResponse();
                }, duration);
        }
    }

    function showDialogue(
        pool,
        options = {}
    ) {
        const dialogue =
            chooseDialogue(pool);

        showHarrowResponse(
            dialogue.title,
            dialogue.text,
            options
        );
    }

    function closeHarrowResponse() {
        if (!dom.harrowResponse) {
            return;
        }

        window.clearTimeout(
            state.responseTimer
        );

        dom.harrowResponse.classList.remove(
            "active",
            "important",
            "sticky"
        );

        dom.harrowResponse.setAttribute(
            "aria-hidden",
            "true"
        );

        dom.harrowResponse.inert = true;
    }


    /* =========================================================
       RELATIONSHIP / HELLION SYSTEM
       ========================================================= */

    function loadRelationship() {
        const fallback = {
            visits: 0,
            interactions: 0,
            pressTouches: 0,
            discoveriesEver: 0,
            stage: "visitor",
            lastStage: "visitor"
        };

        if (!storageAvailable("localStorage")) {
            Object.assign(
                state.relationship,
                fallback
            );

            return;
        }

        try {
            const raw =
                window.localStorage.getItem(
                    STORAGE_KEYS.relationship
                );

            if (!raw) {
                Object.assign(
                    state.relationship,
                    fallback
                );

                return;
            }

            const parsed =
                JSON.parse(raw);

            state.relationship.visits =
                safeNumber(
                    parsed.visits,
                    0
                );

            state.relationship.interactions =
                safeNumber(
                    parsed.interactions,
                    0
                );

            state.relationship.pressTouches =
                safeNumber(
                    parsed.pressTouches,
                    0
                );

            state.relationship.discoveriesEver =
                safeNumber(
                    parsed.discoveriesEver,
                    0
                );

            state.relationship.stage =
                safeText(
                    parsed.stage,
                    "visitor"
                );

            state.relationship.lastStage =
                safeText(
                    parsed.lastStage,
                    state.relationship.stage
                );

        } catch (error) {
            Object.assign(
                state.relationship,
                fallback
            );
        }
    }

    function saveRelationship() {
        if (!storageAvailable("localStorage")) {
            return;
        }

        try {
            window.localStorage.setItem(
                STORAGE_KEYS.relationship,
                JSON.stringify({
                    visits:
                        state.relationship.visits,

                    interactions:
                        state.relationship.interactions,

                    pressTouches:
                        state.relationship.pressTouches,

                    discoveriesEver:
                        state.relationship.discoveriesEver,

                    stage:
                        state.relationship.stage,

                    lastStage:
                        state.relationship.lastStage
                })
            );

        } catch (error) {
            // Non-critical.
        }
    }

    function calculateRelationshipScore() {
        const visitScore =
            Math.min(
                state.relationship.visits * 2,
                12
            );

        const interactionScore =
            Math.min(
                Math.floor(
                    state.relationship.interactions / 2
                ),
                14
            );

        const discoveryScore =
            Math.min(
                state.relationship.discoveriesEver,
                14
            );

        const pressScore =
            Math.min(
                state.relationship.pressTouches,
                8
            );

        return (
            visitScore +
            interactionScore +
            discoveryScore +
            pressScore
        );
    }

    function relationshipStageForScore(score) {
        if (
            score >=
            PROTOTYPE_RELATIONSHIP_THRESHOLDS.familiar
        ) {
            return "familiar";
        }

        if (
            score >=
            PROTOTYPE_RELATIONSHIP_THRESHOLDS.noticed
        ) {
            return "noticed";
        }

        return "visitor";
    }

    function updateRelationshipStage({
        announce = true
    } = {}) {
        const previousStage =
            state.relationship.stage;

        const score =
            calculateRelationshipScore();

        const nextStage =
            relationshipStageForScore(
                score
            );

        state.relationship.lastStage =
            previousStage;

        state.relationship.stage =
            nextStage;

        document.body.dataset.relationshipStage =
            nextStage;

        saveRelationship();

        updateExitAfterthought();

        if (
            announce &&
            previousStage !== nextStage &&
            !state.relationship.promotedThisVisit
        ) {
            state.relationship.promotedThisVisit =
                true;

            announceRelationshipChange(
                nextStage
            );
        }
    }

    function announceRelationshipChange(
        nextStage
    ) {
        if (nextStage === "noticed") {
            showHarrowResponse(
                "YOU'RE STILL HERE.",
                "Most people would've wandered off by now.",
                {
                    importance: "important"
                }
            );

            return;
        }

        if (nextStage === "familiar") {
            showHarrowResponse(
                "I KNOW YOU.",
                "Not personally. Don't make this weird.",
                {
                    importance: "important"
                }
            );

            return;
        }
    }

    function recordInteraction(
        amount = 1,
        options = {}
    ) {
        const {
            press = false,
            silent = false
        } = options;

        state.relationship.interactions +=
            amount;

        if (press) {
            state.relationship.pressTouches +=
                amount;
        }

        saveRelationship();

        updateRelationshipStage({
            announce: !silent
        });
    }

    function recordPermanentDiscovery() {
        state.relationship.discoveriesEver +=
            1;

        saveRelationship();

        updateRelationshipStage();
    }

    function currentRelationshipStage() {
        return (
            state.relationship.stage ||
            "visitor"
        );
    }

    function isHellion() {
        /*
         * Gate 0 intentionally refuses to mint fake status in localStorage.
         * The production relationship engine will answer this from Hellbox history.
         */
        return false;
    }

    function isFamiliar() {
        return currentRelationshipStage() === "familiar";
    }


    /* =========================================================
       DISCOVERY SYSTEM
       ========================================================= */

    function loadDiscoveries() {
        if (!storageAvailable("sessionStorage")) {
            state.discoveries =
                new Set();

            return;
        }

        try {
            const raw =
                window.sessionStorage.getItem(
                    STORAGE_KEYS.discoveries
                );

            const parsed =
                raw
                    ? JSON.parse(raw)
                    : [];

            state.discoveries =
                new Set(
                    Array.isArray(parsed)
                        ? parsed
                        : []
                );

        } catch (error) {
            state.discoveries =
                new Set();
        }

        renderDiscoveryCounter();
    }

    function saveDiscoveries() {
        if (!storageAvailable("sessionStorage")) {
            return;
        }

        try {
            window.sessionStorage.setItem(
                STORAGE_KEYS.discoveries,
                JSON.stringify(
                    Array.from(
                        state.discoveries
                    )
                )
            );

        } catch (error) {
            // Non-critical.
        }
    }

    function discover(
        key,
        message = null
    ) {
        if (!key) {
            return false;
        }

        const alreadyFound =
            state.discoveries.has(key);

        state.discoveries.add(key);

        saveDiscoveries();
        renderDiscoveryCounter();

        if (!alreadyFound) {
            recordPermanentDiscovery();

            if (message) {
                whisper(message);
            }
        }

        return !alreadyFound;
    }

    function renderDiscoveryCounter() {
        if (!dom.discoveryCount) {
            return;
        }

        const count =
            state.discoveries.size;

        dom.discoveryCount.textContent =
            String(count).padStart(
                2,
                "0"
            );

        document.body.classList.toggle(
            "has-discoveries",
            count > 0
        );
    }


    /* =========================================================
       VISIT MEMORY
       ========================================================= */

    function registerVisit() {
        const NEW_VISIT_WINDOW =
            30 * 60 * 1000;

        if (!storageAvailable("localStorage")) {
            state.relationship.visits +=
                1;

            updateRelationshipStage({
                announce: false
            });

            return;
        }

        try {
            const now =
                Date.now();

            const lastSeen =
                safeNumber(
                    window.localStorage.getItem(
                        STORAGE_KEYS.lastSeen
                    ),
                    0
                );

            const qualifiesAsNewVisit =
                !lastSeen ||
                now - lastSeen >
                    NEW_VISIT_WINDOW;

            if (qualifiesAsNewVisit) {
                state.relationship.visits +=
                    1;
            }

            window.localStorage.setItem(
                STORAGE_KEYS.lastSeen,
                String(now)
            );

            window.localStorage.setItem(
                STORAGE_KEYS.visits,
                String(
                    state.relationship.visits
                )
            );

            saveRelationship();

            updateRelationshipStage({
                announce: false
            });

        } catch (error) {
            state.relationship.visits +=
                1;

            updateRelationshipStage({
                announce: false
            });
        }

        updateExitAfterthought();
    }

    function updateExitAfterthought() {
        if (!dom.exitAfterthought) {
            return;
        }

        if (isHellion()) {
            dom.exitAfterthought.textContent =
                "you always come back.";

            return;
        }

        if (isFamiliar()) {
            dom.exitAfterthought.textContent =
                "See you again.";

            return;
        }

        if (
            state.relationship.visits >= 2
        ) {
            dom.exitAfterthought.textContent =
                "See? Back already.";

            return;
        }

        dom.exitAfterthought.textContent =
            "you'll be back.";
    }


    /* =========================================================
       HERO ATMOSPHERE
       ========================================================= */

    const HERO_THOUGHTS = [
        {
            title:
                "I HAVE EXCELLENT JUDGMENT.",
            sub:
                "Evidence remains aggressively inconclusive."
        },
        {
            title:
                "DO NOT TAKE FINANCIAL ADVICE FROM ME.",
            sub:
                "Aesthetic advice is mandatory."
        },
        {
            title:
                "I HAD AN IDEA.",
            sub:
                "Historically a terrible sign."
        },
        {
            title:
                "WAIT. THAT'S ACTUALLY FUNNY.",
            sub:
                "Somebody write that down."
        },
        {
            title:
                "THE CHAIN REMEMBERS.",
            sub:
                "So do screenshots. Tragic."
        },
        {
            title:
                "I'M BUSY BEING RIGHT.",
            sub:
                "Full-time position."
        },
        {
            title:
                "SOMEBODY PUT ADULTS IN CHARGE.",
            sub:
                "Terrible design decision."
        },
        {
            title:
                "I DON'T NEED A ROADMAP.",
            sub:
                "I know where I'm going until I don't."
        },
        {
            title:
                "THIS IS FINE.",
            sub:
                "Definition pending."
        },
        {
            title:
                "PULSICANS ARE VERY NORMAL PEOPLE.",
            sub:
                "This statement was not independently verified."
        },
        {
            title:
                "HEXICANS HAVE OPINIONS.",
            sub:
                "Several."
        },
        {
            title:
                "I'M NOT ARGUING.",
            sub:
                "I'm explaining why you're wrong."
        },
        {
            title:
                "THE INTERNET WAS A MISTAKE.",
            sub:
                "I intend to use all of it."
        }
    ];

    const HELLION_HERO_THOUGHTS = [
        {
            title:
                "THE HELLIONS KEEP FINDING THINGS.",
            sub:
                "I should hide things better."
        },
        {
            title:
                "WELCOME BACK.",
            sub:
                "Outside was boring again."
        },
        {
            title:
                "YOU GET IT NOW.",
            sub:
                "That's unfortunate."
        },
        {
            title:
                "HELLIONS HAVE TERRIBLE IMPULSE CONTROL.",
            sub:
                "Good."
        },
        {
            title:
                "I BUILT THIS FOR PEOPLE LIKE YOU.",
            sub:
                "That is not necessarily a compliment."
        },
        {
            title:
                "STOP LOOKING AT THE REDACTED THING.",
            sub:
                "Actually keep going."
        }
    ];

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

    function rotateHeroTransmission() {
        if (
            !dom.heroTransmission ||
            !dom.heroTransmissionSub
        ) {
            return;
        }

        const pool =
            isHellion()
                ? [
                    ...HERO_THOUGHTS,
                    ...HELLION_HERO_THOUGHTS
                ]
                : HERO_THOUGHTS;

        const thought =
            randomItem(pool);

        if (!thought) {
            return;
        }

        dom.heroTransmission.textContent =
            thought.title;

        dom.heroTransmissionSub.textContent =
            thought.sub;
    }

    function motionShouldBeReduced() {
        return (
            document.body.classList.contains(
                "a11y-reduce-motion"
            ) ||
            window.matchMedia(
                "(prefers-reduced-motion: reduce)"
            ).matches
        );
    }

    function initHeroTransmission() {
        rotateHeroTransmission();

        window.clearInterval(
            state.ui.heroTransmissionInterval
        );

        if (motionShouldBeReduced()) {
            return;
        }

        state.ui.heroTransmissionInterval =
            window.setInterval(() => {
                rotateHeroTransmission();
            }, 12500);
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

        recordInteraction();

        state.ui.lastFocusedElement =
            document.activeElement;

        if (dom.drawerCode) {
            dom.drawerCode.textContent =
                code;
        }

        if (dom.drawerEyebrow) {
            dom.drawerEyebrow.textContent =
                eyebrow;
        }

        if (dom.drawerTitle) {
            dom.drawerTitle.textContent =
                title;
        }

        if (dom.drawerCopy) {
            dom.drawerCopy.innerHTML =
                html;
        }

        if (dom.drawerFootnote) {
            dom.drawerFootnote.innerHTML =
                footnote;
        }

        dom.drawer.inert = false;

        dom.drawer.classList.add(
            "active"
        );

        dom.drawer.setAttribute(
            "aria-hidden",
            "false"
        );

        document.body.classList.add(
            "drawer-open"
        );

        window.setTimeout(() => {
            dom.drawerClose?.focus();
        }, 0);
    }

    function closeDrawer() {
        if (!dom.drawer) {
            return;
        }

        dom.drawer.classList.remove(
            "active"
        );

        dom.drawer.setAttribute(
            "aria-hidden",
            "true"
        );

        dom.drawer.inert = true;

        document.body.classList.remove(
            "drawer-open"
        );

        if (
            state.ui.lastFocusedElement &&
            typeof state.ui.lastFocusedElement.focus ===
                "function"
        ) {
            state.ui.lastFocusedElement.focus();
        }
    }


    /* =========================================================
       HERO HOTSPOTS
       ========================================================= */

    const HOTSPOT_CONTENT = {
        cabal: {
            code:
                "WALL // THREAD 0047",

            eyebrow:
                "HARROW // THEORY",

            title:
                "THE CABAL.",

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
            code:
                "INFRASTRUCTURE // RPC",

            eyebrow:
                "HARROW // UNDER THE FLOORBOARDS",

            title:
                "PULSE BYTE.",

            html: `
                <p>
                    HairyLabs keeps the lair connected to PulseChain.
                </p>

                <p>
                    The comics are the point.
                    This is the machinery that refuses to become an excuse.
                </p>

                <p>
                    Public RPCs are communal drinking fountains.
                    Harrow prefers his own plumbing.
                </p>
            `,

            footnote:
                "CHAIN // 369 // RPC STATUS // CONNECTED."
        },

        harrow: {
            code:
                "HARROW // OBVIOUS",

            eyebrow:
                "HARROW // HARROW",

            title:
                "YES. ME.",

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
            code:
                "DESK // IN PROGRESS",

            eyebrow:
                "HARROW // PANELS",

            title:
                "THAT'S THE POINT.",

            html: `
                <p>
                    Every bad idea eventually becomes a panel.
                </p>

                <p>
                    Enough panels become a comic.
                    Somebody mints it.
                    Suddenly everyone pretends the process was deliberate.
                </p>
            `,

            footnote:
                "WORKFLOW // THINK → DRAW → REGRET → PUBLISH."
        },

        bike: {
            code:
                "MACHINE // UNNAMED",

            eyebrow:
                "HARROW // CAGES ARE FOR OTHER PEOPLE",

            title:
                "THE BIKE.",

            html: `
                <p>
                    Harrow hates cars.
                </p>

                <p>
                    Cars are cages.
                    This is what he uses when the room gets too small.
                </p>

                <p>
                    Blacked-out steel.
                    Low enough to look guilty standing still.
                    Loud enough to finish the argument before Harrow starts it.
                </p>

                <p>
                    It has a name.
                    The last one was rejected.
                    Try not to get attached to anything unfinished.
                </p>
            `,

            footnote:
                "NAME // NOT GOOD ENOUGH YET."
        },

        redacted: {
            code:
                "PRESS COPY // NOT FOR RELEASE",

            eyebrow:
                "HARROW // PUT IT DOWN",

            title:
                "PUT THAT BACK.",

            html: `
                <p>
                    It says PRODUCTION COPY.
                </p>

                <p>
                    It also says NOT FOR RELEASE.
                    Harrow admired the part where you interpreted both as an invitation.
                </p>

                <p>
                    BURN AFTER READING was written for him.
                    Not you.
                </p>
            `,

            footnote:
                "STATUS // UNFINISHED. CURIOSITY // NOT AUTHORIZATION."
        }
    };

    function initHotspots() {
        $$(".lair-hotspot").forEach(
            (button) => {

                /*
                 * Testing improvement:
                 * still visually hidden, but the browser cursor
                 * changes when the pointer actually enters one.
                 */

                button.setAttribute(
                    "aria-label",
                    button.getAttribute(
                        "aria-label"
                    ) || "Something in Harrow's lair"
                );

                button.addEventListener(
                    "mouseenter",
                    () => {
                        document.body.classList.add(
                            "hotspot-near"
                        );
                    }
                );

                button.addEventListener(
                    "mouseleave",
                    () => {
                        document.body.classList.remove(
                            "hotspot-near"
                        );
                    }
                );

                button.addEventListener(
                    "click",
                    () => {
                        const key =
                            button.dataset.hotspot;

                        const content =
                            HOTSPOT_CONTENT[key];

                        if (!content) {
                            return;
                        }

                        discover(
                            `hero:${key}`,
                            isHellion()
                                ? "Still checking my work?"
                                : "There you go. You found one."
                        );

                        openDrawer(content);
                    }
                );
            }
        );
    }


    /* =========================================================
       THEORY WALL
       ========================================================= */

    const THEORY_CONTENT = {
        richard: {
            code:
                "THEORY // RH-369",

            eyebrow:
                "HARROW // CURRENTLY THINKING",

            title:
                "RICHARD.",

            html: `
                <p>
                    Build a chain.
                    Make everybody argue about it.
                    Then become the main character in every conversation
                    without actually being in the room.
                </p>

                <p>
                    Efficient.
                </p>
            `,

            footnote:
                "SATIRE // PUBLIC EVENTS REARRANGED FOR COMEDIC DAMAGE."
        },

        sec: {
            code:
                "THEORY // GOV-004",

            eyebrow:
                "HARROW // REGULATORY FAN CLUB",

            title:
                "VERY SERIOUS PEOPLE.",

            html: `
                <p>
                    They really like rules.
                </p>

                <p>
                    I read the document.
                    Most of it.
                </p>

                <p>
                    The red string remains unconvinced.
                </p>
            `,

            footnote:
                "THIS IS SATIRE. RELAX."
        },

        interpol: {
            code:
                "THEORY // INT-???",

            eyebrow:
                "HARROW // PLEASE RELAX",

            title:
                "INTERPOL.",

            html: `
                <p>
                    No.
                </p>

                <p>
                    I am not elaborating.
                </p>

                <p>
                    I draw comic books.
                    Mostly.
                </p>
            `,

            footnote:
                "DIAGRAM STATUS // ENTIRELY TOO MUCH STRING."
        },

        cabal: {
            code:
                "THEORY // █████",

            eyebrow:
                "HARROW // DIAGRAM INCOMPLETE",

            title:
                "THE CABAL.",

            html: `
                <p>
                    Always.
                    Everywhere.
                    All ways.
                </p>

                <p>
                    What does that even mean?
                </p>

                <p>
                    Excellent question.
                    Stop touching the board.
                </p>
            `,

            footnote:
                "THE CABAL, AS DEPICTED HERE, IS A FICTIONAL SATIRICAL DEVICE."
        },

        nft: {
            code:
                "THEORY // JPG-404",

            eyebrow:
                "HARROW // CULTURE DEPARTMENT",

            title:
                "WHO TOLD THEM NFTS WERE DEAD?",

            html: `
                <p>
                    Bad NFTs died.
                    Actually most of them.
                </p>

                <p>
                    Community.
                    Art.
                    Utility.
                    Vibes.
                </p>

                <p>
                    Yes.
                    All of it.
                </p>
            `,

            footnote:
                "HARROW // FINE. I'LL DO IT."
        },

        sacrifice: {
            code:
                "THEORY // SAC-369",

            eyebrow:
                "HARROW // OLD RECEIPTS",

            title:
                "THE SACRIFICE.",

            html: `
                <p>
                    We were so young.
                </p>

                <p>
                    We were idiots.
                </p>

                <p>
                    Both can be true.
                </p>
            `,

            footnote:
                "MEMORY // EXPENSIVE. TIMING // WORSE."
        },

        influencers: {
            code:
                "THEORY // FEED-∞",

            eyebrow:
                "HARROW // EXPERT DETECTOR",

            title:
                "INFLUENCERS.",

            html: `
                <p>
                    Everyone is an expert during a green candle.
                </p>

                <p>
                    The fascinating part is how quickly the biographies
                    rewrite themselves during a red one.
                </p>
            `,

            footnote:
                "SIGNAL QUALITY // CONFIDENT. ACCURACY // PENDING."
        },

        harrow: {
            code:
                "THEORY // HARROW",

            eyebrow:
                "HARROW // PRIMARY SOURCE",

            title:
                "FINALLY. A RELIABLE SOURCE.",

            html: `
                <p>
                    Harrow.
                </p>

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
        $$(".case-file[data-theory]").forEach(
            (button) => {
                button.addEventListener(
                    "click",
                    () => {
                        const key =
                            button.dataset.theory;

                        const content =
                            THEORY_CONTENT[key];

                        if (!content) {
                            return;
                        }

                        discover(
                            `theory:${key}`,
                            isHellion()
                                ? "You've seen the board before. It got worse."
                                : "See? Everything touches everything."
                        );

                        if (
                            key === "harrow" &&
                            dom.theoryCorrection
                        ) {
                            dom.theoryCorrection.classList.add(
                                "active"
                            );
                        }

                        openDrawer(content);
                    }
                );
            }
        );
    }


    /* =========================================================
       RESPONSIVE ART VIEWPORTS
       Mobile treats the lair, theory wall and Press as rooms that
       can be explored horizontally instead of crushing the art.
       ========================================================= */

    function positionMobileArtViewport(
        selector,
        ratio
    ) {
        const viewport =
            $(selector);

        if (
            !viewport ||
            viewport.dataset.initialPosition ===
                "set"
        ) {
            return;
        }

        const applyPosition = () => {
            const maximum =
                Math.max(
                    0,
                    viewport.scrollWidth -
                    viewport.clientWidth
                );

            if (maximum <= 0) {
                return;
            }

            viewport.scrollLeft =
                maximum * ratio;

            viewport.dataset.initialPosition =
                "set";
        };

        const image =
            $("img", viewport);

        if (
            image &&
            !image.complete
        ) {
            image.addEventListener(
                "load",
                () => {
                    window.requestAnimationFrame(
                        applyPosition
                    );
                },
                {
                    once: true
                }
            );

        } else {
            window.requestAnimationFrame(
                applyPosition
            );
        }
    }

    function initResponsiveArtViews() {
        const mobile =
            window.matchMedia(
                "(max-width: 760px)"
            );

        if (!mobile.matches) {
            return;
        }

        positionMobileArtViewport(
            "#heroSceneViewport",
            0.68
        );

        positionMobileArtViewport(
            "#obsessionWallViewport",
            0.48
        );

        positionMobileArtViewport(
            "#pressMachineViewport",
            0.52
        );
    }


    /* =========================================================
       ACCESSIBILITY, INTERFACE LANGUAGE, AND MOBILE CONTROL
       ========================================================= */

    const SUPPORTED_UI_LOCALES = new Set([
        "en",
        "es",
        "pt-BR"
    ]);

    function announceStatus(message) {
        if (!dom.a11yStatus || !message) {
            return;
        }

        dom.a11yStatus.textContent = "";

        window.requestAnimationFrame(() => {
            dom.a11yStatus.textContent =
                String(message);
        });
    }

    function translation(key, fallback = "") {
        return (
            state.ui.translations?.[key] ||
            fallback ||
            key
        );
    }

    async function loadUiLocale(locale) {
        const nextLocale =
            SUPPORTED_UI_LOCALES.has(locale)
                ? locale
                : "en";

        try {
            const response = await fetch(
                `/locales/${encodeURIComponent(nextLocale)}.json?v=20260828-gate0-1-02`,
                {
                    cache: "force-cache"
                }
            );

            if (!response.ok) {
                throw new Error(
                    `Locale ${nextLocale} unavailable.`
                );
            }

            state.ui.translations =
                await response.json();

            state.ui.locale =
                nextLocale;

        } catch (error) {
            if (nextLocale !== "en") {
                return loadUiLocale("en");
            }

            state.ui.locale = "en";
            state.ui.translations = {};
        }

        document.documentElement.dataset.uiLocale =
            state.ui.locale;

        $$('[data-i18n]').forEach((element) => {
            const key =
                element.dataset.i18n;

            const nextText =
                state.ui.translations?.[key];

            if (typeof nextText === "string") {
                element.textContent =
                    nextText;
            }
        });

        if (dom.interfaceLanguage) {
            dom.interfaceLanguage.value =
                state.ui.locale;
        }

        if (storageAvailable("localStorage")) {
            try {
                window.localStorage.setItem(
                    STORAGE_KEYS.uiLocale,
                    state.ui.locale
                );
            } catch (error) {
                // Non-critical.
            }
        }

        updateAccessSettingLabels();
        updateTickerControl();
        updateTransmissionDisclosure();
    }

    function preferredUiLocale() {
        if (storageAvailable("localStorage")) {
            try {
                const stored =
                    window.localStorage.getItem(
                        STORAGE_KEYS.uiLocale
                    );

                if (SUPPORTED_UI_LOCALES.has(stored)) {
                    return stored;
                }
            } catch (error) {
                // Fall back to browser language.
            }
        }

        const browserLanguages =
            navigator.languages ||
            [navigator.language || "en"];

        for (const item of browserLanguages) {
            if (SUPPORTED_UI_LOCALES.has(item)) {
                return item;
            }

            const base =
                String(item).split("-")[0];

            if (SUPPORTED_UI_LOCALES.has(base)) {
                return base;
            }

            if (
                base === "pt" &&
                SUPPORTED_UI_LOCALES.has("pt-BR")
            ) {
                return "pt-BR";
            }
        }

        return "en";
    }

    function readAccessibilityPreferences() {
        const fallback = {
            largeText: false,
            highContrast: false,
            reduceMotion: false
        };

        if (!storageAvailable("localStorage")) {
            return fallback;
        }

        try {
            const raw =
                window.localStorage.getItem(
                    STORAGE_KEYS.accessibility
                );

            if (!raw) {
                return fallback;
            }

            return {
                ...fallback,
                ...JSON.parse(raw)
            };

        } catch (error) {
            return fallback;
        }
    }

    function writeAccessibilityPreferences(preferences) {
        if (!storageAvailable("localStorage")) {
            return;
        }

        try {
            window.localStorage.setItem(
                STORAGE_KEYS.accessibility,
                JSON.stringify(preferences)
            );
        } catch (error) {
            // Non-critical.
        }
    }

    function currentAccessibilityPreferences() {
        return {
            largeText:
                document.body.classList.contains(
                    "a11y-large-text"
                ),
            highContrast:
                document.body.classList.contains(
                    "a11y-high-contrast"
                ),
            reduceMotion:
                document.body.classList.contains(
                    "a11y-reduce-motion"
                )
        };
    }

    function setAccessPreference(name, enabled, {
        save = true,
        announce = true
    } = {}) {
        const className = {
            largeText: "a11y-large-text",
            highContrast: "a11y-high-contrast",
            reduceMotion: "a11y-reduce-motion"
        }[name];

        if (!className) {
            return;
        }

        document.body.classList.toggle(
            className,
            Boolean(enabled)
        );

        if (save) {
            writeAccessibilityPreferences(
                currentAccessibilityPreferences()
            );
        }

        updateAccessSettingLabels();

        if (name === "reduceMotion") {
            initHeroTransmission();
            updateTickerControl();
        }

        if (announce) {
            const label = {
                largeText: "Larger text",
                highContrast: "High contrast",
                reduceMotion: "Reduced motion"
            }[name];

            announceStatus(
                `${label} ${enabled ? "on" : "off"}.`
            );
        }
    }

    function updateAccessSettingLabels() {
        const controls = [
            [dom.accessTextToggle, "largeText"],
            [dom.accessContrastToggle, "highContrast"],
            [dom.accessMotionToggle, "reduceMotion"]
        ];

        controls.forEach(([button, key]) => {
            if (!button) {
                return;
            }

            const enabled =
                currentAccessibilityPreferences()[key];

            button.setAttribute(
                "aria-pressed",
                enabled ? "true" : "false"
            );

            const stateElement =
                $("[data-setting-state]", button);

            if (stateElement) {
                stateElement.textContent =
                    enabled
                        ? translation("setting.on", "ON")
                        : translation("setting.off", "OFF");
            }
        });
    }

    function focusableElements(root) {
        if (!root) {
            return [];
        }

        return $$(
            'a[href], button:not([disabled]), select:not([disabled]), input:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])',
            root
        ).filter((element) => {
            return (
                element.offsetWidth > 0 ||
                element.offsetHeight > 0
            );
        });
    }

    function trapFocus(event, root) {
        if (
            event.key !== "Tab" ||
            !root
        ) {
            return false;
        }

        const items =
            focusableElements(root);

        if (items.length === 0) {
            return false;
        }

        const first = items[0];
        const last = items[items.length - 1];

        if (
            event.shiftKey &&
            document.activeElement === first
        ) {
            event.preventDefault();
            last.focus();
            return true;
        }

        if (
            !event.shiftKey &&
            document.activeElement === last
        ) {
            event.preventDefault();
            first.focus();
            return true;
        }

        return false;
    }

    function openAccessPanel() {
        if (!dom.accessPanel) {
            return;
        }

        state.ui.lastFocusedElement =
            document.activeElement;

        state.ui.accessPanelOpen = true;

        dom.accessPanel.inert = false;
        dom.accessPanel.classList.add("active");
        dom.accessPanel.setAttribute(
            "aria-hidden",
            "false"
        );

        document.body.classList.add(
            "access-panel-open"
        );

        closeMobileMenu();

        window.setTimeout(() => {
            dom.accessPanelClose?.focus();
        }, 0);
    }

    function closeAccessPanel() {
        if (!dom.accessPanel) {
            return;
        }

        state.ui.accessPanelOpen = false;

        dom.accessPanel.classList.remove("active");
        dom.accessPanel.setAttribute(
            "aria-hidden",
            "true"
        );

        dom.accessPanel.inert = true;

        document.body.classList.remove(
            "access-panel-open"
        );

        if (
            state.ui.lastFocusedElement &&
            typeof state.ui.lastFocusedElement.focus ===
                "function"
        ) {
            state.ui.lastFocusedElement.focus();
        }
    }

    function initAccessibilityPanel() {
        const preferences =
            readAccessibilityPreferences();

        setAccessPreference(
            "largeText",
            Boolean(preferences.largeText),
            { save: false, announce: false }
        );

        setAccessPreference(
            "highContrast",
            Boolean(preferences.highContrast),
            { save: false, announce: false }
        );

        setAccessPreference(
            "reduceMotion",
            Boolean(preferences.reduceMotion),
            { save: false, announce: false }
        );

        $$('[data-open-access]').forEach((button) => {
            button.addEventListener(
                "click",
                openAccessPanel
            );
        });

        dom.accessPanelBackdrop?.addEventListener(
            "click",
            closeAccessPanel
        );

        dom.accessPanelClose?.addEventListener(
            "click",
            closeAccessPanel
        );

        dom.accessTextToggle?.addEventListener(
            "click",
            () => {
                setAccessPreference(
                    "largeText",
                    !document.body.classList.contains(
                        "a11y-large-text"
                    )
                );
            }
        );

        dom.accessContrastToggle?.addEventListener(
            "click",
            () => {
                setAccessPreference(
                    "highContrast",
                    !document.body.classList.contains(
                        "a11y-high-contrast"
                    )
                );
            }
        );

        dom.accessMotionToggle?.addEventListener(
            "click",
            () => {
                setAccessPreference(
                    "reduceMotion",
                    !document.body.classList.contains(
                        "a11y-reduce-motion"
                    )
                );
            }
        );

        dom.interfaceLanguage?.addEventListener(
            "change",
            () => {
                loadUiLocale(
                    dom.interfaceLanguage.value
                );

                announceStatus(
                    "Interface language updated."
                );
            }
        );
    }

    function openMobileMenu() {
        if (!dom.mobileNav) {
            return;
        }

        state.ui.mobileMenuOpen = true;

        dom.mobileNav.inert = false;
        dom.mobileNav.classList.add("active");
        dom.mobileNav.setAttribute(
            "aria-hidden",
            "false"
        );

        dom.mobileMenuButton?.setAttribute(
            "aria-expanded",
            "true"
        );

        const first =
            focusableElements(dom.mobileNav)[0];

        first?.focus();
    }

    function closeMobileMenu({ restoreFocus = false } = {}) {
        if (!dom.mobileNav) {
            return;
        }

        state.ui.mobileMenuOpen = false;

        dom.mobileNav.classList.remove("active");
        dom.mobileNav.setAttribute(
            "aria-hidden",
            "true"
        );

        dom.mobileNav.inert = true;

        dom.mobileMenuButton?.setAttribute(
            "aria-expanded",
            "false"
        );

        if (restoreFocus) {
            dom.mobileMenuButton?.focus();
        }
    }

    function initMobileMenu() {
        dom.mobileMenuButton?.addEventListener(
            "click",
            () => {
                if (state.ui.mobileMenuOpen) {
                    closeMobileMenu({
                        restoreFocus: true
                    });
                } else {
                    openMobileMenu();
                }
            }
        );

        dom.mobileNav?.addEventListener(
            "click",
            (event) => {
                if (event.target.closest("a")) {
                    closeMobileMenu();
                }
            }
        );

        document.addEventListener(
            "pointerdown",
            (event) => {
                if (
                    !state.ui.mobileMenuOpen ||
                    dom.mobileNav?.contains(
                        event.target
                    ) ||
                    dom.mobileMenuButton?.contains(
                        event.target
                    )
                ) {
                    return;
                }

                closeMobileMenu();
            }
        );
    }

    function updateTransmissionDisclosure() {
        if (
            !dom.heroTransmissionPanel ||
            !dom.transmissionToggle
        ) {
            return;
        }

        const expanded =
            dom.heroTransmissionPanel.classList.contains(
                "is-expanded"
            );

        dom.transmissionToggle.setAttribute(
            "aria-expanded",
            expanded ? "true" : "false"
        );

        dom.transmissionToggle.textContent =
            expanded
                ? translation("transmission.less", "LESS")
                : translation("transmission.more", "MORE");

        dom.transmissionToggle.setAttribute(
            "aria-label",
            expanded
                ? "Collapse Harrow transmission"
                : "Expand Harrow transmission"
        );
    }

    function initTransmissionDisclosure() {
        dom.transmissionToggle?.addEventListener(
            "click",
            () => {
                dom.heroTransmissionPanel?.classList.toggle(
                    "is-expanded"
                );

                updateTransmissionDisclosure();
            }
        );

        updateTransmissionDisclosure();
    }

    function updateTickerControl() {
        if (!dom.tickerToggle) {
            return;
        }

        const reduced =
            motionShouldBeReduced();

        dom.tickerToggle.hidden =
            reduced;

        dom.tickerToggle.setAttribute(
            "aria-pressed",
            state.ui.tickerPaused
                ? "true"
                : "false"
        );

        dom.tickerToggle.textContent =
            state.ui.tickerPaused
                ? translation("motion.resume", "RESUME")
                : translation("motion.pause", "PAUSE");

        dom.tickerToggle.closest(
            ".obsession-strip"
        )?.classList.toggle(
            "is-paused",
            state.ui.tickerPaused
        );
    }

    function initTickerControl() {
        dom.tickerToggle?.addEventListener(
            "click",
            () => {
                state.ui.tickerPaused =
                    !state.ui.tickerPaused;

                updateTickerControl();

                announceStatus(
                    state.ui.tickerPaused
                        ? "Moving thought ticker paused."
                        : "Moving thought ticker resumed."
                );
            }
        );

        updateTickerControl();
    }

    function initArtViewportControls() {
        const viewports = [
            dom.heroSceneViewport,
            dom.obsessionWallViewport,
            dom.pressMachineViewport
        ].filter(Boolean);

        viewports.forEach((viewport) => {
            viewport.addEventListener(
                "keydown",
                (event) => {
                    const step =
                        Math.max(
                            80,
                            viewport.clientWidth * 0.42
                        );

                    if (event.key === "ArrowLeft") {
                        event.preventDefault();
                        viewport.scrollBy({
                            left: -step,
                            behavior: motionShouldBeReduced()
                                ? "auto"
                                : "smooth"
                        });
                    }

                    if (event.key === "ArrowRight") {
                        event.preventDefault();
                        viewport.scrollBy({
                            left: step,
                            behavior: motionShouldBeReduced()
                                ? "auto"
                                : "smooth"
                        });
                    }

                    if (event.key === "Home") {
                        event.preventDefault();
                        viewport.scrollTo({
                            left: 0,
                            behavior: motionShouldBeReduced()
                                ? "auto"
                                : "smooth"
                        });
                    }

                    if (event.key === "End") {
                        event.preventDefault();
                        viewport.scrollTo({
                            left:
                                viewport.scrollWidth,
                            behavior: motionShouldBeReduced()
                                ? "auto"
                                : "smooth"
                        });
                    }
                }
            );

            let dragging = false;
            let startX = 0;
            let startScroll = 0;

            viewport.addEventListener(
                "pointerdown",
                (event) => {
                    if (
                        event.pointerType !== "mouse" ||
                        event.target.closest(
                            "button, a, select, input"
                        )
                    ) {
                        return;
                    }

                    dragging = true;
                    startX = event.clientX;
                    startScroll = viewport.scrollLeft;
                    viewport.classList.add("is-dragging");
                    viewport.setPointerCapture(
                        event.pointerId
                    );
                }
            );

            viewport.addEventListener(
                "pointermove",
                (event) => {
                    if (!dragging) {
                        return;
                    }

                    viewport.scrollLeft =
                        startScroll -
                        (event.clientX - startX);
                }
            );

            const endDrag = (event) => {
                if (!dragging) {
                    return;
                }

                dragging = false;
                viewport.classList.remove(
                    "is-dragging"
                );

                try {
                    viewport.releasePointerCapture(
                        event.pointerId
                    );
                } catch (error) {
                    // Pointer capture may already be released.
                }
            };

            viewport.addEventListener(
                "pointerup",
                endDrag
            );

            viewport.addEventListener(
                "pointercancel",
                endDrag
            );
        });
    }

    function initMobileHeaderBehavior() {
        const mobile =
            window.matchMedia(
                "(max-width: 760px)"
            );

        const header =
            $(".site-header");

        if (!header) {
            return;
        }

        state.ui.lastScrollY =
            window.scrollY;

        window.addEventListener(
            "scroll",
            () => {
                if (!mobile.matches) {
                    header.classList.remove(
                        "header-hidden"
                    );
                    document.body.classList.remove(
                        "header-hidden-state",
                        "mobile-scrolling"
                    );
                    return;
                }

                const current =
                    Math.max(0, window.scrollY);

                const delta =
                    current -
                    state.ui.lastScrollY;

                const blocked =
                    document.body.classList.contains(
                        "drawer-open"
                    ) ||
                    document.body.classList.contains(
                        "reader-open"
                    ) ||
                    document.body.classList.contains(
                        "access-panel-open"
                    ) ||
                    state.ui.mobileMenuOpen;

                if (!blocked && current > 120) {
                    if (delta > 7) {
                        header.classList.add(
                            "header-hidden"
                        );
                        document.body.classList.add(
                            "header-hidden-state"
                        );
                    } else if (delta < -5) {
                        header.classList.remove(
                            "header-hidden"
                        );
                        document.body.classList.remove(
                            "header-hidden-state"
                        );
                    }
                } else {
                    header.classList.remove(
                        "header-hidden"
                    );
                    document.body.classList.remove(
                        "header-hidden-state"
                    );
                }

                document.body.classList.add(
                    "mobile-scrolling"
                );

                window.clearTimeout(
                    state.ui.mobileScrollTimer
                );

                state.ui.mobileScrollTimer =
                    window.setTimeout(() => {
                        document.body.classList.remove(
                            "mobile-scrolling"
                        );
                    }, 180);

                state.ui.lastScrollY =
                    current;
            },
            {
                passive: true
            }
        );
    }

    function initSectionNavigationState() {
        if (!("IntersectionObserver" in window)) {
            return;
        }

        const links = $$([
            '.header-nav a[href^="#"]',
            '.mobile-nav a[href^="#"]'
        ].join(","));

        const byTarget = new Map();

        links.forEach((link) => {
            const target =
                link.getAttribute("href");

            if (!byTarget.has(target)) {
                byTarget.set(target, []);
            }

            byTarget.get(target).push(link);
        });

        const observer = new IntersectionObserver(
            (entries) => {
                const visible = entries
                    .filter((entry) => entry.isIntersecting)
                    .sort(
                        (a, b) =>
                            b.intersectionRatio -
                            a.intersectionRatio
                    )[0];

                if (!visible) {
                    return;
                }

                const hash =
                    `#${visible.target.id}`;

                links.forEach((link) => {
                    link.removeAttribute(
                        "aria-current"
                    );
                });

                (byTarget.get(hash) || [])
                    .forEach((link) => {
                        link.setAttribute(
                            "aria-current",
                            "true"
                        );
                    });
            },
            {
                rootMargin: "-25% 0px -60% 0px",
                threshold: [0.05, 0.25, 0.5]
            }
        );

        [
            "archive",
            "evidence",
            "press",
            "harrow",
            "signals"
        ].forEach((id) => {
            const section =
                document.getElementById(id);

            if (section) {
                observer.observe(section);
            }
        });
    }


    /* =========================================================
       GENERAL HARROW INTERACTIONS
       ========================================================= */

    function initHarrowInteractions() {
        if (dom.harrowOrb) {
            dom.harrowOrb.addEventListener(
                "click",
                () => {
                    recordInteraction();

                    const stage =
                        currentRelationshipStage();

                    const pool =
                        DIALOGUE.orb[stage] ||
                        DIALOGUE.orb.visitor;

                    discover(
                        "harrow:orb"
                    );

                    showDialogue(pool);
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
                    recordInteraction();

                    clicks +=
                        1;

                    discover(
                        "logo:hellbox"
                    );

                    if (clicks === 1) {
                        whisper(
                            isHellion()
                                ? "Still checking whether I changed the logo?"
                                : "Yes. I like the logo too."
                        );

                        return;
                    }

                    if (clicks === 2) {
                        whisper(
                            "Touch it again. See what happens."
                        );

                        return;
                    }

                    document.body.classList.add(
                        "logo-disobedience"
                    );

                    showHarrowResponse(
                        "CONGRATULATIONS.",
                        "You successfully annoyed the branding.",
                        {
                            importance: "important"
                        }
                    );

                    await sleep(1100);

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
                    recordInteraction();

                    discover(
                        "note:therapy"
                    );

                    showHarrowResponse(
                        "MEDICAL OPINION.",
                        "My credentials are between me and whatever institution forgot to revoke them."
                    );
                }
            );
        }

        if (dom.archiveSticky) {
            dom.archiveSticky.addEventListener(
                "click",
                () => {
                    recordInteraction();

                    discover(
                        "note:archive"
                    );

                    showHarrowResponse(
                        "I LEFT YOU A NOTE.",
                        isHellion()
                            ? "You know where I keep them now."
                            : "Do you know how exhausting personalization is?"
                    );
                }
            );
        }

        if (dom.archiveEmblem) {
            dom.archiveEmblem.addEventListener(
                "click",
                () => {
                    recordInteraction();

                    discover(
                        "archive:emblem"
                    );

                    whisper(
                        isHellion()
                            ? "The box knows you."
                            : "The box remembers what belongs to you."
                    );
                }
            );
        }

        if (dom.harrowPortrait) {
            dom.harrowPortrait.addEventListener(
                "click",
                () => {
                    recordInteraction();

                    discover(
                        "harrow:portrait"
                    );

                    showDialogue(
                        DIALOGUE.harrowVanity
                    );
                }
            );
        }

        if (dom.harrowProfileCard) {
            dom.harrowProfileCard.addEventListener(
                "click",
                () => {
                    recordInteraction();

                    discover(
                        "harrow:profile"
                    );

                    showDialogue(
                        DIALOGUE.harrowVanity
                    );
                }
            );
        }

        if (dom.harrowWordmark) {
            dom.harrowWordmark.addEventListener(
                "click",
                () => {
                    recordInteraction();

                    discover(
                        "harrow:wordmark"
                    );

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
                    recordInteraction();

                    discover(
                        "harrow:review"
                    );

                    showHarrowResponse(
                        "UNBIASED.",
                        "I personally verified the reviewer had excellent taste."
                    );
                }
            );
        }

        if (dom.lockedSignal) {
            dom.lockedSignal.addEventListener(
                "click",
                () => {
                    recordInteraction();

                    discover(
                        "signal:locked"
                    );

                    showDialogue(
                        isHellion()
                            ? DIALOGUE.classified.hellion
                            : DIALOGUE.classified.visitor
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
            code:
                "SYSTEM // FUEL",

            eyebrow:
                "HARROW // CLASSIFIED",

            title:
                "WRONG DRAWER.",

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
            code:
                "SYSTEM // RELAY",

            eyebrow:
                "HARROW // SECONDARY PATH",

            title:
                "NOT CONNECTED.",

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
            code:
                "SYSTEM // INPUT",

            eyebrow:
                "HARROW // HARDWARE",

            title:
                "NO INPUT.",

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
        $$(
            "[data-classified-object]"
        ).forEach((button) => {
            button.addEventListener(
                "click",
                () => {
                    recordInteraction();

                    const key =
                        button.dataset.classifiedObject;

                    const content =
                        CLASSIFIED_OBJECTS[key];

                    if (!content) {
                        return;
                    }

                    discover(
                        `classified:${key}`
                    );

                    showDialogue(
                        isHellion()
                            ? DIALOGUE.classified.hellion
                            : DIALOGUE.classified.visitor
                    );

                    openDrawer(content);
                }
            );
        });

        if (dom.classifiedMainObject) {
            dom.classifiedMainObject.addEventListener(
                "click",
                () => {
                    recordInteraction();

                    discover(
                        "classified:main"
                    );

                    showDialogue(
                        isHellion()
                            ? DIALOGUE.classified.hellion
                            : DIALOGUE.classified.visitor,
                        {
                            importance:
                                state.relationship.interactions %
                                4 ===
                                0
                                    ? "important"
                                    : "normal"
                        }
                    );
                }
            );
        }
    }


    /* =========================================================
       PROJECT / WORLD OBJECTS
       These answer the questions the front door should answer
       without turning Hellbox into a corporate explainer page.
       ========================================================= */

    function initProjectObjects() {
if (dom.readerDormantObject) {
            dom.readerDormantObject.addEventListener(
                "click",
                () => {
                    discover(
                        "object:reader"
                    );

                    openDrawer({
                        code:
                            "SYSTEM // READER",

                        eyebrow:
                            "HARROW // THE PART THAT MATTERS",

                        title:
                            "THE READER.",

                        html: `
                            <p>
                                This is the part people forget
                                when they get excited about tokens.
                            </p>

                            <p>
                                The collectible is the key.
                                The comic is the reason.
                            </p>

                            <p>
                                When a publication is live,
                                the Box checks the wallet,
                                verifies access,
                                and opens the protected pages here.
                            </p>

                            <p>
                                No PDF dump.
                                No generic storefront.
                                You read it inside the Box.
                            </p>
                        `,

                        footnote:
                            state.publications.length > 0
                                ? "READER // READY WHEN THE RIGHT KEY ARRIVES."
                                : "READER // BUILT. WAITING FOR A PUBLIC RELEASE."
                    });
                }
            );
        }

        if (dom.bytesInfrastructureObject) {
            dom.bytesInfrastructureObject.addEventListener(
                "click",
                () => {
                    discover(
                        "infrastructure:bytes",
                        "Yes. Even the plumbing has lore."
                    );

                    openDrawer({
                        code:
                            "INFRASTRUCTURE // BYTES",

                        eyebrow:
                            "HARROW // PRIVATE PLUMBING",

                        title:
                            "BACKED BY BYTES.",

                        html: `
                            <p>
                                Harrow dislikes dependencies.
                                Public RPCs count.
                            </p>

                            <p>
                                Hellbox uses Pulse Bytes infrastructure
                                as part of its private PulseChain plumbing.
                            </p>

                            <p>
                                The point is not to make infrastructure
                                the main character.
                                The point is to make sure the main character
                                still has a stage.
                            </p>
                        `,

                        footnote:
                            "CHAIN // 369 // INFRASTRUCTURE SHOULD BE BORING UNTIL IT BREAKS."
                    });
                }
            );
        }
    }


    /* =========================================================
       PRESS ART OBJECTS
       The machine artwork carries the explanation.
       ========================================================= */

    const PRESS_OBJECT_CONTENT = {
        chain: {
            code:
                "PRESS // CHAIN 369",

            eyebrow:
                "HARROW // PULSECHAIN",

            title:
                "THE MACHINE HAS A HOME.",

            html: `
                <p>
                    PulseChain.
                    Chain ID 369.
                </p>

                <p>
                    Cheap enough to publish without asking permission
                    from the gas meter.
                </p>

                <p>
                    Fast enough that Harrow can make another bad decision
                    before the first one cools down.
                </p>
            `,

            footnote:
                "PRESS NETWORK // PULSECHAIN // 369."
        },

        qc: {
            code:
                "PRESS // QC",

            eyebrow:
                "HARROW // QUALITY CONTROL",

            title:
                "INDEPENDENT REVIEW.",

            html: `
                <p>
                    Every publication passes through a rigorous
                    independent quality-control department.
                </p>

                <p>
                    Harrow runs it.
                </p>

                <p>
                    The artist also happens to be Harrow.
                    Management has reviewed the conflict
                    and found Harrow blameless.
                </p>
            `,

            footnote:
                "QC // APPROVED BY THE PERSON WHO MADE IT."
        },

        output: {
            code:
                "PRESS // OUTPUT BAY",

            eyebrow:
                "HARROW // PUBLICATION",

            title:
                "THIS IS WHAT COMES OUT.",

            html: `
                <p>
                    Pages become a publication.
                </p>

                <p>
                    A publication becomes an edition.
                    The edition becomes the key the Reader can recognize.
                </p>

                <p>
                    The first real public release will occupy this bay
                    when Harrow decides it is finished.
                </p>

                <p>
                    So never.
                    Or soon.
                    Same thing around here.
                </p>
            `,

            footnote:
                "OUTPUT BAY // CURRENTLY WAITING FOR SOMETHING WORTH PUBLISHING."
        }
    };

    function initPressArtObjects() {
        $$("[data-press-object]").forEach(
            (button) => {
                button.addEventListener(
                    "click",
                    (event) => {
                        event.stopPropagation();

                        const key =
                            button.dataset.pressObject;

                        const content =
                            PRESS_OBJECT_CONTENT[key];

                        if (!content) {
                            return;
                        }

                        discover(
                            `press:${key}`,
                            isHellion()
                                ? "Still inspecting the machine?"
                                : "The machine has more going on than the lever."
                        );

                        openDrawer(
                            content
                        );
                    }
                );
            }
        );
    }


    /* =========================================================
       ROADMAP / MANUAL OBJECTS
       ========================================================= */

    function openRoadmapObject() {
        discover(
            "object:roadmap",
            isHellion()
                ? "You already know I hate calling this a roadmap."
                : "Fine. Here's the part you're allowed to see."
        );

        openDrawer({
            code:
                "OBJECT // WHAT NEXT",

            eyebrow:
                "HARROW // CURRENT OBSESSIONS",

            title:
                "THE PLAN*",

            html: `
                <p>
                    I hate roadmaps.
                    They make unfinished ideas look like appointments.
                </p>

                <div class="roadmap-object">

                    <div>
                        <span>NOW</span>

                        <strong>
                            BUILD THE BOX.
                        </strong>

                        <p>
                            Publishing system.
                            Archive.
                            Wallet identity.
                            The Press.
                            Reader.
                            Make the place feel alive.
                        </p>
                    </div>

                    <div>
                        <span>NEXT</span>

                        <strong>
                            MAKE THE COMICS HIT HARDER.
                        </strong>

                        <p>
                            The reader becomes part theater,
                            part comic engine,
                            part terrible decision.
                        </p>
                    </div>

                    <div>
                        <span>AFTER THAT</span>

                        <strong>
                            PUT THINGS ONCHAIN.
                        </strong>

                        <p>
                            Native collectible editions.
                            Ownership-gated reading.
                            Supply that means something.
                        </p>
                    </div>

                    <div>
                        <span>LATER</span>

                        <strong>
                            THE PART I'M NOT SHOWING YOU.
                        </strong>

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

    function openManualObject() {
        discover(
            "object:manual",
            "I call it a manual because whitepaper sounds like homework."
        );

        openDrawer({
            code:
                "OBJECT // MANUAL",

            eyebrow:
                "HARROW // HOW THE BOX WORKS",

            title:
                "THE MANUAL.",

            html: `
                <p>
                    This is where the serious questions eventually get answers
                    without forcing the rest of Hellbox to dress like a startup.
                </p>

                <div class="roadmap-object">

                    <div>
                        <span>PUBLICATIONS</span>

                        <strong>
                            THE THING YOU ACTUALLY WANT.
                        </strong>

                        <p>
                            Comics and graphic novels exist as publications
                            inside Hellbox.
                        </p>
                    </div>

                    <div>
                        <span>OWNERSHIP</span>

                        <strong>
                            YOUR WALLET IS THE RECEIPT.
                        </strong>

                        <p>
                            The box recognizes onchain artifacts associated
                            with an address.
                        </p>
                    </div>

                    <div>
                        <span>THE PRESS</span>

                        <strong>
                            THIS MAKES THEM.
                        </strong>

                        <p>
                            Minting belongs inside the machine,
                            not inside a generic ecommerce widget
                            wearing a crypto costume.
                        </p>
                    </div>

                    <div>
                        <span>THE READER</span>

                        <strong>
                            THIS IS WHY ANY OF IT MATTERS.
                        </strong>

                        <p>
                            Ownership gets you into the work.
                            The reading experience does the rest.
                        </p>
                    </div>

                </div>

                <p>
                    Economics, mechanics and deeper documentation
                    belong inside objects like this.

                    They do not get to hijack the front door.
                </p>
            `,

            footnote:
                "DOCUMENT STATUS // HARROW STILL HATES DOCUMENTATION."
        });
    }


    /* =========================================================
       PRESS MACHINE
       ========================================================= */

    function readStoredPressTouches() {
        if (!storageAvailable("sessionStorage")) {
            state.press.touchCount =
                0;

            return;
        }

        try {
            state.press.touchCount =
                safeNumber(
                    window.sessionStorage.getItem(
                        STORAGE_KEYS.pressTouches
                    ),
                    0
                );

        } catch (error) {
            state.press.touchCount =
                0;
        }
    }

    function storePressTouches() {
        if (!storageAvailable("sessionStorage")) {
            return;
        }

        try {
            window.sessionStorage.setItem(
                STORAGE_KEYS.pressTouches,
                String(
                    state.press.touchCount
                )
            );

        } catch (error) {
            // Non-critical.
        }
    }

    function pressDialoguePool() {
        if (isHellion()) {
            return DIALOGUE.pressTouch.hellion;
        }

        if (isFamiliar()) {
            return DIALOGUE.pressTouch.familiar;
        }

        return DIALOGUE.pressTouch.visitor;
    }

    function setPressRail(activeState) {
        $$(".press-state").forEach(
            (item) => {
                item.classList.toggle(
                    "active",
                    item.dataset.state ===
                        activeState
                );
            }
        );
    }

    function setPressState(nextState) {
        state.press.state =
            nextState;

        if (!dom.pressSection) {
            return;
        }

        dom.pressSection.classList.remove(
            "machine-awake",
            "machine-alert",
            "machine-pulling"
        );

        let miniStatus =
            "IDLE";

        let machineState =
            "ASLEEP";

        let consoleLabel =
            "STATUS";

        let consoleTitle =
            "DON'T TOUCH IT.";

        let consoleText =
            "I mean it.";

        let power =
            "00";

        let ink =
            "??";

        switch (nextState) {
            case "awake":
                dom.pressSection.classList.add(
                    "machine-awake"
                );

                miniStatus =
                    "AWAKE";

                machineState =
                    "AWAKE";

                consoleLabel =
                    "HARROW // YOU DID THIS";

                consoleTitle =
                    "NOW IT'S AWAKE.";

                consoleText =
                    "Try pretending this wasn't exactly what you wanted.";

                power =
                    "37";

                ink =
                    "??";

                break;

            case "wallet":
                dom.pressSection.classList.add(
                    "machine-awake"
                );

                miniStatus =
                    "IDENTIFY";

                machineState =
                    "WAITING";

                consoleLabel =
                    "IDENTIFICATION";

                consoleTitle =
                    "SHOW ME THE WALLET.";

                consoleText =
                    "Chaos still requires an address.";

                power =
                    "62";

                ink =
                    "??";

                break;

            case "ready":
                dom.pressSection.classList.add(
                    "machine-awake"
                );

                miniStatus =
                    "READY";

                machineState =
                    "READY";

                consoleLabel =
                    "PRESS // READY";

                consoleTitle =
                    isHellion()
                        ? "YOU KNOW WHAT THIS DOES."
                        : "DON'T GET EXCITED.";

                consoleText =
                    isHellion()
                        ? "No public release loaded. You're going to pull it anyway."
                        : "The machine is ready. The publication isn't.";

                power =
                    "91";

                ink =
                    "OK";

                break;

            case "pressing":
                dom.pressSection.classList.add(
                    "machine-awake",
                    "machine-pulling",
                    "machine-alert"
                );

                miniStatus =
                    "WORKING";

                machineState =
                    "WORKING";

                consoleLabel =
                    "PRESS // ACTIVE";

                consoleTitle =
                    "SEE WHAT YOU DID?";

                consoleText =
                    "Now the machine thinks it has a job.";

                power =
                    "99";

                ink =
                    "RUN";

                break;

            case "confirmed":
                dom.pressSection.classList.add(
                    "machine-awake"
                );

                miniStatus =
                    "YOURS";

                machineState =
                    "DONE";

                consoleLabel =
                    "PRESS // COMPLETE";

                consoleTitle =
                    "THERE. HAPPY?";

                consoleText =
                    "Reserved for an actual confirmed mint.";

                power =
                    "44";

                ink =
                    "OK";

                break;

            case "error":
                dom.pressSection.classList.add(
                    "machine-awake",
                    "machine-alert"
                );

                miniStatus =
                    "NO";

                machineState =
                    "NO";

                consoleLabel =
                    "HARROW // NO";

                consoleTitle =
                    "THERE'S NOTHING TO MINT.";

                consoleText =
                    "Stop trying to brute-force unfinished art.";

                power =
                    "13";

                ink =
                    "--";

                break;

            case "idle":
            default:
                break;
        }

        if (dom.pressMiniStatus) {
            dom.pressMiniStatus.textContent =
                miniStatus;
        }

        if (dom.pressMachineState) {
            dom.pressMachineState.textContent =
                machineState;
        }

        if (dom.pressConsoleLabel) {
            dom.pressConsoleLabel.textContent =
                consoleLabel;
        }

        if (dom.pressConsoleTitle) {
            dom.pressConsoleTitle.textContent =
                consoleTitle;
        }

        if (dom.pressConsoleText) {
            dom.pressConsoleText.textContent =
                consoleText;
        }

        if (dom.pressPowerValue) {
            dom.pressPowerValue.textContent =
                power;
        }

        if (dom.pressInkValue) {
            dom.pressInkValue.textContent =
                ink;
        }

        if (dom.pressRpcValue) {
            dom.pressRpcValue.textContent =
                "369";
        }

        setPressRail(
            nextState === "awake"
                ? "idle"
                : nextState
        );

        updateDiagnostics();
    }

    function wakePress() {
        recordInteraction(
            1,
            {
                press: true
            }
        );

        state.press.touchCount +=
            1;

        storePressTouches();

        if (!state.press.awake) {
            state.press.awake =
                true;

            setPressState(
                "awake"
            );

            discover(
                "press:wake",
                "You woke it up."
            );
        }

        showDialogue(
            pressDialoguePool()
        );
    }

    async function pullPressLever() {
        recordInteraction(
            1,
            {
                press: true
            }
        );

        if (dom.pressLever) {
            dom.pressLever.classList.add(
                "pulled"
            );

            window.setTimeout(() => {
                dom.pressLever?.classList.remove(
                    "pulled"
                );
            }, 620);
        }

        state.press.leverPulls +=
            1;

        if (state.press.busy) {
            showHarrowResponse(
                "WAIT.",
                state.press.leverPulls % 2 === 0
                    ? "You press elevator buttons repeatedly too, don't you?"
                    : "It's already doing the thing. Have some dignity."
            );

            return;
        }

        state.press.busy =
            true;

        if (!state.press.awake) {
            state.press.awake =
                true;

            setPressState(
                "awake"
            );

            await sleep(500);
        }

        if (!state.wallet.connected) {
            setPressState(
                "wallet"
            );

            showDialogue(
                DIALOGUE.pressLever.noWallet,
                {
                    importance:
                        "important"
                }
            );

            state.press.busy =
                false;

            updateDiagnostics();

            return;
        }

        setPressState(
            "ready"
        );

        await sleep(450);

        setPressState(
            "pressing"
        );

        whisper(
            state.press.leverPulls > 2
                ? "You know this is still empty."
                : "This would be the dramatic part."
        );

        await sleep(1450);

        /*
         * IMPORTANT:
         *
         * There is intentionally NO fake transaction here.
         *
         * Real mint flow plugs into this location after:
         * - publication is public
         * - contract is deployed
         * - backend can prepare a verified transaction
         */

        setPressState(
            "error"
        );

        showDialogue(
            DIALOGUE.pressLever.empty,
            {
                importance:
                    "important"
            }
        );

        await sleep(2600);

        setPressState(
            state.wallet.connected
                ? "ready"
                : "wallet"
        );

        state.press.busy =
            false;

        updateDiagnostics();
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

        setPressState(
            state.wallet.connected
                ? "ready"
                : "wallet"
        );
    }

    function updatePressPublication() {
        const publication =
            state.publications[0] ||
            null;

        if (
            !dom.pressPublication ||
            !dom.pressSupply
        ) {
            return;
        }

        if (!publication) {
            dom.pressPublication.textContent =
                "NONE";

            dom.pressSupply.textContent =
                "-- / --";

            return;
        }

        dom.pressPublication.textContent =
            safeText(
                publication.title,
                safeText(
                    publication.publicationKey,
                    "UNKNOWN"
                )
            );

        const minted =
            publication.minted ??
            publication.mintedSupply ??
            null;

        const maxSupply =
            publication.maxSupply ??
            publication.supply ??
            null;

        if (
            minted !== null &&
            maxSupply !== null
        ) {
            dom.pressSupply.textContent =
                `${minted} / ${maxSupply}`;

        } else if (
            maxSupply !== null
        ) {
            dom.pressSupply.textContent =
                `-- / ${maxSupply}`;

        } else {
            dom.pressSupply.textContent =
                "-- / --";
        }
    }

    function initPress() {
        readStoredPressTouches();

        setPressState(
            "idle"
        );

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
        return (
            typeof window.ethereum !==
            "undefined"
        )
            ? window.ethereum
            : null;
    }

    async function readWalletState() {
        const provider =
            getEthereumProvider();

        state.wallet.provider =
            provider;

        if (!provider) {
            renderWalletState();
            return;
        }

        try {
            const accounts =
                await provider.request({
                    method:
                        "eth_accounts"
                });

            const chainId =
                await provider.request({
                    method:
                        "eth_chainId"
                });

            state.wallet.connected =
                Array.isArray(accounts) &&
                accounts.length > 0;

            state.wallet.address =
                state.wallet.connected
                    ? accounts[0]
                    : null;

            state.wallet.chainId =
                normalizeChainId(
                    chainId
                );

        } catch (error) {
            state.wallet.address =
                null;

            state.wallet.chainId =
                null;

            state.wallet.connected =
                false;
        }

        renderWalletState();
    }

    async function connectWallet() {
        const provider =
            getEthereumProvider();

        if (!provider) {
            showHarrowResponse(
                "NO WALLET.",
                "Install an EVM wallet first. I'm talented, not supernatural.",
                {
                    importance:
                        "important"
                }
            );

            return;
        }

        try {
            recordInteraction();

            if (dom.walletButton) {
                dom.walletButton.disabled =
                    true;

                dom.walletButton.textContent =
                    "LOOKING...";
            }

            const accounts =
                await provider.request({
                    method:
                        "eth_requestAccounts"
                });

            if (
                !Array.isArray(accounts) ||
                accounts.length === 0
            ) {
                throw new Error(
                    "No wallet account returned"
                );
            }

            const chainId =
                await provider.request({
                    method:
                        "eth_chainId"
                });

            state.wallet.provider =
                provider;

            state.wallet.address =
                accounts[0];

            state.wallet.chainId =
                normalizeChainId(
                    chainId
                );

            state.wallet.connected =
                true;

            renderWalletState();

            discover(
                "wallet:connected"
            );

            if (
                state.wallet.chainId !==
                PULSECHAIN.chainId
            ) {
                showDialogue(
                    DIALOGUE.wrongChain,
                    {
                        importance:
                            "important",

                        sticky:
                            true
                    }
                );

            } else {
                showDialogue(
                    isHellion()
                        ? DIALOGUE.walletConnected.hellion
                        : DIALOGUE.walletConnected.visitor,
                    {
                        importance:
                            "important"
                    }
                );
            }

            await loadPublications();

        } catch (error) {
            showHarrowResponse(
                "NEVER MIND.",
                "You either rejected it or your wallet decided today was its day to become performance art.",
                {
                    importance:
                        "important"
                }
            );

        } finally {
            if (dom.walletButton) {
                dom.walletButton.disabled =
                    false;
            }

            renderWalletState();
        }
    }

    function renderWalletState() {
        const connected =
            state.wallet.connected &&
            Boolean(
                state.wallet.address
            );

        const onPulseChain =
            state.wallet.chainId ===
            PULSECHAIN.chainId;

        if (dom.walletButton) {
            dom.walletButton.textContent =
                connected
                    ? truncateAddress(
                        state.wallet.address
                    )
                    : (
                        isHellion()
                            ? translation(
                                "wallet.showAgain",
                                "SHOW ME AGAIN"
                            )
                            : translation(
                                "wallet.show",
                                "SHOW ME"
                            )
                    );
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
                            ? (
                                isHellion()
                                    ? "HELLION"
                                    : "SEEN"
                            )
                            : "WRONG CHAIN"
                    )
                    : "WAITING";
        }

        if (dom.terminalAction) {
            dom.terminalAction.textContent =
                connected
                    ? "LOOK AGAIN"
                    : (
                        isHellion()
                            ? translation(
                                "wallet.showAgain",
                                "SHOW ME AGAIN"
                            )
                            : translation(
                                "wallet.show",
                                "SHOW ME"
                            )
                    );
        }

        if (!connected) {
            if (dom.terminalTitle) {
                dom.terminalTitle.textContent =
                    isHellion()
                        ? "YOU KNOW THE DRILL."
                        : "DON'T BE SHY.";
            }

            if (dom.terminalMessage) {
                dom.terminalMessage.textContent =
                    isHellion()
                        ? "Show me the wallet again."
                        : "Show me the wallet.";
            }

            if (dom.archiveHarrowNote) {
                dom.archiveHarrowNote.textContent =
                    isHellion()
                        ? "let's see what followed you home."
                        : "let's see the damage.";
            }
        }

        document.body.classList.toggle(
            "wrong-chain",
            connected &&
            !onPulseChain
        );

        updatePressFromWallet();
        updateDiagnostics();
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
                    recordInteraction();

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

        const provider =
            getEthereumProvider();

        if (
            provider &&
            typeof provider.on ===
                "function"
        ) {
            provider.on(
                "accountsChanged",
                async (accounts) => {
                    if (
                        !Array.isArray(accounts) ||
                        accounts.length === 0
                    ) {
                        state.wallet.address =
                            null;

                        state.wallet.connected =
                            false;

                        renderWalletState();
                        renderCollection();

                        return;
                    }

                    state.wallet.address =
                        accounts[0];

                    state.wallet.connected =
                        true;

                    renderWalletState();

                    await loadPublications();
                }
            );

            provider.on(
                "chainChanged",
                async (chainId) => {
                    state.wallet.chainId =
                        normalizeChainId(
                            chainId
                        );

                    renderWalletState();

                    if (
                        state.wallet.chainId !==
                        PULSECHAIN.chainId
                    ) {
                        showDialogue(
                            DIALOGUE.wrongChain,
                            {
                                importance:
                                    "important",

                                sticky:
                                    true
                            }
                        );
                    }

                    await loadPublications();
                }
            );
        }
    }


    /* =========================================================
       API
       ========================================================= */

    async function apiJson(
        url,
        options = {}
    ) {
        const response =
            await fetch(
                url,
                {
                    ...options,

                    headers: {
                        Accept:
                            "application/json",

                        ...(options.headers ||
                            {})
                    }
                }
            );

        let body =
            null;

        try {
            body =
                await response.json();

        } catch (error) {
            body =
                null;
        }

        if (!response.ok) {
            const message =
                body?.error ||
                body?.message ||
                `Request failed: ${response.status}`;

            const apiError =
                new Error(message);

            apiError.status =
                response.status;

            apiError.body =
                body;

            throw apiError;
        }

        return body;
    }

    function normalizePublicationList(
        payload
    ) {
        if (Array.isArray(payload)) {
            return payload;
        }

        if (
            Array.isArray(
                payload?.publications
            )
        ) {
            return payload.publications;
        }

        if (
            Array.isArray(
                payload?.items
            )
        ) {
            return payload.items;
        }

        if (
            Array.isArray(
                payload?.comics
            )
        ) {
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
            state.publications =
                [];

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

        updateDiagnostics();
    }


    /* =========================================================
       COLLECTION
       ========================================================= */

    function publicationIdentity(
        publication
    ) {
        return (
            publication.publicationKey ||
            publication.key ||
            publication.slug ||
            publication.id ||
            "unknown"
        );
    }

    function publicationTitle(
        publication
    ) {
        return (
            publication.title ||
            publication.name ||
            publicationIdentity(
                publication
            )
        );
    }

    function publicationLifecycle(
        publication
    ) {
        return (
            publication.lifecycle ||
            publication.status ||
            "circulating"
        );
    }

    function publicationReaderEnabled(
        publication
    ) {
        if (
            publication.reader === true ||
            publication.readerEnabled ===
                true
        ) {
            return true;
        }

        if (
            publication.reader &&
            typeof publication.reader ===
                "object"
        ) {
            return (
                publication.reader.enabled !==
                false
            );
        }

        return false;
    }

    function calculateCollectionSummary() {
        /*
         * Ownership remains deliberately conservative.
         * We do NOT infer ownership just because a wallet
         * is connected.
         */

        const known =
            state.publications.length;

        state.collection = {
            known,
            owned: 0,
            missing:
                state.wallet.connected
                    ? known
                    : 0,
            evolved: 0
        };
    }

    function renderCollection(
        options = {}
    ) {
        calculateCollectionSummary();

        const {
            error = false
        } = options;

        if (dom.summaryKnown) {
            dom.summaryKnown.textContent =
                String(
                    state.collection.known
                ).padStart(
                    2,
                    "0"
                );
        }

        if (dom.summaryOwned) {
            dom.summaryOwned.textContent =
                String(
                    state.collection.owned
                ).padStart(
                    2,
                    "0"
                );
        }

        if (dom.summaryMissing) {
            dom.summaryMissing.textContent =
                String(
                    state.collection.missing
                ).padStart(
                    2,
                    "0"
                );
        }

        if (dom.summaryEvolved) {
            dom.summaryEvolved.textContent =
                String(
                    state.collection.evolved
                ).padStart(
                    2,
                    "0"
                );
        }

        if (dom.publicationCount) {
            if (error) {
                dom.publicationCount.textContent =
                    "ARCHIVE UNAVAILABLE";

            } else if (
                state.publications.length ===
                0
            ) {
                dom.publicationCount.textContent =
                    "NOTHING PUBLIC YET";

            } else {
                dom.publicationCount.textContent =
                    `${state.publications.length} PUBLIC`;
            }
        }

        if (dom.readerDormantObject) {
            if (error) {
                dom.readerDormantObject.textContent =
                    "READER // OFFLINE";

            } else if (
                state.publications.length > 0
            ) {
                dom.readerDormantObject.textContent =
                    "READER // READY";

            } else {
                dom.readerDormantObject.textContent =
                    "READER // ASLEEP";
            }
        }

        if (!dom.collectionList) {
            return;
        }

        dom.collectionList.innerHTML =
            "";

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
                        ? (
                            isHellion()
                                ? "STILL NOTHING, HELLION."
                                : "NOTHING?"
                        )
                        : (
                            isHellion()
                                ? "YOU KNOW THE DRILL."
                                : "DON'T BE SHY."
                        );
            }

            if (dom.terminalMessage) {
                dom.terminalMessage.textContent =
                    state.wallet.connected
                        ? (
                            isHellion()
                                ? "You came back early again."
                                : "Huh. That's actually impressive."
                        )
                        : "Show me the wallet.";
            }

            if (dom.archiveHarrowNote) {
                dom.archiveHarrowNote.textContent =
                    state.wallet.connected
                        ? (
                            isHellion()
                                ? "patience. disgusting."
                                : "we'll fix this."
                        )
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
            (
                publication,
                index
            ) => {
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
                    document.createElement(
                        "div"
                    );

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

                        <span>
                            WALLET
                        </span>

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
                    recordInteraction();

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
                    URL.revokeObjectURL(
                        url
                    );

                } catch (error) {
                    // Ignore.
                }
            }
        );

        state.reader.objectUrls =
            [];
    }

    function showReaderLoading(
        message =
            "The machine is doing something expensive."
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

    function normalizeReaderPages(
        payload
    ) {
        if (
            Array.isArray(
                payload?.pages
            )
        ) {
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

        if (
            Array.isArray(
                payload?.reader?.manifest?.pages
            )
        ) {
            return payload.reader.manifest.pages;
        }

        return [];
    }

    function pageUrlFromEntry(page) {
        if (
            typeof page === "string"
        ) {
            return page;
        }

        if (
            !page ||
            typeof page !== "object"
        ) {
            return null;
        }

        return (
            page.url ||
            page.src ||
            page.assetUrl ||
            page.asset ||
            page.endpoint ||
            null
        );
    }

    async function openPublicationReader(
        publicationKey
    ) {
        if (!publicationKey) {
            return;
        }

        state.ui.lastFocusedElement =
            document.activeElement;

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
                ? publicationTitle(
                    publication
                )
                : publicationKey;

        state.reader.pageIndex =
            0;

        state.reader.pages =
            [];

        clearReaderObjectUrls();

        if (dom.readerTitle) {
            dom.readerTitle.textContent =
                state.reader.title;
        }

        if (dom.reader) {
            dom.reader.inert = false;

            dom.reader.classList.add(
                "active"
            );

            dom.reader.setAttribute(
                "aria-hidden",
                "false"
            );
        }

        document.body.classList.add(
            "reader-open"
        );

        state.reader.open =
            true;

        window.setTimeout(() => {
            dom.readerClose?.focus();
        }, 0);

        hideReaderError();

        showReaderLoading(
            isHellion()
                ? "Checking your key, Hellion."
                : "Checking whether the box is going to let you in."
        );

        try {
            const payload =
                await apiJson(
                    `/api/reader/${encodeURIComponent(publicationKey)}`
                );

            const pages =
                normalizeReaderPages(
                    payload
                )
                    .map(
                        pageUrlFromEntry
                    )
                    .filter(Boolean);

            if (
                pages.length === 0
            ) {
                throw new Error(
                    "The reader returned no pages."
                );
            }

            state.reader.pages =
                pages;

            renderReader();

            hideReaderLoading();

            discover(
                `reader:${publicationKey}`,
                isHellion()
                    ? "Back inside."
                    : "There. Now read it."
            );

        } catch (error) {
            const status =
                error?.status ||
                0;

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

        dom.reader.classList.remove(
            "active"
        );

        dom.reader.setAttribute(
            "aria-hidden",
            "true"
        );

        dom.reader.inert = true;

        document.body.classList.remove(
            "reader-open"
        );

        state.reader.open =
            false;

        clearReaderObjectUrls();
        hideReaderError();
        hideReaderLoading();

        updateDiagnostics();

        if (
            state.ui.lastFocusedElement &&
            typeof state.ui.lastFocusedElement.focus ===
                "function"
        ) {
            state.ui.lastFocusedElement.focus();
        }
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
            state.reader.pageIndex +
            1;

        if (dom.readerPageNumber) {
            dom.readerPageNumber.textContent =
                String(
                    humanPage
                ).padStart(
                    2,
                    "0"
                );
        }

        if (dom.readerPageCount) {
            dom.readerPageCount.textContent =
                String(
                    pageCount
                ).padStart(
                    2,
                    "0"
                );
        }

        if (dom.readerBottomLabel) {
            dom.readerBottomLabel.textContent =
                `${String(humanPage).padStart(2, "0")} / ${String(pageCount).padStart(2, "0")}`;
        }

        if (
            state.reader.mode ===
            "paged"
        ) {
            renderPagedReader();

        } else {
            renderContinuousReader();
        }

        updateDiagnostics();
    }

    function renderPagedReader() {
        if (
            !dom.readerPageImage ||
            state.reader.pages.length ===
                0
        ) {
            return;
        }

        const pageUrl =
            state.reader.pages[
                state.reader.pageIndex
            ];

        dom.readerPageImage.src =
            pageUrl;

        dom.readerPageImage.classList.toggle(
            "fit-page",
            state.reader.fit ===
                "page"
        );

        dom.readerPageImage.classList.toggle(
            "fit-width",
            state.reader.fit ===
                "width"
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

        dom.readerContinuous.innerHTML =
            "";

        state.reader.pages.forEach(
            (
                url,
                index
            ) => {
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
                    `PAGE ${String(index + 1).padStart(2, "0")}`;

                const image =
                    document.createElement(
                        "img"
                    );

                image.src =
                    url;

                image.alt =
                    `${state.reader.title} page ${
                        index + 1
                    }`;

                wrapper.appendChild(
                    label
                );

                wrapper.appendChild(
                    image
                );

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
        if (
            state.reader.pageIndex <=
            0
        ) {
            return;
        }

        state.reader.pageIndex -=
            1;

        renderReader();
    }

    function readerNext() {
        if (
            state.reader.pageIndex >=
            state.reader.pages.length -
                1
        ) {
            return;
        }

        state.reader.pageIndex +=
            1;

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
                    state.reader.pageIndex =
                        0;

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
                    state.reader.fit =
                        "page";

                    renderReader();
                }
            );
        }

        if (dom.readerFitWidth) {
            dom.readerFitWidth.addEventListener(
                "click",
                () => {
                    state.reader.fit =
                        "width";

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
    }


    /* =========================================================
       GLOBAL KEYBOARD
       ========================================================= */

    function initKeyboardControls() {
        document.addEventListener(
            "keydown",
            (event) => {
                /*
                 * PRIVATE TESTING SHORTCUT:
                 *
                 * Ctrl + Shift + H
                 *
                 * Opens our diagnostic panel.
                 * Nothing visible on normal site usage.
                 */

                if (
                    event.altKey &&
                    event.key.toLowerCase() ===
                        "a"
                ) {
                    event.preventDefault();

                    if (state.ui.accessPanelOpen) {
                        closeAccessPanel();
                    } else {
                        openAccessPanel();
                    }

                    return;
                }

                if (
                    event.ctrlKey &&
                    event.shiftKey &&
                    event.key.toLowerCase() ===
                        "h"
                ) {
                    event.preventDefault();

                    toggleDiagnostics();

                    return;
                }


                if (state.ui.accessPanelOpen) {
                    if (event.key === "Escape") {
                        closeAccessPanel();
                        return;
                    }

                    if (trapFocus(event, dom.accessPanel)) {
                        return;
                    }
                }

                if (state.ui.mobileMenuOpen) {
                    if (event.key === "Escape") {
                        closeMobileMenu({ restoreFocus: true });
                        return;
                    }

                    if (trapFocus(event, dom.mobileNav)) {
                        return;
                    }
                }

                if (
                    dom.drawer?.classList.contains(
                        "active"
                    )
                ) {
                    if (
                        event.key ===
                        "Escape"
                    ) {
                        closeDrawer();
                        return;
                    }

                    trapFocus(event, dom.drawer);

                    return;
                }

                if (
                    dom.harrowResponse?.classList.contains(
                        "active"
                    ) &&
                    event.key ===
                        "Escape"
                ) {
                    closeHarrowResponse();

                    return;
                }

                if (
                    !dom.reader?.classList.contains(
                        "active"
                    )
                ) {
                    return;
                }

                if (
                    event.key ===
                    "Escape"
                ) {
                    closeReader();

                    return;
                }

                if (trapFocus(event, dom.reader)) {
                    return;
                }

                if (
                    state.reader.mode !==
                    "paged"
                ) {
                    return;
                }

                if (
                    event.key ===
                    "ArrowLeft"
                ) {
                    readerPrevious();
                }

                if (
                    event.key ===
                    "ArrowRight"
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
            !(
                "IntersectionObserver"
                in window
            )
        ) {
            return;
        }

        const seenZones =
            new Set();

        const observer =
            new IntersectionObserver(
                (entries) => {
                    entries.forEach(
                        (entry) => {
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
                                seenZones.has(
                                    zone
                                )
                            ) {
                                return;
                            }

                            seenZones.add(
                                zone
                            );

                            switch (zone) {
                                case "box":
                                    whisper(
                                        isHellion()
                                            ? "You know where this starts."
                                            : "This is where the problem starts."
                                    );
                                    break;

                                case "archive":
                                    if (
                                        !state.wallet.connected
                                    ) {
                                        whisper(
                                            isHellion()
                                                ? "Show me the wallet again."
                                                : "Show me what you brought."
                                        );
                                    }
                                    break;

                                case "theory":
                                    whisper(
                                        isHellion()
                                            ? "You still think that's the whole board?"
                                            : "I can explain all of this. Probably."
                                    );
                                    break;

                                case "press":
                                    whisper(
                                        isHellion()
                                            ? "Don't touch it. Yes, I know."
                                            : "Don't touch the machine."
                                    );
                                    break;

                                case "harrow":
                                    whisper(
                                        isHellion()
                                            ? "Still the important section."
                                            : "Finally. The important section."
                                    );
                                    break;

                                case "classified":
                                    whisper(
                                        isHellion()
                                            ? "Hellions don't get clearance either."
                                            : "Keep scrolling. It still says no."
                                    );
                                    break;

                                case "exit":
                                    whisper(
                                        isHellion()
                                            ? "You'll be back."
                                            : "Good. Go do something irresponsible."
                                    );
                                    break;

                                default:
                                    break;
                            }
                        }
                    );
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
                observer.observe(
                    section
                );
            }
        );
    }


    /* =========================================================
       RETURN VISITOR GREETING
       ========================================================= */

    function greetVisitor() {
        if (
            state.relationship.visits <=
                1 &&
            currentRelationshipStage() ===
                "visitor"
        ) {
            window.setTimeout(
                () => {
                    whisper(
                        "Try not to make this weird."
                    );
                },
                2200
            );

            return;
        }

        let title =
            "YOU AGAIN.";

        let text =
            "This is becoming a habit.";

        if (isHellion()) {
            const options = [
                {
                    title:
                        "HELLION.",
                    text:
                        "There you are."
                },
                {
                    title:
                        "WELCOME BACK.",
                    text:
                        "Outside still disappointing?"
                },
                {
                    title:
                        "BACK AGAIN.",
                    text:
                        "Predictable. Useful. I approve."
                },
                {
                    title:
                        "YOU RETURNED.",
                    text:
                        "I assume this means everything else failed to hold your attention."
                }
            ];

            const choice =
                chooseDialogue(options);

            title =
                choice.title;

            text =
                choice.text;

        } else if (
            currentRelationshipStage() ===
            "familiar"
        ) {
            title =
                "THERE YOU ARE.";

            text =
                "I was wondering how long you'd pretend to have other things to do.";

        } else if (
            currentRelationshipStage() ===
            "noticed"
        ) {
            title =
                "BACK?";

            text =
                "Interesting.";
        }

        window.setTimeout(
            () => {
                showHarrowResponse(
                    title,
                    text,
                    {
                        importance:
                            "important"
                    }
                );
            },
            2200
        );
    }


    /* =========================================================
       PRIVATE DIAGNOSTIC MODE
       ========================================================= */

    function ensureDiagnosticPanel() {
        let panel =
            $("#hellboxDiagnosticPanel");

        if (panel) {
            return panel;
        }

        panel =
            document.createElement(
                "div"
            );

        panel.id =
            "hellboxDiagnosticPanel";

        panel.setAttribute(
            "aria-hidden",
            "true"
        );

        panel.style.position =
            "fixed";

        panel.style.right =
            "16px";

        panel.style.bottom =
            "16px";

        panel.style.zIndex =
            "999999";

        panel.style.width =
            "320px";

        panel.style.maxWidth =
            "calc(100vw - 32px)";

        panel.style.padding =
            "16px";

        panel.style.background =
            "rgba(5, 5, 6, 0.96)";

        panel.style.border =
            "1px solid rgba(255, 58, 32, 0.6)";

        panel.style.boxShadow =
            "0 0 40px rgba(0,0,0,0.8)";

        panel.style.fontFamily =
            "monospace";

        panel.style.fontSize =
            "12px";

        panel.style.lineHeight =
            "1.6";

        panel.style.color =
            "#f2efe8";

        panel.style.display =
            "none";

        panel.innerHTML = `
            <div style="
                display:flex;
                align-items:center;
                justify-content:space-between;
                gap:12px;
                margin-bottom:12px;
            ">
                <strong style="
                    color:#ff3b24;
                    letter-spacing:.1em;
                ">
                    HELLBOX // DIAGNOSTIC
                </strong>

                <button
                    type="button"
                    id="hellboxDiagnosticClose"
                    style="
                        background:none;
                        border:1px solid #444;
                        color:#fff;
                        cursor:pointer;
                        padding:4px 8px;
                    "
                >
                    X
                </button>
            </div>

            <pre
                id="hellboxDiagnosticBody"
                style="
                    margin:0;
                    white-space:pre-wrap;
                    word-break:break-word;
                "
            ></pre>

            <div style="
                margin-top:12px;
                opacity:.45;
            ">
                CTRL + SHIFT + H
            </div>
        `;

        document.body.appendChild(
            panel
        );

        $("#hellboxDiagnosticClose")
            ?.addEventListener(
                "click",
                () => {
                    toggleDiagnostics(
                        false
                    );
                }
            );

        return panel;
    }

    function toggleDiagnostics(
        force = null
    ) {
        const panel =
            ensureDiagnosticPanel();

        state.diagnostics.enabled =
            force === null
                ? !state.diagnostics.enabled
                : Boolean(force);

        panel.style.display =
            state.diagnostics.enabled
                ? "block"
                : "none";

        panel.setAttribute(
            "aria-hidden",
            state.diagnostics.enabled
                ? "false"
                : "true"
        );

        updateDiagnostics();
    }

    function updateDiagnostics() {
        if (
            !state.diagnostics.enabled
        ) {
            return;
        }

        const panel =
            ensureDiagnosticPanel();

        const body =
            $("#hellboxDiagnosticBody");

        if (!body) {
            return;
        }

        const score =
            calculateRelationshipScore();

        const data = {
            relationship: {
                stage:
                    currentRelationshipStage(),

                authority:
                    "LOCAL RECOGNITION PROTOTYPE",

                hellionEligible:
                    false,

                score,

                visits:
                    state.relationship.visits,

                interactions:
                    state.relationship.interactions,

                discoveriesEver:
                    state.relationship.discoveriesEver,

                pressTouches:
                    state.relationship.pressTouches
            },

            currentSession: {
                discoveries:
                    Array.from(
                        state.discoveries
                    )
            },

            wallet: {
                connected:
                    state.wallet.connected,

                address:
                    state.wallet.address
                        ? truncateAddress(
                            state.wallet.address
                        )
                        : null,

                chainId:
                    state.wallet.chainId,

                correctChain:
                    state.wallet.chainId ===
                    PULSECHAIN.chainId
            },

            archive: {
                publicPublications:
                    state.publications.length
            },

            press: {
                awake:
                    state.press.awake,

                state:
                    state.press.state,

                touchCount:
                    state.press.touchCount,

                leverPulls:
                    state.press.leverPulls,

                busy:
                    state.press.busy
            },

            reader: {
                open:
                    state.reader.open,

                publicationKey:
                    state.reader.publicationKey,

                page:
                    state.reader.pageIndex +
                    1,

                pages:
                    state.reader.pages.length
            }
        };

        body.textContent =
            JSON.stringify(
                data,
                null,
                2
            );

        panel.style.display =
            state.diagnostics.enabled
                ? "block"
                : "none";
    }


    /* =========================================================
       INITIALIZATION
       ========================================================= */

    async function init() {
        [
            dom.drawer,
            dom.harrowResponse,
            dom.reader,
            dom.accessPanel,
            dom.mobileNav
        ].filter(Boolean).forEach((element) => {
            element.inert =
                element.getAttribute("aria-hidden") ===
                "true";
        });

        loadRelationship();
        loadDiscoveries();
        loadDialogueHistory();

        registerVisit();

        updateRelationshipStage({
            announce: false
        });

        updateExitAfterthought();

        await loadUiLocale(
            preferredUiLocale()
        );

        initAccessibilityPanel();
        initMobileMenu();
        initTransmissionDisclosure();
        initTickerControl();
        initArtViewportControls();
        initMobileHeaderBehavior();
        initSectionNavigationState();

        initCursorBurn();
        initHeroTransmission();
        initResponsiveArtViews();

        initDrawerEvents();
        initKeyboardControls();

        initHotspots();
        initTheoryWall();
        initHarrowInteractions();
        initClassified();
        initProjectObjects();

        initPress();
        initPressArtObjects();
        initWalletEvents();
        initReaderControls();

        initScrollObservers();

        await readWalletState();
        await loadPublications();

        updatePressPublication();
        updateDiagnostics();

        greetVisitor();
    }


    /* =========================================================
       START
       ========================================================= */

    if (
        document.readyState ===
        "loading"
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

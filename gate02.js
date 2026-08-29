/**
 * HELLBOX COMICS — GATE 0.2 RUNTIME
 * Laptop polish, full-site localization, and multi-chain foundation.
 */
(() => {
    "use strict";

    const BUILD_ID = "20260828-gate0-2-01";
    const LOCALE_STORAGE_KEY = "hellbox:locale:v2";
    const SUPPORTED_LOCALES = Object.freeze(["en", "es", "pt-BR"]);
    const PUBLIC_LOCALE_NAMES = Object.freeze({
        en: "English",
        es: "Español",
        "pt-BR": "Português do Brasil"
    });

    const state = {
        locale: "en",
        pack: null,
        packs: new Map(),
        sourceByTextNode: new WeakMap(),
        renderedByTextNode: new WeakMap(),
        sourceByElementAttribute: new WeakMap(),
        localizationObserver: null,
        floatingObserver: null,
        scrollTimer: null,
        dragDepth: 0,
        activeChainKey:
            document.body?.dataset?.chainKey ||
            window.HellboxChains?.DEFAULT_CHAIN_KEY ||
            "pulsechain",
        serverChains: new Map(),
        reverseStrings: new Map()
    };

    const normalizeText = (value) => {
        return String(value ?? "")
            .replace(/\s+/g, " ")
            .trim();
    };

    const normalizeLocale = (value) => {
        const raw = String(value || "")
            .trim()
            .replace("_", "-");

        if (!raw) {
            return "en";
        }

        const lower = raw.toLowerCase();

        if (lower === "pt" || lower === "pt-br") {
            return "pt-BR";
        }

        if (lower.startsWith("es")) {
            return "es";
        }

        return SUPPORTED_LOCALES.includes(raw)
            ? raw
            : "en";
    };

    const localeFromUrl = () => {
        try {
            const url = new URL(window.location.href);
            return normalizeLocale(url.searchParams.get("lang"));
        } catch (error) {
            return "en";
        }
    };

    const localeFromStorage = () => {
        try {
            return normalizeLocale(
                window.localStorage.getItem(LOCALE_STORAGE_KEY)
            );
        } catch (error) {
            return "en";
        }
    };

    const preferredInitialLocale = () => {
        const urlLocale = localeFromUrl();

        if (
            new URL(window.location.href)
                .searchParams
                .has("lang")
        ) {
            return urlLocale;
        }

        const stored = localeFromStorage();

        if (stored !== "en") {
            return stored;
        }

        return normalizeLocale(
            navigator.languages?.[0] ||
            navigator.language ||
            "en"
        );
    };

    const escapeHtml = (value) => {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;");
    };

    async function loadPack(locale) {
        const normalized = normalizeLocale(locale);

        if (state.packs.has(normalized)) {
            return state.packs.get(normalized);
        }

        const response = await fetch(
            `/locales/${encodeURIComponent(normalized)}.json?v=${BUILD_ID}`,
            {
                credentials: "same-origin",
                cache: "no-cache"
            }
        );

        if (!response.ok) {
            throw new Error(
                `Locale ${normalized} could not be loaded.`
            );
        }

        const pack = await response.json();

        state.packs.set(normalized, pack);

        return pack;
    }

    function preserveWordCase(source, translated) {
        if (source.toUpperCase() === source) {
            return translated.toUpperCase();
        }

        if (
            source.charAt(0).toUpperCase() ===
            source.charAt(0)
        ) {
            return (
                translated.charAt(0).toUpperCase() +
                translated.slice(1)
            );
        }

        return translated;
    }

    function fallbackWordTranslation(source) {
        const wordMap =
            state.pack?.wordMap || {};

        if (
            !wordMap ||
            Object.keys(wordMap).length === 0
        ) {
            return source;
        }

        return String(source).replace(
            /[A-Za-z]+(?:'[A-Za-z]+)?/g,
            (word) => {
                const translated =
                    wordMap[word.toLowerCase()];

                return translated
                    ? preserveWordCase(
                        word,
                        translated
                    )
                    : word;
            }
        );
    }

    function exactTranslation(source) {
        const normalized = normalizeText(source);

        if (!normalized) {
            return source;
        }

        const exact =
            state.pack?.strings?.[normalized];

        return exact ?? fallbackWordTranslation(
            normalized
        );
    }

    function canonicalSource(value) {
        const normalized = normalizeText(value);

        return (
            state.reverseStrings.get(normalized) ||
            normalized
        );
    }

    function preserveWhitespace(original, translated) {
        const leading =
            String(original).match(/^\s*/)?.[0] || "";

        const trailing =
            String(original).match(/\s*$/)?.[0] || "";

        return `${leading}${translated}${trailing}`;
    }

    function shouldSkipNode(node) {
        const parent = node?.parentElement;

        if (!parent) {
            return true;
        }

        if (
            parent.closest(
                "script, style, code, pre, textarea, " +
                "[data-no-translate], [data-publication-content], " +
                ".reader-page, .reader-continuous, .reader-page-image"
            )
        ) {
            return true;
        }

        return false;
    }

    function translateTextNode(node) {
        if (
            !node ||
            node.nodeType !== Node.TEXT_NODE ||
            shouldSkipNode(node)
        ) {
            return;
        }

        const currentRaw = node.nodeValue || "";
        const current = normalizeText(currentRaw);

        if (!current || !/[A-Za-z]/.test(current)) {
            return;
        }

        const lastRendered =
            state.renderedByTextNode.get(node);

        let source =
            state.sourceByTextNode.get(node);

        /*
         * If the application has replaced the node with new English content,
         * update the canonical source. If it still contains our previous
         * translation, retain the original English source.
         */
        if (
            !source ||
            (
                lastRendered &&
                current !== lastRendered
            )
        ) {
            source = canonicalSource(current);
            state.sourceByTextNode.set(node, source);
        }

        const translated = exactTranslation(source);

        state.renderedByTextNode.set(
            node,
            normalizeText(translated)
        );

        const nextValue = preserveWhitespace(
            currentRaw,
            translated
        );

        if (node.nodeValue !== nextValue) {
            node.nodeValue = nextValue;
        }
    }

    const TRANSLATABLE_ATTRIBUTES = Object.freeze([
        "aria-label",
        "aria-description",
        "title",
        "placeholder",
        "alt",
        "data-empty-label"
    ]);

    function attributeSourceMap(element) {
        let map =
            state.sourceByElementAttribute.get(element);

        if (!map) {
            map = new Map();
            state.sourceByElementAttribute.set(
                element,
                map
            );
        }

        return map;
    }

    function translateElementAttributes(element) {
        if (
            !(element instanceof Element) ||
            element.matches(
                "[data-no-translate], [data-publication-content]"
            )
        ) {
            return;
        }

        const sourceMap =
            attributeSourceMap(element);

        for (const attribute of TRANSLATABLE_ATTRIBUTES) {
            if (!element.hasAttribute(attribute)) {
                continue;
            }

            const current =
                normalizeText(
                    element.getAttribute(attribute)
                );

            if (!current || !/[A-Za-z]/.test(current)) {
                continue;
            }

            if (!sourceMap.has(attribute)) {
                sourceMap.set(attribute, canonicalSource(current));
            }

            const source =
                sourceMap.get(attribute);

            const translated =
                exactTranslation(source);

            if (
                element.getAttribute(attribute) !==
                translated
            ) {
                element.setAttribute(
                    attribute,
                    translated
                );
            }
        }

        if (
            element instanceof HTMLInputElement &&
            ["button", "submit", "reset"].includes(
                element.type
            )
        ) {
            const current =
                normalizeText(element.value);

            if (current) {
                if (!sourceMap.has("value")) {
                    sourceMap.set("value", canonicalSource(current));
                }

                element.value = exactTranslation(
                    sourceMap.get("value")
                );
            }
        }
    }

    function translateTree(root = document.body) {
        if (!root) {
            return;
        }

        if (root instanceof Element) {
            translateElementAttributes(root);
        }

        const walker = document.createTreeWalker(
            root,
            NodeFilter.SHOW_ELEMENT |
                NodeFilter.SHOW_TEXT
        );

        let current = walker.currentNode;

        while (current) {
            if (current.nodeType === Node.TEXT_NODE) {
                translateTextNode(current);
            } else if (current instanceof Element) {
                translateElementAttributes(current);
            }

            current = walker.nextNode();
        }
    }

    function updateMetadata() {
        const title =
            document.querySelector("title");

        if (title?.textContent) {
            const source =
                title.dataset.sourceTitle ||
                canonicalSource(
                    normalizeText(title.textContent)
                );

            title.dataset.sourceTitle = source;
            title.textContent =
                exactTranslation(source);
        }

        document
            .querySelectorAll("meta[content]")
            .forEach((meta) => {
                const current =
                    normalizeText(
                        meta.getAttribute("content")
                    );

                if (
                    !current ||
                    !/[A-Za-z]/.test(current) ||
                    /^https?:/i.test(current)
                ) {
                    return;
                }

                const source =
                    meta.dataset.sourceContent ||
                    canonicalSource(current);

                meta.dataset.sourceContent = source;
                meta.setAttribute(
                    "content",
                    exactTranslation(source)
                );
            });

        const ogLocale =
            document.querySelector(
                'meta[property="og:locale"]'
            );

        if (ogLocale) {
            ogLocale.setAttribute(
                "content",
                state.locale === "pt-BR"
                    ? "pt_BR"
                    : (
                        state.locale === "es"
                            ? "es_ES"
                            : "en_US"
                    )
            );
        }
    }

    function writeLocaleToUrl(locale) {
        try {
            const url =
                new URL(window.location.href);

            if (locale === "en") {
                url.searchParams.delete("lang");
            } else {
                url.searchParams.set(
                    "lang",
                    locale
                );
            }

            window.history.replaceState(
                window.history.state,
                "",
                url
            );
        } catch (error) {
            // URL persistence is helpful, not critical.
        }
    }

    function saveLocale(locale) {
        try {
            window.localStorage.setItem(
                LOCALE_STORAGE_KEY,
                locale
            );
        } catch (error) {
            // Storage may be disabled.
        }
    }

    function isLanguageControl(element) {
        if (!(element instanceof Element)) {
            return false;
        }

        if (
            element.matches(
                "[data-language], [data-locale], " +
                "#languageSelect, #localeSelect, " +
                'select[name*="lang" i], ' +
                'select[id*="lang" i], ' +
                'select[name*="locale" i], ' +
                'select[id*="locale" i]'
            )
        ) {
            return true;
        }

        if (element instanceof HTMLSelectElement) {
            const values =
                Array.from(element.options)
                    .map((option) => {
                        return normalizeLocale(
                            option.value
                        );
                    });

            return values.some((value) => {
                return SUPPORTED_LOCALES.includes(
                    value
                );
            });
        }

        return false;
    }

    function localeFromControl(element) {
        if (element instanceof HTMLSelectElement) {
            return normalizeLocale(element.value);
        }

        return normalizeLocale(
            element.getAttribute("data-language") ||
            element.getAttribute("data-locale") ||
            element.getAttribute("value") ||
            element.textContent
        );
    }

    function synchronizeLanguageControls() {
        document
            .querySelectorAll(
                "[data-language], [data-locale], " +
                "#languageSelect, #localeSelect, " +
                'select[name*="lang" i], ' +
                'select[id*="lang" i], ' +
                'select[name*="locale" i], ' +
                'select[id*="locale" i]'
            )
            .forEach((control) => {
                if (control instanceof HTMLSelectElement) {
                    const existingValues =
                        new Set(
                            Array.from(control.options)
                                .map((option) => {
                                    return normalizeLocale(
                                        option.value
                                    );
                                })
                        );

                    for (const locale of SUPPORTED_LOCALES) {
                        if (!existingValues.has(locale)) {
                            const option =
                                document.createElement(
                                    "option"
                                );

                            option.value = locale;
                            option.textContent =
                                PUBLIC_LOCALE_NAMES[locale];

                            control.append(option);
                        }
                    }

                    Array.from(control.options)
                        .forEach((option) => {
                            const locale =
                                normalizeLocale(
                                    option.value
                                );

                            if (
                                SUPPORTED_LOCALES.includes(
                                    locale
                                )
                            ) {
                                option.value = locale;
                                option.textContent =
                                    PUBLIC_LOCALE_NAMES[locale];
                            }
                        });

                    control.value = state.locale;
                    return;
                }

                const locale =
                    localeFromControl(control);

                control.toggleAttribute(
                    "aria-current",
                    locale === state.locale
                );

                control.classList.toggle(
                    "active",
                    locale === state.locale
                );
            });
    }

    function announceLanguage(locale) {
        const live =
            document.querySelector(
                "#accessibilityAnnouncer, " +
                "#siteAnnouncer, " +
                '[aria-live="polite"]'
            );

        if (!live) {
            return;
        }

        const labels = {
            en: "Interface language changed to English.",
            es: "El idioma de la interfaz cambió a español.",
            "pt-BR":
                "O idioma da interface mudou para português do Brasil."
        };

        live.textContent =
            labels[locale] || labels.en;
    }

    async function setLocale(
        requestedLocale,
        {
            updateUrl = true,
            announce = true
        } = {}
    ) {
        const locale =
            normalizeLocale(requestedLocale);

        let pack;

        try {
            pack = await loadPack(locale);
        } catch (error) {
            if (locale !== "en") {
                return setLocale(
                    "en",
                    {
                        updateUrl,
                        announce
                    }
                );
            }

            throw error;
        }

        state.locale = locale;
        state.pack = pack;

        document.documentElement.lang = locale;
        document.documentElement.dir =
            pack.direction || "ltr";

        document.body.dataset.locale = locale;

        translateTree(document.body);
        updateMetadata();
        synchronizeLanguageControls();
        updateDynamicChainLabels();

        saveLocale(locale);

        if (updateUrl) {
            writeLocaleToUrl(locale);
        }

        if (announce) {
            announceLanguage(locale);
        }

        window.dispatchEvent(
            new CustomEvent(
                "hellbox:localechange",
                {
                    detail: {
                        locale
                    }
                }
            )
        );
    }

    function bindLanguageControls() {
        document.addEventListener(
            "change",
            (event) => {
                const control =
                    event.target instanceof Element
                        ? event.target.closest(
                            "select, [data-language], [data-locale]"
                        )
                        : null;

                if (!isLanguageControl(control)) {
                    return;
                }

                /*
                 * Gate 0.2 owns complete localization. Stop the older shell-only
                 * handler from partially retranslating the menu afterward.
                 */
                event.stopImmediatePropagation();

                setLocale(
                    localeFromControl(control)
                );
            },
            true
        );

        document.addEventListener(
            "click",
            (event) => {
                const control =
                    event.target instanceof Element
                        ? event.target.closest(
                            "[data-language], [data-locale]"
                        )
                        : null;

                if (!isLanguageControl(control)) {
                    return;
                }

                event.preventDefault();
                event.stopImmediatePropagation();

                setLocale(
                    localeFromControl(control)
                );
            },
            true
        );
    }

    function beginLocalizationObserver() {
        state.localizationObserver =
            new MutationObserver((mutations) => {
                for (const mutation of mutations) {
                    if (mutation.type === "characterData") {
                        translateTextNode(
                            mutation.target
                        );
                        continue;
                    }

                    if (
                        mutation.type === "attributes" &&
                        mutation.target instanceof Element
                    ) {
                        translateElementAttributes(
                            mutation.target
                        );
                        continue;
                    }

                    for (const node of mutation.addedNodes) {
                        if (node.nodeType === Node.TEXT_NODE) {
                            translateTextNode(node);
                        } else if (node instanceof Element) {
                            translateTree(node);
                        }
                    }
                }

                synchronizeLanguageControls();
                updateFloatingUiSuppression();
            });

        state.localizationObserver.observe(
            document.body,
            {
                subtree: true,
                childList: true,
                characterData: true,
                attributes: true,
                attributeFilter:
                    TRANSLATABLE_ATTRIBUTES
            }
        );
    }

    /* =============================================================
       CHAIN REGISTRY
       ============================================================= */

    function localChain() {
        return (
            window.HellboxChains?.getChainByKey(
                state.activeChainKey
            ) ||
            window.HellboxChains?.getChainByKey(
                "pulsechain"
            ) ||
            {
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
                enabled: true,
                publishingEnabled: true
            }
        );
    }

    function effectiveChain() {
        return (
            state.serverChains.get(
                state.activeChainKey
            ) ||
            localChain()
        );
    }

    function chainDisplayLabel(chain) {
        return `${String(
            chain.shortName ||
            chain.name ||
            "PulseChain"
        ).toUpperCase()} // ${chain.chainId}`;
    }

    function setTextPreservingSource(
        element,
        value
    ) {
        if (!element) {
            return;
        }

        element.textContent = value;

        const node = element.firstChild;

        if (node?.nodeType === Node.TEXT_NODE) {
            state.sourceByTextNode.set(
                node,
                value
            );

            state.renderedByTextNode.delete(
                node
            );

            translateTextNode(node);
        }
    }

    function updateDynamicChainLabels() {
        const chain = effectiveChain();
        const label = chainDisplayLabel(chain);

        document.body.dataset.chainKey =
            state.activeChainKey;

        document.body.dataset.chainId =
            String(chain.chainId);

        document
            .querySelectorAll(
                "[data-chain-label], " +
                "#headerNetworkName, " +
                "#collectionNetwork"
            )
            .forEach((element) => {
                setTextPreservingSource(
                    element,
                    label
                );
            });

        document
            .querySelectorAll(
                "[data-chain-id], " +
                "#pressRpcValue"
            )
            .forEach((element) => {
                setTextPreservingSource(
                    element,
                    String(chain.chainId)
                );
            });

        /*
         * Gate 0.1 predates the data attributes. Mark only exact root labels,
         * never arbitrary prose mentioning PulseChain.
         */
        document
            .querySelectorAll(
                ".header-network, " +
                ".terminal-top-right, " +
                ".machine-console-readouts"
            )
            .forEach((container) => {
                Array.from(container.childNodes)
                    .filter((node) => {
                        return (
                            node.nodeType ===
                            Node.TEXT_NODE
                        );
                    })
                    .forEach((node) => {
                        const text =
                            normalizeText(
                                node.nodeValue
                            );

                        if (
                            /^PULSECHAIN\s*\/\/\s*369$/i.test(
                                text
                            )
                        ) {
                            node.nodeValue = label;
                        }
                    });
            });
    }

    async function loadServerChains() {
        try {
            const response = await fetch(
                `/api/chains?v=${BUILD_ID}`,
                {
                    credentials: "same-origin",
                    cache: "no-cache"
                }
            );

            if (!response.ok) {
                return;
            }

            const data = await response.json();

            for (const chain of data.chains || []) {
                state.serverChains.set(
                    chain.key,
                    chain
                );
            }
        } catch (error) {
            // The public site remains functional from the bundled registry.
        }

        updateDynamicChainLabels();
    }

    function setActiveChain(chainKey) {
        const candidate =
            state.serverChains.get(chainKey) ||
            window.HellboxChains?.CHAINS?.[chainKey];

        if (!candidate) {
            throw new Error(
                `Unknown Hellbox chain: ${chainKey}`
            );
        }

        state.activeChainKey = chainKey;
        updateDynamicChainLabels();

        window.dispatchEvent(
            new CustomEvent(
                "hellbox:chainchange",
                {
                    detail: {
                        chain: effectiveChain()
                    }
                }
            )
        );

        return effectiveChain();
    }

    /* =============================================================
       ENVIRONMENT + FLOATING UI
       ============================================================= */

    function removeLegacyVisualInstructions() {
        const rejected = new Set([
            "PULL IT. I DARE YOU.",
            "DO NOT PULL THAT."
        ]);

        document
            .querySelectorAll(
                "body *:not(script):not(style)"
            )
            .forEach((element) => {
                if (element.children.length > 0) {
                    return;
                }

                const text =
                    normalizeText(
                        element.textContent
                    );

                if (rejected.has(text)) {
                    element.classList.add(
                        "gate02-legacy-lever-copy"
                    );

                    element.setAttribute(
                        "aria-hidden",
                        "true"
                    );
                }
            });

        document
            .querySelectorAll(
                ".lair-hotspot, " +
                ".obsession-hotspot, " +
                ".press-art-hotspot, " +
                ".press-hotspot"
            )
            .forEach((button) => {
                button.removeAttribute("title");

                if (!button.getAttribute("aria-label")) {
                    button.setAttribute(
                        "aria-label",
                        "Hidden object in Harrow's workspace"
                    );
                }
            });
    }

    function isElementVisible(element) {
        if (!(element instanceof Element)) {
            return false;
        }

        const style =
            window.getComputedStyle(element);

        return (
            style.display !== "none" &&
            style.visibility !== "hidden" &&
            style.opacity !== "0" &&
            element.getAttribute("aria-hidden") !== "true"
        );
    }

    function floatingUiShouldHide() {
        const drawer =
            document.querySelector("#lairDrawer");

        const reader =
            document.querySelector("#hellboxReader");

        const response =
            document.querySelector("#harrowResponse");

        const menu =
            document.querySelector("#mobileMenu");

        return Boolean(
            document.body.classList.contains(
                "drawer-open"
            ) ||
            document.body.classList.contains(
                "reader-open"
            ) ||
            document.body.classList.contains(
                "mobile-menu-open"
            ) ||
            document.body.classList.contains(
                "artwork-dragging"
            ) ||
            document.body.classList.contains(
                "form-focus"
            ) ||
            document.body.classList.contains(
                "is-scrolling"
            ) ||
            isElementVisible(drawer) ||
            isElementVisible(reader) ||
            isElementVisible(response) ||
            (
                menu &&
                menu.getAttribute("aria-hidden") ===
                "false"
            )
        );
    }

    function updateFloatingUiSuppression() {
        document.body.classList.toggle(
            "floating-ui-suppressed",
            floatingUiShouldHide()
        );
    }

    function bindFloatingUiSuppression() {
        window.addEventListener(
            "scroll",
            () => {
                document.body.classList.add(
                    "is-scrolling"
                );

                window.clearTimeout(
                    state.scrollTimer
                );

                state.scrollTimer =
                    window.setTimeout(() => {
                        document.body.classList.remove(
                            "is-scrolling"
                        );

                        updateFloatingUiSuppression();
                    }, 260);

                updateFloatingUiSuppression();
            },
            {
                passive: true
            }
        );

        document.addEventListener(
            "focusin",
            (event) => {
                const target = event.target;

                const formFocus =
                    target instanceof Element &&
                    Boolean(
                        target.closest(
                            "input, textarea, select, " +
                            '[contenteditable="true"]'
                        )
                    );

                document.body.classList.toggle(
                    "form-focus",
                    formFocus
                );

                updateFloatingUiSuppression();
            }
        );

        document.addEventListener(
            "focusout",
            () => {
                window.setTimeout(() => {
                    const target =
                        document.activeElement;

                    const formFocus =
                        target instanceof Element &&
                        Boolean(
                            target.closest(
                                "input, textarea, select, " +
                                '[contenteditable="true"]'
                            )
                        );

                    document.body.classList.toggle(
                        "form-focus",
                        formFocus
                    );

                    updateFloatingUiSuppression();
                }, 0);
            }
        );

        const artSelector =
            ".hero-art, .obsession-wall, " +
            ".press-machine-zone, " +
            "[data-pannable], .mobile-art-viewport";

        document.addEventListener(
            "pointerdown",
            (event) => {
                const target =
                    event.target instanceof Element
                        ? event.target.closest(
                            artSelector
                        )
                        : null;

                if (!target) {
                    return;
                }

                state.dragDepth += 1;

                document.body.classList.add(
                    "artwork-dragging"
                );

                updateFloatingUiSuppression();
            }
        );

        const endDrag = () => {
            state.dragDepth = Math.max(
                0,
                state.dragDepth - 1
            );

            if (state.dragDepth === 0) {
                document.body.classList.remove(
                    "artwork-dragging"
                );
            }

            updateFloatingUiSuppression();
        };

        window.addEventListener(
            "pointerup",
            endDrag
        );

        window.addEventListener(
            "pointercancel",
            endDrag
        );

        state.floatingObserver =
            new MutationObserver(() => {
                updateFloatingUiSuppression();
            });

        state.floatingObserver.observe(
            document.body,
            {
                subtree: true,
                childList: true,
                attributes: true,
                attributeFilter: [
                    "class",
                    "aria-hidden",
                    "open"
                ]
            }
        );
    }

    /* =============================================================
       THEORY TICKER
       ============================================================= */

    const TICKER_THOUGHTS = Object.freeze([
        "I HAD A POINT",
        "WAIT",
        "NO THAT'S ACTUALLY FUNNY",
        "WRITE THAT DOWN",
        "THE CABAL DEFINITELY HAS A GROUP CHAT",
        "WHO LET ETHEREUM CHARGE RENT?",
        "EVERYONE'S AN ECONOMIST DURING A GREEN CANDLE",
        "THE RPC IS FINE. YOU'RE THE PROBLEM",
        "RICHARD, THIS IS WHY I HAVE NOTES",
        "I READ THE DOCUMENT. MOST OF IT",
        "SCREENSHOTS ARE FOREVER",
        "PULSICANS ARE VERY NORMAL PEOPLE",
        "I DON'T NEED A ROADMAP. I NEED MORE WALL",
        "DON'T ERASE THAT",
        "WHERE WAS I?",
        "OH RIGHT. ME.",
        "369"
    ]);

    function tickerSequence() {
        return TICKER_THOUGHTS
            .map((thought) => {
                return (
                    `<span>${escapeHtml(
                        exactTranslation(thought)
                    )}</span><i aria-hidden="true">//</i>`
                );
            })
            .join("");
    }

    function rebuildTicker() {
        const track =
            document.querySelector(
                ".obsession-track"
            );

        if (!track) {
            return;
        }

        track.innerHTML =
            `<span class="ticker-sequence">${tickerSequence()}</span>` +
            `<span class="ticker-sequence" aria-hidden="true">${tickerSequence()}</span>`;

        track.dataset.gate02Ticker = "true";

        const toggle =
            document.querySelector(
                "#tickerToggle, " +
                ".obsession-pause, " +
                ".ticker-toggle"
            );

        if (toggle) {
            const paused =
                document.body.classList.contains(
                    "ticker-paused"
                );

            toggle.textContent = exactTranslation(
                paused ? "RESUME" : "PAUSE"
            );

            toggle.setAttribute(
                "aria-label",
                exactTranslation(
                    paused
                        ? "Resume Harrow's thoughts"
                        : "Pause Harrow's thoughts"
                )
            );
        }
    }

    /* =============================================================
       INITIALIZATION
       ============================================================= */

    async function init() {
        bindLanguageControls();
        bindFloatingUiSuppression();
        removeLegacyVisualInstructions();

        await Promise.all(
            SUPPORTED_LOCALES.map((locale) => {
                return loadPack(locale);
            })
        );

        state.reverseStrings.clear();

        for (const pack of state.packs.values()) {
            for (const [source, translated] of Object.entries(
                pack.strings || {}
            )) {
                const rendered = normalizeText(translated);

                if (
                    rendered &&
                    !state.reverseStrings.has(rendered)
                ) {
                    state.reverseStrings.set(
                        rendered,
                        source
                    );
                }
            }
        }

        await setLocale(
            preferredInitialLocale(),
            {
                updateUrl: true,
                announce: false
            }
        );

        rebuildTicker();
        beginLocalizationObserver();
        await loadServerChains();
        updateFloatingUiSuppression();

        window.HellboxRuntime = Object.freeze({
            buildId: BUILD_ID,
            getLocale: () => state.locale,
            setLocale,
            getActiveChain: () => effectiveChain(),
            setActiveChain,
            getServerChains: () => {
                return Array.from(
                    state.serverChains.values()
                );
            }
        });

        document.documentElement.dataset.gate02 =
            "ready";
    }

    if (document.readyState === "loading") {
        document.addEventListener(
            "DOMContentLoaded",
            () => {
                init().catch((error) => {
                    console.error(
                        "Hellbox Gate 0.2 initialization failed.",
                        error
                    );
                });
            },
            {
                once: true
            }
        );
    } else {
        init().catch((error) => {
            console.error(
                "Hellbox Gate 0.2 initialization failed.",
                error
            );
        });
    }
})();

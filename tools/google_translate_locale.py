#!/usr/bin/env python3
"""
Hellbox Comics — Google-assisted locale draft generator
Gate 0.2 recovery

Purpose
-------
Translate the canonical locales/en.json catalog into a machine-draft locale
without exposing Google credentials in the website or calling Google from a
visitor's browser.

The generated pack is NOT automatically production-approved. Harrow-authored
voice still requires an editorial adaptation pass before the locale is marked
complete/public in locales/manifest.json.

Usage
-----
    export GOOGLE_TRANSLATE_API_KEY="YOUR_KEY"
    python3 tools/google_translate_locale.py es
    python3 tools/google_translate_locale.py pt-BR

Optional:
    GOOGLE_TRANSLATE_MODEL may be set to a model supported by Cloud
    Translation Basic v2. If unset, Google's default translation model is used.

Security
--------
The API key is read only from the environment. Never paste it into this file,
locales, frontend JavaScript, Git, or Cloudflare static assets.
"""

from __future__ import annotations

import argparse
import hashlib
import html
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Dict, Iterable, List, Tuple


ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "locales" / "en.json"
MANIFEST_PATH = ROOT / "locales" / "manifest.json"

API_URL = "https://translation.googleapis.com/language/translate/v2"

# Cloud Translation v2 accepts up to 128 q values in one request. Stay below
# that and also keep request character volume modest for easier retries.
MAX_ITEMS_PER_BATCH = 100
MAX_CHARS_PER_BATCH = 20_000

# Hard local safety cap: refuse to send more than 50,000 source characters
# to Google in any single invocation. This is intentionally conservative
# for Gate 0.2 and keeps accidental runaway translation jobs from occurring.
HARD_SOURCE_CHAR_LIMIT = 50_000

SUPPORTED_GATE02_TARGETS = {
    "es": "Spanish",
    "pt-BR": "Brazilian Portuguese",
}

# Terms that are product names, character names, crypto/community vocabulary,
# handles, or deliberate Hellbox language. These remain exactly as authored.
BASE_PROTECTED_TERMS = [
    "Hellbox Comics",
    "Hellbox",
    "Harrow",
    "Hellion",
    "Hellions",
    "PulseChain",
    "Pulse Byte",
    "Pulse Bytes",
    "Chain ID 369",
    "Hellbox Reader",
    "Hellbox Press",
    "Richard Heart",
    "Pulsicans",
    "HairyLabs",
    "@HellboxComics",
    "@SinnisterHarrow",
    "HELLBOXCOMICS.COM",
]

# These areas contain Harrow's authored personality and must receive explicit
# editorial review even when the Google draft is semantically accurate.
HARROW_REVIEW_PREFIXES = [
    "hero.",
    "ticker.",
    "dialogue.",
    "drawer.",
    "relationship.",
    "discovery.",
    "scroll.",
    "greet.",
    "interaction.",
    "press.state.",
    "press.busy.",
    "press.empty.",
    "harrow.",
    "exit.",
]

# Deliberate tokens that should not be altered by machine translation.
EXACT_VALUE_PRESERVE = {
    "",
    "369",
    "HARROW",
    "HELLION",
    "PULSECHAIN // 369",
    "HELLBOXCOMICS.COM",
    "● LIVE",
}


def die(message: str, exit_code: int = 1) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(exit_code)


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        die(f"Missing required file: {path}")
    except json.JSONDecodeError as exc:
        die(f"Invalid JSON in {path}: {exc}")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def protected_terms(manifest: dict) -> List[str]:
    terms = list(BASE_PROTECTED_TERMS)

    configured = (
        manifest
        .get("translationProduction", {})
        .get("protectedTerms", [])
    )

    if isinstance(configured, list):
        for term in configured:
            if isinstance(term, str) and term.strip():
                terms.append(term.strip())

    # Longest first prevents "Hellbox" from replacing the Hellbox part of
    # "Hellbox Comics" before the larger phrase can be protected.
    return sorted(set(terms), key=len, reverse=True)


def protect_text(text: str, terms: List[str]) -> Tuple[str, Dict[str, str]]:
    replacements: Dict[str, str] = {}
    protected = text

    for index, term in enumerate(terms):
        if term not in protected:
            continue

        token = f"ZXQHBXTERM{index:03d}QXZ"
        protected = protected.replace(term, token)
        replacements[token] = term

    return protected, replacements


def restore_text(text: str, replacements: Dict[str, str]) -> str:
    restored = text

    for token, term in replacements.items():
        restored = restored.replace(token, term)

    return restored


def batch_entries(entries: List[Tuple[str, str]]) -> Iterable[List[Tuple[str, str]]]:
    batch: List[Tuple[str, str]] = []
    char_count = 0

    for entry in entries:
        value_len = len(entry[1])

        if (
            batch
            and (
                len(batch) >= MAX_ITEMS_PER_BATCH
                or char_count + value_len > MAX_CHARS_PER_BATCH
            )
        ):
            yield batch
            batch = []
            char_count = 0

        batch.append(entry)
        char_count += value_len

    if batch:
        yield batch


def google_translate(
    api_key: str,
    target: str,
    texts: List[str],
    model: str | None = None,
) -> List[str]:
    query = urllib.parse.urlencode({"key": api_key})
    url = f"{API_URL}?{query}"

    payload = {
        "q": texts,
        "source": "en",
        "target": target,
        "format": "text",
    }

    if model:
        payload["model"] = model

    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json; charset=utf-8",
            "Accept": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            body = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        die(f"Google Translation returned HTTP {exc.code}: {detail}")
    except urllib.error.URLError as exc:
        die(f"Could not reach Google Translation: {exc}")

    try:
        translations = body["data"]["translations"]
    except (KeyError, TypeError):
        die(f"Unexpected Google Translation response: {body}")

    results = [
        html.unescape(str(item["translatedText"]))
        for item in translations
    ]

    if len(results) != len(texts):
        die(
            "Google Translation returned a different number of translations "
            f"({len(results)}) than requested ({len(texts)})."
        )

    return results


def build_draft(target: str, api_key: str, model: str | None) -> Path:
    source_bytes = SOURCE_PATH.read_bytes()
    source = load_json(SOURCE_PATH)
    manifest = load_json(MANIFEST_PATH)

    source_meta = source.get("_meta")
    if not isinstance(source_meta, dict):
        die("locales/en.json is missing its _meta object.")

    source_values = {
        key: value
        for key, value in source.items()
        if key != "_meta"
    }

    if not all(isinstance(value, str) for value in source_values.values()):
        die("Every canonical locale entry except _meta must be a string.")

    terms = protected_terms(manifest)

    translated: Dict[str, str] = {}
    pending: List[Tuple[str, str]] = []
    token_maps: Dict[str, Dict[str, str]] = {}

    for key, value in source_values.items():
        if value in EXACT_VALUE_PRESERVE:
            translated[key] = value
            continue

        protected, replacements = protect_text(value, terms)
        pending.append((key, protected))
        token_maps[key] = replacements

    total_source_chars = sum(len(value) for _, value in pending)

    if total_source_chars > HARD_SOURCE_CHAR_LIMIT:
        die(
            "Local safety cap exceeded: "
            f"{total_source_chars:,} source characters would be sent to Google, "
            f"but this Gate 0.2 tool allows at most "
            f"{HARD_SOURCE_CHAR_LIMIT:,} per run."
        )

    batches = list(batch_entries(pending))
    print(
        f"Translating {len(pending)} strings from en -> {target} "
        f"in {len(batches)} request batch(es)..."
    )
    print(
        f"Source characters this run: {total_source_chars:,} "
        f"(hard cap: {HARD_SOURCE_CHAR_LIMIT:,})"
    )

    for batch_index, batch in enumerate(batches, start=1):
        keys = [key for key, _ in batch]
        texts = [value for _, value in batch]

        print(f"  Google batch {batch_index}/{len(batches)} ({len(batch)} strings)")
        results = google_translate(
            api_key=api_key,
            target=target,
            texts=texts,
            model=model,
        )

        for key, result in zip(keys, results):
            translated[key] = restore_text(
                result,
                token_maps.get(key, {}),
            )

    # Reassemble in the exact key order of the canonical pack.
    output = {
        "_meta": {
            "schemaVersion": source_meta.get("schemaVersion", 2),
            "catalogVersion": source_meta.get(
                "catalogVersion",
                "0.2.0-recovery.1",
            ),
            "locale": target,
            "direction": "ltr",
            "canonical": False,
            "complete": False,
            "machineDraft": True,
            "draftProvider": "google_cloud_translation_basic_v2",
            "sourceLocale": "en",
            "sourceSha256": sha256_bytes(source_bytes),
            "harrowVoiceApproved": False,
            "reviewRequiredPrefixes": HARROW_REVIEW_PREFIXES,
            "warning": (
                "Machine draft only. Do not mark this locale public until "
                "Harrow voice, layout, accessibility, and completeness QA pass."
            ),
        }
    }

    for key in source_values:
        output[key] = translated[key]

    # Gate against the exact failure mode from the abandoned Gate 0.2 pack.
    if set(output.keys()) - {"_meta"} != set(source_values.keys()):
        die("Generated locale key set does not match canonical English.")

    suspicious = []
    source_code_signals = (
        "addEventListener(",
        "document.body",
        "window.localStorage",
        "querySelector(",
        "=> {",
        "function(",
        "const ",
    )

    for key, value in output.items():
        if key == "_meta":
            continue

        if len(value) > 1_200:
            suspicious.append((key, "oversized"))

        if any(signal in value for signal in source_code_signals):
            suspicious.append((key, "source-code-like"))

    if suspicious:
        die(
            "Generated locale failed corruption guard: "
            + ", ".join(f"{key} ({reason})" for key, reason in suspicious[:10])
        )

    destination = ROOT / "locales" / f"{target}.json"
    destination.write_text(
        json.dumps(output, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    return destination


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Generate a Google Cloud Translation machine draft from "
            "Hellbox locales/en.json."
        )
    )

    parser.add_argument(
        "target",
        choices=sorted(SUPPORTED_GATE02_TARGETS),
        help="Gate 0.2 target locale.",
    )

    parser.add_argument(
        "--check",
        action="store_true",
        help=(
            "Validate files and credentials setup without calling Google "
            "or changing a locale file."
        ),
    )

    return parser.parse_args()


def main() -> None:
    args = parse_args()

    source = load_json(SOURCE_PATH)
    manifest = load_json(MANIFEST_PATH)

    source_keys = {
        key
        for key in source
        if key != "_meta"
    }

    if len(source_keys) < 300:
        die(
            "Canonical English catalog is unexpectedly small. "
            "Refusing to translate an incomplete source pack."
        )

    if manifest.get("defaultLocale") != "en":
        die("Locale manifest does not identify English as the default locale.")

    api_key = os.environ.get("GOOGLE_TRANSLATE_API_KEY", "").strip()
    model = os.environ.get("GOOGLE_TRANSLATE_MODEL", "").strip() or None

    if args.check:
        print(f"Canonical source: {SOURCE_PATH}")
        print(f"Canonical keys: {len(source_keys)}")
        print(f"Target: {args.target} ({SUPPORTED_GATE02_TARGETS[args.target]})")
        source_characters = sum(
            len(value)
            for key, value in source.items()
            if key != "_meta" and isinstance(value, str)
        )

        print(
            "Google API key: "
            + ("present in environment" if api_key else "NOT SET")
        )
        print(f"Model: {model or 'Google default'}")
        print(
            f"Canonical source characters: {source_characters:,} "
            f"(hard cap per run: {HARD_SOURCE_CHAR_LIMIT:,})"
        )

        if source_characters > HARD_SOURCE_CHAR_LIMIT:
            die(
                "Canonical catalog exceeds the local per-run safety cap. "
                "Do not translate until the catalog is intentionally split."
            )

        print("No files changed.")
        return

    if not api_key:
        die(
            "GOOGLE_TRANSLATE_API_KEY is not set. "
            "Export it in this Terminal session; never save it in the repo."
        )

    destination = build_draft(
        target=args.target,
        api_key=api_key,
        model=model,
    )

    print()
    print(f"Created Google machine draft: {destination}")
    print(
        "NEXT: editorial Harrow-voice review is mandatory before "
        "this locale may be marked complete/public."
    )


if __name__ == "__main__":
    main()

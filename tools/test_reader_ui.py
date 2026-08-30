#!/usr/bin/env python3
"""Hellbox Reader browser acceptance/regression test.

Loads the deployed (or supplied) Hellbox frontend, intercepts only publication/Reader
API requests with deterministic fixtures, and verifies the actual Reader UI behavior
at laptop and mobile viewports without changing production data or bypassing the
production Reader API.
"""

from __future__ import annotations

import argparse
import base64
import json
import shutil
import sys
import time
from dataclasses import dataclass
from typing import Dict, Iterable
from urllib.parse import urljoin

try:
    from playwright.sync_api import Browser, BrowserContext, Page, Route, sync_playwright
except Exception as exc:  # pragma: no cover
    print("ERROR: Playwright is required. Install with: python -m pip install playwright", file=sys.stderr)
    raise SystemExit(2) from exc


PAGE_FIXTURES_B64 = [
    "UklGRloAAABXRUJQVlA4IE4AAABQBwCdASp4AKAAPm02mUmkIyKhIGgAgA2JaW7hdUAAO6HVUmyYh1VJsmIdVSbJiHVUmyYh1VJsmIdVSbJiHVUmyYWAAP7/YGgAAAAAAAA=",
    "UklGRloAAABXRUJQVlA4IE4AAABQBwCdASp4AKAAPm02mUmkIyKhIGgAgA2JaW7hdUAAO6HVUmyYh1VJsmIdVSbJiHVUmyYh1VJsmIdVSbJiHVUmyYWAAP7+2CAAAAAAAAA=",
    "UklGRlgAAABXRUJQVlA4IEwAAABQBwCdASp4AKAAPm02mkmkIyKhIGgAgA2JaW7hdUAAO6HVUmyYh1VJsmIdVSbJiHVUmyYh1VJsmIdVSbJiHVUmyYWAAP78XQAAAAAA",
]
PAGE_FIXTURES = [base64.b64decode(item) for item in PAGE_FIXTURES_B64]

TEST_WALLET = "0x1111111111111111111111111111111111111111"
TEST_CHAIN_ID = 369
TEST_SESSION_TOKEN = "gate3-reader-browser-test-session"
TEST_SESSION_EXPIRES_AT = 4102444800  # 2100-01-01
TEST_SESSION_STORAGE_KEY = "hellbox:wallet-session:v1"


@dataclass(frozen=True)
class ViewportCase:
    name: str
    width: int
    height: int
    is_mobile: bool = False
    has_touch: bool = False


VIEWPORTS = (
    ViewportCase("laptop", 1440, 900),
    ViewportCase("tablet", 820, 1180, is_mobile=True, has_touch=True),
    ViewportCase("mobile", 390, 844, is_mobile=True, has_touch=True),
)


def publication_payload() -> Dict[str, object]:
    return {
        "ok": True,
        "apiVersion": "hellbox-v2",
        "source": "gate2-browser-test",
        "publications": [
            {
                "publicationKey": "scivive",
                "title": "SciVive",
                "lifecycle": "circulating",
                "publicVisible": True,
                "presentationClass": "book",
                "reader": {"enabled": True, "accessPolicy": "ownership"},
            }
        ],
        "count": 1,
    }


def wallet_status_payload() -> Dict[str, object]:
    return {
        "ok": True,
        "authenticated": True,
        "wallet": {
            "address": TEST_WALLET,
            "chainId": TEST_CHAIN_ID,
        },
        "source": "gate3-reader-browser-test",
        "publications": [
            {
                "publicationKey": "scivive",
                "title": "SciVive",
                "lifecycle": "circulating",
                "publicVisible": True,
                "presentationClass": "book",
                "reader": {"enabled": True, "accessPolicy": "ownership"},
                "ownership": "owned",
                "ownershipDetails": {
                    "balance": 1,
                    "source": "test-fixture",
                    "authoritative": True,
                },
            }
        ],
        "summary": {
            "known": 1,
            "owned": 1,
            "missing": 0,
            "evolved": 0,
            "unavailable": 0,
            "verificationErrors": 0,
        },
    }


def auth_session_payload() -> Dict[str, object]:
    return {
        "ok": True,
        "authenticated": True,
        "wallet": {
            "address": TEST_WALLET,
            "chainId": TEST_CHAIN_ID,
        },
        "scope": "wallet_identity",
        "expiresAt": TEST_SESSION_EXPIRES_AT,
    }


def reader_payload() -> Dict[str, object]:
    pages = [
        {
            "id": str(index),
            "storageKey": f"page-{index:04d}.webp",
            "endpoint": f"/api/reader/scivive/asset/{index}",
        }
        for index in range(1, 4)
    ]
    return {
        "ok": True,
        "access": "granted",
        "publication": {
            "publicationKey": "scivive",
            "title": "SciVive",
            "lifecycle": "circulating",
            "presentationClass": "book",
        },
        "ownership": {"owned": True, "testFixture": True},
        "reader": {
            "manifest": {
                "version": 1,
                "publicationKey": "scivive",
                "presentationClass": "book",
                "pageCount": 3,
                "pages": pages,
            }
        },
    }


def fulfill_json(route: Route, payload: Dict[str, object], status: int = 200) -> None:
    route.fulfill(
        status=status,
        content_type="application/json; charset=utf-8",
        body=json.dumps(payload),
        headers={"Cache-Control": "no-store"},
    )


def install_routes(page: Page) -> None:
    def handler(route: Route) -> None:
        url = route.request.url
        path = route.request.url.split("?", 1)[0]

        if path.endswith("/api/auth/session"):
            authorization = route.request.headers.get("authorization", "")
            if authorization != f"Bearer {TEST_SESSION_TOKEN}":
                fulfill_json(
                    route,
                    {
                        "ok": False,
                        "authenticated": False,
                        "error": "Reader session required.",
                    },
                    status=401,
                )
                return

            fulfill_json(route, auth_session_payload())
            return

        if path.endswith("/api/wallet-status"):
            authorization = route.request.headers.get("authorization", "")
            if authorization != f"Bearer {TEST_SESSION_TOKEN}":
                fulfill_json(
                    route,
                    {
                        "ok": False,
                        "authenticated": False,
                        "error": "Reader session required.",
                    },
                    status=401,
                )
                return

            fulfill_json(route, wallet_status_payload())
            return

        if path.endswith("/api/publications"):
            fulfill_json(route, publication_payload())
            return

        if path.endswith("/api/reader/scivive"):
            authorization = route.request.headers.get("authorization", "")
            if authorization != f"Bearer {TEST_SESSION_TOKEN}":
                fulfill_json(
                    route,
                    {"ok": False, "error": "Reader session required."},
                    status=401,
                )
                return

            fulfill_json(route, reader_payload())
            return

        marker = "/api/reader/scivive/asset/"
        if marker in path:
            try:
                page_id = int(path.rsplit("/", 1)[1])
            except ValueError:
                route.fulfill(status=404, body="not found")
                return

            if page_id < 1 or page_id > len(PAGE_FIXTURES):
                route.fulfill(status=404, body="not found")
                return

            authorization = route.request.headers.get("authorization", "")
            if authorization != f"Bearer {TEST_SESSION_TOKEN}":
                route.fulfill(
                    status=401,
                    content_type="application/json; charset=utf-8",
                    body=json.dumps({"ok": False, "error": "Reader session required."}),
                    headers={"Cache-Control": "no-store"},
                )
                return

            route.fulfill(
                status=200,
                content_type="image/webp",
                body=PAGE_FIXTURES[page_id - 1],
                headers={
                    "Cache-Control": "private, no-store",
                    "X-Hellbox-Test-Authorization-Seen": "1" if authorization else "0",
                },
            )
            return

        # Prevent unrelated API failures from obscuring the Reader UI test. These are GET-only
        # bootstrap calls and contain no production writes.
        if "/api/" in path:
            fulfill_json(route, {"ok": True})
            return

        route.continue_()

    page.route("**/*", handler)


def assert_condition(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def wait_for_reader_image(page: Page, timeout_ms: int = 15000) -> None:
    page.wait_for_function(
        """
        () => {
            const image = document.querySelector('#readerPageImage');
            return Boolean(
                image &&
                image.src &&
                image.src.startsWith('blob:') &&
                image.complete &&
                image.naturalWidth > 0 &&
                image.naturalHeight > 0
            );
        }
        """,
        timeout=timeout_ms,
    )


def run_viewport(browser: Browser, base_url: str, case: ViewportCase) -> None:
    context: BrowserContext = browser.new_context(
        viewport={"width": case.width, "height": case.height},
        is_mobile=case.is_mobile,
        has_touch=case.has_touch,
        locale="en-US",
    )
    context.add_init_script(
        script=f"""
        (() => {{
            const address = {json.dumps(TEST_WALLET)};
            const chainHex = "0x171";

            window.ethereum = {{
                isMetaMask: true,
                async request(request) {{
                    switch (request?.method) {{
                        case "eth_accounts":
                        case "eth_requestAccounts":
                            return [address];
                        case "eth_chainId":
                            return chainHex;
                        default:
                            throw new Error(
                                `Unsupported Reader acceptance wallet method: ${{request?.method}}`
                            );
                    }}
                }},
                on() {{}},
                removeListener() {{}}
            }};

            window.sessionStorage.setItem(
                {json.dumps(TEST_SESSION_STORAGE_KEY)},
                JSON.stringify({{
                    token: {json.dumps(TEST_SESSION_TOKEN)},
                    address,
                    chainId: {TEST_CHAIN_ID},
                    expiresAt: {TEST_SESSION_EXPIRES_AT}
                }})
            );
        }})();
        """
    )

    page = context.new_page()
    install_routes(page)

    errors = []
    page.on("pageerror", lambda error: errors.append(str(error)))

    url = base_url
    separator = "&" if "?" in url else "?"
    url = f"{url}{separator}gate2-ui-test={int(time.time())}-{case.name}"

    page.goto(url, wait_until="domcontentloaded", timeout=30000)

    page.wait_for_function(
        "() => document.querySelector('#collectionAccessState')?.textContent?.trim() === 'VERIFIED'",
        timeout=20000,
    )

    page.wait_for_function(
        "() => document.querySelector('#summaryOwned')?.textContent?.trim() === '01'",
        timeout=20000,
    )

    button = page.locator('.collection-item-action[data-publication-key="scivive"]')
    button.wait_for(state="visible", timeout=20000)
    assert_condition(button.is_enabled(), f"{case.name}: authoritative owned Reader action is disabled")
    assert_condition("OPEN READER" in button.inner_text(), f"{case.name}: owned Reader action label is wrong")
    button.click()

    reader = page.locator("#hellboxReader")
    reader.wait_for(state="visible", timeout=10000)
    assert_condition("active" in (reader.get_attribute("class") or ""), f"{case.name}: Reader did not become active")

    wait_for_reader_image(page)
    assert_condition(page.locator("#readerPageNumber").inner_text().strip() == "01", f"{case.name}: Reader did not open on page 1")
    assert_condition(page.locator("#readerPageCount").inner_text().strip() == "03", f"{case.name}: Reader page count is wrong")

    image = page.locator("#readerPageImage")
    assert_condition((image.get_attribute("src") or "").startswith("blob:"), f"{case.name}: Reader is not using blob-backed protected image transport")
    assert_condition(page.locator("#hellboxReader iframe").count() == 0, f"{case.name}: Reader unexpectedly contains an iframe")
    assert_condition(page.locator("#hellboxReader embed").count() == 0, f"{case.name}: Reader unexpectedly contains an embed")
    assert_condition(page.locator("#hellboxReader object").count() == 0, f"{case.name}: Reader unexpectedly contains an object/PDF embed")

    # Button navigation.
    page.locator("#readerNext").click()
    page.wait_for_function("() => document.querySelector('#readerPageNumber')?.textContent?.trim() === '02'", timeout=10000)
    wait_for_reader_image(page)

    # Keyboard navigation is a desktop-browser capability.
    if case.name == "laptop":
        page.keyboard.press("ArrowRight")
        page.wait_for_function("() => document.querySelector('#readerPageNumber')?.textContent?.trim() === '03'", timeout=10000)
        page.keyboard.press("ArrowLeft")
        page.wait_for_function("() => document.querySelector('#readerPageNumber')?.textContent?.trim() === '02'", timeout=10000)

    compact_mobile = case.width <= 760

    if compact_mobile:
        # The authored phone layout intentionally hides desktop-only controls.
        # Phone acceptance is protected display + navigation + containment,
        # not desktop control parity.
        assert_condition(not page.locator("#readerFitPage").is_visible(), f"{case.name}: FIT PAGE should be hidden in compact phone layout")
        assert_condition(not page.locator("#readerFitWidth").is_visible(), f"{case.name}: FIT WIDTH should be hidden in compact phone layout")
        assert_condition(not page.locator("#readerLayoutToggle").is_visible(), f"{case.name}: CONTINUOUS should be hidden in compact phone layout")

        assert_condition(page.locator("#readerPrevious").is_visible(), f"{case.name}: previous-page control is not visible")
        assert_condition(page.locator("#readerNext").is_visible(), f"{case.name}: next-page control is not visible")
        assert_condition(page.locator("#readerClose").is_visible(), f"{case.name}: close control is not visible")
        assert_condition("fit-page" in (image.get_attribute("class") or ""), f"{case.name}: compact Reader is not using page-fit presentation")

        # Prove both directions of touch-friendly button navigation.
        page.locator("#readerPrevious").click()
        page.wait_for_function("() => document.querySelector('#readerPageNumber')?.textContent?.trim() === '01'", timeout=10000)
        wait_for_reader_image(page)
        page.locator("#readerNext").click()
        page.wait_for_function("() => document.querySelector('#readerPageNumber')?.textContent?.trim() === '02'", timeout=10000)
        wait_for_reader_image(page)

        image_box = image.bounding_box()
        assert_condition(image_box is not None, f"{case.name}: Reader image has no layout box")
        assert_condition(image_box["x"] >= -1, f"{case.name}: Reader image begins outside the viewport")
        assert_condition(image_box["x"] + image_box["width"] <= case.width + 1, f"{case.name}: Reader image exceeds viewport width")

        no_horizontal_overflow = page.evaluate(
            "() => document.documentElement.scrollWidth <= window.innerWidth + 1"
        )
        assert_condition(no_horizontal_overflow, f"{case.name}: Reader causes horizontal page overflow")
    else:
        # Laptop and tablet expose the full web Reader control surface.
        page.locator("#readerFitWidth").click()
        page.wait_for_function("() => document.querySelector('#readerPageImage')?.classList.contains('fit-width')", timeout=5000)

        # Continuous mode must render image elements and use blob transport lazily.
        page.locator("#readerLayoutToggle").click()
        page.wait_for_function("() => document.querySelector('#readerContinuous')?.classList.contains('active')", timeout=5000)
        page.wait_for_function("() => document.querySelectorAll('#readerContinuous img').length === 3", timeout=5000)
        page.wait_for_function(
            "() => Array.from(document.querySelectorAll('#readerContinuous img')).some(img => (img.src || '').startsWith('blob:'))",
            timeout=10000,
        )

    # Reader modal must remain within the target viewport.
    box = reader.bounding_box()
    assert_condition(box is not None, f"{case.name}: Reader has no layout box")
    assert_condition(box["width"] <= case.width + 1, f"{case.name}: Reader width {box['width']} exceeds viewport {case.width}")

    # Close and ensure focus/modal state returns cleanly.
    page.locator("#readerClose").click()
    page.wait_for_function("() => !document.querySelector('#hellboxReader')?.classList.contains('active')", timeout=5000)

    # Ignore known third-party resource/network console noise; pageerror means application JS exception.
    assert_condition(not errors, f"{case.name}: JavaScript page errors: {errors}")

    context.close()
    print(f"Gate 2 Reader UI {case.name}: PASS ({case.width}x{case.height})")


def launch_browser(playwright, headed: bool) -> Browser:
    # Prefer the user's installed Google Chrome so no Playwright browser download is required.
    try:
        return playwright.chromium.launch(channel="chrome", headless=not headed)
    except Exception:
        # Useful for Linux/self-test environments where system Chromium exists.
        executable = shutil.which("chromium") or shutil.which("chromium-browser")
        if executable:
            return playwright.chromium.launch(
                executable_path=executable,
                headless=not headed,
                args=["--no-sandbox"],
            )
        return playwright.chromium.launch(headless=not headed)


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Hellbox Reader browser acceptance/regression test")
    parser.add_argument("--base-url", default="https://hellboxcomics.com/", help="Hellbox frontend URL to test")
    parser.add_argument("--headed", action="store_true", help="Show the browser while testing")
    args = parser.parse_args(list(argv) if argv is not None else None)

    base_url = args.base_url
    if not base_url.endswith("/") and "?" not in base_url:
        base_url += "/"

    with sync_playwright() as playwright:
        browser = launch_browser(playwright, args.headed)
        try:
            for case in VIEWPORTS:
                run_viewport(browser, base_url, case)
        finally:
            browser.close()

    print("Hellbox Reader browser acceptance: PASS")
    print("Authoritative ownership fixture: PASS")
    print("Production publication/ownership data was not modified by this test.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

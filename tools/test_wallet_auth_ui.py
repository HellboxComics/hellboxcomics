#!/usr/bin/env python3
"""
Hellbox Comics — Gate 3 live wallet identity browser acceptance test.

Purpose
-------
Exercise the REAL production website and REAL production wallet-auth API using
a throwaway EVM wallet that exists only for the lifetime of this process.

The test proves:
  1. The live homepage is loading the Gate 3 identity frontend.
  2. A connected-but-unverified wallet is not treated as verified.
  3. Clicking the real wallet button performs:
       /api/auth/challenge
       personal_sign
       /api/auth/verify
  4. The real UI reaches VERIFIED.
  5. A Hellbox wallet session is stored in sessionStorage.
  6. Reload restores identity only through /api/auth/session.
  7. Identity remains distinct from ownership in the Archive copy.
  8. A chain change clears the browser-side verified state/session.
  9. Throwaway challenge/session rows are deleted from production D1.

This test NEVER prints the throwaway private key, challenge message,
signature, bearer token, or session id.

Requirements
------------
Run from the existing Hellbox Reader virtualenv after:
  python -m pip install playwright eth-account
  python -m playwright install chromium
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
from typing import List

from eth_account import Account
from eth_account.messages import encode_defunct
from playwright.sync_api import sync_playwright


BASE_URL = "https://hellboxcomics.com/?gate3-live-wallet-acceptance=1"
PULSECHAIN_ID = 369
PULSECHAIN_HEX = hex(PULSECHAIN_ID)
SESSION_STORAGE_KEY = "hellbox:wallet-session:v1"


class AcceptanceFailure(RuntimeError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AcceptanceFailure(message)


def cleanup_remote_identity(repo_root: Path, address: str) -> None:
    """Remove every production D1 auth row belonging to the throwaway wallet."""
    sql = f"""
DELETE FROM wallet_sessions
WHERE wallet_address = '{address}';

DELETE FROM wallet_auth_challenges
WHERE wallet_address = '{address}';
"""

    result = subprocess.run(
        [
            "npx",
            "wrangler@latest",
            "d1",
            "execute",
            "hellbox-production",
            "--remote",
            "--command",
            sql,
        ],
        cwd=str(repo_root),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        timeout=90,
        check=False,
    )

    if result.returncode != 0:
        raise AcceptanceFailure(
            "Production D1 cleanup failed. "
            "Run a manual cleanup for the throwaway wallet before continuing."
        )


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]

    account = Account.create()
    address = account.address.lower()
    private_key = account.key.hex()

    request_paths: List[str] = []
    sign_count = 0
    browser = None
    test_error: Exception | None = None
    cleanup_error: Exception | None = None

    def sign_message(message: str) -> str:
        nonlocal sign_count
        sign_count += 1

        signed = Account.sign_message(
            encode_defunct(text=message),
            private_key=private_key,
        )

        value = signed.signature.hex()
        return value if value.startswith("0x") else f"0x{value}"

    provider_script = f"""
(() => {{
    const listeners = Object.create(null);
    let accounts = [{json.dumps(address)}];
    let chainId = {json.dumps(PULSECHAIN_HEX)};

    function emit(eventName, payload) {{
        for (const listener of (listeners[eventName] || [])) {{
            try {{
                listener(payload);
            }} catch (error) {{
                console.error(error);
            }}
        }}
    }}

    window.ethereum = {{
        isMetaMask: true,

        async request(request) {{
            const method = request?.method;
            const params = Array.isArray(request?.params) ? request.params : [];

            switch (method) {{
                case "eth_accounts":
                case "eth_requestAccounts":
                    return [...accounts];

                case "eth_chainId":
                    return chainId;

                case "personal_sign":
                    return await window.__hbSignMessage(String(params[0] || ""));

                default:
                    throw new Error(`Unsupported Gate 3 test wallet method: ${{method}}`);
            }}
        }},

        on(eventName, listener) {{
            if (!listeners[eventName]) {{
                listeners[eventName] = [];
            }}
            listeners[eventName].push(listener);
        }},

        removeListener(eventName, listener) {{
            listeners[eventName] = (listeners[eventName] || [])
                .filter((candidate) => candidate !== listener);
        }}
    }};

    window.__hbWalletAcceptance = {{
        emitChainChanged(nextChainId) {{
            chainId = String(nextChainId);
            emit("chainChanged", chainId);
        }},

        emitAccountsChanged(nextAccounts) {{
            accounts = Array.isArray(nextAccounts) ? [...nextAccounts] : [];
            emit("accountsChanged", [...accounts]);
        }}
    }};
}})();
"""

    try:
        with sync_playwright() as playwright:
            browser = playwright.chromium.launch(headless=True)

            context = browser.new_context(
                viewport={"width": 1440, "height": 900},
                locale="en-US",
            )

            context.expose_function("__hbSignMessage", sign_message)
            context.add_init_script(script=provider_script)

            page = context.new_page()

            def record_request(request) -> None:
                url = request.url
                for path in (
                    "/api/auth/challenge",
                    "/api/auth/verify",
                    "/api/auth/session",
                ):
                    if path in url:
                        request_paths.append(path)

            page.on("request", record_request)

            page.goto(BASE_URL, wait_until="domcontentloaded", timeout=30000)
            page.wait_for_selector("#walletButton", state="visible", timeout=15000)

            script_src = page.locator('script[src*="/app.js"]').get_attribute("src") or ""
            require(
                "/app.js?v=20260829-gate3-" in script_src,
                "Live homepage is not loading a Gate 3 frontend runtime.",
            )

            page.wait_for_function(
                "() => document.querySelector('#collectionAccessState')?.textContent?.trim() === 'UNVERIFIED'",
                timeout=15000,
            )

            require(
                "wallet-verified" not in (page.locator("body").get_attribute("class") or ""),
                "Wallet was incorrectly treated as verified before signing.",
            )

            # Click the REAL site wallet button. The injected provider behaves like
            # a minimal EVM wallet, while the auth HTTP calls go to production.
            page.locator("#walletButton").click()

            page.wait_for_function(
                "() => document.querySelector('#collectionAccessState')?.textContent?.trim() === 'VERIFIED'",
                timeout=30000,
            )

            require(sign_count == 1, "Expected exactly one personal_sign request.")
            require(
                "/api/auth/challenge" in request_paths,
                "Frontend never requested /api/auth/challenge.",
            )
            require(
                "/api/auth/verify" in request_paths,
                "Frontend never requested /api/auth/verify.",
            )

            body_class = page.locator("body").get_attribute("class") or ""
            require(
                "wallet-verified" in body_class,
                "Verified wallet body state was not applied.",
            )

            # Identity must NOT be interpreted as ownership. There are currently
            # no public publications, so renderCollection() may replace the transient
            # Harrow verification dialogue with the normal empty-Archive copy. The
            # durable invariant is that identity says VERIFIED while owned remains 00.
            owned_count = page.locator("#summaryOwned").inner_text().strip()
            require(
                owned_count == "00",
                f"Verified identity incorrectly changed owned publication count to {owned_count!r}.",
            )

            stored_session_raw = page.evaluate(
                f"() => window.sessionStorage.getItem({json.dumps(SESSION_STORAGE_KEY)})"
            )
            require(
                isinstance(stored_session_raw, str) and stored_session_raw,
                "Verified wallet session was not stored in sessionStorage.",
            )

            stored_session = json.loads(stored_session_raw)
            require(
                stored_session.get("address", "").lower() == address,
                "Stored wallet session address does not match the throwaway wallet.",
            )
            require(
                int(stored_session.get("chainId", 0)) == PULSECHAIN_ID,
                "Stored wallet session is not bound to PulseChain 369.",
            )
            require(
                isinstance(stored_session.get("token"), str) and stored_session["token"],
                "Stored wallet session is missing its bearer token.",
            )

            # Reload the real site. No second signature should happen: the browser
            # must restore identity by asking the Worker to validate the D1 session.
            request_paths.clear()
            page.reload(wait_until="domcontentloaded", timeout=30000)

            page.wait_for_function(
                "() => document.querySelector('#collectionAccessState')?.textContent?.trim() === 'VERIFIED'",
                timeout=30000,
            )

            require(sign_count == 1, "Reload unexpectedly requested another signature.")
            require(
                "/api/auth/session" in request_paths,
                "Reload did not validate the stored session through /api/auth/session.",
            )

            # A chain change must immediately clear browser-side trust. This does
            # not revoke the D1 row; the finally block deletes the throwaway rows.
            page.evaluate(
                f"() => window.__hbWalletAcceptance.emitChainChanged({json.dumps(hex(1))})"
            )

            page.wait_for_function(
                "() => document.querySelector('#collectionAccessState')?.textContent?.trim() === 'WRONG CHAIN'",
                timeout=15000,
            )

            cleared_session = page.evaluate(
                f"() => window.sessionStorage.getItem({json.dumps(SESSION_STORAGE_KEY)})"
            )
            require(
                cleared_session is None,
                "Chain change did not clear the browser wallet session.",
            )

            context.close()
            browser.close()
            browser = None

    except Exception as error:
        test_error = error

    finally:
        if browser is not None:
            try:
                browser.close()
            except Exception:
                pass

        try:
            cleanup_remote_identity(repo_root, address)
        except Exception as error:
            cleanup_error = error

    if test_error is not None:
        print(f"Gate 3 live wallet browser acceptance: FAIL")
        print(f"Reason: {test_error}")
        if cleanup_error is None:
            print("Throwaway D1 auth records cleanup: PASS")
        else:
            print(f"Throwaway D1 auth records cleanup: FAIL")
        return 1

    if cleanup_error is not None:
        print("Gate 3 live wallet browser acceptance: PASS")
        print("Throwaway D1 auth records cleanup: FAIL")
        return 1

    print("Gate 3 live wallet browser acceptance: PASS")
    print("Real challenge endpoint: PASS")
    print("Real personal_sign flow: PASS")
    print("Real verify endpoint: PASS")
    print("UI identity state VERIFIED: PASS")
    print("Identity remains separate from ownership: PASS")
    print("D1 session restore after reload: PASS")
    print("Chain-change session clearing: PASS")
    print("Throwaway D1 auth records cleanup: PASS")
    print("Private key/signature/session token printed: NO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

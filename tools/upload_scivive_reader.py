#!/usr/bin/env python3
"""
Hellbox Comics — SciVive Reader R2 uploader/verifier
Gate 2: Reader vertical slice

Purpose
-------
Upload the already-built SciVive Reader manifest and 461 verified WebP page
assets to the private Hellbox R2 bucket, then download every object back from
R2 and verify its SHA-256 against the local source bytes.

This tool deliberately does NOT:
- modify D1
- modify the Worker
- publish SciVive
- make the private bucket public
- commit generated Reader pages to Git

Expected inputs
---------------
Repository:
    publications/scivive/reader/manifest.json

Build output from tools/build_scivive_reader.py:
    ~/.hellbox/build/scivive-reader/build-report.json
    ~/.hellbox/build/scivive-reader/pages/page-0001.webp
    ...
    ~/.hellbox/build/scivive-reader/pages/page-0461.webp

Remote destination
------------------
Bucket:
    hellbox-private

Keys:
    comics/scivive/001/reader/manifest.json
    comics/scivive/001/reader/pages/page-0001.webp
    ...
    comics/scivive/001/reader/pages/page-0461.webp

Usage
-----
From the Hellbox repository root:

    python tools/upload_scivive_reader.py --self-test
    python tools/upload_scivive_reader.py --preflight
    python tools/upload_scivive_reader.py

To re-check R2 later without uploading again:

    python tools/upload_scivive_reader.py --verify-only

Security / authority
--------------------
The script uses the existing authenticated Wrangler session on the local
machine. It never reads, prints, stores, or asks for Cloudflare API tokens.
"""

from __future__ import print_function

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple


PUBLICATION_KEY = "scivive"
EXPECTED_PAGE_COUNT = 461
EXPECTED_SOURCE_BYTES = 8_433_084
EXPECTED_SOURCE_SHA256 = (
    "d105e16e991944b63d8e696c8236f5b4497d3c959119a87e580f46f2181bc548"
)
EXPECTED_IPFS_CID = "QmWKTwYfhMDksDwz5eMwsw8YFJC8yYwPLFZxWAbUyDS2EH"

R2_BUCKET = "hellbox-private"
R2_MANIFEST_KEY = "comics/scivive/001/reader/manifest.json"
R2_PAGE_PREFIX = "comics/scivive/001/reader/pages/"

MANIFEST_PATH = Path("publications/scivive/reader/manifest.json")
DEFAULT_BUILD_DIR = Path.home() / ".hellbox" / "build" / "scivive-reader"
STATE_FILENAME = "r2-upload-state.json"
REPORT_FILENAME = "r2-verification-report.json"

# Gate 2 is being executed against this known-working Wrangler major/minor.
# Override only when intentionally testing another version:
#   export HELLBOX_WRANGLER_PACKAGE="wrangler@4.127.1"
WRANGLER_PACKAGE = os.environ.get(
    "HELLBOX_WRANGLER_PACKAGE",
    "wrangler@4.127.1",
)

PAGE_RE = re.compile(r"^page-(\d{4})\.webp$")


@dataclass(frozen=True)
class UploadObject:
    logical_name: str
    local_path: Path
    remote_key: str
    content_type: str
    byte_size: int
    sha256: str


class HellboxError(RuntimeError):
    pass


def die(message: str, exit_code: int = 1) -> None:
    print("ERROR: " + message, file=sys.stderr)
    raise SystemExit(exit_code)


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise HellboxError("Missing required file: %s" % path)
    except json.JSONDecodeError as exc:
        raise HellboxError("Invalid JSON in %s: %s" % (path, exc))
    except OSError as exc:
        raise HellboxError("Could not read %s: %s" % (path, exc))


def write_json_atomic(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def is_webp(path: Path) -> bool:
    try:
        with path.open("rb") as handle:
            header = handle.read(12)
    except OSError:
        return False
    return len(header) == 12 and header[:4] == b"RIFF" and header[8:12] == b"WEBP"


def require_repo_root(repo_root: Path) -> None:
    required = [
        repo_root / "wrangler.jsonc",
        repo_root / MANIFEST_PATH,
        repo_root / "publications" / "scivive" / "publication.json",
    ]
    missing = [str(path) for path in required if not path.exists()]
    if missing:
        raise HellboxError(
            "Run this command from the Hellbox repository root. Missing: "
            + ", ".join(missing)
        )


def validate_wrangler_bucket(repo_root: Path) -> None:
    config_path = repo_root / "wrangler.jsonc"
    text = config_path.read_text(encoding="utf-8")

    if '"bucket_name": "hellbox-private"' not in text:
        raise HellboxError(
            "wrangler.jsonc does not declare the required hellbox-private bucket."
        )
    if '"binding": "PRIVATE_BUCKET"' not in text:
        raise HellboxError(
            "wrangler.jsonc does not declare the PRIVATE_BUCKET binding."
        )


def validate_manifest(manifest: dict) -> List[dict]:
    failures = []

    if manifest.get("publicationKey") != PUBLICATION_KEY:
        failures.append("publicationKey must be scivive")
    if manifest.get("pageCount") != EXPECTED_PAGE_COUNT:
        failures.append("pageCount must be %d" % EXPECTED_PAGE_COUNT)

    source = manifest.get("source") or {}
    if source.get("byteSize") != EXPECTED_SOURCE_BYTES:
        failures.append("source.byteSize does not match canonical SciVive")
    if str(source.get("sha256", "")).lower() != EXPECTED_SOURCE_SHA256:
        failures.append("source.sha256 does not match canonical SciVive")
    if source.get("pageCount") != EXPECTED_PAGE_COUNT:
        failures.append("source.pageCount does not match canonical SciVive")
    if source.get("verifiedIpfsCid") != EXPECTED_IPFS_CID:
        failures.append("source.verifiedIpfsCid does not match canonical SciVive")

    delivery = manifest.get("delivery") or {}
    if delivery.get("provider") != "r2_private":
        failures.append("delivery.provider must be r2_private")
    if delivery.get("accessClass") != "reader_gated":
        failures.append("delivery.accessClass must be reader_gated")
    if delivery.get("manifestKey") != R2_MANIFEST_KEY:
        failures.append("delivery.manifestKey is not the locked Gate 2 key")
    if delivery.get("assetPrefix") != R2_PAGE_PREFIX:
        failures.append("delivery.assetPrefix is not the locked Gate 2 prefix")
    if delivery.get("pageMediaType") != "image/webp":
        failures.append("delivery.pageMediaType must be image/webp")

    pages = manifest.get("pages")
    if not isinstance(pages, list) or len(pages) != EXPECTED_PAGE_COUNT:
        failures.append("pages must contain exactly %d entries" % EXPECTED_PAGE_COUNT)
        pages = []

    seen_storage_keys = set()
    for index, page in enumerate(pages, start=1):
        expected_name = "page-%04d.webp" % index
        if page.get("pageNumber") != index:
            failures.append("page %d has the wrong pageNumber" % index)
        storage_key = page.get("storageKey")
        if storage_key != expected_name:
            failures.append(
                "page %d storageKey must be %s" % (index, expected_name)
            )
        if storage_key in seen_storage_keys:
            failures.append("duplicate storageKey: %s" % storage_key)
        seen_storage_keys.add(storage_key)
        if page.get("mediaType") != "image/webp":
            failures.append("page %d mediaType must be image/webp" % index)

    if failures:
        raise HellboxError("Reader manifest validation failed: " + "; ".join(failures))

    return pages


def validate_build_report(report: dict) -> None:
    failures = []

    if report.get("publicationKey") != PUBLICATION_KEY:
        failures.append("publicationKey is not scivive")

    source = report.get("source") or {}
    if source.get("byte_size") != EXPECTED_SOURCE_BYTES:
        failures.append("source.byte_size does not match")
    if str(source.get("sha256", "")).lower() != EXPECTED_SOURCE_SHA256:
        failures.append("source.sha256 does not match")
    if source.get("page_count") != EXPECTED_PAGE_COUNT:
        failures.append("source.page_count does not match")
    if source.get("verifiedIpfsCid") != EXPECTED_IPFS_CID:
        failures.append("source.verifiedIpfsCid does not match")

    render = report.get("render") or {}
    if render.get("total_pages") != EXPECTED_PAGE_COUNT:
        failures.append("render.total_pages does not match")
    if not isinstance(render.get("total_output_bytes"), int) or render.get(
        "total_output_bytes", 0
    ) <= 0:
        failures.append("render.total_output_bytes is invalid")

    delivery = report.get("delivery") or {}
    if delivery.get("bucket") != R2_BUCKET:
        failures.append("delivery.bucket is not hellbox-private")
    if delivery.get("manifestKey") != R2_MANIFEST_KEY:
        failures.append("delivery.manifestKey does not match")
    if delivery.get("pagePrefix") != R2_PAGE_PREFIX:
        failures.append("delivery.pagePrefix does not match")

    git_policy = report.get("gitPolicy") or {}
    if git_policy.get("generatedReaderPagesBelongInGit") is not False:
        failures.append("build report Git policy is not locked to false")
    if git_policy.get("generatedReaderPagesBelongInR2") is not True:
        failures.append("build report R2 policy is not locked to true")

    if failures:
        raise HellboxError("Reader build report validation failed: " + "; ".join(failures))


def build_upload_plan(
    repo_root: Path,
    build_dir: Path,
    manifest: dict,
    pages: List[dict],
) -> Tuple[List[UploadObject], int]:
    manifest_path = repo_root / MANIFEST_PATH
    pages_dir = build_dir / "pages"

    if not pages_dir.is_dir():
        raise HellboxError(
            "Reader pages directory is missing: %s. Run the builder first." % pages_dir
        )

    disk_page_paths = sorted(pages_dir.glob("page-*.webp"))
    if len(disk_page_paths) != EXPECTED_PAGE_COUNT:
        raise HellboxError(
            "Expected exactly %d page-*.webp files, found %d."
            % (EXPECTED_PAGE_COUNT, len(disk_page_paths))
        )

    expected_names = {"page-%04d.webp" % number for number in range(1, 462)}
    actual_names = {path.name for path in disk_page_paths}
    if actual_names != expected_names:
        missing = sorted(expected_names - actual_names)
        extras = sorted(actual_names - expected_names)
        raise HellboxError(
            "Reader page filename set is wrong. Missing=%s Extras=%s"
            % (missing[:10], extras[:10])
        )

    objects = []

    manifest_size = manifest_path.stat().st_size
    manifest_sha = sha256_file(manifest_path)
    objects.append(
        UploadObject(
            logical_name="manifest",
            local_path=manifest_path,
            remote_key=R2_MANIFEST_KEY,
            content_type="application/json",
            byte_size=manifest_size,
            sha256=manifest_sha,
        )
    )

    total_page_bytes = 0
    for index, page in enumerate(pages, start=1):
        storage_key = page["storageKey"]
        if Path(storage_key).name != storage_key or not PAGE_RE.match(storage_key):
            raise HellboxError("Unsafe Reader storageKey: %s" % storage_key)

        page_path = pages_dir / storage_key
        if not page_path.is_file():
            raise HellboxError("Missing Reader page: %s" % page_path)
        size = page_path.stat().st_size
        if size <= 0:
            raise HellboxError("Reader page is empty: %s" % page_path)
        if not is_webp(page_path):
            raise HellboxError("Reader page is not a valid WebP container: %s" % page_path)

        digest = sha256_file(page_path)
        total_page_bytes += size
        objects.append(
            UploadObject(
                logical_name="page-%04d" % index,
                local_path=page_path,
                remote_key=R2_PAGE_PREFIX + storage_key,
                content_type="image/webp",
                byte_size=size,
                sha256=digest,
            )
        )

    report = load_json(build_dir / "build-report.json")
    render = report.get("render") or {}
    reported_total = render.get("total_output_bytes")
    if reported_total != total_page_bytes:
        raise HellboxError(
            "Generated page byte total (%d) does not match build report (%s)."
            % (total_page_bytes, reported_total)
        )

    return objects, total_page_bytes


def wrangler_base_command() -> List[str]:
    return ["npx", "--yes", WRANGLER_PACKAGE]


def run_command(command: List[str], cwd: Path) -> subprocess.CompletedProcess:
    return subprocess.run(
        command,
        cwd=str(cwd),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )


def check_wrangler(repo_root: Path) -> str:
    command = wrangler_base_command() + ["--version"]
    result = run_command(command, repo_root)
    if result.returncode != 0:
        detail = (result.stderr or result.stdout or "unknown error").strip()
        raise HellboxError("Wrangler is unavailable: %s" % detail)
    output = (result.stdout or result.stderr).strip()
    return output


def r2_object_path(obj: UploadObject) -> str:
    return R2_BUCKET + "/" + obj.remote_key


def upload_one(repo_root: Path, obj: UploadObject) -> None:
    command = wrangler_base_command() + [
        "r2",
        "object",
        "put",
        r2_object_path(obj),
        "--file",
        str(obj.local_path),
        "--content-type",
        obj.content_type,
        "--remote",
        "--force",
    ]
    result = run_command(command, repo_root)
    if result.returncode != 0:
        detail = (result.stderr or result.stdout or "unknown error").strip()
        raise HellboxError(
            "R2 upload failed for %s: %s" % (obj.remote_key, detail)
        )


def download_and_hash(repo_root: Path, obj: UploadObject, temp_dir: Path) -> Tuple[int, str]:
    destination = temp_dir / (obj.logical_name + ".remote")
    destination.unlink(missing_ok=True)

    command = wrangler_base_command() + [
        "r2",
        "object",
        "get",
        r2_object_path(obj),
        "--file",
        str(destination),
        "--remote",
    ]
    result = run_command(command, repo_root)
    if result.returncode != 0:
        detail = (result.stderr or result.stdout or "unknown error").strip()
        raise HellboxError(
            "R2 verification download failed for %s: %s" % (obj.remote_key, detail)
        )
    if not destination.is_file():
        raise HellboxError(
            "Wrangler reported success but created no verification file for %s"
            % obj.remote_key
        )

    size = destination.stat().st_size
    digest = sha256_file(destination)
    destination.unlink(missing_ok=True)
    return size, digest


def object_identity(obj: UploadObject) -> dict:
    return {
        "remoteKey": obj.remote_key,
        "byteSize": obj.byte_size,
        "sha256": obj.sha256,
        "contentType": obj.content_type,
    }


def load_state(path: Path) -> dict:
    if not path.exists():
        return {
            "schemaVersion": "1.0.0",
            "publicationKey": PUBLICATION_KEY,
            "bucket": R2_BUCKET,
            "objects": {},
        }
    state = load_json(path)
    if state.get("publicationKey") != PUBLICATION_KEY or state.get("bucket") != R2_BUCKET:
        raise HellboxError("Existing R2 upload state belongs to a different target.")
    if not isinstance(state.get("objects"), dict):
        raise HellboxError("Existing R2 upload state is malformed.")
    return state


def state_has_matching_upload(state: dict, obj: UploadObject) -> bool:
    entry = state.get("objects", {}).get(obj.remote_key) or {}
    return (
        entry.get("uploaded") is True
        and entry.get("byteSize") == obj.byte_size
        and entry.get("sha256") == obj.sha256
    )


def mark_uploaded(state_path: Path, state: dict, obj: UploadObject) -> None:
    entry = object_identity(obj)
    entry.update(
        {
            "uploaded": True,
            "uploadedAtUnix": int(time.time()),
            "verified": False,
        }
    )
    state.setdefault("objects", {})[obj.remote_key] = entry
    write_json_atomic(state_path, state)


def mark_verified(state_path: Path, state: dict, obj: UploadObject) -> None:
    entry = state.setdefault("objects", {}).get(obj.remote_key) or object_identity(obj)
    entry.update(object_identity(obj))
    entry.update(
        {
            "uploaded": True,
            "verified": True,
            "verifiedAtUnix": int(time.time()),
        }
    )
    state["objects"][obj.remote_key] = entry
    write_json_atomic(state_path, state)


def progress_label(index: int, total: int) -> str:
    if index == 1:
        return "manifest"
    return "page %04d/%04d" % (index - 1, total - 1)


def should_print_progress(index: int, total: int) -> bool:
    if index == 1 or index == total:
        return True
    page_number = index - 1
    return page_number == 1 or page_number % 25 == 0 or page_number == EXPECTED_PAGE_COUNT


def perform_upload(
    repo_root: Path,
    objects: List[UploadObject],
    state_path: Path,
    state: dict,
    reupload: bool,
) -> Tuple[int, int]:
    uploaded = 0
    reused = 0
    total = len(objects)

    print()
    print("Uploading protected Reader objects to R2...")
    for index, obj in enumerate(objects, start=1):
        if not reupload and state_has_matching_upload(state, obj):
            reused += 1
        else:
            upload_one(repo_root, obj)
            mark_uploaded(state_path, state, obj)
            uploaded += 1

        if should_print_progress(index, total):
            verb = "uploaded" if not state_has_matching_upload(state, obj) else "ready"
            # mark_uploaded makes the state match; use a neutral status in output.
            print("R2 upload ready: %s" % progress_label(index, total))

    return uploaded, reused


def perform_verification(
    repo_root: Path,
    objects: List[UploadObject],
    state_path: Path,
    state: dict,
) -> None:
    total = len(objects)
    print()
    print("Verifying every protected Reader object by downloading it from remote R2...")

    with tempfile.TemporaryDirectory(prefix="hellbox-r2-verify-") as temp_name:
        temp_dir = Path(temp_name)
        for index, obj in enumerate(objects, start=1):
            remote_size, remote_sha = download_and_hash(repo_root, obj, temp_dir)
            if remote_size != obj.byte_size:
                raise HellboxError(
                    "Remote byte-size mismatch for %s: %d != %d"
                    % (obj.remote_key, remote_size, obj.byte_size)
                )
            if remote_sha.lower() != obj.sha256.lower():
                raise HellboxError(
                    "Remote SHA-256 mismatch for %s: %s != %s"
                    % (obj.remote_key, remote_sha, obj.sha256)
                )

            mark_verified(state_path, state, obj)

            if should_print_progress(index, total):
                print("R2 verification PASS: %s" % progress_label(index, total))


def write_verification_report(
    report_path: Path,
    objects: List[UploadObject],
    total_page_bytes: int,
    wrangler_version: str,
) -> None:
    payload = {
        "schemaVersion": "1.0.0",
        "publicationKey": PUBLICATION_KEY,
        "verifiedAtUnix": int(time.time()),
        "wrangler": wrangler_version,
        "bucket": R2_BUCKET,
        "manifestKey": R2_MANIFEST_KEY,
        "pagePrefix": R2_PAGE_PREFIX,
        "objectCount": len(objects),
        "pageCount": EXPECTED_PAGE_COUNT,
        "pageBytes": total_page_bytes,
        "allObjectsDownloadedAndSha256Verified": True,
        "manifest": object_identity(objects[0]),
        "firstPage": object_identity(objects[1]),
        "lastPage": object_identity(objects[-1]),
        "source": {
            "byteSize": EXPECTED_SOURCE_BYTES,
            "sha256": EXPECTED_SOURCE_SHA256,
            "verifiedIpfsCid": EXPECTED_IPFS_CID,
        },
    }
    write_json_atomic(report_path, payload)


def run_self_test() -> None:
    with tempfile.TemporaryDirectory(prefix="hellbox-r2-uploader-selftest-") as temp_name:
        root = Path(temp_name)
        sample = root / "page-0001.webp"
        sample.write_bytes(b"RIFF" + (4).to_bytes(4, "little") + b"WEBP" + b"TEST")
        if not is_webp(sample):
            die("Uploader self-test WebP detection failed.")

        digest = sha256_file(sample)
        if len(digest) != 64:
            die("Uploader self-test SHA-256 failed.")

        state_path = root / "state.json"
        obj = UploadObject(
            logical_name="page-0001",
            local_path=sample,
            remote_key=R2_PAGE_PREFIX + sample.name,
            content_type="image/webp",
            byte_size=sample.stat().st_size,
            sha256=digest,
        )
        state = load_state(state_path)
        if state_has_matching_upload(state, obj):
            die("Uploader self-test fresh state incorrectly matched an upload.")
        mark_uploaded(state_path, state, obj)
        if not state_has_matching_upload(state, obj):
            die("Uploader self-test resumable state failed.")
        mark_verified(state_path, state, obj)
        persisted = load_state(state_path)
        if not persisted["objects"][obj.remote_key].get("verified"):
            die("Uploader self-test verification state failed.")

    print("Hellbox Reader R2 uploader self-test: PASS")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Upload and cryptographically verify SciVive Reader presentation assets "
            "in the private Hellbox R2 bucket."
        )
    )
    parser.add_argument(
        "--build-dir",
        default=str(DEFAULT_BUILD_DIR),
        help="Reader build directory (default: %(default)s)",
    )
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="Test local uploader logic without contacting Cloudflare.",
    )
    parser.add_argument(
        "--preflight",
        action="store_true",
        help="Validate manifest/build/pages/Wrangler but do not upload anything.",
    )
    parser.add_argument(
        "--verify-only",
        action="store_true",
        help="Do not upload; download and SHA-256 verify every expected remote object.",
    )
    parser.add_argument(
        "--reupload",
        action="store_true",
        help="Upload every object even when local resumable state says it already succeeded.",
    )
    parser.add_argument(
        "--reset-state",
        action="store_true",
        help="Delete only the local resumable upload-state file before starting.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.self_test:
        run_self_test()
        return 0

    repo_root = Path.cwd().resolve()
    build_dir = Path(args.build_dir).expanduser().resolve()
    state_path = build_dir / STATE_FILENAME
    verification_report_path = build_dir / REPORT_FILENAME

    try:
        require_repo_root(repo_root)
        validate_wrangler_bucket(repo_root)

        manifest = load_json(repo_root / MANIFEST_PATH)
        pages = validate_manifest(manifest)

        build_report = load_json(build_dir / "build-report.json")
        validate_build_report(build_report)

        objects, total_page_bytes = build_upload_plan(
            repo_root=repo_root,
            build_dir=build_dir,
            manifest=manifest,
            pages=pages,
        )

        if len(objects) != EXPECTED_PAGE_COUNT + 1:
            raise HellboxError(
                "Upload plan must contain 1 manifest + %d pages." % EXPECTED_PAGE_COUNT
            )

        wrangler_version = check_wrangler(repo_root)

        if args.reset_state:
            state_path.unlink(missing_ok=True)

        state = load_state(state_path)

        print("Gate 2 Reader R2 preflight: PASS")
        print("Publication: %s" % PUBLICATION_KEY)
        print("Wrangler: %s" % wrangler_version)
        print("R2 bucket: %s" % R2_BUCKET)
        print("Manifest key: %s" % R2_MANIFEST_KEY)
        print("Page prefix: %s" % R2_PAGE_PREFIX)
        print("Reader pages: %d" % EXPECTED_PAGE_COUNT)
        print("Objects in upload plan: %d" % len(objects))
        print("Reader page bytes: %s" % format(total_page_bytes, ","))
        print("First page: %s" % objects[1].remote_key)
        print("Last page: %s" % objects[-1].remote_key)
        print("Local resumable state: %s" % state_path)

        if args.preflight:
            print("No files were uploaded to R2 by this preflight command.")
            return 0

        if args.verify_only:
            perform_verification(repo_root, objects, state_path, state)
            uploaded_count = 0
            reused_count = 0
        else:
            uploaded_count, reused_count = perform_upload(
                repo_root=repo_root,
                objects=objects,
                state_path=state_path,
                state=state,
                reupload=args.reupload,
            )
            perform_verification(repo_root, objects, state_path, state)

        write_verification_report(
            report_path=verification_report_path,
            objects=objects,
            total_page_bytes=total_page_bytes,
            wrangler_version=wrangler_version,
        )

        print()
        print("Gate 2 SciVive private R2 delivery: PASS")
        print("Remote objects verified: %d" % len(objects))
        print("Remote Reader pages verified: %d" % EXPECTED_PAGE_COUNT)
        if not args.verify_only:
            print("Uploaded this run: %d" % uploaded_count)
            print("Reused from resumable state: %d" % reused_count)
        print("Every remote object matched local byte size and SHA-256.")
        print("Verification report: %s" % verification_report_path)
        print("No D1 records or Worker code were changed by this command.")
        return 0

    except HellboxError as exc:
        die(str(exc))

    return 1


if __name__ == "__main__":
    raise SystemExit(main())

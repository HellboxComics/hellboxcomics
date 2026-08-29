#!/usr/bin/env python3
"""Build the SciVive facsimile assets used by the Hellbox BOOK Reader.

This tool is intentionally strict. It will only build from the verified SciVive
PDF fingerprint already locked by Hellbox Gate 1 / Gate 2, and it validates the
committed Reader manifest before reporting success.

Generated presentation assets are build output only. They belong in R2, not Git.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sys
import tempfile
import time
import urllib.error
import urllib.request
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable

PUBLICATION_KEY = "scivive"
EXPECTED_SOURCE_BYTES = 8_433_084
EXPECTED_SOURCE_SHA256 = (
    "d105e16e991944b63d8e696c8236f5b4497d3c959119a87e580f46f2181bc548"
)
EXPECTED_PAGE_COUNT = 461
EXPECTED_IPFS_CID = "QmWKTwYfhMDksDwz5eMwsw8YFJC8yYwPLFZxWAbUyDS2EH"

MANIFEST_PATH = Path("publications/scivive/reader/manifest.json")
DEFAULT_BUILD_DIR = Path.home() / ".hellbox" / "build" / "scivive-reader"
DEFAULT_TARGET_WIDTH = 1800
DEFAULT_WEBP_QUALITY = 90

R2_BUCKET = "hellbox-private"
R2_MANIFEST_KEY = "comics/scivive/001/reader/manifest.json"
R2_PAGE_PREFIX = "comics/scivive/001/reader/pages/"

DEFAULT_SOURCE_URLS = (
    "https://cdn.hellboxcomics.com/comics/scivive/001/book/sciVive.pdf",
    f"https://ipfs.io/ipfs/{EXPECTED_IPFS_CID}",
)


@dataclass(frozen=True)
class SourceFingerprint:
    byte_size: int
    sha256: str
    page_count: int


@dataclass(frozen=True)
class RenderStats:
    generated: int
    reused: int
    total_pages: int
    total_output_bytes: int
    target_width_px: int
    webp_quality: int
    min_width_px: int
    max_width_px: int
    min_height_px: int
    max_height_px: int


def die(message: str, exit_code: int = 1) -> "NoReturn":
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(exit_code)


def import_render_dependencies():
    try:
        import pymupdf as fitz  # type: ignore
    except ImportError:
        try:
            import fitz  # type: ignore
        except ImportError:
            die(
                "PyMuPDF is not installed. Activate the Reader virtual environment "
                "and run: python -m pip install pymupdf pillow"
            )

    try:
        from PIL import Image  # type: ignore
    except ImportError:
        die(
            "Pillow is not installed. Activate the Reader virtual environment "
            "and run: python -m pip install pymupdf pillow"
        )

    return fitz, Image


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def fingerprint_pdf(path: Path, fitz) -> SourceFingerprint:
    if not path.is_file():
        die(f"Source PDF does not exist: {path}")

    byte_size = path.stat().st_size
    sha256 = sha256_file(path)

    try:
        with fitz.open(path) as document:
            page_count = document.page_count
    except Exception as exc:  # pragma: no cover - library-specific detail
        die(f"Could not open source PDF: {exc}")

    return SourceFingerprint(
        byte_size=byte_size,
        sha256=sha256,
        page_count=page_count,
    )


def verify_canonical_source(path: Path, fitz) -> SourceFingerprint:
    fingerprint = fingerprint_pdf(path, fitz)

    problems: list[str] = []
    if fingerprint.byte_size != EXPECTED_SOURCE_BYTES:
        problems.append(
            f"byte size {fingerprint.byte_size:,} != {EXPECTED_SOURCE_BYTES:,}"
        )
    if fingerprint.sha256.lower() != EXPECTED_SOURCE_SHA256.lower():
        problems.append(
            f"SHA-256 {fingerprint.sha256} != {EXPECTED_SOURCE_SHA256}"
        )
    if fingerprint.page_count != EXPECTED_PAGE_COUNT:
        problems.append(
            f"page count {fingerprint.page_count} != {EXPECTED_PAGE_COUNT}"
        )

    if problems:
        detail = "; ".join(problems)
        die(
            "SciVive source verification FAILED. No Reader pages were built. "
            + detail
        )

    return fingerprint


def stream_download(url: str, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    partial = destination.with_suffix(destination.suffix + ".partial")
    partial.unlink(missing_ok=True)

    request = urllib.request.Request(
        url,
        headers={
            "User-Agent": "HellboxReaderBuilder/1.0 (+https://hellboxcomics.com)"
        },
    )

    try:
        with urllib.request.urlopen(request, timeout=60) as response, partial.open(
            "wb"
        ) as output:
            shutil.copyfileobj(response, output, length=1024 * 1024)
    except (urllib.error.URLError, TimeoutError, OSError) as exc:
        partial.unlink(missing_ok=True)
        raise RuntimeError(str(exc)) from exc

    partial.replace(destination)


def acquire_source(
    explicit_source: str | None,
    cached_pdf: Path,
    fitz,
) -> tuple[Path, SourceFingerprint, str]:
    if explicit_source:
        source_path = Path(explicit_source).expanduser()
        if not source_path.is_file():
            die(
                "--source must be a local PDF file. "
                f"File not found: {source_path}"
            )
        fingerprint = verify_canonical_source(source_path, fitz)
        return source_path, fingerprint, "local"

    if cached_pdf.is_file():
        try:
            fingerprint = verify_canonical_source(cached_pdf, fitz)
            return cached_pdf, fingerprint, "verified-cache"
        except SystemExit:
            print(
                "Cached source failed verification; deleting it before retrying trusted sources."
            )
            cached_pdf.unlink(missing_ok=True)

    errors: list[str] = []
    for url in DEFAULT_SOURCE_URLS:
        print(f"Fetching verified SciVive source candidate: {url}")
        try:
            stream_download(url, cached_pdf)
            fingerprint = verify_canonical_source(cached_pdf, fitz)
            return cached_pdf, fingerprint, url
        except (RuntimeError, SystemExit) as exc:
            cached_pdf.unlink(missing_ok=True)
            errors.append(f"{url}: {exc}")
            print(f"Source candidate rejected: {url}")

    die(
        "Could not acquire a verified SciVive PDF from the configured Hellbox R2 "
        "mirror or the verified IPFS CID. You can supply the canonical file with "
        "--source /path/to/sciVive.pdf. Attempts: "
        + " | ".join(errors)
    )


def load_manifest(repo_root: Path) -> dict:
    path = repo_root / MANIFEST_PATH
    if not path.is_file():
        die(
            f"Reader manifest is missing: {path}. "
            "Run this command from the Hellbox repository root."
        )

    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        die(f"Reader manifest could not be parsed: {exc}")


def validate_manifest_contract(manifest: dict) -> None:
    failures: list[str] = []

    if manifest.get("publicationKey") != PUBLICATION_KEY:
        failures.append("publicationKey is not scivive")
    if manifest.get("pageCount") != EXPECTED_PAGE_COUNT:
        failures.append(f"pageCount is not {EXPECTED_PAGE_COUNT}")

    source = manifest.get("source") or {}
    if source.get("byteSize") != EXPECTED_SOURCE_BYTES:
        failures.append("source.byteSize does not match the locked PDF")
    if str(source.get("sha256", "")).lower() != EXPECTED_SOURCE_SHA256.lower():
        failures.append("source.sha256 does not match the locked PDF")
    if source.get("pageCount") != EXPECTED_PAGE_COUNT:
        failures.append("source.pageCount does not match the locked PDF")
    if source.get("verifiedIpfsCid") != EXPECTED_IPFS_CID:
        failures.append("source.verifiedIpfsCid does not match the locked CID")

    delivery = manifest.get("delivery") or {}
    if delivery.get("provider") != "r2_private":
        failures.append("delivery.provider must be r2_private")
    if delivery.get("manifestKey") != R2_MANIFEST_KEY:
        failures.append("delivery.manifestKey does not match the Gate 2 R2 key")
    if delivery.get("assetPrefix") != R2_PAGE_PREFIX:
        failures.append("delivery.assetPrefix does not match the Gate 2 R2 prefix")
    if delivery.get("pageMediaType") != "image/webp":
        failures.append("delivery.pageMediaType must be image/webp")

    pages = manifest.get("pages")
    if not isinstance(pages, list) or len(pages) != EXPECTED_PAGE_COUNT:
        failures.append(f"manifest must contain exactly {EXPECTED_PAGE_COUNT} pages")
    else:
        for page_number, page in enumerate(pages, start=1):
            expected_name = f"page-{page_number:04d}.webp"
            if str(page.get("id")) != str(page_number):
                failures.append(f"page {page_number}: id mismatch")
                break
            if page.get("pageNumber") != page_number:
                failures.append(f"page {page_number}: pageNumber mismatch")
                break
            if page.get("storageKey") != expected_name:
                failures.append(
                    f"page {page_number}: storageKey must be {expected_name}"
                )
                break
            if page.get("mediaType") != "image/webp":
                failures.append(f"page {page_number}: mediaType must be image/webp")
                break

    if failures:
        die("Reader manifest contract FAILED: " + "; ".join(failures))


def image_dimensions(paths: Iterable[Path], Image) -> tuple[int, int, int, int]:
    widths: list[int] = []
    heights: list[int] = []
    for path in paths:
        with Image.open(path) as image:
            widths.append(image.width)
            heights.append(image.height)

    return min(widths), max(widths), min(heights), max(heights)


def render_pages(
    source_pdf: Path,
    pages_dir: Path,
    target_width: int,
    quality: int,
    rebuild: bool,
    fitz,
    Image,
) -> RenderStats:
    pages_dir.mkdir(parents=True, exist_ok=True)

    if rebuild:
        for stale in pages_dir.glob("page-*.webp"):
            stale.unlink()

    generated = 0
    reused = 0

    with fitz.open(source_pdf) as document:
        if document.page_count != EXPECTED_PAGE_COUNT:
            die(
                "Source page count changed between verification and render; refusing build."
            )

        for index in range(EXPECTED_PAGE_COUNT):
            page_number = index + 1
            output = pages_dir / f"page-{page_number:04d}.webp"

            if output.is_file() and output.stat().st_size > 0 and not rebuild:
                reused += 1
            else:
                page = document.load_page(index)
                width_points = float(page.rect.width)
                if width_points <= 0:
                    die(f"Page {page_number} has an invalid PDF width.")

                scale = target_width / width_points
                pixmap = page.get_pixmap(
                    matrix=fitz.Matrix(scale, scale),
                    alpha=False,
                    colorspace=fitz.csRGB,
                )

                image = Image.frombytes(
                    "RGB",
                    (pixmap.width, pixmap.height),
                    pixmap.samples,
                )
                image.save(
                    output,
                    format="WEBP",
                    quality=quality,
                    method=6,
                )
                image.close()
                generated += 1

            if page_number == 1 or page_number % 25 == 0 or page_number == EXPECTED_PAGE_COUNT:
                print(
                    f"Rendered/verified page {page_number:04d}/{EXPECTED_PAGE_COUNT:04d}"
                )

    expected_paths = [
        pages_dir / f"page-{page_number:04d}.webp"
        for page_number in range(1, EXPECTED_PAGE_COUNT + 1)
    ]

    missing = [str(path) for path in expected_paths if not path.is_file()]
    if missing:
        die(f"Reader build is incomplete; missing {len(missing)} page asset(s).")

    unexpected = sorted(pages_dir.glob("page-*.webp"))
    if len(unexpected) != EXPECTED_PAGE_COUNT:
        die(
            "Reader page directory does not contain exactly "
            f"{EXPECTED_PAGE_COUNT} WebP page assets. Found {len(unexpected)}."
        )

    min_width, max_width, min_height, max_height = image_dimensions(
        expected_paths, Image
    )
    total_output_bytes = sum(path.stat().st_size for path in expected_paths)

    return RenderStats(
        generated=generated,
        reused=reused,
        total_pages=EXPECTED_PAGE_COUNT,
        total_output_bytes=total_output_bytes,
        target_width_px=target_width,
        webp_quality=quality,
        min_width_px=min_width,
        max_width_px=max_width,
        min_height_px=min_height,
        max_height_px=max_height,
    )


def write_build_report(
    build_dir: Path,
    fingerprint: SourceFingerprint,
    source_origin: str,
    render_stats: RenderStats,
) -> Path:
    report_path = build_dir / "build-report.json"
    report = {
        "schemaVersion": "1.0.0",
        "publicationKey": PUBLICATION_KEY,
        "builtAtUnix": int(time.time()),
        "source": {
            "origin": source_origin,
            **asdict(fingerprint),
            "verifiedIpfsCid": EXPECTED_IPFS_CID,
        },
        "render": asdict(render_stats),
        "delivery": {
            "bucket": R2_BUCKET,
            "manifestKey": R2_MANIFEST_KEY,
            "pagePrefix": R2_PAGE_PREFIX,
            "firstPageKey": R2_PAGE_PREFIX + "page-0001.webp",
            "lastPageKey": R2_PAGE_PREFIX + "page-0461.webp",
        },
        "gitPolicy": {
            "generatedReaderPagesBelongInGit": False,
            "generatedReaderPagesBelongInR2": True,
        },
    }
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    return report_path


def run_self_test() -> None:
    fitz, Image = import_render_dependencies()

    with tempfile.TemporaryDirectory(prefix="hellbox-reader-selftest-") as temp_name:
        temp_dir = Path(temp_name)
        pdf_path = temp_dir / "fixture.pdf"
        pages_dir = temp_dir / "pages"

        document = fitz.open()
        for number in range(1, 4):
            page = document.new_page(width=612, height=792)
            page.insert_text(
                (72, 96),
                f"Hellbox Reader self-test page {number}",
                fontsize=18,
            )
        document.save(pdf_path)
        document.close()

        with fitz.open(pdf_path) as fixture:
            if fixture.page_count != 3:
                die("Self-test fixture PDF page count is wrong.")

            for index in range(3):
                page = fixture.load_page(index)
                scale = 900 / float(page.rect.width)
                pixmap = page.get_pixmap(
                    matrix=fitz.Matrix(scale, scale),
                    alpha=False,
                    colorspace=fitz.csRGB,
                )
                image = Image.frombytes(
                    "RGB",
                    (pixmap.width, pixmap.height),
                    pixmap.samples,
                )
                pages_dir.mkdir(parents=True, exist_ok=True)
                output = pages_dir / f"page-{index + 1:04d}.webp"
                image.save(output, format="WEBP", quality=90, method=6)
                image.close()

        outputs = sorted(pages_dir.glob("page-*.webp"))
        if len(outputs) != 3 or any(path.stat().st_size == 0 for path in outputs):
            die("Self-test WebP rendering failed.")

        with Image.open(outputs[0]) as image:
            if image.format != "WEBP" or image.width != 900:
                die("Self-test WebP verification failed.")

    print("Hellbox Reader builder self-test: PASS")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build verified SciVive WebP pages for the Hellbox BOOK Reader."
    )
    parser.add_argument(
        "--source",
        help=(
            "Optional local canonical sciVive.pdf. Without this option, the tool "
            "uses its verified cache, then the Hellbox public R2 mirror, then IPFS."
        ),
    )
    parser.add_argument(
        "--build-dir",
        default=str(DEFAULT_BUILD_DIR),
        help=f"Build output directory (default: {DEFAULT_BUILD_DIR})",
    )
    parser.add_argument(
        "--target-width",
        type=int,
        default=DEFAULT_TARGET_WIDTH,
        help=f"Rendered page width in pixels (default: {DEFAULT_TARGET_WIDTH})",
    )
    parser.add_argument(
        "--quality",
        type=int,
        default=DEFAULT_WEBP_QUALITY,
        help=f"WebP quality 1-100 (default: {DEFAULT_WEBP_QUALITY})",
    )
    parser.add_argument(
        "--rebuild",
        action="store_true",
        help="Delete existing page-*.webp files and render every page again.",
    )
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="Verify local PDF-to-WebP dependencies without downloading SciVive.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.self_test:
        run_self_test()
        return 0

    if args.target_width < 1000 or args.target_width > 3200:
        die("--target-width must be between 1000 and 3200 pixels.")
    if args.quality < 70 or args.quality > 100:
        die("--quality must be between 70 and 100.")

    repo_root = Path.cwd().resolve()
    manifest = load_manifest(repo_root)
    validate_manifest_contract(manifest)
    print("Reader manifest contract: PASS")

    fitz, Image = import_render_dependencies()

    requested_build_dir = Path(args.build_dir).expanduser()
    build_dir = (requested_build_dir if requested_build_dir.is_absolute() else repo_root / requested_build_dir).resolve()
    source_cache = build_dir / "source" / "sciVive.pdf"
    pages_dir = build_dir / "pages"

    source_pdf, fingerprint, source_origin = acquire_source(
        args.source,
        source_cache,
        fitz,
    )

    print("SciVive source verification: PASS")
    print(f"Source bytes: {fingerprint.byte_size:,}")
    print(f"Source SHA-256: {fingerprint.sha256}")
    print(f"Source pages: {fingerprint.page_count}")

    render_stats = render_pages(
        source_pdf=source_pdf,
        pages_dir=pages_dir,
        target_width=args.target_width,
        quality=args.quality,
        rebuild=args.rebuild,
        fitz=fitz,
        Image=Image,
    )

    report_path = write_build_report(
        build_dir=build_dir,
        fingerprint=fingerprint,
        source_origin=source_origin,
        render_stats=render_stats,
    )

    print()
    print("Gate 2 SciVive Reader asset build: PASS")
    print(f"Reader pages: {render_stats.total_pages}")
    print(f"Newly rendered: {render_stats.generated}")
    print(f"Reused: {render_stats.reused}")
    print(f"Output bytes: {render_stats.total_output_bytes:,}")
    print(
        "Rendered dimensions: "
        f"{render_stats.min_width_px}-{render_stats.max_width_px}px wide x "
        f"{render_stats.min_height_px}-{render_stats.max_height_px}px high"
    )
    print(f"Pages directory: {pages_dir}")
    print(f"Build report: {report_path}")
    print(f"R2 bucket: {R2_BUCKET}")
    print(f"R2 page prefix: {R2_PAGE_PREFIX}")
    print("No files were uploaded to R2 by this command.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

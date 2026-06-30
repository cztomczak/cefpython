# Copyright (c) 2026 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""
Download CEF binaries from Spotify Automated Builds.

Reads the required CEF version from src/version/cef_version_*.h, queries
the Spotify CDN index to find the matching standard distribution, downloads
it with progress output, verifies the SHA1 checksum, and extracts it to the
build/ directory.

The extracted directory (eg. build/cef_binary_3.2883.1553.g80bd606_windows64/)
is exactly what automate.py --prebuilt-cef expects.

Usage:
    download_cef.py [--build-dir=<dir>] [--platform=<plat>]
                    [--no-extract] [--keep-archive] [--dry-run]
    download_cef.py (-h | --help)

Options:
    -h --help               Show this help message.
    --build-dir=<dir>       Build directory [default: cefpython/build/].
    --platform=<plat>       CEF platform postfix to download, eg. windows64,
                            linux64, macosx64. Defaults to current platform.
    --no-extract            Download the archive but do not extract it.
    --keep-archive          Keep the archive file after extraction.
    --dry-run               Print what would be done without downloading.

Typical workflow:
    python tools/download_cef.py
    python tools/automate.py --prebuilt-cef
    python tools/build.py xx.x
"""

import argparse
import hashlib
import json
import os
import time
import sys
import tarfile
import zipfile

# Allow running from any directory
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common

SPOTIFY_CDN_BASE = "https://cef-builds.spotifycdn.com"
SPOTIFY_INDEX_URL = SPOTIFY_CDN_BASE + "/index.json"

SCRIPT = os.path.basename(__file__)


def log(msg):
    print("[{}] {}".format(SCRIPT, msg))


def main():
    args = parse_args()

    build_dir = os.path.abspath(args.build_dir) if args.build_dir else common.BUILD_DIR
    cef_postfix2 = args.platform if args.platform else common.CEF_POSTFIX2

    if cef_postfix2 == "unknown":
        log("ERROR: Could not detect platform. Use --platform to specify it.")
        log("Valid values: windows32, windows64, linux32, linux64, macosx64")
        sys.exit(1)

    version = common.get_cefpython_version()
    cef_version = version["CEF_VERSION"]

    log("CEF version : {}".format(cef_version))
    log("Platform    : {}".format(cef_postfix2))
    log("Build dir   : {}".format(build_dir))

    # Skip if already extracted
    extract_dir = os.path.join(
        build_dir, "cef_binary_{}_{}".format(cef_version, cef_postfix2))
    if os.path.isdir(extract_dir):
        log("Already extracted: {}".format(extract_dir))
        log("Delete that directory to force a fresh download.")
        return

    # Query Spotify index
    log("Fetching index: {}".format(SPOTIFY_INDEX_URL))
    file_info = find_in_index(cef_version, cef_postfix2)

    filename = file_info["name"]
    expected_sha1 = file_info.get("sha1", "")
    file_size = int(file_info.get("size", 0))
    download_url = "{}/{}".format(SPOTIFY_CDN_BASE, filename)
    archive_path = os.path.join(build_dir, filename)

    log("File        : {}".format(filename))
    if file_size:
        log("Size        : {:.1f} MB".format(file_size / (1024 * 1024)))
    if expected_sha1:
        log("SHA1        : {}".format(expected_sha1))

    if args.dry_run:
        log("Dry run — nothing downloaded.")
        return

    os.makedirs(build_dir, exist_ok=True)

    # Download (skip if archive already present and valid)
    if os.path.isfile(archive_path):
        log("Archive already present, verifying checksum...")
        if expected_sha1 and not verify_sha1(archive_path, expected_sha1):
            log("Checksum mismatch — re-downloading.")
            os.remove(archive_path)
            download(download_url, archive_path, file_size)
            check_sha1(archive_path, expected_sha1)
        else:
            log("Checksum OK — skipping download.")
    else:
        download(download_url, archive_path, file_size)
        check_sha1(archive_path, expected_sha1)

    if args.no_extract:
        log("--no-extract set — done.")
        return

    log("Extracting to: {}".format(build_dir))
    extract(archive_path, build_dir)

    if not args.keep_archive:
        log("Removing archive: {}".format(os.path.basename(archive_path)))
        os.remove(archive_path)

    if os.path.isdir(extract_dir):
        log("Done: {}".format(extract_dir))
    else:
        log("WARNING: Expected directory not found after extraction:")
        log("  {}".format(extract_dir))
        log("Check build/ for the extracted contents.")


def parse_args():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--build-dir", metavar="DIR",
                        help="Build directory (default: cefpython/build/)")
    parser.add_argument("--platform", metavar="PLAT",
                        help="CEF platform postfix eg. windows64, linux64, "
                             "macosx64 (default: auto-detect)")
    parser.add_argument("--no-extract", action="store_true",
                        help="Download archive but do not extract")
    parser.add_argument("--keep-archive", action="store_true",
                        help="Keep archive after extraction")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print what would happen without downloading")
    return parser.parse_args()


def find_in_index(cef_version, cef_postfix2):
    """Fetch Spotify index and return the standard-distribution file entry."""
    try:
        from urllib.request import urlopen
        from urllib.error import URLError
    except ImportError:
        from urllib2 import urlopen, URLError

    try:
        response = urlopen(SPOTIFY_INDEX_URL, timeout=30)
        index = json.loads(response.read().decode("utf-8"))
    except Exception as exc:
        log("ERROR: Could not fetch index: {}".format(exc))
        sys.exit(1)

    if cef_postfix2 not in index:
        log("ERROR: Platform '{}' not found in Spotify index.".format(cef_postfix2))
        log("Available platforms: {}".format(", ".join(sorted(index.keys()))))
        sys.exit(1)

    versions = index[cef_postfix2].get("versions", [])
    for ver_entry in versions:
        if ver_entry.get("cef_version") != cef_version:
            continue
        for file_entry in ver_entry.get("files", []):
            if file_entry.get("type") == "standard":
                return file_entry
        log("ERROR: No standard distribution found for version '{}' on '{}'."
            .format(cef_version, cef_postfix2))
        log("Available file types: {}"
            .format(", ".join(f.get("type", "?")
                              for f in ver_entry.get("files", []))))
        sys.exit(1)

    recent = [v.get("cef_version", "?") for v in versions[:8]]
    log("ERROR: CEF version '{}' not found for platform '{}'."
        .format(cef_version, cef_postfix2))
    log("Most recent available versions: {}".format(", ".join(recent)))
    sys.exit(1)


def download(url, dest_path, expected_size=0, max_retries=50):
    """Download url to dest_path with a progress bar and resume support."""
    try:
        from urllib.request import Request, urlopen
    except ImportError:
        from urllib2 import Request, urlopen

    log("Downloading: {}".format(url))

    total = expected_size
    downloaded = 0
    chunk_size = 1024 * 1024  # 1 MB

    # Resume from an existing partial file if present
    if os.path.isfile(dest_path):
        downloaded = os.path.getsize(dest_path)
        if total and downloaded >= total:
            log("Already fully downloaded: {}".format(os.path.basename(dest_path)))
            return
        if downloaded > 0:
            log("Resuming from {:.1f} MB...".format(downloaded / (1024 * 1024)))

    for attempt in range(1, max_retries + 1):
        if attempt > 1:
            # Re-check how much we have on disk after a failed attempt
            if os.path.isfile(dest_path):
                downloaded = os.path.getsize(dest_path)
            log("Retry {}/{} (resuming from {:.1f} MB): {}".format(
                attempt, max_retries, downloaded / (1024 * 1024), url))

        req = Request(url)
        if downloaded > 0:
            req.add_header("Range", "bytes={}-".format(downloaded))

        try:
            response = urlopen(req, timeout=120)
        except Exception as exc:
            if attempt == max_retries:
                log("ERROR: Download failed: {}".format(exc))
                sys.exit(1)
            log("WARNING: Connection error (attempt {}): {}".format(attempt, exc))
            time.sleep(2)
            continue

        # Determine total size from response
        content_range = response.headers.get("Content-Range")
        if content_range:
            # e.g. "bytes 100-200/614600000"
            try:
                total = int(content_range.rsplit("/", 1)[-1])
            except (ValueError, IndexError):
                pass
        else:
            total = int(response.headers.get("Content-Length") or total or 0)
            if downloaded > 0:
                # Server didn't honour Range; start over
                log("WARNING: Server ignored Range header, restarting download.")
                downloaded = 0

        error = None

        try:
            mode = "ab" if downloaded > 0 else "wb"
            with open(dest_path, mode) as fp:
                while True:
                    chunk = response.read(chunk_size)
                    if not chunk:
                        break
                    fp.write(chunk)
                    downloaded += len(chunk)
                    _print_progress(downloaded, total)
        except Exception as exc:
            error = exc

        print()  # end progress line

        if error is None and total and downloaded < total:
            error = "short read: got {:.1f} MB of {:.1f} MB".format(
                downloaded / (1024 * 1024), total / (1024 * 1024))

        if error is not None:
            if attempt == max_retries:
                log("ERROR: Download failed: {}".format(error))
                sys.exit(1)
            log("WARNING: Download incomplete (attempt {}): {}".format(attempt, error))
            time.sleep(2)
            continue

        log("Saved: {}".format(os.path.basename(dest_path)))
        return


def _print_progress(downloaded, total):
    mb = downloaded / (1024 * 1024)
    if total:
        pct = min(downloaded * 100 // total, 100)
        total_mb = total / (1024 * 1024)
        line = "\r  {:.1f} / {:.1f} MB  ({:3d}%)".format(mb, total_mb, pct)
    else:
        line = "\r  {:.1f} MB".format(mb)
    sys.stdout.write(line)
    sys.stdout.flush()


def verify_sha1(file_path, expected_sha1):
    """Return True if the file's SHA1 matches expected_sha1."""
    sha1 = hashlib.sha1()
    with open(file_path, "rb") as fp:
        for chunk in iter(lambda: fp.read(65536), b""):
            sha1.update(chunk)
    return sha1.hexdigest().lower() == expected_sha1.lower()


def check_sha1(file_path, expected_sha1):
    """Verify SHA1; remove file and exit on mismatch."""
    if not expected_sha1:
        return
    log("Verifying SHA1...")
    if verify_sha1(file_path, expected_sha1):
        log("SHA1 OK.")
    else:
        log("ERROR: SHA1 mismatch for {}.".format(os.path.basename(file_path)))
        os.remove(file_path)
        sys.exit(1)


def extract(archive_path, dest_dir):
    """Extract a .zip or .tar.bz2/.tar.gz archive with progress."""
    if archive_path.endswith(".zip"):
        _extract_zip(archive_path, dest_dir)
    elif ".tar." in os.path.basename(archive_path):
        _extract_tar(archive_path, dest_dir)
    else:
        log("ERROR: Unrecognised archive format: {}".format(archive_path))
        sys.exit(1)
    print()  # end progress line


def _extract_zip(archive_path, dest_dir):
    with zipfile.ZipFile(archive_path, "r") as zf:
        members = zf.namelist()
        total = len(members)
        for i, member in enumerate(members, 1):
            zf.extract(member, dest_dir)
            if i % 200 == 0 or i == total:
                sys.stdout.write("\r  {}/{} files".format(i, total))
                sys.stdout.flush()


def _extract_tar(archive_path, dest_dir):
    mode = "r:*"  # auto-detect compression
    with tarfile.open(archive_path, mode) as tf:
        members = tf.getmembers()
        total = len(members)
        # filter= kwarg added in Python 3.12 to suppress deprecation warning
        extract_kwargs = {}
        if sys.version_info >= (3, 12):
            extract_kwargs["filter"] = "data"
        for i, member in enumerate(members, 1):
            tf.extract(member, dest_dir, **extract_kwargs)
            if i % 200 == 0 or i == total:
                sys.stdout.write("\r  {}/{} files".format(i, total))
                sys.stdout.flush()


if __name__ == "__main__":
    main()

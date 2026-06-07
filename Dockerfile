# ============================================================================
# AI-first language benchmark — reproducible toolchain image
#
# Bundles every benchmark language so anyone can re-run the generated parsers
# against the test cases in the SAME environment:
#   JavaScript (Node), Python, Zero, MoonBit, NanoLang, Vera
#
# Build (auto-detects host arch: arm64 / amd64):
#   docker build -t ai-lang-bench .
# Run an interactive shell with all toolchains on PATH:
#   docker run --rm -it ai-lang-bench
# Re-run the existing benchmark test harnesses:
#   docker run --rm ai-lang-bench scripts/run_bench_tests.sh
#
# Versions are PINNED for reproducibility (see ARGs below). See DOCKER.md.
# ============================================================================

# Debian 13 "trixie" (GCC 14) is required: on arm64 there is no prebuilt
# z3-solver wheel for the version vera pins (>=4.15.5), so z3 is compiled from
# source — and z3 4.16's source needs C++20 <format>, which bookworm's GCC 12
# lacks. trixie's GCC 14 provides it. (amd64 still uses the x86_64 wheel.)
FROM node:22-trixie-slim

# --- pinned versions (override at build time with --build-arg) -------------
ARG ZERO_VERSION=v0.2.1
ARG VERA_REF=v0.0.160
ARG NANOLANG_REF=main
# TARGETARCH is provided automatically by BuildKit: "amd64" or "arm64"
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
    MOON_HOME=/opt/moon \
    VIRTUAL_ENV=/opt/venv \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8
# Put every toolchain on PATH up front. ENV covers non-login shells and direct
# `docker run <image> <tool>` invocations; the profile.d drop-in below re-adds
# the same paths for LOGIN shells (`bash -l`), which otherwise reset PATH via
# /etc/profile — this is what the default CMD and interactive shells use.
ENV PATH="/opt/venv/bin:/opt/moon/bin:/usr/local/bin:${PATH}"
RUN printf 'export PATH="/opt/venv/bin:/opt/moon/bin:/usr/local/bin:$PATH"\n' \
        > /etc/profile.d/00-bench-path.sh

# --- base OS deps (Python 3.13 from trixie, build tools for C/native) -------
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl git xz-utils file \
        python3 python3-venv python3-pip \
        build-essential gcc make pkg-config \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Zero (zerolang) — prebuilt release binary, checksum-verified, arch-aware
# ---------------------------------------------------------------------------
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) z_asset="zero-linux-x64";  z_sha="db75216c60b7040873878a94e26cbbed8853fc25c8a55ac5f1f30d27adef04da" ;; \
        arm64) z_asset="zero-linux-arm64"; z_sha="c69b35e9924102cff82479c78f565938f5ad7451826b188987189305b657f707" ;; \
        *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /usr/local/bin/zero \
        "https://github.com/vercel-labs/zerolang/releases/download/${ZERO_VERSION}/${z_asset}"; \
    echo "${z_sha}  /usr/local/bin/zero" | sha256sum -c -; \
    chmod +x /usr/local/bin/zero; \
    zero --version

# ---------------------------------------------------------------------------
# Vera — Python reference compiler, installed editable into a venv
# ---------------------------------------------------------------------------
RUN set -eux; \
    python3 -m venv "${VIRTUAL_ENV}"; \
    pip install --no-cache-dir --upgrade pip; \
    git clone --depth 1 --branch "${VERA_REF}" https://github.com/aallan/vera.git /opt/vera; \
    pip install --no-cache-dir -e /opt/vera; \
    vera --version || vera --help | head -1

# ---------------------------------------------------------------------------
# MoonBit — official installer (downloads the toolchain into $MOON_HOME)
# ---------------------------------------------------------------------------
RUN set -eux; \
    curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash; \
    moon version || moon --version

# ---------------------------------------------------------------------------
# NanoLang — C sources, built from a 3-stage bootstrap (heaviest layer; last)
# ---------------------------------------------------------------------------
RUN set -eux; \
    git clone --depth 1 --branch "${NANOLANG_REF}" https://github.com/jordanhubbard/nanolang.git /opt/nanolang; \
    cd /opt/nanolang; \
    make build; \
    # expose the produced compiler on PATH (path varies; symlink whatever built)
    for cand in bin/nanolang bin/nano build/nanolang nanolang; do \
        if [ -x "/opt/nanolang/$cand" ]; then ln -sf "/opt/nanolang/$cand" /usr/local/bin/nanolang; break; fi; \
    done; \
    (command -v nanolang && nanolang --version) || echo "WARN: nanolang binary not auto-located; see /opt/nanolang"

# --- the benchmark repository ----------------------------------------------
WORKDIR /bench
COPY . /bench

# print a versions banner by default
CMD ["bash", "-lc", "scripts/print_versions.sh; exec bash"]

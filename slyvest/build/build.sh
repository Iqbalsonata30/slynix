#!/usr/bin/env bash
set -euo pipefail
source_dir=$1
release_dir=$2
sha=$3
cd "$source_dir"
[[ $(git rev-parse HEAD) == "$sha" && -z $(git status --porcelain) ]] || { echo 'Build source is not the confirmed clean commit.' >&2; exit 1; }
export SLYVEST_BUILD_COMMIT="$sha"
export CARGO_TARGET_DIR="$release_dir/target"
export SOURCE_DATE_EPOCH
SOURCE_DATE_EPOCH=$(git show -s --format=%ct HEAD)
(cd apps/journal-web && bun install --frozen-lockfile && bun run check && bun run test && bun run build)
cargo fmt --all --check
cargo clippy --locked --workspace --all-targets --all-features -- -D warnings
cargo test --locked --workspace
cargo test --locked -p slyvest --doc
python3 .github/scripts/check_stable_doctests.py
cargo run --locked --example phase2_performance -- 1 3 3 1
cargo build --locked --release -p slyvest-cli --bin slyvest -p slyvest-viewer --bin slyvest-viewer
mkdir -p "$release_dir/bin"
install -m755 "$CARGO_TARGET_DIR/release/slyvest" "$release_dir/bin/slyvest"
install -m755 "$CARGO_TARGET_DIR/release/slyvest-viewer" "$release_dir/bin/slyvest-viewer"

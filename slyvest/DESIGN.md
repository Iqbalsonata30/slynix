# Slyvest user-service design

Personal integration lives in slynix, not the application repository. This host
is Ubuntu WSL2 with an existing user systemd manager, no linger, and active Home
Manager output `iqbalsonata`. The explicitly confirmed journal is
`/home/iqbalsonata/Programming/slyvest/data/journal.sqlite`.

- Default read-only, loopback/dynamic port, optional authoring/backup directory.
  No initialization, migration, journal replacement or implicit database fallback.
- A supervisor captures viewer stdout through a pipe (never journald), validates
  the loopback capability URL and authenticated health, then atomically publishes
  a 0600 handoff inside a 0700 user runtime directory. It binds the handoff to
  systemd's invocation ID/MainPID. URL helpers reject inactive/unready/stale
  instances. No token in configuration, Nix store, updater output or build logs.
- Viewer handles SIGINT, so systemd and the supervisor use SIGINT, then bounded
  shutdown. Failure/stop removes the handoff; readiness is validated, not inferred
  from process creation. No automatic restart loop interrupts editing sessions.
- Updater owns a separate bare clone and detached clean worktree for exact
  origin/main. Require merged-main PR and successful exact-commit GitHub checks.
  Build frontend first with frozen Bun lockfile, then Rust with Cargo.lock using
  native Nix tools pinned by the build flake. Retain a Nix environment GC root per
  release. Check both executable identities; test using synthetic journals.
- Default update only stages a validated candidate. Activation is explicit because
  the service cannot know about unsaved browser fields. CAS/publication uses an
  integration lock and atomic symlinks; retain previous release. On readiness
  failure restore it, using exactly the same configured journal. Same-SHA updates
  are no-ops. No timers, polling, stash, reset or writes to the development checkout.
- Status prints fetched main / installed / actually-running SHA, never URL.
  WSL systemd starts with the user's manager; no linger/global WSL changes. A
  stopped WSL distro cannot serve the browser. A restart creates a new capability.

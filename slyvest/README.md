# Slyvest sebagai user service

Integrasi personal untuk `homeConfigurations.iqbalsonata`. Host yang diuji:
Ubuntu 24.04 WSL2, Linux x86_64, user systemd aktif, linger tetap `no`.
Tidak mengubah aplikasi, domain, schema, atau konfigurasi global WSL.

## Konfigurasi

Module `config/home/slyvest.nix`, pilihan host di `config/home/home.nix`:

```nix
services.slyvest = {
  enable = true;
  journal = "/home/iqbalsonata/Programming/slyvest/data/journal.sqlite";
  # port = 0;                  # default: loopback dengan port dinamis
  # enableAuthoring = true;    # opt-in; default false
  # backupDirectory = "/path/yang/sudah/ada"; # opt-in terpisah
};
```

Path jurnal dikonfirmasi pengguna. Service tidak melakukan init, migrasi, pergantian
jurnal, atau fallback. Direktori backup harus sudah ada. Binary dijalankan langsung,
bukan Cargo/Vite/build saat startup. Frontend produksi sudah embedded.

Root `flake.lock` mengikuti kebijakan lama repo: diabaikan Git. Pertahankan lockfile
aktif dan gunakan flake **path:** agar evaluasi memakai lockfile tersebut. Lockfile
build Slyvest terpisah dan di-commit. Paket unfree yang sudah ada pada host membutuhkan:

```bash
cd ~/.config/home-manager
NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure \
  --flake "path:$PWD#iqbalsonata"
```

Jangan memperbarui input root bersamaan dengan integrasi ini. Sebelum versi pertama
terpasang, service dapat skipped karena binary `current` belum ada.

## Start, open, update, rollback

```bash
slyvest-update                 # stage saja: fetch, gate, build/check, smoke test
slyvest-status                 # SHA origin/main, terpasang, benar-benar berjalan
# Simpan pekerjaan dan tutup editor sebelum aktivasi eksplisit:
slyvest-update --activate <SHA-main-yang-ditampilkan>
systemctl --user start slyvest-viewer.service
systemctl --user status slyvest-viewer.service
slyvest-url                    # tampilkan URL privat hanya untuk dibuka sendiri
systemctl --user stop slyvest-viewer.service
systemctl --user restart slyvest-viewer.service
slyvest-rollback               # aktivasi eksplisit versi sebelumnya
```

Buka **seluruh URL** dari `slyvest-url` di browser. Jangan bagikan URL, masukkan ke
screenshot, shell tracing, atau log. Helper menolak sesi mati/belum siap/invocation
lama. Restart menghasilkan capability baru. Reload browser tetap mengikuti recovery
sesi Slyvest: buka lagi URL privat aktif; capability tidak disimpan di browser storage.

CLI dan viewer terpasang dari SHA yang sama:

```bash
~/.local/state/slyvest-service/current/bin/slyvest --version
~/.local/state/slyvest-service/current/bin/slyvest-viewer --version
```

Unit mulai bersama user `default.target` ketika jurnal dan binary tersedia. Tidak
perlu terminal terbuka. Tidak ada restart otomatis, polling, perubahan linger, atau
systemd global. WSL yang dihentikan ikut menghentikan service. Windows menggunakan
localhost forwarding WSL yang sudah tersedia; jangan memperluas bind jika forwarding
bermasalah. Setelah restart distro, ambil URL sesi baru. Perubahan konfigurasi unit
melalui Home Manager juga dapat restart service: simpan pekerjaan lebih dulu.

## Batas privasi dan deployment

Supervisor menangkap stdout viewer lewat pipe, menyembunyikan stderr child, dan hanya
mengeluarkan pesan aman ke journald. Handoff atomik berada di
`$XDG_RUNTIME_DIR/slyvest-viewer/session.json`, direktori 0700/file 0600, terikat ke
MainPID dan invocation ID. Stop/failure membersihkannya. Helper melakukan health
check berautentikasi tanpa proxy. Capability tidak masuk argumen command, Nix store,
updater log, atau environment. Unit menggunakan SIGINT sesuai handler `ctrl_c`
viewer, shutdown terbatas, dan core dump dinonaktifkan. Snapshot recovery browser
tetap hanya di memori; restart dapat mengakhiri sesi yang memegangnya.

Updater memiliki clone bare `~/.local/state/slyvest-service/source.git` dan worktree
detached bersih per SHA di `releases/<SHA>/source`. Tidak menyentuh checkout developer,
stash, reset, atau artefak developer. Hanya mengambil `origin/main` upstream Slyvest.
Gate meminta PR sudah merged ke main serta kedua job CI wajib sukses untuk SHA tepat.
Pending/failure/tidak dapat diverifikasi menolak aktivasi. Ini bergantung pada review
workflow GitHub, bukan bukti kriptografis persetujuan manusia. Perubahan nama job perlu
review gate. Repo privat memakai akses Git dan autentikasi `gh` pengguna yang sudah
ada; tidak menyalin token GitHub ke konfigurasi integrasi.

Build native memakai nixpkgs yang dipin dalam `slyvest/build/flake.lock` (Rust 1.98.1,
Bun 1.4.2 saat implementasi). Frontend frozen-lockfile dibangun dahulu, lalu Rust
`--locked`. Format, Clippy, workspace/doc tests, frontend tests, doctest fence checker,
benchmark smoke, identitas kedua executable, dan smoke journal sintetis harus lulus
sebelum manifest kandidat diterbitkan. Target build milik release updater sendiri.
Profile Nix per release menjadi GC root untuk closure native. Ini bukan paket Ubuntu
CI; diuji pada Ubuntu WSL dengan Nix, bukan klaim pengujian NixOS terpisah.

SHA sama tidak build/restart. Aktivasi eksplisit memakai symlink atomik dan lock
lokal, lalu menguji readiness. Gagal startup mengembalikan versi sebelumnya memakai
jurnal yang sama. Jika jurnal rusak/hilang, versi lama juga mungkin gagal; tidak ada
repair atau schema downgrade. Jangan gunakan init sebagai repair. Artefak/cache dan
versi lama tidak dihapus otomatis; disk usage dapat besar.

## Bukti dan pengulangan tes

```bash
python3 -m unittest discover -s slyvest/tests -v
python3 slyvest/tests/host_integration.py /path/release-lama /path/release-baru
```

Host test memakai dua release valid dari SHA main berbeda, jurnal sintetis, dan unit
sementara di runtime user; unit dibersihkan setelah tes. Opsional:
`PLAYWRIGHT_MODULE=/absolute/node_modules/playwright/index.mjs` dan
`PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/absolute/chromium` mengaktifkan tes browser.
Node/Playwright hanya dependency tes, bukan service. Test tidak mencetak URL privat.

Bukti 7–8 November 2026:

- 8 unit test keselamatan lulus.
- Build/check native lulus untuk `5d11bed970cd4c420ab6ee6705f8b4dc0cd9ffec` dan
  `ae169161e93a3166470cf881fb4f92b830418453`, kedua executable sesuai SHA.
- Start/stop/restart, URL baru, permission, penolakan sesi mati, update dua SHA,
  same-SHA no-op, build failure tanpa restart, readiness failure dengan rollback,
  rollback eksplisit, log tanpa token, jurnal sintetis identik byte-per-byte lulus.
  Build failure diinjeksi pada batas build; readiness failure memakai binary fixture.
- Chromium nyata membuka frontend embedded, API tanpa auth ditolak, capability
  dihapus dari address bar, tanpa request eksternal atau localStorage.
- PowerShell Windows memperoleh HTTP 200 dari loopback WSL. Browser GUI Windows
  belum diotomasi; Chromium pengujian berjalan di Linux/WSL.
- Activation package Home Manager dibangun dengan lockfile aktif, tanpa update input.

Lihat [catatan desain](DESIGN.md). Tidak ada perubahan repository aplikasi atau
publikasi release; konfigurasi personal ini mengikuti review PR repo Home Manager.

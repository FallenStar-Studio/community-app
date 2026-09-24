# Visual QA · Godot prototype

Date: 2026-09-25  
Host: macOS, Apple Silicon  
Engine: Godot 4.7.2 stable, standard build

## Verified in the exported app

| Check | Result |
|---|---|
| GDScript parse and asset import | Pass; Godot headless editor scan/import completed without script errors. |
| Headless data/security and GitHub adapter checks | Pass; 33 passed, 0 failed. This includes feed/API normalization, empty-feed behavior, comment provenance, registry validation and request gating. |
| macOS export and launch | Pass; the exported app launched as a universal x86_64 + arm64 bundle. Bundle ID: `org.plyra.community`. |
| English / Chinese switch | Pass; the home, discussion list, discussion detail, MOD list and MOD detail were inspected in both languages. Sample titles, bodies, authors, categories and MOD metadata switch with the UI. |
| Artwork integration | Pass; the home hero uses a new project-bundled voxel forest and waterfall illustration derived from the reference image's mood and palette. |
| Discussion / MOD content | Pass; local demo cards, filters, detail views, long text and the bundled article image render in the packaged app. |
| Public GitHub data adapters | Pass; the Godot HTTP client fetched the live community feed (2 Discussions, 5 GitHub categories) and the separate live MOD registry (0 entries). This verifies guest-feed and empty-registry reads, not authenticated GraphQL access. |
| Live-data UI | Pass; the refreshed macOS app displayed both real public-feed Discussions and the valid empty MOD registry without inserting demo cards into either successful live result. |
| Long mixed-language title | Pass; the discussion detail header now wraps long English/Chinese titles and keeps the language switch and account button within the desktop window. |
| Idle frame pacing | Pass; after 8 seconds without input, the app returns to a 10 FPS cap. Mouse movement, keyboard and touch input raise the cap to 60 FPS. |

## Idle resource sample

After leaving the exported app idle for about 8 seconds, Godot telemetry showed 10 FPS, 4.59 ms/frame and 22.3 MiB video memory. A fresh `top -l 6 -s 2 -pid <app-pid>` sample reported 0.0–5.2% process CPU (about 4.1% average across six readings) and about 338 MiB resident memory.

This is one short macOS session, not a comparative benchmark. GPU utilization percentage was not measured: macOS `powermetrics` required superuser privileges, and the Godot video-memory figure is not GPU utilization.

## Still pending

- Native macOS Chinese IME composition, candidate windows and long-form input remain unverified; the Settings page only provides a local input area.
- Android export and device checks (IME, soft keyboard, touch, long reading and images) are not yet done. Windows and Linux exports have not been built.
- GitHub feed and MOD registry HTTP adapters were verified against the public repositories. The live Discussions detail page showed its published bilingual body and zero comments. GraphQL read-query normalization is covered with local payload tests, but has not been verified against an authorized live account. OAuth Device Flow and app-originated posting/commenting are not implemented; no client write operations were tested.
- The macOS bundle is ad-hoc signed and not notarized; it is for local prototype use.

Bundled demo fixtures remain available for offline mode, failed requests and automated tests. In the verified online run, the two displayed Discussions came from the GitHub public feed and the MOD page showed zero entries from the valid live registry response. MOD source/download URLs and hashes are empty; nothing in the prototype downloads or installs MODs.

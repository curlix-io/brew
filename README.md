# curlix Homebrew tap

Install the Curlix CLI (auth-first client for `login`, `connect`, etc.):

```sh
brew tap curlix-io/cli
brew install curlix
curlix login
```

Or, without a separate `brew tap` step:

```sh
brew install curlix-io/cli/curlix
```

(This repo is named `curlix-io/homebrew-cli` — Homebrew's own naming convention
[`homebrew-<tapname>`] is what makes the short `curlix-io/cli` form above resolve without
needing the full repo URL.)

## Layout

- `Formula/curlix.rb` — downloads prebuilt binaries from this tap's own GitHub Releases
  (`cli-v*` tags on [curlix-io/homebrew-cli](https://github.com/curlix-io/homebrew-cli/releases)),
  not from [curlix-io/curlix](https://github.com/curlix-io/curlix) — that repo is private, so its
  own `cli-v*` releases (created by the same release job, before publishing here) are an internal
  CI record only and aren't fetchable by `brew`/`curl` outside the org.

The canonical formula template lives in the main repo at `packaging/homebrew/curlix.rb`. The
**Release CLI** workflow (or `packaging/publish-cli-local.sh` for a manual release) updates this
file on each CLI release when `HOMEBREW_TAP_TOKEN` is configured, and pushes the result here.

Real `cli-v*` releases with real checksums exist — `brew install curlix` works. Note some
platform legs may lag behind the latest version or be temporarily unavailable if a given
release's build matrix didn't complete for that platform (check `Formula/curlix.rb`'s own
comments for the current per-platform pinned version).

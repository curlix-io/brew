# Homebrew formula for the curlix CLI.
#
# This lives in the curlix tap repo (curlix-io/brew) as Formula/curlix.rb.
# A copy is kept here so the formula is versioned next to the build tooling; the
# release CI (.github/workflows/release-cli.yml) regenerates the version + sha256
# values and pushes the result to the tap on every CLI release.
#
#   brew tap curlix-io/brew https://github.com/curlix-io/brew.git
#   brew install curlix
#
# It installs a prebuilt, self-contained binary (PyInstaller one-folder bundle) —
# no Python toolchain required on the user's machine.
class Curlix < Formula
  desc "Curlix CLI — authenticate and connect to your databases through curlix"
  # Not the GitHub source repo (curlix-io/curlix) — that's private, so `brew info curlix` would
  # link users to a 404/login wall. The product's own public site is the right "homepage" here.
  homepage "https://curlix.io"
  version "1.2.5"
  license :cannot_represent # Proprietary

  on_macos do
    on_arm do
      url "https://github.com/curlix-io/brew/releases/download/cli-v#{version}/curlix-#{version}-darwin-arm64.tar.gz"
      sha256 "e296e527e62665b90d6354371b79c352a7831cb740af70272700ab5a8a53fddb"
    end
    # darwin-x86_64 (macos-13 runner) has never produced a successful build — every
    # release-cli.yml run for this leg has hung/been cancelled waiting on a runner.
    # Omitted rather than shipping a placeholder checksum: Homebrew reports "not
    # available on this platform" instead of a 404/checksum failure. Add back once
    # a real darwin-x86_64 tarball + sha256 exists.
  end

  on_linux do
    on_arm do
      # Pinned to the last version actually built for this platform (1.2.3) — the
      # 1.2.4 build matrix never completed (GH Actions billing lockout, see
      # curlix-io/curlix .github/workflows/release-cli.yml run 30568321766).
      url "https://github.com/curlix-io/brew/releases/download/cli-v1.2.3/curlix-1.2.3-linux-arm64.tar.gz"
      sha256 "92f21b44f8587f56d544373594f948ea0d84824969b153d2be8ffeabe397e035"
    end
    on_intel do
      url "https://github.com/curlix-io/brew/releases/download/cli-v1.2.3/curlix-1.2.3-linux-x86_64.tar.gz"
      sha256 "f20146edeea4c4ae013c9b13448585315446849edf24b0fa3a59e4b199f1c7fe"
    end
  end

  def install
    # The tarball contains the PyInstaller one-folder bundle (launcher + _internal/).
    # Homebrew strips the single top-level "curlix/" dir, so install everything here
    # into libexec and expose only the launcher on PATH.
    libexec.install Dir["*"]
    bin.install_symlink libexec/"curlix"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/curlix --version")
  end
end

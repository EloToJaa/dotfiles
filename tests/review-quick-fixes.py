"""Run with Python and Neovim on PATH."""

import argparse
import os
from pathlib import Path
import re
import subprocess
import tempfile
import textwrap

REPO = Path(__file__).resolve().parents[1]


def check_quickfix(root: Path) -> None:
    source = (REPO / "homeModules/dev/nvim/config/keymaps.nix").read_text()
    match = re.search(r'key = "<M-q>";\s+action = mkRaw \'\'(.*?)\'\';', source, re.S)
    assert match, "Quickfix callback not found"
    (root / "delete.lua").write_text(
        "return " + textwrap.dedent(match.group(1)).strip()
    )
    subprocess.run(
        [
            "nvim",
            "--headless",
            "-u",
            "NONE",
            "-l",
            str(REPO / "tests/quickfix-delete.lua"),
        ],
        env=dict(
            os.environ,
            REVIEW_TEST_DIR=str(root),
            XDG_CACHE_HOME=str(root / "cache"),
            XDG_STATE_HOME=str(root / "state"),
        ),
        check=True,
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="dotfiles-review-tests-") as directory:
        check_quickfix(Path(directory))

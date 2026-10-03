"""Run with Python, Neovim, patch and sh on PATH; pass the pinned Waypaper source."""

import argparse
import ast
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import tempfile
import textwrap
from types import SimpleNamespace

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


def check_shell(root: Path, waypaper_source: Path) -> None:
    changer = root / "waypaper/changer.py"
    changer.parent.mkdir()
    shutil.copyfile(waypaper_source / "waypaper/changer.py", changer)
    with (REPO / "homeModules/desktop/waypaper-post-command.patch").open() as patch:
        subprocess.run(["patch", "-d", str(root), "-p1"], stdin=patch, check=True)

    bindir = root / "bin"
    bindir.mkdir()
    shell = shutil.which("sh")
    assert shell
    for name, body in {
        "pkill": "exit 1\n",
        "wall-change": 'printf "%s\\0" "$@" > "$REVIEW_OUTPUT"\n',
    }.items():
        executable = bindir / name
        executable.write_text(f"#!{shell}\n{body}")
        executable.chmod(0o755)
    output = root / "args"
    env = dict(os.environ, PATH=str(bindir), REVIEW_OUTPUT=str(output))
    config = (REPO / "homeModules/desktop/waypaper.nix").read_text()
    command = re.search(r"post_command = (.+)", config).group(1)

    # Execute the actual patched upstream block without importing GTK or changing a wallpaper.
    node = next(
        node
        for node in ast.walk(ast.parse(changer.read_text()))
        if isinstance(node, ast.If)
        and ast.unparse(node.test) == "cf.post_command and cf.use_post_command"
    )
    code = compile(ast.Module(body=[node], type_ignores=[]), str(changer), "exec")

    class Processes:
        @staticmethod
        def Popen(command: str, shell: bool) -> subprocess.Popen:
            subprocess.run([shutil.which("sh"), "-n", "-c", command], check=True)
            process = subprocess.Popen(command, shell=shell, env=env)
            assert process.wait(timeout=5) == 0
            return process

    injected = root / "injected"
    paths = [
        "/tmp/plain.png",
        "/tmp/white space.png",
        "/tmp/single' double\".png",
        f"/tmp/$(touch {injected}).png",
        f"/tmp/`touch {injected}`.png",
        "/tmp/new\nline; *.png",
        "/tmp/$monitor $HOME \\ path.png",
    ]
    for path in paths:
        exec(
            code,
            dict(
                cf=SimpleNamespace(post_command=command, use_post_command=True),
                image_path=path,
                monitor="All",
                shlex=shlex,
                subprocess=Processes(),
            ),
        )
        assert output.read_bytes() == path.encode() + b"\0"
    assert not injected.exists()

    source = (REPO / "homeModules/desktop/swaync/default.nix").read_text()
    commands = re.findall(r'command = "(record (?:screen|area|gif).*?)";', source)
    assert len(commands) == 3
    for command in commands:
        subprocess.run([shell, "-n", "-c", command], check=True)
    print(
        "PASS: pinned Waypaper quoting, no-match cleanup, seven filenames, recording shell syntax"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("waypaper_source", type=Path)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="dotfiles-review-tests-") as directory:
        root = Path(directory)
        check_quickfix(root)
        check_shell(root, args.waypaper_source.resolve())

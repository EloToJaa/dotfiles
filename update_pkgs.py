import datetime
import json
import os
import re
import subprocess


def run_command(command: str):
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True, shell=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print("Command failed with exit code:", e.returncode)
        print("Error output:", e.stdout)
        return None

def get_hash_and_rev(owner: str, repo: str) -> tuple[str | None, str | None]:
    output = run_command(f"nurl https://github.com/{owner}/{repo} --json --fetcher fetchFromGitHub")
    if output is None:
        return None, None

    json_data = json.loads(output)["args"]
    hash = json_data["hash"]
    rev = json_data["rev"]

    return hash, rev

def get_owner_and_repo(file_path: str) -> tuple[str | None, str | None]:
    with open(file_path, "r") as f:
        content = f.read()

    owner_match = re.search(r"owner = \"(.*?)\";", content)
    repo_match = re.search(r"repo = \"(.*?)\";", content)

    if owner_match is None or repo_match is None:
        return None, None

    owner = owner_match.group(1)
    repo = repo_match.group(1)

    return owner, repo

def get_version() -> str:
    date_now = datetime.datetime.now()
    date_string = date_now.strftime("%Y-%m-%d")
    version = f"unstable-{date_string}"
    return version

def write_to_file(file_path: str, hash: str, rev: str, version: str):
    with open(file_path, "r") as f:
        content = f.read()

    content = re.sub(r"rev = \".*?\";", f"rev = \"{rev}\";", content)
    content = re.sub(r"hash = \".*?\";", f"hash = \"{hash}\";", content)
    content = re.sub(r"version = \".*?\";", f"version = \"{version}\";", content)

    with open(file_path, "w") as f:
        f.write(content)

def process_file(file_path: str):
    owner, repo = get_owner_and_repo(file_path)
    if owner is None or repo is None:
        print(f"{file_path}: Could not find owner or repo")
        return

    version = get_version()

    hash, rev = get_hash_and_rev(owner, repo)
    if hash is None or rev is None:
        print(f"{file_path}: Could not get hash or rev")
        return

    write_to_file(file_path, hash, rev, version)

def get_all_files(directory: str) -> list[str]:
    new_files: list[str] = []
    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            extension = os.path.splitext(file)[1]
            if extension == ".nix":
                new_files.append(file_path)
            
    return new_files

def process_directory(directory: str):
    files = get_all_files(directory)
    for file in files:
        process_file(file)

if __name__ == "__main__":
    process_directory("modules/home/yazi/plugins")
    process_directory("pkgs")

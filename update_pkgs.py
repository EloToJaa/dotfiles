import datetime
import json
import re
import subprocess


def run_command(command: str):
    print(command)
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
    # get json from nurl output
    json_data = json.loads(output)["args"]
    hash = json_data["hash"]
    rev = json_data["rev"]

    print(f"Got hash: {hash}")
    print(f"Got rev: {rev}")
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

    print(f"Found owner: {owner}")
    print(f"Found repo: {repo}")
    return owner, repo

def get_version() -> str:
    date_now = datetime.datetime.now()
    date_string = date_now.strftime("%Y-%m-%d")
    version = f"unstable-{date_string}"
    print(f"Version: {version}")
    return version

if __name__ == "__main__":
    file_path = "modules/home/yazi/plugins/git.nix"
    owner, repo = get_owner_and_repo(file_path)
    if owner is None or repo is None:
        print("Could not find owner or repo")
        exit(1)
    version = get_version()

    get_hash_and_rev(owner, repo)

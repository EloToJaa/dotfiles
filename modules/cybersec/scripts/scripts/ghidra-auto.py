import itertools as IT
import os
import select
import subprocess
import sys
import tempfile

import click

PROJECT_DIRECTORY = "/tmp"


def name_sequence(sep):
    count = IT.count()
    yield ""
    while True:
        yield "{s}_{n:d}".format(s=sep, n=next(count))


def uniquify(path, sep=""):
    orig = tempfile._name_sequence
    with tempfile._once_lock:
        tempfile._name_sequence = name_sequence(sep)
        path = os.path.normpath(path)
        dirname, basename = os.path.split(path)
        filename, ext = os.path.splitext(basename)
        _, filename = tempfile.mkstemp(
            dir=dirname, prefix=filename, suffix=ext
        )
        os.remove(filename)
        tempfile._name_sequence = orig
    return filename


def shouldRun():
    click.secho(
        "Will run analysis in 3 seconds, press any key to cancel", fg="green"
    )
    i, _, _ = select.select([sys.stdin], [], [], 3)

    if i:
        return False
    return True


@click.command()
@click.argument("filename", type=click.Path(exists=True))
@click.option("-t", "--temp", "temp", is_flag=True)
def main(filename, temp):
    if os.path.isdir(filename):
        return os.system("ghidra")
    if ".gpr" in filename:
        os.system(f'ghidra "{os.path.abspath(filename)}"')
        return
    if temp:
        proj_file = uniquify(
            os.path.join(
                PROJECT_DIRECTORY, os.path.basename(filename) + ".gpr"
            )
        )
        out_dir = PROJECT_DIRECTORY
    else:
        proj_file = uniquify(filename + ".gpr")
        out_dir = os.path.dirname(filename)
        out_dir = out_dir if out_dir != "" else "."
    proj_name = os.path.splitext(os.path.basename(proj_file))[0]
    file_output = subprocess.check_output(
        f'file "{filename}"', shell=True
    ).decode("utf8")
    click.secho(file_output, fg="yellow")
    r = shouldRun()
    if r:
        os.system(
            f"ghidra-analyzeHeadless {out_dir}"
            f'"{proj_name}" -import "{filename}"'
        )
        os.system(f'ghidra "{proj_file}"')


if __name__ == "__main__":
    main()

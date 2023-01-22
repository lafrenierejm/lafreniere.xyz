#!/usr/bin/env python3

from os import close
from pathlib import Path
from subprocess import run
from tempfile import mkstemp

ROOT_DIR = Path(
    run(["git", "rev-parse", "--show-toplevel"], capture_output=True)
    .stdout.decode()
    .strip()
)

PUBLIC_DIR = Path("public").absolute().relative_to(ROOT_DIR)
DOCS_DIR = PUBLIC_DIR / "docs"


def rename_index_html(path: Path, dirs_modified: list[Path] = []):
    for child in path.iterdir():
        if child.is_dir():
            rename_index_html(child)
            if not any(child.iterdir()):
                # The directory is now empty.
                print(f"Removing {child}")
                child.rmdir()
                dirs_modified.append(child)
            else:
                print(f"Leaving {child} because it's not empty")
        elif child.is_file():
            if child.name == "index.html" or child.name == "index.xml":
                new_path = f"{path}{child.suffix}"
                print(f"Renaming {child} to {new_path}")
                child.rename(new_path)
    return dirs_modified


def replace_dir_links(path: Path, dir_names: list[str]):
    for child in path.iterdir():
        if child.is_dir():
            replace_dir_links(child, dir_names)
        elif child.is_file() and (
            child.suffix == ".html" or child.suffix == ".xml"
        ):
            print(f"Replacing content in {child}")
            fd, tmp_file = mkstemp()
            close(fd)
            with (open(child) as input, open(tmp_file, "w") as output):
                for line in input:
                    for dir_name in dir_names:
                        line = line.replace(f"{dir_name}/", f"{dir_name}.html")
                    output.write(line)
            with (open(tmp_file) as input, open(child, "w") as output):
                for line in input:
                    output.write(line)


if __name__ == "__main__":
    run(["hugo", "--minify", "--theme", "hugo-book"])
    dirs_modified = rename_index_html(DOCS_DIR)
    replace_dir_links(
        PUBLIC_DIR, [str(dir.relative_to(PUBLIC_DIR)) for dir in dirs_modified]
    )
    run(
        [
            "aws",
            "s3",
            "sync",
            str(PUBLIC_DIR.absolute()),
            "s3://lafreniere.xyz",
            "--delete",
        ]
    )

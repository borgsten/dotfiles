#!/usr/bin/env python3

from pathlib import Path
from typing import List, Dict
from urllib.parse import urlparse
from urllib.request import urlretrieve
import fnmatch
import logging
import os
import subprocess
import zipfile


STRIPPED_FILE_EXTENSIONS = [".sh", ".py"]


logger: logging.Logger = logging.getLogger(__name__)


def _format_stdout(stdout: bytes) -> str:
    lines = '\n\t'.join(stdout.decode().splitlines())
    return f"\n\t{lines}"


def _remove_extension(file_name: Path) -> Path:
    if file_name.suffix in STRIPPED_FILE_EXTENSIONS:
        return Path(file_name.stem)
    return file_name


def _run_command(command: str) -> None:
    try:
        stdout = subprocess.check_output(command.split(), stderr=subprocess.STDOUT)
        if stdout:
            logger.debug(_format_stdout(stdout))
    except subprocess.CalledProcessError as e:
        logger.warn(f"Failed to run command: {e.stdout.decode()}")
        raise e


def _download_file(url: str, dest: Path) -> Path:
    filename = Path(urlparse(url).path)
    dest = dest.joinpath(filename.name)
    logger.debug(f"Downloading {url} to {dest}")
    urlretrieve(url, dest)
    return dest


def _symlink(src: Path, dest: Path, force: bool) -> None:
    logger.info(f"Linking {src} -> {dest}")

    src = src.absolute()
    dest = dest.expanduser()
    logger.debug(f"Fullpath: {src} -> {dest}")

    if dest.is_symlink():
        dest.unlink()
    elif (dest.is_file() or dest.is_dir()):
        if force:
            logger.info(f"Creating backup in {dest}.bkp")
            os.rename(dest, dest.with_suffix(dest.suffix + ".bkp"))
        else:
            logger.warn("File exists, will not create symlink")
            return

    parent_path = dest.parent
    if not parent_path.is_dir():
        create_directory(parent_path)

    dest.symlink_to(src)


def symlink(arguments: Dict) -> None:
    try:
        src = Path(arguments["src"])
        dest = Path(arguments["dest"])
    except KeyError as e:
        logger.error(f"Missing non-optional key: {e}")
        return

    force = arguments.get("force", False)
    glob_pattern = arguments.get("glob", "")
    strip = arguments.get("strip", False)

    if not glob_pattern:
        dest_path = dest.expanduser()
        if dest_path.is_dir() and not dest_path.is_symlink():
            dest = dest.joinpath(src.name)
        return _symlink(src, dest, force)

    logger.info(f"Linking globbed pattern {src.joinpath(glob_pattern)}")
    for file in src.glob(glob_pattern):
        dest_name = Path(file.name)
        if strip:
            dest_name = _remove_extension(dest_name)

        _symlink(file, dest.joinpath(dest_name), force)


def create_directory(dest: Path) -> None:
    dest = dest.expanduser()
    if dest.is_dir():
        return
    logger.info(f"Creating path {dest}")
    dest.mkdir(parents=True, exist_ok=True)


def install_package(names: List[str], update: bool) -> None:
    if update:
        logger.info("Updating APT cache")
        command = "sudo apt-get update"
        _run_command(command)
    logger.info(f"Installing {', '.join(names)}")
    command = f"sudo apt-get install -y {' '.join(names)}"
    _run_command(command)


def clone_repo(arguments: Dict) -> None:
    try:
        repo = arguments["repo"]
        dest = Path(arguments["dest"])
    except KeyError as e:
        logger.error(f"Missing non-optional key: {e}")
        return

    dest = dest.expanduser()
    if dest.exists():
        logger.warn(f"{dest} exists, will not clone {repo}")
        return
    logger.info(f"Cloning {repo} to {dest}")

    parent_path = dest.parent
    if not parent_path.exists():
        create_directory(parent_path)

    command = f"git clone {repo} {dest}"
    _run_command(command)


def change_shell(shell_path: str) -> None:
    current_shell = os.environ.get("SHELL", None)
    if current_shell and current_shell == shell_path:
        logger.info(f"Shell already set to: {current_shell}")
        return

    command = f"chsh -s {shell_path}"
    logger.info(f"Changing shell to {shell_path}")
    _run_command(command)


def install_font(arguments: Dict) -> None:
    try:
        url = arguments["url"]
        file_patterns = arguments["file_patterns"]
    except KeyError as e:
        logger.error(f"Missing non-optional key: {e}")
        return
    force = arguments.get("force", False)

    dest = Path("~/.local/share/fonts/").expanduser()

    create_directory(dest)

    for pattern in file_patterns:
        if list(dest.glob(pattern)) and not force:
            logger.warning(f"Skipping installing {url}, fonts exists")
            return

    def matches_pattern(filename: str) -> bool:
        for pattern in file_patterns:
            if fnmatch.fnmatch(filename, pattern):
                return True
        return False

    file_name = _download_file(url, Path("/tmp"))

    with zipfile.ZipFile(file_name) as zf:
        for file in filter(lambda file: matches_pattern(file.filename), zf.infolist()):
            dest_file = dest.joinpath(file.filename).expanduser()
            if dest_file.exists() and not force:
                logger.warn(f"File exists {file.filename}")
                continue
            logger.debug(f"Extracting {file.filename} to {dest_file}")
            zf.extract(file, path=dest)

    command = f"fc-cache {dest.expanduser()}"
    _run_command(command)
    logger.debug("Updated font cache")

#!/usr/bin/env python3

from pathlib import Path
import argparse
import logging
import yaml

from lib import actions


logger = logging.getLogger()
logging.basicConfig(format='%(levelname)s: %(message)s')


def main(config_path: Path):
    if not config_path.is_file():
        logger.error(f"Could not load config file: {config_path}")
        return
    with config_path.open('r') as conf:
        config = yaml.safe_load(conf)

    dirs = config.get("create-dirs", None)
    if dirs:
        logger.info("Creating directories".center(40, "="))
        for dir in dirs:
            actions.create_directory(Path(dir))
        logger.info("=" * 40)

    repos = config.get("clone", None)
    if repos:
        logger.info("Cloning repos".center(40, "="))
        for repo_item in repos:
            actions.clone_repo(repo_item)
        logger.info("=" * 40)

    packages = config.get("packages", None)
    if packages:
        logger.info("Installing packages".center(40, "="))
        actions.install_package(packages, False)
        logger.info("=" * 40)

    fonts = config.get("fonts", None)
    if fonts:
        logger.info("Installing fons".center(40, "="))
        for item in fonts:
            actions.install_font(item)
        logger.info("=" * 40)

    shell = config.get("shell", None)
    if shell:
        logger.info("Changing shell".center(40, "="))
        actions.change_shell(shell)
        logger.info("=" * 40)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-d', '--debug',
        help="Debug logging",
        action="store_const", dest="loglevel", const=logging.DEBUG,
        default=logging.WARNING,
    )
    parser.add_argument(
        '-v', '--verbose',
        help="Verbose logging",
        action="store_const", dest="loglevel", const=logging.INFO,
    )
    parser.add_argument(
        '-c', help="Alternative config file",
        type=str, default="config.yml",
        dest="config_path"
    )
    args = parser.parse_args()
    logger.setLevel(args.loglevel)

    main(Path(args.config_path))

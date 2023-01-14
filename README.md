# opl-update script for Open PS2 Loader

This is a simple shell script for preparing PS1 and PS2 backups for use with Open PS2 Loader.

A Unix-like OS is assumed.  I personally run this on FreeBSD.  I expect Linux to work too.

## What it does

* Sets up POPSTARTER.  Converts bin/cue backups to VCD.

* Splits PS2 DVD backups and creates `ul.*`, `ul.cfg`.

## Usage

1. Clone the repo.

2. `git submodule --update init` to fetch dependencies

3. Create two folders, `PSX` and `PS2`.  Stick bin/cue backups in the former, ISOs in the latter.

4. `sh update.sh`

Note: Use on BSD will require GNU make installed from ports or packages.

This will create a directory called `out`.  This can be shared directly as an SMB share for use with OPL's
network functionality.  Or you can copy the contents to a USB drive.

# Raspberry Pi xRDP Installation Script

This shell script installs xRDP for Raspberry Pi Model 4B, and can apply several fixes.

## Usage

```
Usage:
        install.sh [OPTIONS]

Options:
        -h,--help               Prints this message.
        -q,--quiet              Do not print command output.
        -i,--apt-install        Installs the APT version of xRDP. This is the default.
        -I,--cnergy-install     Installs the C-Nergy version of xRDP.
        -c,--fix-closing        Fixes immediate closing of RDP.
        -b,--fix-browsers       Fixes browsers while using RDP.
```

# Local iWave V25.2 artifacts

Place the normal (non-IBERT) files from the iWave V25.2 deliverable here:

```text
vendor/iwave/v25.2/FPGA/system_boot.pdi
vendor/iwave/v25.2/FPGA/system_pld.pdi
vendor/iwave/v25.2/FPGA/system.xsa
```

These files are ignored by Git. Do not force-add them.

The hashes observed for the exact REL1.0 files tested on the Alpaca board are:

```text
F0A8C4C5D6337F9398EF2704A82B565E2AB84F8A55C61DB38C9255283E1FCF80  system_boot.pdi
26B1EEF4E599C0C266628780D6149587A6F3E8E8B9DC51EE4777A6F41EC1C617  system_pld.pdi
02A8B45B42BAB4998E95A4237F69E8BCDDC825573CD71C1145B1E8737026A77F  system.xsa
```

Run `scripts/verify-release.ps1` before programming. A different hash is not
automatically malicious, but it means the file is not the exact tested
release and should be identified before use.

Do not substitute the files under `Binaries/IBERT`; those are transceiver test
images, not the normal FPGA platform image.

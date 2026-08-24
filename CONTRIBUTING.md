# Contributing

Keep changes reproducible against an identified hardware and vendor release.

- State the full iWave development-kit ordering code and carrier revision.
- State the Vivado and iWave release versions used for testing.
- Never commit a PDI, XSA, vendor archive, license file, serial number, device
  DNA, credential, or private schematic.
- Treat OSPI/eMMC/eFUSE operations as a separate, explicitly reviewed flow.
- Keep the default smoke test volatile and recoverable by power cycling.
- Record the exact command and observed hardware result in the pull request.

For RTL changes, run the supplied testbench or an equivalent simulator check
before testing on hardware. For board constraints, cite the matching iWave
document and verify the carrier/SOM revision before merging.

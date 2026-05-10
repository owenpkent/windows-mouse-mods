# Security Policy

## Reporting a vulnerability

If you believe you have found a security vulnerability in this project, please report it privately so the issue can be triaged before public disclosure.

**Preferred channel:** [LinkedIn message to Owen Kent](https://www.linkedin.com/in/owenpkent/) with the subject line `windows-right-click-lock security report`.

Please include:

- A description of the issue and the impact you believe it has.
- Steps to reproduce, or a proof-of-concept if you have one.
- The affected version or commit hash.
- Whether you intend to disclose the issue publicly, and on what timeline.

Please do **not** open a public GitHub issue for suspected vulnerabilities.

## Scope

In scope:

- The reference implementation under `src/WindowsRightClickLock/`.
- The PowerShell helpers under `scripts/`.
- Anything that ships in a release artifact from this repository.

Out of scope:

- Third-party dependencies. Report those upstream. This project depends only on the .NET 9 BCL.
- Issues that require physical access to an already-compromised machine, or that depend on the user running an attacker-supplied binary.
- Theoretical issues with no demonstrable impact on confidentiality, integrity, or availability.

## Response expectations

This is a personal project maintained on a best-effort basis. Acknowledgement target is 7 days. Triage and any fix timeline depend on severity and complexity. You will be credited in the release notes for the fix unless you ask otherwise.

## Hardening already applied

The repository contains an applied security audit at [docs/security-review.md](docs/security-review.md). New reports that overlap with already-mitigated findings will be closed with a pointer to the relevant section.

# Temporal UI Server Container Patching

## Security Vulnerability Remediation - 2026-02-20

### Initial Scan

```bash
docker build -t temporal-ui-server:scan .
trivy image --severity HIGH,CRITICAL temporal-ui-server:scan
```

**Findings:** 10 HIGH/CRITICAL vulnerabilities in Go binaries (`ui-server`, `dockerize`):

- **2 CRITICAL CVEs** (same CVE across both binaries)
- **8 HIGH CVEs** (same 4 CVEs across both binaries)

All vulnerabilities were in `stdlib` compiled with **Go 1.25.3**.

### Patched Vulnerabilities

**1. Go stdlib — Upgrade to 1.25.7 (Dockerfile):**

```dockerfile
FROM golang:1.25.7-alpine3.22 AS builder
FROM golang:1.25.7-alpine3.22 AS base-builder
```

✅ Upgraded from `golang:1.25.3-alpine3.22` to fix 5 Go stdlib CVEs:

- ✅ CVE-2025-68121 (CRITICAL) - FIXED (`crypto/tls`: unexpected session resumption)
- ✅ CVE-2025-61726 (HIGH) - FIXED (`net/url`: memory exhaustion via crafted query params)
- ✅ CVE-2025-61728 (HIGH) - FIXED (`archive/zip`: excessive CPU on archive index build)
- ✅ CVE-2025-61729 (HIGH) - FIXED (`crypto/x509`: DoS via excessive resource consumption)
- ✅ CVE-2025-61730 (HIGH) - FIXED (TLS 1.3 handshake multi-message record handling)

**2. echo/v4 — Upgrade to v4.15.0 (go.mod):**

```
github.com/labstack/echo/v4 v4.13.4 → v4.15.0
```

✅ Upgraded to fix AIKIDO-2025-10947 (Medium) — JSON Log Injection via missing character escape in logger middleware (`home/ui-server/ui-server`).

### Alpine OS Layer

**Result:** 0 vulnerabilities — Alpine 3.22.3 base is clean.

### Verification

```bash
docker build -t temporal-ui-server:scan .
trivy image --severity HIGH,CRITICAL temporal-ui-server:scan
```

**Result:** 0 HIGH, 0 CRITICAL vulnerabilities ✅

### Build & Push

```bash
./build-and-push.sh v2.34.3
```

Pushed multi-arch (`linux/amd64`, `linux/arm64`) to:

- `891377036258.dkr.ecr.ap-southeast-1.amazonaws.com/temporalio-ui:v2.34.3`
- `891377036258.dkr.ecr.ap-southeast-1.amazonaws.com/temporalio-ui:latest`

## Summary

- **Patched:** 2 components (Go stdlib 1.25.7, echo/v4 v4.15.0)
- **Go binary CVEs resolved:** CVE-2025-68121, CVE-2025-61726, CVE-2025-61728, CVE-2025-61729, CVE-2025-61730
- **echo CVE resolved:** AIKIDO-2025-10947 (JSON Log Injection)
- **Alpine OS layer:** Clean — no OS-level CVEs
- **Status:** All HIGH/CRITICAL vulnerabilities resolved ✅
- **Risk Level:** None outstanding

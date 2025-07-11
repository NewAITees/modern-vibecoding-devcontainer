# Docker Build Issues and Solutions

## 🔥 Current Issue: GPG Signature Errors in Docker Build

### Error Description
Docker builds fail with GPG errors when trying to install system packages via `apt-get`:

```
GPG error: http://deb.debian.org/debian bookworm InRelease: At least one invalid signature was encountered.
E: The repository 'http://deb.debian.org/debian bookworm InRelease' is not signed.
```

### Root Cause Analysis

Based on research (2025), this issue is caused by **libseccomp compatibility problems**:

1. **libseccomp blocks new syscalls**: Outdated libseccomp on the host blocks new Linux syscalls used by Debian Bookworm
2. **Docker seccomp profile**: Docker sets a default seccomp profile that blocks newer syscalls not yet known to older libseccomp versions
3. **Debian Bookworm changes**: Python Docker images now use Debian 12 (Bookworm) which requires newer syscalls

### Attempted Solutions

#### ❌ Failed Attempts
1. **GPG key fixes**: `--allow-unauthenticated`, manual key downloads - still fails
2. **Debian Bullseye base**: Still encounters GPG issues
3. **Alternative repositories**: Same underlying syscall blocking issue

#### ⚠️ Partial Solutions
1. **Seccomp bypass**: `docker build --security-opt seccomp=unconfined`
   - May not be supported on all platforms
   - Security implications
2. **Disk space cleanup**: Some cases are actually disk space issues disguised as GPG errors

### Current Working Approach

**Minimal Base + Post-Install CLI Tools**:
- Use basic `python:3.12-slim` with only `uv`
- Install Node.js, Claude Code, Gemini CLI via user documentation
- Avoid `apt-get` during build process

### Host System Solutions

To fix permanently, update the host system:

```bash
# Update Docker (recommended)
# Install latest Docker version (20+)

# Update libseccomp
sudo apt-get update && sudo apt-get install libseccomp2

# For macOS Docker Desktop
# Increase disk space allocation
# Update to latest Docker Desktop version
```

### Alternative Workarounds

#### 1. Use Pre-built Images
```dockerfile
FROM node:20-slim as base
# Install Python separately
```

#### 2. Multi-stage Build
```dockerfile
FROM node:20 as node-stage
FROM python:3.12-slim
COPY --from=node-stage /usr/local/bin/node /usr/local/bin/
COPY --from=node-stage /usr/local/bin/npm /usr/local/bin/
```

#### 3. Manual Binary Installation
```bash
# Install CLI tools in running container
curl -fsSL https://claude.ai/claude-code/install.sh | bash
npm install -g @google/generative-ai-cli
```

## 📋 Recommended Action Plan

1. **Short-term**: Use minimal Dockerfile + installation documentation
2. **Medium-term**: Monitor Docker/libseccomp updates
3. **Long-term**: Migrate to more recent host systems

## 🔗 References

- [Docker libseccomp issue discussion](https://github.com/docker/for-mac/issues/6963)
- [Debian Bookworm GPG problems](https://stackoverflow.com/questions/76955036/build-started-failing-using-python3-8-docker-image-on-apt-get-update-and-instal)
- [Docker seccomp documentation](https://docs.docker.com/engine/security/seccomp/)

## 📅 Status

- **Issue Identified**: 2025-01-11
- **Current Status**: Workaround implemented
- **Next Review**: Check for Docker/libseccomp updates monthly
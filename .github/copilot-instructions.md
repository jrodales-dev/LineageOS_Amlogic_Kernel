# Copilot Instructions for LineageOS Amlogic Kernel

## Repository Overview

This is the **LineageOS kernel for Amlogic SoCs** (System-on-Chip), specifically targeting devices with Amlogic processors. It's based on Linux kernel **4.9.337** and is approximately **987MB** in size with **43,797 source files** (.c and .h).

**Key Facts:**
- **Kernel Version:** 4.9.337 (Roaring Lionus)
- **Primary Target:** ARM64 architecture for Amlogic devices (S905X, S905Y2, S905Y3, etc.)
- **Secondary Target:** ARM 32-bit architecture support
- **Project Type:** Linux kernel with Android/LineageOS customizations
- **Languages:** C, Assembly, Shell scripts, Perl, Python, Makefiles
- **Build System:** Kbuild (Linux kernel build system)

## Critical Build Requirements

### Toolchains

**For ARM64 builds (primary):**
- Cross-compiler: `aarch64-linux-gnu-` or `aarch64-linux-android-`
- Recommended: Linaro GCC 6.3.1 (2017.02) for aarch64
- Path: `/opt/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin/`

**For ARM 32-bit builds:**
- Cross-compiler: `arm-linux-gnueabihf-`
- Recommended: Linaro GCC 6.3.1 (2017.02) for arm
- Path: `/opt/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf/bin/`

### Required Build Tools
- GNU Make >= 3.80
- GCC >= 3.2 (host compiler)
- binutils >= 2.12
- bison, flex
- libssl-dev, libelf-dev
- bc (calculator)
- device-tree-compiler (dtc)
- lzop, u-boot-tools, cpio, kmod
- rsync, git, wget

## Build Instructions

### 1. Configuration

**For ARM64 (primary architecture):**
```bash
make ARCH=arm64 meson64_defconfig
```

**For ARM 32-bit:**
```bash
make ARCH=arm olddefconfig  # with existing .config
```

**Available defconfigs:**
- `arch/arm64/configs/meson64_defconfig` - Main ARM64 config
- `arch/arm64/configs/meson64_smarthome_defconfig` - Smart home variant
- `arch/arm64/configs/g12a_defconfig` - G12A specific
- `.github/workflows/.configatv` - Pre-built config for ARM32 builds (5767 lines)

**Configuration takes ~2-3 seconds.**

### 2. Building the Kernel

**Standard ARM64 build:**
```bash
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
make -j$(nproc) Image
```

**Build with specific output directory:**
```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- O=../kernel-output Image -j$(nproc)
```

**ARM 32-bit uImage build:**
```bash
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export UIMAGE_LOADADDR=0x1080000
make -j$(nproc) UIMAGE_LOADADDR=0x1080000 uImage
```

**Expected outputs:**
- ARM64: `arch/arm64/boot/Image` (or `Image.gz`)
- ARM32: `arch/arm/boot/uImage`
- vmlinux, System.map

**Build time:** Varies significantly (minutes to hours depending on hardware; use -j$(nproc) for parallelism).

### 3. Building Device Tree Blobs (DTBs)

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- dtbs -j$(nproc)
```

**DTB location:** `arch/arm64/boot/dts/amlogic/*.dtb`

**Important DTBs:**
- `g12a_s905y2_deadpool.dtb`
- `sm1_s905y3_deadpool.dtb`
- Various `gxl_p212_*.dtb` for ARM32

### 4. Building Modules

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules -j$(nproc)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=output modules_install
```

**Module cleanup (recommended):**
```bash
rm -rf output/lib/modules/*/build
rm -rf output/lib/modules/*/source
```

### 5. Cleaning

**Clean build artifacts (keeps .config):**
```bash
make ARCH=arm64 clean
```

**Complete clean (removes .config):**
```bash
make ARCH=arm64 mrproper
```

**Distclean (mrproper + editor backups):**
```bash
make ARCH=arm64 distclean
```

**ALWAYS run `make mrproper` before switching architectures or defconfigs to avoid build errors.**

## Pre-Commit Validation

A pre-commit hook is automatically installed by the build system at `.git/hooks/pre-commit`. It runs:

1. **checkpatch.pl** - Linux kernel coding style checker
   ```bash
   ./scripts/checkpatch.pl --no-signoff -
   ```

2. **licence_pre.pl** - Amlogic license checker (for drivers/amlogic/, include/linux/amlogic/, arch/arm64/boot/dts/amlogic/)
   ```bash
   ./scripts/amlogic/licence_pre.pl -
   ```

**To manually validate before committing:**
```bash
git diff --cached --stat -p HEAD -- | ./scripts/checkpatch.pl --no-signoff -
```

**The pre-commit hook will reject commits that fail checkpatch or license validation.**

## GitHub Actions Workflow

**Workflow file:** `.github/workflows/build_32.yml`

**What it does:**
1. Installs dependencies (build-essential, toolchain, etc.)
2. Downloads Linaro GCC 6.3.1 for ARM 32-bit
3. Runs `make ARCH=arm mrproper` to clean
4. Copies `.github/workflows/.configatv` to `.config`
5. Runs `make ARCH=arm olddefconfig`
6. Builds kernel: `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- UIMAGE_LOADADDR=0x1080000 uImage`
7. Builds DTBs: `make ARCH=arm dtbs`
8. Builds modules and installs with `INSTALL_MOD_STRIP=1`
9. Converts DTBs to DTS for inspection
10. Uploads artifacts

**Typical CI build time:** 20-40 minutes (depending on GitHub runner load).

## Repository Structure

### Key Directories
- `arch/arm64/` - ARM64 architecture code (primary target)
  - `arch/arm64/configs/` - Kernel configurations
  - `arch/arm64/boot/dts/amlogic/` - Device tree sources (~200+ DTS files)
- `arch/arm/` - ARM 32-bit architecture code
- `drivers/amlogic/` - Amlogic-specific drivers (69 subdirectories)
- `scripts/amlogic/` - Build and validation scripts specific to Amlogic
- `build.config.*` - Build configuration files for different targets
- `Documentation/` - Kernel documentation
- `firmware/` - Binary firmware files

### Important Files in Root
- `Makefile` - Main kernel Makefile (defines VERSION=4, PATCHLEVEL=9, SUBLEVEL=337)
- `README` - Standard Linux kernel README
- `MAINTAINERS` - Subsystem maintainers
- `COPYING` - GPL v2 license
- `.config` - Generated kernel configuration (after make defconfig)
- `build.config.meson.arm64.deadpool` - Build config for Deadpool device

### Build Scripts (scripts/amlogic/)
- `mkimage_64.sh` - ARM64 kernel build wrapper
- `mkimage_32.sh` - ARM 32-bit kernel build wrapper
- `mk_gx.sh` - Build script for GX series SoCs
- `mk_dtb_gx.sh` - DTB build helper
- `code_check.sh` - Code validation script (uses Coverity)
- `pre-commit` - Git pre-commit hook (checkpatch + license validation)
- `licence_check.pl` / `licence_pre.pl` - License validation for Amlogic code

## Common Build Issues and Workarounds

### Issue 1: Cross-Compiler Not Found
**Error:** `aarch64-linux-gnu-gcc: command not found`

**Solution:** Export the toolchain path:
```bash
export PATH=/opt/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin:$PATH
export CROSS_COMPILE=aarch64-linux-gnu-
```

### Issue 2: Config Mismatch Between Architectures
**Error:** Various build errors after switching ARCH

**Solution:** ALWAYS run `make mrproper` before changing architecture:
```bash
make ARCH=arm64 mrproper
make ARCH=arm64 meson64_defconfig
```

### Issue 3: Missing Dependencies
**Error:** `bc: command not found` or similar

**Solution:** Install all required packages:
```bash
sudo apt-get install build-essential bc bison flex libssl-dev libelf-dev device-tree-compiler
```

### Issue 4: Pre-Commit Hook Failures
**Error:** Commit rejected due to checkpatch warnings

**Solution:** Fix coding style issues or use `--no-verify` for urgent commits (not recommended):
```bash
git commit --no-verify
```

Better: Fix the issues reported by checkpatch.

### Issue 5: License Check Failures
**Error:** `Licence_WARN` from licence_pre.pl

**Solution:** Add proper license headers to new files in drivers/amlogic/, include/linux/amlogic/, or arch/arm64/boot/dts/amlogic/.

## Code Modification Guidelines

### When Modifying Amlogic Drivers
- Files in `drivers/amlogic/`, `include/linux/amlogic/`, `arch/arm64/boot/dts/amlogic/` require proper license headers
- Run `./scripts/amlogic/licence_check.pl <file>` before committing
- The pre-commit hook will automatically check licenses

### When Modifying Kernel Code
- Follow Linux kernel coding style
- Run checkpatch on your changes:
  ```bash
  ./scripts/checkpatch.pl --file <filename>
  ```
- Or on a patch:
  ```bash
  git diff | ./scripts/checkpatch.pl -
  ```

### When Adding New Device Trees
- Place in `arch/arm64/boot/dts/amlogic/` or `arch/arm/boot/dts/amlogic/`
- Add to Makefile in the same directory
- Test DTB compilation: `make ARCH=arm64 <dtb_name>.dtb`
- Verify with: `dtc -I dtb -O dts <dtb_name>.dtb`

## Testing Your Changes

### Build Test
```bash
# Clean build from scratch
make ARCH=arm64 mrproper
make ARCH=arm64 meson64_defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc) Image dtbs modules
```

### Style Check
```bash
./scripts/checkpatch.pl --file path/to/modified/file.c
```

### License Check (for Amlogic files)
```bash
./scripts/amlogic/licence_check.pl path/to/file.c
```

## External Modules

The `build.config.meson.arm64.deadpool` references external modules not present in this repository:
- `private/dhd-driver/bcmdhd.101.10.361.x` - Broadcom WiFi driver
- `private/mali-driver/bifrost` - Mali GPU driver
- `private/optee_driver` - OP-TEE secure OS driver
- `private/media_modules` - Media codec drivers

**These are not included in this repository and will fail if you try to build them. Skip building external modules unless you have the private/ directory.**

## Important Notes

1. **Always specify ARCH** - Never rely on defaults; always use `ARCH=arm64` or `ARCH=arm`
2. **Use mrproper between major changes** - Switching configs or architectures requires `make mrproper`
3. **Parallel builds** - Always use `-j$(nproc)` for faster builds
4. **Output directory** - Consider using `O=` option to keep source tree clean
5. **Verbose mode** - Use `V=1` for debugging build issues: `make V=1 ...`
6. **Pre-commit hook** - Installed automatically; bypasses require `git commit --no-verify`
7. **Toolchain consistency** - Use Linaro GCC 6.3.1 as specified in build scripts for compatibility

## Trust These Instructions

These instructions have been validated against the actual repository structure, build scripts, and GitHub Actions workflows. Follow them precisely to avoid common pitfalls. Only search for additional information if you encounter errors not documented here or if the repository structure has changed since these instructions were written.

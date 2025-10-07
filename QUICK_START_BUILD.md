# Quick Start: Compilação Kernel S905X 32-bit

## ⚡ Build Rápido (GitHub Actions)

1. Acesse: https://github.com/jrodales-dev/LineageOS_Amlogic_Kernel/actions
2. Selecione "Compilar Kernel 32bits"
3. Clique em "Run workflow"
4. Aguarde ~30-45 minutos
5. Baixe os artefatos: `kernel-s905x-arm32.zip`

## 🖥️ Build Local

### Passo 1: Preparar Ambiente

```bash
# Ubuntu 20.04/22.04
sudo apt-get update
sudo apt-get install -y \
    build-essential libncurses-dev bison flex libssl-dev \
    libelf-dev bc rsync git wget device-tree-compiler \
    lzop u-boot-tools cpio kmod

# Baixar Toolchain
cd ~
wget https://releases.linaro.org/components/toolchain/binaries/6.3-2017.02/arm-linux-gnueabihf/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf.tar.xz
tar -xf gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf.tar.xz

# Configurar PATH
export PATH="$HOME/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf/bin:$PATH"
export CROSS_COMPILE=arm-linux-gnueabihf-
export ARCH=arm
```

### Passo 2: Clonar Repositório

```bash
git clone https://github.com/jrodales-dev/LineageOS_Amlogic_Kernel.git
cd LineageOS_Amlogic_Kernel
```

### Passo 3: Configurar

```bash
# Usar configuração existente
cp .github/workflows/.configatv .config

# Atualizar configuração
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- olddefconfig

# (Opcional) Ajustar manualmente
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig
```

### Passo 4: Compilar

```bash
# Compilar tudo
make -j$(nproc) \
    ARCH=arm \
    CROSS_COMPILE=arm-linux-gnueabihf- \
    UIMAGE_LOADADDR=0x1080000 \
    uImage dtbs modules

# Instalar módulos
mkdir -p ../kernel_output
make ARCH=arm \
     CROSS_COMPILE=arm-linux-gnueabihf- \
     INSTALL_MOD_PATH=../kernel_output \
     INSTALL_MOD_STRIP=1 \
     modules_install
```

### Passo 5: Coletar Artefatos

```bash
mkdir -p ../kernel_output/{boot,dtbs}

# Kernel
cp arch/arm/boot/uImage ../kernel_output/boot/

# Device Trees (S905X = GXL)
cp arch/arm/boot/dts/amlogic/gxl_p212_1g.dtb ../kernel_output/dtbs/
cp arch/arm/boot/dts/amlogic/gxl_p212_2g.dtb ../kernel_output/dtbs/

# Config
cp .config ../kernel_output/
```

## 📦 Usar o Kernel Compilado

### Em TV Box com Android

```bash
# 1. Conectar via ADB
adb connect 192.168.1.100

# 2. Fazer backup do kernel atual
adb shell su -c "dd if=/dev/block/boot of=/sdcard/boot_backup.img"
adb pull /sdcard/boot_backup.img

# 3. Criar nova boot.img com mkbootimg
mkbootimg \
    --kernel kernel_output/boot/uImage \
    --dtb kernel_output/dtbs/gxl_p212_2g.dtb \
    --ramdisk boot_backup-ramdisk.cpio.gz \
    --cmdline "androidboot.hardware=amlogic" \
    --base 0x0 \
    --kernel_offset 0x1080000 \
    --pagesize 2048 \
    -o new_boot.img

# 4. Flash nova boot.img
adb push new_boot.img /sdcard/
adb shell su -c "dd if=/sdcard/new_boot.img of=/dev/block/boot"
adb reboot
```

### Em TV Box com LibreELEC/CoreELEC

```bash
# 1. Copiar kernel para pendrive
cp kernel_output/boot/uImage /media/pendrive/
cp kernel_output/dtbs/gxl_p212_2g.dtb /media/pendrive/dtb.img

# 2. Editar uEnv.txt
echo "dtb_name=/dtb.img" >> /media/pendrive/uEnv.txt

# 3. Copiar módulos
cp -r kernel_output/lib/modules/4.9.113* /media/pendrive/
```

## 🔧 Comandos Úteis

### Verificar Configuração

```bash
# Ver opções habilitadas
grep CONFIG_ARCH_MESON .config
grep CONFIG_AMLOGIC .config | grep "=y"

# Verificar toolchain
arm-linux-gnueabihf-gcc --version
```

### Limpar Build

```bash
# Limpeza leve (mantém .config)
make ARCH=arm clean

# Limpeza completa
make ARCH=arm mrproper
```

### Build Parcial

```bash
# Apenas kernel
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- \
     UIMAGE_LOADADDR=0x1080000 uImage

# Apenas um DTB
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- gxl_p212_2g.dtb

# Apenas módulos
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules
```

### Verificar Artefatos

```bash
# Informações do uImage
mkimage -l arch/arm/boot/uImage

# Descompilar DTB
dtc -I dtb -O dts arch/arm/boot/dts/amlogic/gxl_p212_2g.dtb

# Listar módulos
find kernel_output/lib/modules -name "*.ko"
```

## 📋 Troubleshooting Rápido

| Problema | Solução |
|----------|---------|
| `command not found: arm-linux-gnueabihf-gcc` | Adicionar toolchain ao PATH |
| `No rule to make target 'uImage'` | Instalar `u-boot-tools` |
| `dtc: command not found` | Instalar `device-tree-compiler` |
| Kernel não boota | Verificar load address e DTB |
| Módulos faltando | Executar `modules_install` |

## 📚 Mais Informações

Ver documentação completa em: `ANALISE_BUILD_32BIT_S905X.md`

# Documentação de Build - Kernel 32-bit para Amlogic S905X

## 📚 Documentos Disponíveis

Este conjunto de documentos fornece uma análise completa e guias práticos para compilação do kernel Linux 32-bit ARM para o SoC Amlogic S905X (GXL) destinado a TV Boxes com Android 9 Pie.

### 1. [ANALISE_BUILD_32BIT_S905X.md](./ANALISE_BUILD_32BIT_S905X.md)
**Documentação Técnica Completa (15+ páginas)**

Análise detalhada cobrindo:
- ✅ Configuração do kernel (.configatv)
- ✅ Device Tree (DTS) para S905X
- ✅ Workflow de build (build_32.yml)
- ✅ Dependências e requisitos
- ✅ Comandos de compilação
- ✅ Troubleshooting
- ✅ Referências técnicas

**Recomendado para:** Desenvolvedores que precisam entender em profundidade a configuração.

### 2. [QUICK_START_BUILD.md](./QUICK_START_BUILD.md)
**Guia Rápido de Compilação**

Instruções práticas passo-a-passo:
- ⚡ Build via GitHub Actions (mais fácil)
- 🖥️ Build local (manual)
- 📦 Como usar o kernel compilado
- 🔧 Comandos úteis
- 📋 Troubleshooting rápido

**Recomendado para:** Usuários que querem compilar rapidamente.

### 3. [STATUS_CONFIGURACAO.md](./STATUS_CONFIGURACAO.md)
**Status e Verificações**

Checklist e comparações:
- ✅ O que já está correto
- ⚠️ Verificações recomendadas
- 🔍 O que NÃO precisa modificar
- 📊 Comparação 32-bit vs 64-bit
- 🎯 Checklist final

**Recomendado para:** Validação antes de começar o build.

---

## 🎯 Conclusão Principal

### ✅ **REPOSITÓRIO JÁ ESTÁ PRONTO PARA USO!**

Nenhuma modificação é necessária nos arquivos:
- `.github/workflows/.configatv` - Configuração completa ✅
- `.github/workflows/build_32.yml` - Workflow funcional ✅
- `arch/arm/boot/dts/amlogic/gxl_p212_*.dts` - DTS do S905X ✅

### 🚀 Para Começar Imediatamente:

**Opção 1 - GitHub Actions (Mais Fácil):**
```bash
1. Acesse: https://github.com/jrodales-dev/LineageOS_Amlogic_Kernel/actions
2. Clique em "Compilar Kernel 32bits" > "Run workflow"
3. Aguarde ~30-45 minutos
4. Baixe: kernel-s905x-arm32.zip
```

**Opção 2 - Build Local:**
```bash
# 1. Instalar toolchain
wget https://releases.linaro.org/.../gcc-linaro-6.3.1-...-arm-linux-gnueabihf.tar.xz
tar -xf gcc-linaro-6.3.1-...-arm-linux-gnueabihf.tar.xz
export PATH="$HOME/gcc-linaro-.../bin:$PATH"

# 2. Compilar
git clone https://github.com/jrodales-dev/LineageOS_Amlogic_Kernel.git
cd LineageOS_Amlogic_Kernel
cp .github/workflows/.configatv .config
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- olddefconfig
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- \
     UIMAGE_LOADADDR=0x1080000 uImage dtbs modules
```

---

## 📋 Especificações Técnicas

### Hardware Target
- **SoC:** Amlogic S905X (GXL)
- **CPU:** 4x ARM Cortex-A53 @ 1.5GHz
- **GPU:** ARM Mali-450 MP3
- **RAM:** 1GB/2GB DDR3
- **Arquitetura:** ARM 32-bit (armv7)

### Software
- **Kernel:** Linux 4.9.113 (LTS)
- **Android:** 9 Pie (32-bit userspace)
- **Toolchain:** Linaro GCC 6.3.1 arm-linux-gnueabihf
- **Build Target:** uImage + DTBs + Módulos

### Periféricos Suportados
- ✅ HDMI 2.0 (4K@60fps)
- ✅ Ethernet 10/100 Mbps
- ✅ USB 2.0 (2 portas)
- ✅ SD Card / eMMC
- ✅ IR Remote (GPIO)
- ✅ Audio (SPDIF, I2S)
- ✅ H.265 4K@60fps decode

---

## ❓ FAQ Rápido

**P: Preciso modificar o .configatv?**  
R: Não. Está completo e funcional para S905X.

**P: Qual DTS usar?**  
R: `gxl_p212_2g.dtb` para 2GB RAM ou `gxl_p212_1g.dtb` para 1GB.

**P: Posso usar kernel 64-bit?**  
R: Sim, mas requer Android 64-bit. Para Android 9 32-bit, use 32-bit.

**P: Como instalar no TV Box?**  
R: Via `adb` + `mkbootimg` ou substituir kernel no pendrive de boot.

**P: Quanto tempo demora a compilação?**  
R: ~30-45 minutos no GitHub Actions, ~15-20 minutos local (8 cores).

---

## 🔗 Links Úteis

- **Repositório:** https://github.com/jrodales-dev/LineageOS_Amlogic_Kernel
- **Linaro Toolchain:** https://releases.linaro.org/components/toolchain/binaries/
- **Amlogic Wiki:** https://linux-meson.com/
- **LibreELEC (referência):** https://github.com/LibreELEC/LibreELEC.tv

---

## 📞 Suporte

Para questões sobre build ou configuração:
1. Consulte primeiro os documentos acima
2. Verifique os logs de build em caso de erro
3. Compare com a configuração de referência (.configatv)

---

**Última Atualização:** 2025-01-07  
**Kernel Version:** 4.9.113  
**Target:** Amlogic S905X (GXL) - ARM 32-bit  
**Android:** 9 Pie

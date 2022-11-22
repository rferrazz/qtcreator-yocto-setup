#!/bin/bash

set -e


if [ $# -lt 2 ]; then
    echo "Usage: $0 <sdktool path> <sdk_id> [optional_icon_file]"
    exit 1
fi

SDKTOOL=${1?"Missing first parameter: sdktool executable path"}
SDK_ID=${2?"Missing second parameter: sdk_id"}
ICON="${3:-default.jpg}"

CXX_CODEGEN_FLAGS=${OE_QMAKE_CXX/[^ ]* //}
C_CODEGEN_FLAGS=${OE_QMAKE_CC/[^ ]* //}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp -f ${ICON} ${SDKTARGETSYSROOT}/logo.jpg

NAME="Qt $(qmake -query QT_VERSION) ${SDK_ID}"

# Remove already installed kits with the same name (useful when upgrading or changing sdk folder)

${SDKTOOL} rmKit \
    --id "${SDK_ID}.kit" 1>/dev/null 2>&1 || true

${SDKTOOL} rmQt \
    --id "${SDK_ID}.qt" 1>/dev/null 2>&1 || true

${SDKTOOL} rmDebugger \
    --id "${SDK_ID}.dbg" 1>/dev/null 2>&1 || true

${SDKTOOL} rmTC \
    --id "ProjectExplorer.ToolChain.Gcc:${SDK_ID}.c" 1>/dev/null 2>&1 || true

${SDKTOOL} rmTC \
    --id "ProjectExplorer.ToolChain.Gcc:${SDK_ID}.cxx" 1>/dev/null 2>&1 || true

# ${SDKTOOL} rmDev \
#     --id "${SDK_ID}.dev" 1>/dev/null 2>&1 || true

# Install the new kit

# Note: OE_QMAKE_CXX is used here to prevent linking problems
${SDKTOOL} addTC \
    --id "ProjectExplorer.ToolChain.Gcc:${SDK_ID}.cxx" \
    --name "G++ (${SDK_ID})" \
    --path "$(type -p ${OE_QMAKE_CXX})" \
    --abi "arm-linux-generic-elf-32bit"  \
    --language 2 \
    ProjectExplorer.GccToolChain.PlatformCodeGenFlags "QVariantList:${CXX_CODEGEN_FLAGS}"

${SDKTOOL} addTC \
    --id "ProjectExplorer.ToolChain.Gcc:${SDK_ID}.c" \
    --name "GCC (${SDK_ID})" \
    --path "$(type -p ${OE_QMAKE_CC})" \
    --abi "arm-linux-generic-elf-32bit"  \
    --language 1 \
    ProjectExplorer.GccToolChain.PlatformCodeGenFlags "QVariantList:${C_CODEGEN_FLAGS}"

${SDKTOOL} addQt \
    --id "${SDK_ID}.qt" \
    --name "${SDK_ID}" \
    --qmake "$(type -p qmake)" \
    --type "RemoteLinux.EmbeddedLinuxQt"

${SDKTOOL} addDebugger \
    --id "${SDK_ID}.dbg" \
    --name "GDB (${SDK_ID})" \
    --binary "$(type -p ${GDB})" \
    --engine 1 \
    --abis "arm-linux-generic-elf-32bit"

# ${SDKTOOL} addDev \
#     --id "${SDK_ID}.dev" \
#     --name "${SDK_ID} device" \
#     --origin 0 \
#     --type 0 \
#     --osType "GenericLinuxOsType" \
#     --authentication 3 \
#     --host "${TARGET_HOSTNAME}" \
#     --sshPort "22" \
#     --timeout 10 \
#     --uname "root" \
#     --password "" \
#     --freePorts "10000-10100"

${SDKTOOL} addKit \
    --id "${SDK_ID}.kit" \
    --name "${SDK_ID}" \
    --qt "${SDK_ID}.qt" \
    --devicetype "GenericLinuxOsType" \
    --device "${SDK_ID}.dev" \
    --sysroot "${SDKTARGETSYSROOT}" \
    --Cxxtoolchain "ProjectExplorer.ToolChain.Gcc:${SDK_ID}.cxx" \
    --Ctoolchain "ProjectExplorer.ToolChain.Gcc:${SDK_ID}.c" \
    --icon "${SDKTARGETSYSROOT}/logo.jpg" \
    --mkspec "linux-oe-g++" \
    --debuggerid "${SDK_ID}.dbg" \
    --env "OE_QMAKE_CXX=${OE_QMAKE_CXX}" \
    --env "OE_QMAKE_RCC=${OE_QMAKE_RCC}" \
    --env "OE_QMAKE_INCDIR_QT=${OE_QMAKE_INCDIR_QT}" \
    --env "OE_QMAKE_AR=${OE_QMAKE_AR}" \
    --env "OE_QMAKE_LINK=${OE_QMAKE_LINK}" \
    --env "OE_QMAKE_PATH_HOST_BINS=${OE_QMAKE_PATH_HOST_BINS}" \
    --env "OE_QMAKE_MOC=${OE_QMAKE_MOC}" \
    --env "OE_QMAKE_LIBDIR_QT=${OE_QMAKE_LIBDIR_QT}" \
    --env "OE_QMAKE_CXXFLAGS=${OE_QMAKE_CXXFLAGS}" \
    --env "OE_QMAKE_CC=${OE_QMAKE_CC}" \
    --env "OE_QMAKE_CFLAGS=${OE_QMAKE_CFLAGS}" \
    --env "OE_QMAKE_UIC=${OE_QMAKE_UIC}" \
    --env "OE_QMAKE_LDFLAGS=${OE_QMAKE_LDFLAGS}" \
    --env "QMAKESPEC=${QMAKESPEC}" \
    --env "OE_QMAKE_QDBUSXML2CPP=${OE_QMAKE_QDBUSXML2CPP}" \
    --env "OE_QMAKE_QDBUSCPP2XML=${OE_QMAKE_QDBUSCPP2XML}" \
    --env "OE_QMAKE_QT_CONFIG=${OE_QMAKE_QT_CONFIG}"


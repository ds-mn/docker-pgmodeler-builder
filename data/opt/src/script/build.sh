#!/bin/bash

DIR_INSTALL=/opt/pgmodeler
DIR_POSTGRESQL=/opt/postgresql
DIR_SRC=/opt/src
DIR_SRC_PGMODELER=${DIR_SRC}/pgmodeler
PATH=/usr/lib/mxe/usr/bin:${PATH}

TC_PREFIX=$(ls /usr/lib/mxe/usr/bin | grep shared-gcov | head -c4)
if [ ${TC_PREFIX} == "i686" ]; then
  TOOLCHAIN=i686-w64-mingw32.shared
  LIB_SUFFIX=""
else
  TOOLCHAIN=x86_64-w64-mingw32.shared
  LIB_SUFFIX="-x64"
fi

NUM_CPUS_DEF=$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}')
NUM_CPUS=${2:-NUM_CPUS_DEF}
function build() {
  local dir_mxe=/usr/lib/mxe
  local dir_mxe_toolchain=${dir_mxe}/usr/${TOOLCHAIN}
  local dir_qt=${dir_mxe_toolchain}/qt5
  local dir_plugins=${dir_qt}/plugins
  local dir_plugins_install=${DIR_INSTALL}/qtplugins
  local objdump=${dir_mxe}/usr/bin/${TOOLCHAIN}-objdump

  cd ${DIR_SRC_PGMODELER}

  # Replace some bits that are only relevant when building ON Windows.

  sed -i pgmodeler.pri -e 's/^.*wingetdate.*$/ BUILDNUM=$$system("date \x27+%Y%m%d\x27")/' pgmodeler.pri

  # Build pgModeler.

  ${TOOLCHAIN}-qmake-qt5 -r PREFIX=${DIR_INSTALL} PGSQL_INC=${DIR_POSTGRESQL}/include \
    PGSQL_LIB=${DIR_POSTGRESQL}/lib/libpq.dll XML_INC=${dir_mxe_toolchain}/include/libxml2 \
    XML_LIB=${dir_mxe_toolchain}/bin/libxml2-2.dll
  make -j${NUM_CPUS}
  make install
  rm ${DIR_INSTALL}/*.a

  # Copy dependencies.

  cd ${DIR_SRC}/pydeployqt

  ./deploy.py --build=${DIR_INSTALL} --objdump=${objdump} ${DIR_INSTALL}/pgmodeler.exe
  ./deploy.py --build=${DIR_INSTALL} --objdump=${objdump} ${DIR_INSTALL}/pgmodeler-ch.exe
  ./deploy.py --build=${DIR_INSTALL} --objdump=${objdump} ${DIR_INSTALL}/pgmodeler-cli.exe

  cp ${dir_qt}/bin/Qt5Network.dll ${DIR_INSTALL}
  cp ${dir_qt}/bin/Qt5PrintSupport.dll ${DIR_INSTALL}
  cp ${dir_qt}/bin/Qt5Svg.dll ${DIR_INSTALL}
  cp ${dir_mxe_toolchain}/bin/libcrypto-1_1${LIB_SUFFIX}.dll ${DIR_INSTALL}
  cp ${dir_mxe_toolchain}/bin/liblzma-5.dll ${DIR_INSTALL}
  cp ${dir_mxe_toolchain}/bin/libssl-1_1${LIB_SUFFIX}.dll ${DIR_INSTALL}
  cp ${dir_mxe_toolchain}/bin/libxml2-2.dll ${DIR_INSTALL}
  cp ${DIR_POSTGRESQL}/lib/libpq.dll ${DIR_INSTALL}

  # Add QT configuration.

  echo -e "[Paths]\nPrefix=.\nPlugins=qtplugins\nLibraries=." >${DIR_INSTALL}/qt.conf

  # Copy QT plugins.

  mkdir -p ${dir_plugins_install}/platforms

  cp -R ${dir_plugins}/imageformats ${dir_plugins_install}
  cp ${dir_plugins}/platforms/qwindows.dll ${dir_plugins_install}/platforms
  cp -R ${dir_plugins}/printsupport ${dir_plugins_install}
}

function clone_source() {
  cd ${DIR_SRC_PGMODELER}

  git fetch -a
  git pull --ff-only || exit 2
}

function check_version() {
  local tags_file=$(mktemp)

  cd ${DIR_SRC_PGMODELER}

  git tag >${tags_file}
  #  git branch -a |tail -n+2 | awk -F'/' '{print $NF}' >> ${tags_file}
  sort -o ${tags_file} ${tags_file}
  echo ""

  if [ -z "${1}" ]; then
    echo -e "Missing pgModeler version.  Valid versions:\n"
    cat ${tags_file}

    exit 0
  fi

  if [[ "${1}" =~ $(echo ^\($(paste -sd'|' ${tags_file})\)$) ]]; then
    git checkout -b ${1} ${1}
  else
    echo -e "Invalid pgModeler version '${1}'.  Valid versions:\n"
    cat ${tags_file}

    exit 0
  fi
  #  git clone https://github.com/pgmodeler/plugins.git
  #  pushd plugins
  #  git checkout develop
  ##  rm -r dummy
  #  popd
}

clone_source
check_version ${1}
build

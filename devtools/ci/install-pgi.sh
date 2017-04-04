#!/bin/sh

# Install PGI Community Edition on Travis
# https://github.com/nemequ/pgi-travis
#
# Originally written for Squash <https://github.com/quixdb/squash> by
# Evan Nemerson.  For documentation, bug reports, support requests,
# etc. please use <https://github.com/nemequ/pgi-travis>.
#
# To the extent possible under law, the author(s) of this script have
# waived all copyright and related or neighboring rights to this work.
# See <https://creativecommons.org/publicdomain/zero/1.0/> for
# details.

DESTINATION="${HOME}/pgi"
TEMPORARY_FILES="/tmp"

export PGI_SILENT=true
export PGI_ACCEPT_EULA=accept
export PGI_INSTALL_DIR="${HOME}/pgi"
export PGI_INSTALL_NVIDIA=false
export PGI_INSTALL_AMD=false
export PGI_INSTALL_JAVA=false
export PGI_INSTALL_MPI=false
export PGI_MPI_GPU_SUPPORT=false
export PGI_INSTALL_MANAGED=false

VERBOSE=false

while [ $# != 0 ]; do
    case "$1" in
	"--dest")
	    export PGI_INSTALL_DIR="$(realpath "$2")"; shift
	    ;;
	"--tmpdir")
	    TEMPORARY_FILES="$2"; shift
	    ;;
	"--nvidia")
	    export PGI_INSTALL_NVIDIA=true; shift
	    ;;
	"--amd")
	    export PGI_INSTALL_AMD=true; shift
	    ;;
	"--java")
	    export PGI_INSTALL_JAVA=true; shift
	    ;;
	"--mpi")
	    export PGI_INSTALL_MPI=true; shift
	    ;;
	"--mpi-gpu")
	    export PGI_INSTALL_MPI_GPU=true; shift
	    ;;
	"--managed")
	    export PGI_INSTALL_MANAGED=true; shift
	    ;;
	"--verbose")
	    VERBOSE=true;
	    ;;
	*)
	    echo "Unrecognized argument '$1'"
	    exit 1
	    ;;
    esac
    shift
done

if [ ! -e "${TEMPORARY_FILES}" ]; then
    mkdir -p "${TEMPORARY_FILES}"
fi

if [ ! -e "${TEMPORARY_FILES}"/pgi.tar.gz ]; then
    wget -cO "${TEMPORARY_FILES}"/pgi.tar.gz \
	 -U "pgi-travis (https://github.com/nemequ/pgi-travis; ${TRAVIS_REPO_SLUG})" \
	 --header="X-Travis-Build-Number: ${TRAVIS_BUILD_NUMBER}" \
	 --header="X-Travis-Event-Type: ${TRAVIS_EVENT_TYPE}" \
	 --header="X-Travis-Job-Number: ${TRAVIS_JOB_NUMBER}" \
	 --referer="http://www.pgroup.com/products/community.htm" \
	 "https://www.pgroup.com/support/downloader.php?file=pgi-community-linux-x64" || exit 1
fi

if [ x"${VERBOSE}" = "xtrue" ]; then
    VERBOSE_SHORT="-v"
    VERBOSE_V="v"
fi

cd "${TEMPORARY_FILES}"
tar zxf${VERBOSE_V}k pgi.tar.gz
cd "${TEMPORARY_FILES}"/install_components && ./install

PGI_VERSION=$(basename "${PGI_INSTALL_DIR}"/linux86-64/*.*/)

INSTALL_BINDIR="${HOME}/bin"
if [ ! -e "${INSTALL_BINDIR}" ]; then
    mkdir -p "${INSTALL_BINDIR}"
fi

for file in "${PGI_INSTALL_DIR}"/linux86-64/"${PGI_VERSION}"/bin/*; do
    dest="${INSTALL_BINDIR}/$(basename "${file}")"
    if [ -x "${file}" ]; then
	echo "#!/bin/sh -x" > "${dest}"
	echo "PGI=${PGI_INSTALL_DIR} PGI_INSTALL=\"\${PGI}\"/linux86-64/${PGI_VERSION} LM_LICENSE_FILE=\"\${PGI}\"/license.dat ${file} \$@" >> "${dest}"
	chmod 0755 "${dest}"
    fi
done

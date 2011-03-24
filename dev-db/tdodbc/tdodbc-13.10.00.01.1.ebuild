# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils rpm

MY_PV=${PV/%.[0-9]/-\1}
TDICU_PV="13.10.00.00-1"
TDGSS_PV="13.10.00.02-1"

DESCRIPTION="Teradata ODBC driver Package"
HOMEPAGE="http://downloads.teradata.com/download/connectivity/odbc-driver/linux"
SRC_URI="${PN}__LINUX_INDEP.${MY_PV}.tar.gz"

LICENSE="Teradata"
SLOT="0"
KEYWORDS="~x86"
IUSE=""
RESTRICT="fetch"

DEPEND="app-arch/rpm2targz"
RDEPEND="virtual/libstdc++ sys-libs/lib-compat"

pkg_nofetch() {
		eerror "Please go to:"
		eerror "  ${HOMEPAGE}"
		eerror "select your platform and download"
		eerror "Teradata ODBC Driver for Linux, which is:"
		eerror " ${SRC_URI}"
		eerror "Then after downloading put it in:"
		eerror "  ${DISTDIR}"
		die
}

src_prepare() {
	mkdir "${S}"
	rm *.txt
	unpack ./tdicu__linux_indep.*.tar.gz && \
		rm ./tdicu__linux_indep.*.tar.gz || die
	unpack ./TeraGSS_redhatlinux-i386__linux_i386.*.tar.gz && \
		rm ./TeraGSS_redhatlinux-i386__linux_i386.*.tar.gz || die
	rm ./TeraGSS_suselinux-x8664__linux_x8664.*.tar.gz
	unpack ./tdodbc__linux_x64.*.tar.gz && \
		rm ./tdodbc__linux_x64.*.tar.gz || die
	cd "${S}"
	rpm_unpack ./../tdicu/tdicu-*.noarch.rpm && \
		rm -r ./../tdicu || die
	rpm_unpack ./../TeraGSS/TeraGSS_redhatlinux-i386-*.i386.rpm && \
		rm -r ./../TeraGSS || die
	rpm_unpack ./../tdodbc/tdodbc-*.noarch.rpm && \
		rm -r ./../tdodbc || die
	einfo Removing amd64 libraries and binaries
	rm -r opt/teradata/client/${MY_PV%.[0-9]*.[0-9]*-[0-9]*}/odbc_64
	rm -r usr/lib64
	rm -r opt/teradata/client/13.10/tdicu/lib64
}

src_install() {
	TDGSS_DIR="/opt/teradata/teragss/redhatlinux-i386/${TDGSS_PV%-[0-9]*}"
	cd "${S}${TDGSS_DIR}" || die
	dodir "${TDGSS_DIR%/redhatlinux-i386/${TDGSS_PV%-[0-9]*}}/site/redhatlinux-i386" || die
	insinto "${TDGSS_DIR%/redhatlinux-i386/${TDGSS_PV%-[0-9]*}}/site" || die
	doins etc/TdgssUserConfigFile.xml || die
	dosym "${TDGSS_DIR}" "${TDGSS_DIR%/${TDGSS_PV%-[0-9]*}}/client" || die
	echo "${TDGSS_PV%-[0-9]*}" > version || die
	insinto "${TDGSS_DIR}" || die
	doins version && rm version || die
	dosym /opt/teradata/teragss /usr/teragss
	into "${TDGSS_DIR}" || die
	dobin bin/* && rm bin/* || die
	dolib lib/*.so lib/*.a && rm lib/*.so lib/*.a || die
	rmdir etc/cfg
	dodir "${TDGSS_DIR}/etc/cfg"
	for my_dir in doc/html doc/pod doc/man1 etc lib/tcl/Tds lib/java inc
	do
		insinto "${TDGSS_DIR}/${my_dir}" || die
		doins "${my_dir}/"* && rm "${my_dir}/"* && rmdir "${my_dir}" || die
	done
	TDODBC_DIR="/opt/teradata/client/${MY_PV%.[0-9]*.[0-9]*-[0-9]*}/odbc_32"
	cd "${S}${TDODBC_DIR}" || die
	into "${TDODBC_DIR}" || die
	dobin bin/* bin/.build_pre130_bridge && rm bin/* bin/.build_pre130_bridge || die
	dolib lib/*.so && rm lib/*.so || die
	echo "export LD_LIBRARY_PATH=${TDODBC_DIR}/lib:\$LD_LIBRARY_PATH" > tdodbc.sh || die
	insinto /etc/profile.d || die
	doins tdodbc.sh && rm tdodbc.sh || die
	for my_dir in include locale/en_US/LC_MESSAGES msg help/man/man5 samples/C samples/C++
	do
		insinto "${TDODBC_DIR}/${my_dir}" || die
		doins "${my_dir}/"* && rm "${my_dir}/"* && rmdir "${my_dir}" || die
	done
	for my_file in README odbc.ini odbcinst.ini
	do
		insinto "${TDODBC_DIR}" || die
		doins "${my_file}" && rm "${my_file}" || die
	done
	TDICU_DIR="/opt/teradata/client/${MY_PV%.[0-9]*.[0-9]*-[0-9]*}/tdicu"
	cd "${S}${TDICU_DIR}" || die
	into "/usr"
	dolib lib/* || die
	into "${TDICU_DIR}" || die
	dolib lib/* && rm lib/* || die
}

pkg_postinst () {
	einfo runing tdgssconfig configuration utility
	/opt/teradata/teragss/redhatlinux-i386/client/bin/run_tdgssconfig || die
}

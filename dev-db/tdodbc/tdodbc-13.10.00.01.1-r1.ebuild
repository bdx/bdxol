# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils rpm

DESCRIPTION="Teradata ODBC driver Package"
HOMEPAGE="http://downloads.teradata.com/download/connectivity/odbc-driver/linux"
SRC_URI=${PN}__LINUX_INDEP.${PV/%.[0-9]/-\1}.tar.gz

LICENSE="Teradata"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="motif"
RESTRICT="fetch"

[[ "${ARCH}" == "amd64" ]] || \
	RDEPEND="sys-libs/lib-compat"

RDEPEND="${RDEPEND}
		virtual/libstdc++
		motif? ( x11-libs/openmotif:2.2 )"

DEPEND="${RDEPEND}
		app-arch/rpm2targz"

pkg_nofetch() {
		eerror "Please go to:"
		eerror "  ${HOMEPAGE}"
		eerror "select your platform and download"
		eerror "Teradata ODBC Driver for Linux, which is:"
		eerror "  ${SRC_URI}"
		eerror "Then after downloading put it in:"
		eerror "  ${DISTDIR}"
		die
}

src_prepare() {
	mkdir "${S}"
	rm *.txt
	unpack ./tdicu__linux_indep.*.tar.gz && \
		rm ./tdicu__linux_indep.*.tar.gz || die
	[[ "${ARCH}" == "amd64" ]] && {
		unpack ./TeraGSS_suselinux-x8664__linux_x8664.*.tar.gz && \
			rm ./TeraGSS_suselinux-x8664__linux_x8664.*.tar.gz || die
		rm ./TeraGSS_redhatlinux-i386__linux_i386.*.tar.gz
	} || {
		unpack ./TeraGSS_redhatlinux-i386__linux_i386.*.tar.gz && \
			rm ./TeraGSS_redhatlinux-i386__linux_i386.*.tar.gz || die
		rm ./TeraGSS_suselinux-x8664__linux_x8664.*.tar.gz
	}
	unpack ./tdodbc__linux_x64.*.tar.gz && \
		rm ./tdodbc__linux_x64.*.tar.gz || die
	cd "${S}"
	rpm_unpack ./../tdicu/tdicu-*.noarch.rpm && \
		rm -r ./../tdicu || die
	[[ "${ARCH}" == "amd64" ]] && {
		rpm_unpack ./../TeraGSS/TeraGSS_suselinux-x8664-*.x86_64.rpm && \
			rm -r ./../TeraGSS || die
	} || {
		rpm_unpack ./../TeraGSS/TeraGSS_redhatlinux-i386-*.i386.rpm && \
			rm -r ./../TeraGSS || die
	}
	rpm_unpack ./../tdodbc/tdodbc-*.noarch.rpm && \
		rm -r ./../tdodbc || die
	[[ "${ARCH}" == "amd64" ]] && {
		einfo Removing x86 libraries and binaries
		rm -r opt/teradata/client/[0-9][0-9].[0-9][0-9]/odbc_32
		rm -r usr/lib
		rm -r opt/teradata/client/[0-9][0-9].[0-9][0-9]/tdicu/lib
	} || {
		einfo Removing amd64 libraries and binaries
		rm -r opt/teradata/client/[0-9][0-9].[0-9][0-9]/odbc_64
		rm -r usr/lib64
		rm -r opt/teradata/client/[0-9][0-9].[0-9][0-9]/tdicu/lib64
	}
}

src_install() {
	TDODBC_DIR="/$(ls -d opt/teradata/client/[0-9][0-9].[0-9][0-9]/odbc_[36][24])"
	TDICU_DIR="/$(ls -d opt/teradata/client/[0-9][0-9].[0-9][0-9]/tdicu)"
	[[ "${ARCH}" == "amd64" ]] && {
		MY_DIST="suselinux-x8664"
	} || {
		MY_DIST="redhatlinux-i386"
	}
	TDGSS_DIR="/$(ls -d opt/teradata/teragss/${MY_DIST}/[0-9][0-9].[0-9][0-9].[0-9][0-9].[0-9][0-9] || die )"
	dodir "${TDGSS_DIR}/../../site/${MY_DIST}" || die
	dosym "${TDGSS_DIR}" "${TDGSS_DIR}/../client" || die
	echo "$(ls ${TDGSS_DIR#\/}/..)" > version || die
	insinto "${TDGSS_DIR}" || die
	doins version && rm version || die
	cd "${S}${TDGSS_DIR}" || die
	insinto "${TDGSS_DIR}/../../site" || die
	doins etc/TdgssUserConfigFile.xml || die
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
	cd "${S}${TDODBC_DIR}" || die
	into "${TDODBC_DIR}" || die
	dobin bin/* bin/.build_pre130_bridge && rm bin/* bin/.build_pre130_bridge || die
	dolib lib/*.so && rm lib/*.so || die
	echo "export LD_LIBRARY_PATH=${TDGSS_DIR}/lib:${TDODBC_DIR}/lib:\$LD_LIBRARY_PATH" > tdodbc.sh || die
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
	cd "${S}${TDICU_DIR}" || die
	into "/usr"
	[[ "${ARCH}" == "amd64" ]] && {
		dolib lib64/* || die
	} || {
		dolib lib/* || die
	}
	into "${TDICU_DIR}" || die
	[[ "${ARCH}" == "amd64" ]] && {
		dolib lib64/* && rm lib64/* || die
	} || {
		dolib lib/* && rm lib/* || die
	}
}

pkg_postinst () {
	[[ "${ARCH}" == "amd64" ]] && {
		MY_DIST="suselinux-x8664"
	} || {
		MY_DIST="redhatlinux-i386"
	}
	einfo runing tdgssconfig configuration utility
	/opt/teradata/teragss/${MY_DIST}/client/bin/run_tdgssconfig || die
}

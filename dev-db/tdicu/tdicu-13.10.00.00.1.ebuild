# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils rpm

MY_PV=${PV/%.[0-9]/-\1}

DESCRIPTION="Shared common components for Internationalization for Teradata"
HOMEPAGE="http://downloads.teradata.com/download/connectivity/odbc-driver/linux"
SRC_URI=tdodbc__LINUX_INDEP.13.10.00.01-1.tar.gz
IUSE=""
LICENSE="Teradata"
SLOT="0"
KEYWORDS="~x86 ~amd64"
RESTRICT="fetch"

[[ "${ARCH}" == "amd64" ]] || \
	RDEPEND="sys-libs/lib-compat"

RDEPEND="${RDEPEND}
		virtual/libstdc++"

DEPEND="${RDEPEND}
		app-arch/rpm2targz"

QA_DT_NEEDED="/usr/lib.*/libicudatatd.so.36.0"

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

src_unpack() {
	unpack ${A}
	unpack "./${PN}__linux_indep.${MY_PV}.tar.gz"
	rpm_unpack "./${PN}/${PN}-${MY_PV}.noarch.rpm"
}

src_install() {
	cd "opt/teradata/client/${PV%.[0-9][0-9].[0-9][0-9].[0-9]}/tdicu"
	[[ "${ARCH}" == "amd64" ]] && {
		cd lib64
	} || {
		cd lib
	}
	dolib *
}

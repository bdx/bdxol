# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="SSL VPN Client for Fortinet"
HOMEPAGE="http://www.forticlient.com/"
SRC_URI="ftp://pftpintl:F0rt1intl@support.fortinet.com/FortiGate/v4.00/4.0MR3/MR3_Patch_14/SSL-VPN/forticlientsslvpn_linux_4.4.2287.tar.gz"
LICENSE="FortiClientSSLVPN"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~x86"
DEPEND=""
RDEPEND="${DEPEND}
	sys-apps/iproute2
	net-dialup/ppp"

S="${WORKDIR}/forticlientsslvpn"
QA_PREBUILT="opt/forticlient-sslvpn/forticlientsslvpn opt/forticlient-sslvpn/helper/subproc"

src_unpack() {
    unpack ${A}
    cd "${S}"
}

src_install() {
	exeinto opt/forticlient-sslvpn
	doexe forticlientsslvpn
	doexe forticlientsslvpn_cli
	cp -r helper ${D}/opt/forticlient-sslvpn/helper
}

pkg_postinst() {
	ewarn "Forticlient SSL VPN is closed-source."
	einfo "Installed in /opt/forticlient-sslvpn"
}








   


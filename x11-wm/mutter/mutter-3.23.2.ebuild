# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools gnome2

DESCRIPTION="GNOME 3 compositing window manager based on Clutter"
HOMEPAGE="https://git.gnome.org/browse/mutter/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="deprecated-background +introspection kms test wayland"
REQUIRED_USE="
	wayland? ( kms )
"

# libXi-1.7.4 or newer needed per:
# https://bugzilla.gnome.org/show_bug.cgi?id=738944
COMMON_DEPEND="
	>=x11-libs/pango-1.2[X,introspection?]
	>=x11-libs/cairo-1.10[X]
	>=x11-libs/gtk+-3.19.8:3[X,introspection?]
	>=dev-libs/glib-2.36.0:2[dbus]
	>=media-libs/clutter-1.25.6:1.0[X,introspection?]
	>=media-libs/cogl-1.17.1:1.0=[introspection?]
	>=media-libs/libcanberra-0.26[gtk3]
	>=x11-libs/startup-notification-0.7
	>=x11-libs/libXcomposite-0.2
	>=gnome-base/gsettings-desktop-schemas-3.21.4[introspection?]
	gnome-base/gnome-desktop:3=
  >=dev-util/gdbus-codegen-2.50
	>sys-power/upower-0.99:=

	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	>=x11-libs/libXcomposite-0.2
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	>=x11-libs/libXi-1.7.4
	x11-libs/libXinerama
	>=x11-libs/libXrandr-1.5
	x11-libs/libXrender
	x11-libs/libxcb
	x11-libs/libxkbfile
	>=x11-libs/libxkbcommon-0.4.3[X]
	x11-misc/xkeyboard-config

	gnome-extra/zenity

	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
	kms? (
		dev-libs/libinput
		>=media-libs/clutter-1.20[egl]
		media-libs/cogl:1.0=[kms]
		>=media-libs/mesa-10.3[gbm]
		virtual/libgudev
		x11-libs/libdrm:= )
	wayland? (
		>=dev-libs/wayland-1.6.90
		>=dev-libs/wayland-protocols-1.1
		>=media-libs/clutter-1.20[wayland]
		x11-base/xorg-server[wayland] )
		>=sys-auth/elogind-2016
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.41
	sys-devel/gettext
	virtual/pkgconfig
	x11-proto/xextproto
	x11-proto/xineramaproto
	x11-proto/xproto
	test? ( app-text/docbook-xml-dtd:4.5 )
"
RDEPEND="${COMMON_DEPEND}
	!x11-misc/expocity
"

src_prepare() {
	if use deprecated-background; then
		eapply "${FILESDIR}"/${PN}-3.18.4-restore-deprecated-background-code.patch
	fi

  echo ">>> Replacing systemd with elogind in source files ..."
  grep -lr "systemd" --include \*.c | while read -r line ; do
       echo " * ${S}/$line"
       sed -i 's/include <systemd/include <elogind/g' "${S}/$line" || die 'sed failed'
  done

  echo ">>> Replacing libsystemd with libelogind in configuration file ..."
  sed -i 's/libsystemd/libelogind/g' "${S}/configure.ac"

  echo ">>> Fixing linux header include ..."
  grep -lr "input-event-codes.h" --include \*.c | while read -r line ; do
       echo " * ${S}/$line"
       sed -i 's/include <linux\/input-event-codes.h/include <linux\/input.h/g' "${S}/$line" || die 'sed failed'
  done

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--enable-sm \
		--enable-startup-notification \
		--enable-verbose-mode \
		--with-libcanberra \
		$(use_enable introspection) \
		$(use_enable kms native-backend) \
		$(use_enable wayland)
}

{ pkgs
, lib
, stdenv
, fetchFromGitHub
,
}:
let
  pname = "breezy-desktop";
  uuid = "breezydesktop@org.xronlinux";
in
stdenv.mkDerivation rec {
  inherit pname;
  version = "v0.10.5.4-beta";

  src = fetchFromGitHub {
    owner = "wheaney";
    repo = pname;
    rev = version;
    fetchSubmodules = true;
    sha256 = "sha256-pwc2GX3/N6zKYeKMcRVPUBzijQmPYn/fqZZRL7ba1qQ=";
  };

  nativeBuildInputs = with pkgs; [ buildPackages.glib ];
  installPhase = ''
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp -r -T gnome/src $out/share/gnome-shell/extensions/${uuid}
  '';
  meta = {
    description = "Breezy GNOME XR Desktop";
    longDescription = "XR virtual desktop for GNOME.";
    homepage = "https://github.com/wheaney/breezy-desktop";
    license = lib.licenses.gpl2Plus; # https://wiki.gnome.org/Projects/GnomeShell/Extensions/Review#Licensing
    maintainers = with lib.maintainers; [ piegames ];
  };
  passthru = {
    extensionPortalSlug = pname;
    extensionUuid = uuid;
  };
}

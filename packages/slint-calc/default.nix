{ rustPlatform
, fetchFromGitHub
, libxkbcommon
, fontconfig
, xorg
, wayland
, pkg-config
, openssl
,
}:
rustPlatform.buildRustPackage {
  name = "slint-cal";
  src = fetchFromGitHub {
    owner = "Simcra";
    repo = "slint-rust-calculator";
    rev = "5a6f583d5642d174c6fe73581ae989e16be6b4c0";
    hash = "sha256-mnfNPef4QddF1IunHBLbXQ19FTAuynd5soI4drLPwNA=";
  };

  cargoHash = "sha256-fGYYijbsozIrL5IGRzUPmt5U0yqgcU5aTTCr4lT2AFE=";

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    openssl
  ];

  buildInputs = [
    libxkbcommon
    fontconfig

    # Wayland
    wayland

    # Xorg/X11
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
  ];
}

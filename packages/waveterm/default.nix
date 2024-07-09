{ fetchurl
, appimageTools
, libsecret
}: appimageTools.wrapType2 rec {
  name = "waveterm";
  version = "0.7.6";
  src = fetchurl {
    url = "https://github.com/wavetermdev/waveterm/releases/download/v${version}/Wave-linux-x86_64-${version}.AppImage";
    hash = "sha256-JacFG2jBhLvl+hMkHQG+VfKoDJd1cgU2S3gkloSeh5A=";
  };
  extraPkgs = pkgs: with pkgs; [ libsecret ];

}

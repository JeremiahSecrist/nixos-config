{ stdenv
, libgcc
, lib
, fetchFromGitHub
, cmake
, pkg-config
, patchelf
, python311Packages
, libusb
, curl
, libevdev
, json_c
, hidapi
, openssl
,
}:
let
  version = "v0.10.5.3";
  pname = "xrDriver";
in
stdenv.mkDerivation {
  inherit pname version;
  src = fetchFromGitHub {
    owner = "wheaney";
    repo = "XRLinuxDriver";
    rev = version;
    sha256 = "sha256-hH/LuvTKpTcmcGodYStN8bedrMIVsJ8agvKiKN719aY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = with python311Packages; [ pyyaml curl libevdev json_c hidapi libusb ];
  dontStrip = true;
  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DSYSTEM_INSTALL=1"
  ];
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp ../lib/x86_64/libRayNeoXRMiniSDK.so $out/lib
    cp ./xrDriver $out/bin
    patchelf --set-rpath ${lib.makeLibraryPath [libusb curl libevdev json_c hidapi openssl libgcc]}:$out/lib:${stdenv.cc.cc.lib}/lib/ $out/lib/libRayNeoXRMiniSDK.so
    patchelf --set-rpath ${lib.makeLibraryPath [libusb curl libevdev json_c hidapi openssl libgcc]}:$out/lib:${stdenv.cc.cc.lib}/lib/ $out/bin/xrDriver
  '';

  meta = {
    description = "Linux Driver for XR devices";
    homepage = "https://github.com/wheaney/XRLinuxDriver";
    license = lib.licenses.mit;
  };
}

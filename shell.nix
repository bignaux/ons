with import <nixpkgs> {};

# see https://nixos.wiki/wiki/Android

stdenv.mkDerivation rec{
  name = "ons";

  nativeBuildInputs = [];

  buildInputs =  [
		abootimg
		android-tools 
		apktool
		apksigner
		pmbootstrap
		payload_dumper
		android-studio
		universal-android-debloater
	];

  checkInputs = [];
}

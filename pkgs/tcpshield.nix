{
  fetchurl,
  lib,
}:
fetchurl {
  url = "https://github.com/TCPShield/RealIP/releases/download/2.8.1/TCPShield-2.8.1.jar";
  sha256 = "Q74HTEi+3JnI8MtkFvlulo4ONQ0R0DFQtvAanwm8Clw=";
  meta.license = lib.licenses.mit;
}

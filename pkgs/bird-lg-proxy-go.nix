{
  lib,
  pkgs,
}:
pkgs.buildGoModule (finalAttrs: {
  pname = "bird-lgproxy-go";
  version = "v1.4.0";
  src = pkgs.fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    tag = "v1.4.0";
    hash = "sha256-7VF0MFNa3edKOWmMBib0DxlB1c1h3qBieA4YeUAuBzM=";
  };
  vendorHash = "sha256-iosWHHeJyqMPF+Y01+mj70HDKWw0FAZKDpEESAwS/i4=";

  modRoot = "proxy";

  meta = {
    mainProgram = "proxy";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = lib.licenses.gpl3Only;
  };
})

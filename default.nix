{ pkgs ? import ./nix/nixpkgs.nix }:
let
  lib = pkgs.lib;

  assertMsg = pred: msg:
    if pred then true
    else builtins.trace "assert failed: ${msg}" false;

  # utility to check if a hash is matching
  hashMatchFile = file: wanted:
    let
      got = builtins.hashString "sha256" (builtins.readFile file);
    in
      assertMsg (wanted == got)
        ''
          hash mismatch for file '${toString file}':
            wanted: sha256:${wanted}
            got:    sha256:${got}
        '';

  # another attempt to make filterSource nicer to use
  allowSource = { allow, src }:
    let
      out = builtins.filterSource filter src;
      filter = path: _fileType:
        lib.any (checkElem path) allow;
      checkElem = path: elem:
        lib.hasPrefix (toString elem) (toString path);
    in
      out;

  # get some metadata from ./Cargo.toml
  meta = builtins.fromTOML (builtins.readFile ./Cargo.toml);

  # run ./update-cargo-nix.sh to update those values
  cargoLockHash = "36f58d1ddf4d56bc75aa1d18bb7c4e894eb56c2a0f4a81d83c3f24aec2e98926";
  cargoSha256 = "13khx1f85xzhch5r942kx28ijjv0137pcgmdnxx06dmqvgfkf3mi";
in
pkgs.rustPlatform.buildRustPackage {
  pname = meta.package.name;
  version = meta.package.version;

  src = allowSource {
    allow = [
      ./Cargo.lock
      ./Cargo.toml
      ./fuzz
      ./src
      ./test_data
      ./wasm
    ];
    src = ./.;
  };

  # update both values whenever Cargo.lock changes
  cargoSha256 =
    assert (hashMatchFile ./Cargo.lock cargoLockHash);
    cargoSha256;
}
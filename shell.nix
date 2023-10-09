{ pkgs ? import <nixpkgs> { overlays = [ (import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/refs/heads/stable.zip")) ]; } }:
let
  rust-as-on-ci = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
  package="ethabi";
  check-no-std = pkgs.writeShellApplication rec {
    name = "check-no-std";
    runtimeInputs = [ rust-as-on-ci ];
    text = ''
      cargo build --locked --no-default-features --target thumbv7em-none-eabi --package ${package} --features=serde
    '';
  };
  check-wasm-std = pkgs.writeShellApplication rec {
    name = "check-wasm-std";
    runtimeInputs = [ rust-as-on-ci ];
    text = ''
      cargo build --no-default-features --target wasm32-unknown-unknown --locked --package ${package} --features=serde,schema,std
    '';
  };
in
pkgs.mkShell {
  nativeBuildInputs = [ rust-as-on-ci check-no-std check-wasm-std];
}
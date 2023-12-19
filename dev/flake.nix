{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.get-flake.url = "github:ursi/get-flake";

  inputs.crane.url = "github:ipetkov/crane";

  outputs = { nixpkgs, get-flake, crane, ... }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      checks = forAllSystems (system:
        let
          inherit (nixpkgsFor.${system}) lib newScope runCommand;

          crane-maturin-src = runCommand "crane-maturin-src"
            {
              src = builtins.path {
                path = ../.;
                name = "source";
                filter = path: type: lib.hasSuffix ".nix" path;
              };
            } ''
            mkdir -p $out
            cp -r $src/* $out
            cp ${./flake.lock} $out/flake.lock
          '';

          crane-maturin = get-flake (toString crane-maturin-src);

          callPackage = newScope (
            nixpkgsFor.${system} // {
              inherit callPackage crane crane-maturin;
            }
          );
        in
        lib.filterAttrs (n: v: lib.isDerivation v) (callPackage ../tests { }));

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              maturin
            ];
          };
        });
    };
}

{
  outputs = { nixpkgs, crane, ... }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      lib = forAllSystems (system:
        let
          craneLib = crane.lib.${system};
        in
        {
          buildMaturinPythonPackage =
            nixpkgsFor.${system}.callPackage ./buildMaturinPythonPackage.nix { inherit craneLib; };
        });
    };
}

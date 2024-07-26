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
          pkgs = nixpkgsFor.${system};
          craneLib = crane.mkLib pkgs;
        in
        {
          buildMaturinPythonPackage =
            pkgs.callPackage ./buildMaturinPythonPackage.nix { inherit nixpkgs craneLib; };
        });
    };
}

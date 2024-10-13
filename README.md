# crane-maturin

[![builds.sr.ht status](https://builds.sr.ht/~vlaci/crane-maturin.svg)](https://builds.sr.ht/~vlaci/crane-maturin?)

Helper to build python packages with [maturin](https://maturin.rs) and cache their build dependencies through [crane](https://crane.dev)

# Usage in flake.nix

See also examples in [tests](item/tests)

```nix
{
  inputs.crane.url = "github:ipetkov/crane";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs-unstable";

  inputs.crane-maturin.url = "sourcehut:~vlaci/crane-maturin";
  
  outputs = { crane, crane-maturin, nixpkgs, ... }: let
    system = "x86_64-linux";
    cmLib = crane-maturin.mkLib crane nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = cmLib.buildMaturinPackage {
      src = ./.;
    };
  };
}
```

## License

Licensed under MPL-2.0 license ([LICENSE](item/LICENSE)) or <https://opensource.org/licenses/MPL-2.0>


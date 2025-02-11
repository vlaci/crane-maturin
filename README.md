<!--
SPDX-FileCopyrightText: 2024 László Vaskó <vlaci@fastmail.com>

SPDX-License-Identifier: MIT
-->

# crane-maturin

[![builds.sr.ht status](https://builds.sr.ht/~vlaci/crane-maturin.svg)](https://builds.sr.ht/~vlaci/crane-maturin?)

Helper to build python packages with [maturin](https://maturin.rs) and cache their build dependencies through [crane](https://crane.dev)

# Usage in flake.nix

See also examples in [tests](item/tests)

```nix
{
  inputs.crane.url = "github:ipetkov/crane";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs-unstable";

  inputs.crane-maturin.url = "github:vlaci/crane-maturin";
  
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

Licensed under MIT license ([LICENSE](LICENSES/MIT.txt)) or <https://opensource.org/licenses/MIT>


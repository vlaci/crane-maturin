{ crane-maturin
, system
, maturin  # used to get example crate to test
}:

crane-maturin.lib.${system}.buildMaturinPythonPackage {
  src = "${maturin.src}/test-crates/pyo3-pure";
}

{ crane-maturin
, system
, maturin  # used to get example crate to test
, python310
}:

crane-maturin.lib.${system}.buildMaturinPythonPackage {
  pname = "pyo3-pure-custom";
  src = "${maturin.src}/test-crates/pyo3-pure";
  python = python310;
}

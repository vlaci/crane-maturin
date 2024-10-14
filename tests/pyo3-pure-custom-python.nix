# SPDX-FileCopyrightText: 2024 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{
  cmLib,
  python310,
  maturin, # used to get example crate to test
}:

cmLib.buildMaturinPackage {
  pname = "pyo3-pure-custom";
  src = "${maturin.src}/test-crates/pyo3-pure";
  python = python310;
}

# SPDX-FileCopyrightText: 2024 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{
  cmLib,
  maturin, # used to get example crate to test
}:

cmLib.buildMaturinPackage { src = "${maturin.src}/test-crates/pyo3-pure"; }

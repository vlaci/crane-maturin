# SPDX-FileCopyrightText: 2024 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{
  cmLib,
  python310,
  test-crates,
}:

cmLib.buildMaturinPackage {
  pname = "pyo3-pure-custom";
  src = "${test-crates}/pyo3-pure";
  python = python310;
}

# SPDX-FileCopyrightText: 2026 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{
  cmLib,
  test-crates,
}:

cmLib.buildMaturinPackage { src = "${test-crates}/pyo3-mixed-py-subdir"; }

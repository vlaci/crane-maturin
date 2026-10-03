# SPDX-FileCopyrightText: 2026 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

# `passthru.tests` must test the overridden package, not the original one.
{
  cmLib,
  python3,
  python313,
  test-crates,
}:

assert python3.pythonVersion != python313.pythonVersion;
(cmLib.buildMaturinPackage {
  pname = "pyo3-pure-override";
  src = "${test-crates}/pyo3-pure";
}).override
  { python = python313; }

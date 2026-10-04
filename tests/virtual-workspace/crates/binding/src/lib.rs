// SPDX-FileCopyrightText: 2026 László Vaskó <vlaci@fastmail.com>
//
// SPDX-License-Identifier: MIT

use pyo3::prelude::*;

#[pymodule]
fn virtual_workspace(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add("fortytwo", 42)
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_dummy() {}
}

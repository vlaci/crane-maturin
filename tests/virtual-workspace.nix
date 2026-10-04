# SPDX-FileCopyrightText: 2026 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{ cmLib }:

cmLib.buildMaturinPackage { src = ./virtual-workspace; }

# Static Security Code Analysis Using the LLVM Compiler Frontend (`CERT EXP45-C`)

BSc Computer Science Thesis — Eötvös Loránd University (ELTE), Department of Programming Languages and Compilers (2022)  
**Author:** Andrei Cristea · **Supervisor:** Dr. Zoltán Gera

> **Checker source code:** Located in the [`llvm-project`](https://github.com/havenousername/llvm-project) submodule (fork of LLVM with the `CERT EXP45-C` `clang-tidy` checker, `lit` tests, and module registration).

## Overview

This repository brings together the thesis documentation, build scripts, and evaluation/profiling pipeline for a `clang-tidy` static-analysis checker enforcing **SEI CERT C/C++ Rule `EXP45-C`**: *Do not perform assignments in selection statements* (`cert-assignments-in-selection` / `cert-exp45-c`).

While standard compiler warnings like `-Wparentheses` catch trivial bugs such as `if (a = b)`, they miss unintentional assignments inside:
- Logical expressions (`&&`, `||`, `and`, `or`), e.g. `while ((v = w) && flag)`
- Ternary and GNU binary conditional expressions (`?:`, `?:`) — both standalone and nested inside selection statements
- Comma expressions used as controlling conditions (`if`, `while`, `do ... while`, `for`)

The checker also enforces SEI CERT `EXP45-C` exceptions to avoid false positives:
- **EX1:** Assignment used as an operand to a relational/comparison operator (`if ((x = y) != 0)`)
- **EX2:** Assignment wrapped as a single parenthesized primary expression (`if ((x = y))`)
- **EX3:** Assignment inside a function call argument or array subscript (`if (foo(x = y))`, `if (arr[x = y])`)

## Two AST Matcher Architectures (Top-Down vs. Bottom-Up)

To study trade-offs in correctness, readability, and runtime performance within Clang's AST (`LibASTMatchers`), two independent checker implementations were built and compared:

1. **Top-Down Matcher:** Matches selection statements (`if`, `while`, `do...while`, `for`), ternary operators, and logical `&&`/`||`, then traverses downward into controlling expressions. Uses a PIMPL helper with `llvm::SmallVector` for diagnostic deduplication.
2. **Bottom-Up Matcher:** Matches assignment `BinaryOperator` (`=`) nodes first and checks AST ancestors (`hasAncestor`) to determine whether the assignment appears in a prohibited selection/logical context.

## Evaluation & Benchmarking

Both implementations were verified with LLVM `lit` tests, integrated with **CodeChecker**, and run across four large open-source C/C++ codebases: **FFmpeg**, **LLVM**, **Linux Kernel**, and **MySQL Server**.

### Differential Cross-Checking (Initial Run Before Final Fixes)

Comparing both independent checkers on real codebases exposed false positives (e.g., Linux `perf` in `hists.c` and `intel-pt.c`) as well as a Top-Down false negative caught by Bottom-Up in MySQL Server (`} while (eptr ? (eptr = eptr->next) : nullptr);`):

| Project | Top-Down (Warnings / TP / FP) | Bottom-Up (Warnings / TP / FP) |
| :--- | :---: | :---: |
| **FFmpeg** | 2 / 2 / 0 | 2 / 2 / 0 |
| **LLVM** | 0 / 0 / 0 | 2 / 2 / 0 |
| **Linux Kernel** | 4 / 3 / 1 | 26 / 3 / 23 |
| **MySQL Server** | 15 / 13 / 2 | 30 / 14 / 16 |

### Performance Profiling (`clang-tidy --enable-check-profile`)

- **FFmpeg (`fftools`, 22 files):** Bottom-Up ran ~2× faster on average (mean `0.0019` vs. `0.0041`, max `0.0106` vs. `0.0169`) because selection/logical nodes outnumbered assignments (`554` vs. `212` matches in `ffprobe.c`).
- **MySQL Server (`sql/auth`, 45 files):** Top-Down had more predictable performance; on outlier `sha2_password.cc`, Bottom-Up was `1.33×` slower despite fewer root matches (`956` assignments vs. `1,950` selection expressions) due to repeated `hasAncestor` traversals.
- **Conclusion:** Top-Down was selected as the final implementation for readability, fewer false positives, and steadier performance, incorporating edge-case fixes discovered from the Bottom-Up comparison.

## Repository Structure

```text
├── llvm-project/          # Submodule → havenousername/llvm-project (LLVM fork with EXP45-C checker)
├── thesis/                # LaTeX thesis source and documentation
├── get_clang.sh           # Helper script to configure and build LLVM / clang-tidy
├── test_apps_checker.sh   # Batch runner for clang-tidy diagnostics & check profiling across C/C++ repos
└── test-profile.ipynb     # Profiling analysis & performance plots (FFmpeg / MySQL Server)

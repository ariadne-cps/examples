# Ariadne Examples

[![Build](https://github.com/ariadne-cps/examples/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/ariadne-cps/examples/actions/workflows/ci.yml?query=branch%3Amain)

C++ examples for the [Ariadne](https://github.com/ariadne-cps/ariadne) framework, organized by module.

## Contents

The `evolution/` module contains 37 C++ programs:

- `continuous/`: continuous-time dynamical systems, including attractors, Lorenz, Laub–Loomis and Van der Pol.
- `continuous/noisy/`: differential inclusion and uncertain-input benchmark models.
- `discrete/`: Hénon map.
- `hybrid/`: hybrid systems including bouncing balls, heating, lasers, converters and water tanks.
- `pdes/`: acoustic first-order PDE and Dirichlet examples.

## Build with Ariadne

The repository includes Ariadne in the `ss/ari` Git submodule and builds it in the **same CMake tree** as all examples. No installation is required. CMake initializes `ss/ari` automatically, synchronizes it when the parent Gitlink changes, and preserves an intentionally selected local Ariadne commit otherwise:

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_PYTHON_BINDINGS=OFF
cmake --build build --parallel
```

### Optional standalone examples

`evolution/` and its individual example directories can also be configured independently against an existing Ariadne installation. They use the shared `cmake/FindAriadne.cmake` discovery module:

```sh
cmake -S evolution -B build-evolution -DCMAKE_PREFIX_PATH=/path/to/ariadne/install
cmake --build build-evolution --parallel
```

The former `ss/ard` checkout may remain as an obsolete local directory after updating an existing clone. Review any local changes before deleting it; the new checkout is `ss/ari`.

## Continuous integration

GitHub Actions compiles Ariadne and all examples in one CMake build on Ubuntu, macOS and Windows. Compilation uses `sccache` when available. **Examples are compiled but not executed in CI.**

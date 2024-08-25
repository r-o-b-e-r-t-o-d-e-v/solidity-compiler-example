# Solidity Compiler Example

---

# Table of contents
- [Overview](#overview)
- [Examples](#examples)
  - [docker-compile](#docker-compile)
  - [js-compile](#js-compile)

---

## Overview

This repository contains a couple of examples on the use of _solc_ compiler to
generate ABIs and binaries for your Solidity smart contracts.

---

## Examples

### docker-compile

The [docker-compile](docker-compiler/README.md) example consists of a few shell
scripts that will compile your sources with a _solc_ installed in a Docker
container that will be automatically deployed and removed once the compilation is
finish.

### js-compile

The [js-compile](js-compiler/README.md) example is another quick solution to
compile smart contracts that makes use of JS and Node environment to generate
ABIs and binaries of the selected sources.

---

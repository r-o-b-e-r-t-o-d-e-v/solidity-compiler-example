# Javascript _solc_ compiler

---

# Table of contents
- [Overview](#overview)
- [Scripts](#scripts)

---

## Overview

Simple solution to quickly compile Solidity smart contracts.

It makes use of _solc_ JS library to do the actual compilation.

---

## Scripts

If you are in root you can go to the example directory by running:
```
cd js-compiler
```

### compile.js

This script is in charge of a few tasks:
- Take care of validations and normalization of introduced arguments.
- Do the call to the actual compilation of sources.
- Exporting and packing the compile generated files.

You can start compiling your smart contracts just by running it without parameters:
```
npm run compile
```

However, you have a few parameters available to cover your needs:

| Param | Description                                                                                                                                                                                                                                                                                  |
| ----- |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| -c <contracts_folder> | Param to set the location of the contracts. <br><br>If not specified, the script will search the sources in the root of the example (/solidity-compiler-example/js-compiler/contracts).<br><br>This arg expects the path to be related to the execution context.                             |
| -o <output_folder>    | Param to set the location of the output folder the compile files will be generated at. <br><br>If not specified, the script will create an output folder in the same directory where the contracts are located at. <br><br>This arg expects the path to be related to the execution context. |
| --pack                | Flag to tell the script to pack the compiled files so every smart contract just have a single .json file containing both the abi and the bin. Otherwise each contract would have several files (.bin and .abi).                                                                              |
| --keep-unpacked       | Flag to tell the script if, despite of packing the compiled files should also keep the original ones. <br><br>**Requires --pack flag to also be set.                                                                                                                                         |

You can run the script with commands like this:

```
npm run compile -- --pack --keep-unpacked -c ./contracts -o ./contracts/output
```

---

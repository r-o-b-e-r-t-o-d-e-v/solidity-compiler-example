# Docker _solc_ compiler

---

# Table of contents
- [Overview](#overview)
- [Scripts](#scripts)

---

## Overview

Simple solution to quickly compile Solidity smart contracts.

It makes use of _solc_ to do the actual compilation in a Docker container.

Docker is required to be installed to run this example.

---

## Scripts

If you are in root you can go to the example directory by running:
```
cd docker-compiler
```

### compile.sh

This script works as an orchestrator to run smaller and more specialized ones
that will be part as the whole compilation.

It will also take care of validations and normalization of parameters that the
other scripts need.

You can start compiling your sources just by running it without parameters:
```
./compiler/compile.sh
```

However, you have a few parameters available to cover your needs:

| Param | Description                                                                                                                                                                                                                                                                                                                                                                                                                       |
| ----- |-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| -c <contracts_folder> | Param to set the location of the contracts. <br><br>If not specified, the script will search for a so called 'contracts' folder in all the subdirectories from the execution context.<br><br>This arg expects the path to be related to the execution context.                                                                                                                                                                    |
| -o <output_folder>    | Param to set the location of the output folder the compile files will be generated at. <br><br>If not specified, the script will search for a so called 'output' folder in all the subdirectories from the execution context. <br><br>If none is found, it will use the 'contracts' folder to generate the output files there (.../contracts/output/*). <br><br>This arg expects the path to be related to the execution context. |
| --pack                | Flag to tell the script to pack the compiled files so every smart contract just have a single .json file containing both the abi and the bin. Otherwise each contract would have several files (.bin, .abi and _meta).                                                                                                                                                                                                            |
| --keep-unpacked       | Flag to tell the script if when packing the compiled files should also keep the original ones. <br><br>**Requires --pack flag to also be set.                                                                                                                                                                                                                                                                                         |

You can run the script with commands like this:

```
./compiler/compile.sh --pack --keep-unpacked -c ./contracts -o ./contracts/output
```


### compile-contracts.sh

This script is the one that makes the actual call to solc in order to compile
the smart contracts.

In a similar way to the compile.sh script, it **requires** two parameters to
set the sources and output folder **absolute** locations.

| Param | Description                                                                                                                                                                                                       |
| ----- |-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| -c <contracts_folder> | Param to set the location of the contracts. If not specified, the script will exit. <br><br>This arg expects the path to be absolute, no matter the execution context.                                            |
| -o <output_folder> | Param to set the location of the output folder the compile files will be generated at. <br><br>If not specified, the script will exit. This arg expects the path to be absolute, no matter the execution context. |

### pack-output.sh

This script processes the compile generated files and packs them into a single
json file for each smart contract.

It **requires** the output folder to be provided as an **absolute** path and also
accepts a flag to determine whether it should keep the original compile generated
files or not.

| Param | Description                                                                                                                                                                                                       |
| ----- |-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| -o <output_folder> | Param to set the location of the output folder the compile files will be generated at. <br><br>If not specified, the script will exit. This arg expects the path to be absolute, no matter the execution context. |
| --keep-unpacked | Flag to tell the script if when packing the compiled files should also keep the original ones.                                                                                                                    |

---

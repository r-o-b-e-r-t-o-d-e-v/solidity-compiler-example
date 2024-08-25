const solc = require('solc');
const fs = require('fs');
const path = require('path');
const {getParamValue, hasFlag} = require("./utils/args_utils");


const args = process.argv.slice(2);


// Handle packing related params
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
const pack = hasFlag(args, '--pack');
const keepUnpacked = hasFlag(args, '--keep-unpacked');

if (!pack && keepUnpacked) {
    console.log("Flag --keep-unpacked can only be used along with --pack");
    process.exit(1);
}
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


// Handle contracts and output location path params
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
const {contractsDir, outputDir} = solveSourcesAndOutput(args)
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


// Get all Solidity file names from the sources directory.
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
let contractFileNames;

// If the directory doesn't exist, it stops the execution of the script
try {
    contractFileNames = fs.readdirSync(contractsDir).filter(file => file.endsWith('.sol'));
} catch (err) {
    if (err.code === 'ENOENT') {
        console.error(`Error: Directory '${contractsDir}' does not exist.`);
    } else {
        console.error('An unexpected error occurred:', err.message);
    }
    process.exit(1);
}

// If the directory has no Solidity files, no sources to compile, hence it finishes the execution of the script
if(contractFileNames.length === 0){
    console.log(`No contracts were found at ${contractsDir}`);
    process.exit(0);
}
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


// Create the sources object dynamically (to use it in the compilation call)
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
const sources = {};
contractFileNames.forEach(file => {
    sources[file] = {
        content: fs.readFileSync(path.join(contractsDir, file), 'utf8')
    };
});
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


// Compile the contracts
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
const input = JSON.stringify({
    language: 'Solidity',
    sources: sources,
    settings: {
        outputSelection: {
            '*': {
                // '*': ['abi', 'evm.bytecode'],
                '*': ['*'],
            },
        },
    },
});

const output = JSON.parse(solc.compile(input));
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


// Prepare the output directory
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
if (fs.existsSync(outputDir)) {
    fs.rmSync(outputDir, {recursive: true, force: true});
}
fs.mkdirSync(outputDir, {recursive: true});

const shouldKeepOriginals = !pack || keepUnpacked

// Loop through each contract in the output
for (const contractFileName in output.contracts) {
    const contracts = output.contracts[contractFileName];
    const contractName = Object.keys(contracts)[0];
    const contractDetails = Object.values(contracts)[0];

    const abi = contractDetails.abi;
    const bytecode = contractDetails.evm.bytecode.object;

    if (shouldKeepOriginals) {
        fs.writeFileSync(path.join(outputDir, `${contractName}_abi.json`), JSON.stringify(abi, null, 2));
        fs.writeFileSync(path.join(outputDir, `${contractName}_bytecode.json`), JSON.stringify(bytecode, null, 2));
    }

    if (pack) {
        let packedDir;
        if (keepUnpacked) {
            packedDir = path.join(outputDir, 'packed')
        } else {
            packedDir = outputDir
        }
        if (!fs.existsSync(packedDir)) {
            fs.mkdirSync(packedDir, {recursive: true});
        }
        fs.writeFileSync(path.join(packedDir, `${contractName}.json`), JSON.stringify({
            packingVersion: '1.0.0',
            abi: abi,
            bin: bytecode,
        }, null, 2));
    }
}

console.log(`ABI and bytecode exported to ${outputDir}`);
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

function solveSourcesAndOutput(args) {
    const currentContext = process.cwd()

    const paramContractsDir = getParamValue(args, '-c')
    const paramOutputDir = getParamValue(args, '-o')

    let contractsDir = path.join(__dirname, '../contracts');    // Default
    if (paramContractsDir) {
        contractsDir = path.join(currentContext, paramContractsDir);
    }

    let outputDir = path.join(contractsDir, 'output');    // Default
    if (paramOutputDir) {
        outputDir = path.join(currentContext, paramOutputDir);
    }

    return { contractsDir: contractsDir, outputDir: outputDir }
}

const solc = require('solc');
const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);

function hasFlag(flag) {
    return args.includes(flag);
}

const pack = hasFlag('--pack');
const keepUnpacked = hasFlag('--keep-unpacked');

if(!pack && keepUnpacked) {
    console.log("Flag --keep-unpacked can only be used along with --pack");
    process.exit(1);
}


const contractsDir = path.join(__dirname, '../contracts');
const outputDir = path.join(contractsDir, 'output');



// Get all Solidity files from the directory
const contractFileNames = fs.readdirSync(contractsDir).filter(file => file.endsWith('.sol'));

// Create the sources object dynamically
const sources = {};
contractFileNames.forEach(file => {
    sources[file] = {
        content: fs.readFileSync(path.join(contractsDir, file), 'utf8')
    };
});


// Compile the contracts
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
const input = {
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
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


// Prepare the output directory
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
if (fs.existsSync(outputDir)) {
    fs.rmSync(outputDir, { recursive: true, force: true });
}
fs.mkdirSync(outputDir);

// Loop through each contract in the output
for (const contractFileName in output.contracts) {
    const contracts = output.contracts[contractFileName];
    const contractName = Object.keys(contracts)[0];
    const contractDetails = Object.values(contracts)[0];

    const abi = contractDetails.abi;
    const bytecode = contractDetails.evm.bytecode.object;

    if(!pack || keepUnpacked) {
        fs.writeFileSync(path.join(outputDir, `${contractName}_abi.json`), JSON.stringify(abi, null, 2));
        fs.writeFileSync(path.join(outputDir, `${contractName}_bytecode.json`), JSON.stringify(bytecode, null, 2));
    }

    if(pack) {
        let packedDir;
        if(keepUnpacked) {
            packedDir = path.join(outputDir, 'packed')
        } else {
            packedDir = outputDir
        }
        if (!fs.existsSync(packedDir)) {
            fs.mkdirSync(packedDir);
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

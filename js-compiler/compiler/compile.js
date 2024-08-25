const solc = require('solc');
const fs = require('fs');
const path = require('path');

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
if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir);
}

// Loop through each contract in the output
for (const contractFileName in output.contracts) {
    const contracts = output.contracts[contractFileName];

    // Loop through each contract in the file
    for (const contractName in contracts) {
        const contractDetails = contracts[contractName];

        // Write ABI to a JSON file
        const abi = contractDetails.abi;
        fs.writeFileSync(path.join(outputDir, `${contractName}_abi.json`), JSON.stringify(abi, null, 2));

        // Write bytecode to a JSON file
        const bytecode = contractDetails.evm.bytecode.object;
        fs.writeFileSync(path.join(outputDir, `${contractName}_bytecode.json`), JSON.stringify(bytecode, null, 2));
    }
}

console.log(`ABI and bytecode exported to ${outputDir}`);
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

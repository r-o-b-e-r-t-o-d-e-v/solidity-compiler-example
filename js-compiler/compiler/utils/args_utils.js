
function getParamValue(args, param) {
    const index = args.indexOf(param);
    if (index > -1 && (index + 1 >= args.length || args[index + 1].startsWith('-') || args[index + 1].startsWith('--'))) {
        console.log(`Param ${param} doesn't have a proper value set`);
        process.exit(1);
    }
    if (index === -1) {
        return null;
    }
    return args[index + 1];
}

function hasFlag(args, flag) {
    return args.includes(flag);
}

module.exports = {
    getParamValue,
    hasFlag
};

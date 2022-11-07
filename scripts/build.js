// command - luabundler bundle src/main.lua -p "src/?.lua" -o bundle.lua

const { randomUUID: uuid } = require('node:crypto');
const { promisify } = require('node:util');
const exec = promisify(require('child_process').exec);

(async () => {
    try {
        const { stdout } = await exec('luabundler bundle src/main.lua -p "src/?.lua" -o bundle.lua');
        console.log('stdout:', stdout);
    } catch (error) {
        throw new Error(error);
    }     
})()

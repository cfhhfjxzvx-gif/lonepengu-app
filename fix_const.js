const fs = require('fs');
const path = require('path');

const rootDir = 'c:/Users/MEET PARMAR/Desktop/lone-pengu-app/lone-pengu-app/lib';

function getAllFiles(dirPath, arrayOfFiles) {
    const files = fs.readdirSync(dirPath);
    arrayOfFiles = arrayOfFiles || [];

    files.forEach(function (file) {
        if (fs.statSync(dirPath + "/" + file).isDirectory()) {
            arrayOfFiles = getAllFiles(dirPath + "/" + file, arrayOfFiles);
        } else {
            if (file.endsWith('.dart')) {
                arrayOfFiles.push(path.join(dirPath, "/", file));
            }
        }
    });

    return arrayOfFiles;
}

const files = getAllFiles(rootDir);

files.forEach(file => {
    let content = fs.readFileSync(file, 'utf8');
    let original = content;

    // Remove const from lines that contain LPColors
    let lines = content.split('\n');
    let newLines = [];
    let inConstBlock = false;
    let braceCount = 0;

    // Pattern 1: Multi-line const
    // const Widget(
    //   ... LPColors.xxx ...
    // )
    // This is hard to catch perfectly without a parser, but we can detect 'const ' followed by 'LPColors' before the next ';' or closing ')'

    // Simpler: Just remove 'const' if the next 10 lines contain 'LPColors' and it's a widget-like constructor
    for (let i = 0; i < lines.length; i++) {
        let line = lines[i];
        if (line.trim().startsWith('const ') && !line.includes(';')) {
            // Look ahead to see if LPColors is mentioned before the next semicolon
            let foundLPColors = false;
            for (let j = i; j < Math.min(i + 20, lines.length); j++) {
                if (lines[j].includes('LPColors.')) {
                    foundLPColors = true;
                    break;
                }
                if (lines[j].includes(';') || lines[j].includes('=>')) break;
            }

            if (foundLPColors) {
                line = line.replace('const ', '');
                console.log(`Fixed multi-line const in ${file} at line ${i + 1}`);
            }
        } else if (line.includes('const ') && line.includes('LPColors.')) {
            line = line.replace('const ', '');
            console.log(`Fixed single-line const in ${file} at line ${i + 1}`);
        }
        newLines.push(line);
    }

    content = newLines.join('\n');

    if (content !== original) {
        fs.writeFileSync(file, content);
    }
});

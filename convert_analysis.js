const fs = require('fs');
const content = fs.readFileSync('analysis_2.txt', 'utf16le');
fs.writeFileSync('analysis_utf8.txt', content, 'utf8');

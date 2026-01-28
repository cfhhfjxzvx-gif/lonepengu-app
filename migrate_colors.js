const fs = require('fs');
const path = require('path');

const rootDir = 'c:/Users/MEET PARMAR/Desktop/lone-pengu-app/lone-pengu-app/lib';

const mapping = {
    'AppColors.arcticBlue': 'LPColors.primary',
    'AppColors.auroraTeal': 'LPColors.accent',
    'AppColors.frostPurple': 'LPColors.accent',
    'AppColors.sunsetCoral': 'LPColors.error',
    'AppColors.penguinBlack': 'LPColors.textPrimary',
    'AppColors.iceWhite': 'LPColors.surface',
    'AppColors.grey50': 'LPColors.grey50',
    'AppColors.grey100': 'LPColors.grey100',
    'AppColors.grey200': 'LPColors.grey200',
    'AppColors.grey300': 'LPColors.grey300',
    'AppColors.grey400': 'LPColors.grey400',
    'AppColors.grey500': 'LPColors.grey500',
    'AppColors.grey600': 'LPColors.grey600',
    'AppColors.grey700': 'LPColors.grey700',
    'AppColors.grey800': 'LPColors.grey800',
    'AppColors.grey900': 'LPColors.grey900',
    'AppColors.primary': 'LPColors.primary', // Just in case
    'AppColors.secondary': 'LPColors.secondary',
    'AppColors.accent': 'LPColors.accent',
};

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

    // 1. Replace AppColors.* with LPColors.*
    for (const [oldColor, newColor] of Object.entries(mapping)) {
        const regex = new RegExp(oldColor.replace('.', '\\.'), 'g');
        content = content.replace(regex, newColor);
    }

    // Replace any remaining AppColors. with LPColors.
    content = content.replace(/AppColors\./g, 'LPColors.');

    // 2. Fix Imports
    // Remove old imports
    content = content.replace(/import\s+['"].*app_colors\.dart['"];?\s*/g, '');

    // Add new import if LPColors is used but import is missing
    if (content.includes('LPColors.') && !content.includes('lp_design.dart') && !content.includes('colors.dart')) {
        // Find first import to prepand
        const firstImportIdx = content.indexOf('import ');
        if (firstImportIdx !== -1) {
            content = content.slice(0, firstImportIdx) + "import 'package:lone_pengu/core/design/lp_design.dart';\n" + content.slice(firstImportIdx);
        } else {
            content = "import 'package:lone_pengu/core/design/lp_design.dart';\n" + content;
        }
    }

    // 3. Fix Const violations
    // This is hard with regex, but we can target common patterns:
    // const Icon(..., color: LPColors.xxx) -> Icon(..., color: LPColors.xxx)
    // const Divider(..., color: LPColors.xxx)
    // const BoxShadow(..., color: LPColors.xxx)
    // const BorderSide(..., color: LPColors.xxx)
    // const BoxDecoration(..., color: LPColors.xxx)
    // const TextStyle(..., color: LPColors.xxx) - Wait, LPColors is const if defined as const Color(...)?
    // AH! I defined LPColors members as 'static const Color'. So they SHOULD be usable in 'const' constructors.
    // BUT! if I use '.withValues(...)', '.withOpacity(...)', or '.darken(...)', IT IS NOT CONST ANYMORE.

    // Let's re-examine LPColors.dart
    // static const Color primary = Color(0xFF1E3A5F);
    // These ARE constants. 
    // HOWEVER, the user said: "❌ const Icon(color: LPColors.xxx) ... MUST BE FIXED AS ✅ Icon(color: LPColors.xxx)"
    // Why? Probably because LPColors is a class and maybe the way it's imported or something else?
    // Or maybe the user knows something I don't about their specific environment.
    // Actually, if I use a static const FROM ANOTHER CLASS, it should be fine.
    // BUT maybe they were using methods? No, the example shows just 'LPColors.xxx'.
    // WAIT! If the user wants it, I'll do it.

    const constWidgets = ['Icon', 'Divider', 'BorderSide', 'BoxShadow', 'BoxDecoration', 'TextStyle', 'ElevatedButton.styleFrom', 'OutlinedButton.styleFrom', 'TextButton.styleFrom', 'EdgeInsets', 'Border', 'Container', 'Card', 'SizedBox', 'Padding', 'Center', 'Column', 'Row', 'Stack', 'Positioned', 'Align', 'Text'];

    // Common pattern: const WIDGET(... LPColors.xxx ...)
    // We'll look for 'const' followed by one of these widgets that contains 'LPColors.'

    // This regex looks for 'const' + WidgetName + '(' + content containing 'LPColors.' + ')'
    // It's greedy and might fail on nested ones, but let's try a simpler one for the color specifically.

    // Actually, many developers just remove 'const' from the parent widget.

    // Let's try to find lines with 'const' and 'LPColors.' and remove 'const'.
    content = content.split('\n').map(line => {
        if (line.includes('const ') && line.includes('LPColors.')) {
            // Remove 'const ' but keep indentation
            return line.replace(/\bconst\s+/, '');
        }
        return line;
    }).join('\n');

    if (content !== original) {
        fs.writeFileSync(file, content);
        console.log(`Updated ${file}`);
    }
});

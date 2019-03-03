const fs = require('fs');

fs.writeFileSync('.git/hooks/pre-commit', `#!/bin/sh

echo Rebuilding model for you.
rojo build -o Antimony.rbxmx
git add Antimony.rbxmx`);
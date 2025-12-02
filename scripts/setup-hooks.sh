#!/bin/sh
# Setup git hooks for development

echo '#!/bin/sh
stylua --check lua/ tests/ || exit 1' > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "pre-commit hook installed"

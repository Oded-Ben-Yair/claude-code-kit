# /parallel

Create a git worktree for parallel development.

## Usage

```
/parallel <feature-name>
```

## What This Does

1. Creates a new git worktree at `../{project}-{feature-name}`
2. Creates a new branch `feature/{feature-name}`
3. Copies necessary config files (.env*, etc.)
4. Installs dependencies if package.json exists

## Example

```
/parallel auth-refactor
```

Creates:
- Worktree: `../seekapa-auth-refactor/`
- Branch: `feature/auth-refactor`

## Implementation

When user runs `/parallel <name>`:

```bash
# Get project name from current directory
PROJECT=$(basename $(pwd))
FEATURE=$1
WORKTREE_DIR="../${PROJECT}-${FEATURE}"
BRANCH="feature/${FEATURE}"

# Pre-flight checks
echo "Creating worktree for: $FEATURE"
echo "Location: $WORKTREE_DIR"
echo "Branch: $BRANCH"

# Check if worktree already exists
if [ -d "$WORKTREE_DIR" ]; then
    echo "❌ Worktree already exists at $WORKTREE_DIR"
    exit 1
fi

# Create the worktree
git worktree add "$WORKTREE_DIR" -b "$BRANCH"

# Copy config files
for f in .env .env.local .env.development .nvmrc; do
    if [ -f "$f" ]; then
        cp "$f" "$WORKTREE_DIR/"
        echo "✅ Copied $f"
    fi
done

# Install dependencies
cd "$WORKTREE_DIR"
if [ -f "package.json" ]; then
    echo "📦 Installing npm dependencies..."
    npm install
fi

echo ""
echo "✅ Worktree ready!"
echo ""
echo "To start working:"
echo "  cd $WORKTREE_DIR"
echo "  claude"
echo ""
echo "When done, cleanup with:"
echo "  git worktree remove $WORKTREE_DIR"
```

## Cleanup

After merging your PR:

```bash
# From main project directory
git worktree remove ../seekapa-auth-refactor
git branch -d feature/auth-refactor
```

## Notes

- Each worktree can run its own Claude Code session
- Changes in one worktree don't affect others
- Push changes before removing worktree
- Use `git worktree list` to see all active worktrees

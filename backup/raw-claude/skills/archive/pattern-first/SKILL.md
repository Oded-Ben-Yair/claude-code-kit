name: pattern-first
description: Enforces pattern-based code generation by searching for existing implementations before writing any new code. Prevents "AI slop" and ensures consistency with project conventions.

---

# Pattern-First Implementation Skill

## Purpose

This skill ensures that ALL code generation follows existing patterns in the codebase. It's based on the key insight from research: **"Pattern over Rules"** - learning from concrete historical examples outperforms abstract guidelines.

## Trigger Conditions

This skill activates when:
- Writing any new code (functions, classes, components)
- Implementing a new feature
- Adding a new endpoint
- Creating a new test
- Any task that involves code generation

## The Pattern-First Protocol

### Step 1: Pattern Discovery (MANDATORY - DO NOT SKIP)

Before writing ANY code, execute these searches:

```bash
# Find similar implementations by functionality
grep -r "[relevant_keyword]" ./src --include="*.ts" --include="*.tsx" --include="*.py" -l

# Find by naming pattern (e.g., for a new UserService)
find ./src -name "*Service*" -type f

# Find by file type (e.g., for new API endpoint)
find ./src/api -name "*.ts" -type f | head -10
```

### Step 2: Pattern Analysis

For each relevant file found, analyze and document:

| Aspect | Pattern Found | Source File |
|--------|---------------|-------------|
| **Naming** | How are things named? | `path/to/example.ts` |
| **Structure** | How is the file organized? | `path/to/example.ts` |
| **Error Handling** | How are errors caught/thrown? | `path/to/example.ts` |
| **Logging** | What logging pattern is used? | `path/to/example.ts` |
| **Testing** | How are tests structured? | `path/to/example.spec.ts` |
| **Imports** | What import style is used? | `path/to/example.ts` |

### Step 3: Pattern Application

When writing new code:

1. **Copy structure, not content** - Mirror the organization of existing files
2. **Match naming exactly** - If existing code uses `getUser`, don't use `fetchUser`
3. **Follow error patterns** - If existing code throws `CustomError`, do the same
4. **Maintain test style** - If tests use `describe/it`, don't use `test`

### Step 4: Pattern Verification

Before completing, verify:
- [ ] New code would "fit in" with existing code
- [ ] A reviewer wouldn't know if existing team or AI wrote it
- [ ] No new patterns were invented when existing ones exist

## Example: Adding a New API Endpoint

### WRONG Approach (AI Slop)
```typescript
// AI just generates generic code without checking existing patterns
export async function handler(req, res) {
  try {
    const result = await doSomething();
    res.json(result);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}
```

### RIGHT Approach (Pattern-First)
```typescript
// First, search for existing endpoints
grep -r "router\." ./src/api --include="*.ts" -A 5

// Found pattern in src/api/users.ts:
// router.get('/', validateRequest(schema), asyncHandler(getUsers))

// Now follow that EXACT pattern:
router.get('/:id', validateRequest(getUserSchema), asyncHandler(getUserById));
```

## Integration with Agents

### With Code Worker
The Code Worker MUST invoke this skill before any implementation:
```
1. Receive task from Planner
2. Invoke pattern-first skill
3. Document patterns found
4. Implement following patterns
5. Send to Judge for review
```

### With Code Judge
The Judge verifies pattern compliance:
- Does the new code match found patterns?
- Were any patterns invented unnecessarily?
- Would this pass code review for consistency?

## Anti-Patterns to Avoid

| Don't Do This | Do This Instead |
|---------------|-----------------|
| Invent new naming conventions | Find and follow existing names |
| Use different error handling | Match existing error patterns |
| Create new file structures | Mirror existing organization |
| Add comments in different style | Match existing comment patterns |
| Use different import organization | Follow existing import style |

## Output Template

When this skill completes, it should output:

```markdown
## Pattern Analysis: [Feature Name]

### Patterns Found
1. **[Category]**: [Pattern description]
   - Source: `path/to/file.ts:line`
   - Example: `code snippet`

2. **[Category]**: [Pattern description]
   - Source: `path/to/file.ts:line`
   - Example: `code snippet`

### Patterns to Apply
- [ ] Naming: Follow [pattern] from [file]
- [ ] Structure: Follow [pattern] from [file]
- [ ] Error handling: Follow [pattern] from [file]
- [ ] Testing: Follow [pattern] from [file]

### Ready for Implementation
Proceed with Code Worker, applying these patterns.
```

## Memory Integration

After successful pattern application, store the mapping:
```
memory.create({
  entity: "[project-name]-patterns",
  observation: "For [feature type], follow patterns from [files]"
})
```

This builds a knowledge base for future pattern lookups.

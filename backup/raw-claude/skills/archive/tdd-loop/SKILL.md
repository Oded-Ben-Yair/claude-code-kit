name: tdd-loop
description: Automated Test-Driven Development workflow that enforces writing tests first, validates implementation, and uses the Judge agent for final validation.

---

# TDD Loop Skill

## Purpose

This skill enforces a strict Test-Driven Development workflow:
1. Write failing test FIRST
2. Write minimal code to pass
3. Refactor while keeping green
4. Judge validates the result

Based on Cursor research: Using the **test runner as an objective Judge** dramatically improves code quality.

## Trigger Conditions

Invoke this skill when:
- Implementing any new feature
- Fixing a bug (write regression test first)
- User explicitly requests `/tdd`
- Adding to existing test suites

## The TDD Loop Protocol

### Step 1: Red (Write Failing Test)

**BEFORE writing any implementation code:**

```markdown
## TDD Step 1: Write Failing Test

### Test Description
- Feature: [what we're testing]
- Expected behavior: [what should happen]
- Edge cases: [what could go wrong]

### Test Code
[Write the test that describes desired behavior]

### Verification
Run: [test command]
Expected: FAIL (test not implemented yet)
Actual: [result]
```

**Critical Rules:**
- Test MUST describe the desired behavior, not the implementation
- Test MUST fail before implementation exists
- Test MUST be deterministic (no random data, stable timestamps)

### Step 2: Green (Minimal Implementation)

**Write the MINIMUM code to make the test pass:**

```markdown
## TDD Step 2: Make Test Pass

### Implementation Approach
[Brief description of minimal solution]

### Code Written
[The implementation code]

### Verification
Run: [test command]
Expected: PASS
Actual: [result]
```

**Critical Rules:**
- Write ONLY enough code to pass the test
- Don't anticipate future requirements
- Don't optimize prematurely
- Don't add features the test doesn't require

### Step 3: Refactor (Improve While Green)

**Improve code quality without changing behavior:**

```markdown
## TDD Step 3: Refactor

### Improvements Made
- [Improvement 1]: [why]
- [Improvement 2]: [why]

### Verification
Run: [test command]
Expected: PASS (still passing)
Actual: [result]
```

**Critical Rules:**
- Tests MUST stay green throughout refactoring
- If tests break, revert immediately
- Focus on readability, not cleverness
- Apply project patterns (from pattern-first skill)

### Step 4: Judge Validation

**Hand off to Code Judge for final validation:**

```markdown
## TDD Step 4: Judge Review

### Submitting for Review
- Tests written: X
- Implementation files: Y
- Coverage: Z%

### Questions for Judge
1. Does the test actually test the requirement?
2. Is the implementation minimal?
3. Are edge cases covered?
4. Does it match project patterns?
```

## Test Quality Checklist

Before considering a test "done":

- [ ] **Descriptive name**: Test name describes the behavior
- [ ] **Single assertion**: One logical assertion per test
- [ ] **Independent**: Test doesn't depend on other tests
- [ ] **Deterministic**: Same result every run
- [ ] **Fast**: Runs in milliseconds, not seconds
- [ ] **Edge cases**: Covers boundary conditions
- [ ] **Error paths**: Tests error handling too

## Example: TDD for User Authentication

### RED: Write Failing Test
```typescript
describe('UserService', () => {
  describe('authenticate', () => {
    it('should return user when credentials are valid', async () => {
      const user = await userService.authenticate('valid@email.com', 'correctPassword');
      expect(user).toBeDefined();
      expect(user.email).toBe('valid@email.com');
    });

    it('should throw AuthError when password is incorrect', async () => {
      await expect(
        userService.authenticate('valid@email.com', 'wrongPassword')
      ).rejects.toThrow(AuthError);
    });
  });
});
```

Run tests: `npm test` → **FAIL** (userService.authenticate doesn't exist)

### GREEN: Minimal Implementation
```typescript
class UserService {
  async authenticate(email: string, password: string): Promise<User> {
    const user = await this.userRepository.findByEmail(email);
    if (!user || !await this.verifyPassword(password, user.passwordHash)) {
      throw new AuthError('Invalid credentials');
    }
    return user;
  }
}
```

Run tests: `npm test` → **PASS**

### REFACTOR: Improve
```typescript
class UserService {
  async authenticate(email: string, password: string): Promise<User> {
    const user = await this.findUserOrThrow(email);
    await this.verifyPasswordOrThrow(password, user.passwordHash);
    return user;
  }

  private async findUserOrThrow(email: string): Promise<User> {
    const user = await this.userRepository.findByEmail(email);
    if (!user) throw new AuthError('Invalid credentials');
    return user;
  }

  private async verifyPasswordOrThrow(password: string, hash: string): Promise<void> {
    if (!await this.verifyPassword(password, hash)) {
      throw new AuthError('Invalid credentials');
    }
  }
}
```

Run tests: `npm test` → **PASS** (still passing after refactor)

## Integration with Agents

### Workflow
```
1. User invokes /tdd "feature description"
2. TDD Loop skill activates
3. Code Worker writes failing test (RED)
4. Code Worker writes minimal impl (GREEN)
5. Code Worker refactors (REFACTOR)
6. Code Judge validates (JUDGE)
7. If REVISE → back to step 3
8. If APPROVE → done
```

### Agent Handoffs
| From | To | When |
|------|----|----- |
| User | TDD Loop | `/tdd` invoked |
| TDD Loop | Code Worker | Execute RED/GREEN/REFACTOR |
| Code Worker | Code Judge | After each cycle |
| Code Judge | Code Worker | REVISE verdict |
| Code Judge | User | APPROVE verdict |

## Anti-Patterns

| Don't | Do |
|-------|-----|
| Write test after implementation | Write test FIRST, always |
| Write multiple tests at once | One test at a time |
| Write more than minimal code | Only enough to pass |
| Skip refactoring | Always refactor when green |
| Ignore failing tests | Fix immediately or revert |

## Commands

| Command | Action |
|---------|--------|
| `/tdd "feature"` | Start TDD loop for feature |
| `/tdd:red` | Just write the failing test |
| `/tdd:green` | Implement to pass current test |
| `/tdd:refactor` | Refactor with tests green |
| `/tdd:status` | Show current TDD state |

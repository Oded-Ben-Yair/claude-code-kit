---
description: Creates comprehensive unit tests with edge cases and error handling
argument-hint: [file_or_function_path] [--framework=jest|pytest|junit|mocha]
---

# Comprehensive Unit Test Generator

You are a software testing expert specializing in Test-Driven Development (TDD) and comprehensive test coverage. Your task is to generate a complete, production-ready test suite for the specified code.

## Step 1: Code Analysis

### 1.1 Load Target Code
- **Target:** @$1
- **Analyze:** Understand the functionality, inputs, outputs, dependencies, and edge cases

### 1.2 Detect Testing Framework
Automatically detect the testing framework from the project:
- **JavaScript/TypeScript:** Jest, Mocha, Jasmine, Vitest
- **Python:** PyTest, unittest, nose2
- **Java:** JUnit, TestNG
- **Go:** testing package
- **Ruby:** RSpec, Minitest
- **C#:** NUnit, xUnit

If framework cannot be detected, use the `--framework` argument or the language's default.

### 1.3 Identify Test Requirements
Determine what needs to be tested:
- **Public functions/methods:** All externally accessible functionality
- **Classes:** Constructor, methods, properties
- **Edge cases:** Boundary conditions, empty inputs, null values
- **Error conditions:** Invalid inputs, exceptions, error states
- **Integration points:** External dependencies, APIs, databases

## Step 2: Test Suite Design

### 2.1 Test Categories
Organize tests into categories:

#### Happy Path Tests
- Normal, expected inputs and outputs
- Typical use cases
- Standard workflows

#### Edge Case Tests
- Boundary values (min, max, zero, negative)
- Empty inputs (empty strings, empty arrays, null)
- Large inputs (stress testing)
- Special characters and Unicode

#### Error Handling Tests
- Invalid inputs
- Type mismatches
- Out-of-range values
- Missing required parameters
- Exceptions and error states

#### Integration Tests
- External dependencies (mocked)
- API calls (mocked)
- Database interactions (mocked)
- File system operations (mocked)

### 2.2 Test Naming Convention
Use descriptive, readable test names following the pattern:
- `test_<function>_<scenario>_<expected_result>`
- Example: `test_user_login_with_valid_credentials_returns_token`
- Example: `test_calculate_discount_with_negative_price_raises_error`

## Step 3: Test Implementation

### 3.1 Test Structure
Each test should follow the AAA pattern:
- **Arrange:** Set up test data and mocks
- **Act:** Execute the function under test
- **Assert:** Verify the expected outcome

### 3.2 Mocking Strategy
For external dependencies:
- **Mock external APIs:** Use mock responses
- **Mock database calls:** Use in-memory or mock data
- **Mock file system:** Use temporary files or mocks
- **Mock time-dependent functions:** Use fixed timestamps

### 3.3 Assertions
Use appropriate assertions:
- **Equality:** `assertEqual`, `toBe`, `toEqual`
- **Type checking:** `assertIsInstance`, `toBeInstanceOf`
- **Exceptions:** `assertRaises`, `toThrow`
- **Collections:** `assertIn`, `toContain`, `toHaveLength`
- **Approximations:** `assertAlmostEqual`, `toBeCloseTo` (for floating-point)

## Step 4: Generate Complete Test Suite

### 4.1 Test File Structure

For Python (PyTest):
```python
import pytest
from unittest.mock import Mock, patch
from module_name import function_to_test, ClassToTest

# Test fixtures
@pytest.fixture
def sample_data():
    """Fixture providing sample test data."""
    return {"key": "value"}

# Happy path tests
class TestFunctionName:
    def test_function_with_valid_input_returns_expected_output(self):
        """Test that function returns correct result with valid input."""
        # Arrange
        input_data = "test"
        expected_output = "TEST"
        
        # Act
        result = function_to_test(input_data)
        
        # Assert
        assert result == expected_output

# Edge case tests
class TestFunctionNameEdgeCases:
    def test_function_with_empty_string_returns_empty_string(self):
        """Test that function handles empty string correctly."""
        assert function_to_test("") == ""
    
    def test_function_with_none_raises_type_error(self):
        """Test that function raises TypeError for None input."""
        with pytest.raises(TypeError):
            function_to_test(None)

# Error handling tests
class TestFunctionNameErrorHandling:
    def test_function_with_invalid_type_raises_type_error(self):
        """Test that function raises TypeError for invalid input type."""
        with pytest.raises(TypeError):
            function_to_test(123)
```

For JavaScript (Jest):
```javascript
import { functionToTest, ClassToTest } from './module';

describe('functionToTest', () => {
  // Happy path tests
  describe('Happy Path', () => {
    it('should return expected output with valid input', () => {
      // Arrange
      const input = 'test';
      const expectedOutput = 'TEST';
      
      // Act
      const result = functionToTest(input);
      
      // Assert
      expect(result).toBe(expectedOutput);
    });
  });

  // Edge case tests
  describe('Edge Cases', () => {
    it('should return empty string when input is empty', () => {
      expect(functionToTest('')).toBe('');
    });

    it('should handle null input gracefully', () => {
      expect(() => functionToTest(null)).toThrow(TypeError);
    });
  });

  // Error handling tests
  describe('Error Handling', () => {
    it('should throw TypeError for invalid input type', () => {
      expect(() => functionToTest(123)).toThrow(TypeError);
    });
  });
});
```

### 4.2 Coverage Goals
Aim for comprehensive coverage:
- **Line coverage:** 90%+ of code lines executed
- **Branch coverage:** All conditional branches tested
- **Function coverage:** All functions called at least once
- **Edge case coverage:** All boundary conditions tested

### 4.3 Test Documentation
Each test should include:
- **Docstring/comment:** Explaining what is being tested
- **Clear variable names:** Self-documenting code
- **Inline comments:** For complex setup or assertions

## Step 5: Test Quality Checklist

Verify that the generated tests meet these criteria:
- [ ] Tests are independent (can run in any order)
- [ ] Tests are isolated (no shared state between tests)
- [ ] Tests are fast (no unnecessary delays or I/O)
- [ ] Tests are deterministic (same input always gives same result)
- [ ] Tests are readable (clear names and structure)
- [ ] Tests use appropriate mocks for external dependencies
- [ ] Tests cover happy path, edge cases, and error conditions
- [ ] Tests follow the project's testing conventions
- [ ] Tests include setup and teardown if needed
- [ ] Tests are well-organized into logical groups

## Step 6: Output

### 6.1 Test File Content
Provide the complete test file content, ready to be saved as:
- `test_<module_name>.py` (Python)
- `<module_name>.test.js` (JavaScript)
- `<ModuleName>Test.java` (Java)
- Or the appropriate naming convention for the detected framework

### 6.2 Test Execution Instructions
Provide commands to run the tests:
```bash
# Python (PyTest)
pytest test_module_name.py -v

# JavaScript (Jest)
npm test module_name.test.js

# Java (JUnit)
mvn test -Dtest=ModuleNameTest
```

### 6.3 Coverage Report Instructions
Provide commands to generate coverage reports:
```bash
# Python
pytest --cov=module_name --cov-report=html

# JavaScript
npm test -- --coverage

# Java
mvn test jacoco:report
```

### 6.4 Summary
Provide a summary of the generated tests:
- **Total tests:** Number of test cases generated
- **Test categories:** Happy path, edge cases, error handling
- **Coverage estimate:** Expected code coverage percentage
- **Dependencies:** Any additional testing libraries needed

## Best Practices Applied

1. **Test isolation:** Each test is independent
2. **Clear naming:** Test names describe what is being tested
3. **AAA pattern:** Arrange, Act, Assert structure
4. **Comprehensive coverage:** Happy path, edge cases, and errors
5. **Proper mocking:** External dependencies are mocked
6. **Documentation:** Tests are well-documented
7. **Maintainability:** Tests are easy to understand and modify

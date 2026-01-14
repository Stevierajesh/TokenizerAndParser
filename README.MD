## CalculatorEngine Documentation

### Client-View Methods

A simple arithmetic calculator supporting:

- `+`, `-`, `*`, `/`, `%`, and `(`  
    (with support for implicit multiplication using `(`)

**Method:**  
`calculate(expression)` &rarr; returns integer or float value

**Requirements:**

- Pass in a string expression
- No whitespace in the expression

**Sample Usage:**

```ruby
require_relative("calcEngine") # Require the rb file in which class is stored.

calculator = CalculatorEngine.new # Create a new CalculatorEngine Object

puts calculator.calculate("2/2")
```

---

### Implementation-View Methods

<sub>
**Note:**  
Implementation could have been done using a stack and one method. However, to support implicit multiplication (e.g., `"2(3)"`), a tokenizer/parser with a **custom** approach was used. This is a bit overkill for this assignment.
</sub>

---

#### Tokenizer/Parser

**Method:**  
`tokenizer(string, indexOfString)` &rarr; Array of Tokens

- Custom tokenizer and parser in one method
- Each token has:
    - **Type:** token type
    - **Value:** token value
    - **Operation:** operation

**Sample Output:**  
`tokenizer("2(3)", 0)` &rarr; `[["num", 2, "*"], ["group", [["num", 3, "N"]], "N"]]`

**Token Types:**

- `group`: Parenthesis (evaluated later using recursion)
- `num`: Integer (or decimal) found

**Token Value:**

- `[[]]`: Another token to evaluate recursively
- `N`: End of an expression (either in a group or full expression)

---
**Method:**  
`middleMan(string)` &rarr; Array of Tokens
- Finds Higher Precedence Operators, and reformats into a type:group token
- Makes it so that the Evaluator, (which reads from left to right) can correctly evaluate expressions without parenthesis

Sample: "2+3*4"

Tokens Before middleMan: [["num", 2, "+"], ["num", 3, "*"], ["num", 4, "N"]]

Tokens After middleMan: [["num", 2, "+"], ["group", [["num", 3, "*"], ["num", 4, "N"]], "N"]]


**Method:**  
`evaluate(tokens)`

- Custom evaluator for tokenized expressions
- Checks token type (`group` or `num`)
- Evaluates by tracking previous and current tokens
- Recurses when finding a `group` token
=======


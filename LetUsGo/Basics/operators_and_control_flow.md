## **1. Operators in Golang**

Operators are symbols that perform operations on variables and values. Below is a detailed explanation of all operators in Go, organized into categories with examples.

### **Hierarchy of Operators**
| **Category**            | **Operators**                                                                                   | **Description**                                                                 |
|--------------------------|-------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| **Arithmetic Operators** | `+`, `-`, `*`, `/`, `%`                                                                         | Perform basic mathematical operations like addition, subtraction, etc.         |
| **Relational Operators** | `==`, `!=`, `<`, `>`, `<=`, `>=`                                                                | Compare two values and return a boolean result (`true` or `false`).             |
| **Logical Operators**    | `&&`, `\|\|`, `!`                                                                               | Perform logical operations (AND, OR, NOT).                                      |
| **Bitwise Operators**    | `&`, `\|`, `^`, `<<`, `>>`                                                                      | Perform bit-level operations on integers.                                       |
| **Assignment Operators** | `=`, `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `\|=`, `^=`                              | Assign values to variables, often combined with arithmetic/bitwise operations.  |
| **Miscellaneous**        | `&` (address-of), `*` (dereference), `:=` (short declaration), `...` (variadic function syntax) | Special-purpose operators for pointers, declarations, and variadic functions.   |

---

### **Detailed Explanation with Examples**

#### **1. Arithmetic Operators**
| Operator | Description       | Example                     | Output |
|----------|-------------------|-----------------------------|--------|
| `+`      | Addition          | `5 + 3`                     | `8`    |
| `-`      | Subtraction       | `5 - 3`                     | `2`    |
| `*`      | Multiplication    | `5 * 3`                     | `15`   |
| `/`      | Division          | `10 / 3`                    | `3`    |
| `%`      | Modulus (Remainder)| `10 % 3`                   | `1`    |

Example:
```go
package main
import "fmt"

func main() {
    a := 10
    b := 3
    fmt.Println(a + b) // Output: 13
    fmt.Println(a % b) // Output: 1
}
```

---

#### **2. Relational Operators**
| Operator | Description           | Example          | Output |
|----------|-----------------------|------------------|--------|
| `==`     | Equal to              | `5 == 5`         | `true` |
| `!=`     | Not equal to          | `5 != 3`         | `true` |
| `<`      | Less than             | `5 < 3`          | `false`|
| `>`      | Greater than          | `5 > 3`          | `true` |
| `<=`     | Less than or equal to | `5 <= 5`         | `true` |
| `>=`     | Greater than or equal to | `5 >= 3`      | `true` |

Example:
```go
package main
import "fmt"

func main() {
    x := 10
    y := 20
    fmt.Println(x == y) // Output: false
    fmt.Println(x < y)  // Output: true
}
```

---

#### **3. Logical Operators**
| Operator | Description | Example                  | Output |
|----------|-------------|--------------------------|--------|
| `&&`     | Logical AND | `true && false`          | `false`|
| `\|\|`   | Logical OR  | `true \|\| false`        | `true` |
| `!`      | Logical NOT | `!true`                  | `false`|

Example:
```go
package main
import "fmt"

func main() {
    a := true
    b := false
    fmt.Println(a && b) // Output: false
    fmt.Println(a || b) // Output: true
    fmt.Println(!a)     // Output: false
}
```

---

#### **4. Bitwise Operators**
| Operator | Description          | Example        | Output |
|----------|----------------------|----------------|--------|
| `&`      | Bitwise AND          | `5 & 3`        | `1`    |
| `\|`     | Bitwise OR           | `5 \| 3`       | `7`    |
| `^`      | Bitwise XOR          | `5 ^ 3`        | `6`    |
| `<<`     | Left shift           | `5 << 1`       | `10`   |
| `>>`     | Right shift          | `5 >> 1`       | `2`    |

Example:
```go
package main
import "fmt"

func main() {
    fmt.Println(5 & 3)  // Output: 1
    fmt.Println(5 << 1) // Output: 10
}
```

---

#### **5. Assignment Operators**
| Operator | Description          | Example        | Equivalent To |
|----------|----------------------|----------------|---------------|
| `=`      | Simple assignment    | `x = 5`        | `x = 5`       |
| `+=`     | Add and assign       | `x += 3`       | `x = x + 3`   |
| `-=`     | Subtract and assign  | `x -= 3`       | `x = x - 3`   |
| `*=`     | Multiply and assign  | `x *= 3`       | `x = x * 3`   |
| `/=`     | Divide and assign    | `x /= 3`       | `x = x / 3`   |

Example:
```go
package main
import "fmt"

func main() {
    x := 10
    x += 5
    fmt.Println(x) // Output: 15
}
```

---

## **2. Control Statements in Golang**

Control statements determine the flow of execution in a program.

---

### **If-Else Statements**
The `if-else` statement executes code based on a condition.

#### Syntax:
```go
if condition {
    // Code to execute if condition is true
} else {
    // Code to execute if condition is false
}
```

#### Example:
```go
package main
import "fmt"

func main() {
    age := 20
    if age >= 18 {
        fmt.Println("You are an adult.")
    } else {
        fmt.Println("You are a minor.")
    }
}
```

#### Else-If:
```go
package main
import "fmt"

func main() {
    score := 85
    if score >= 90 {
        fmt.Println("Grade: A")
    } else if score >= 80 {
        fmt.Println("Grade: B")
    } else {
        fmt.Println("Grade: C")
    }
}
```

---

### **Switch Statement**
The `switch` statement evaluates a value against multiple cases.

#### Syntax:
```go
switch expression {
case value1:
    // Code for value1
case value2:
    // Code for value2
default:
    // Default code
}
```

#### Example:
```go
package main
import "fmt"

func main() {
    day := "Monday"
    switch day {
    case "Monday":
        fmt.Println("Start of the week")
    case "Friday":
        fmt.Println("End of the week")
    default:
        fmt.Println("Midweek")
    }
}
```

#### Fallthrough:
The `fallthrough` keyword forces execution to continue to the next case.

```go
package main
import "fmt"

func main() {
    num := 2
    switch num {
    case 1:
        fmt.Println("One")
        fallthrough
    case 2:
        fmt.Println("Two")
        fallthrough
    case 3:
        fmt.Println("Three")
    }
}
// Output:
// Two
// Three
```

---

### **Loops in Golang**
Go supports only one looping construct: `for`. However, it can be used in various forms.

#### **1. Basic For Loop**
```go
for initialization; condition; increment {
    // Code block
}
```

Example:
```go
package main
import "fmt"

func main() {
    for i := 1; i <= 5; i++ {
        fmt.Println(i)
    }
}
```

#### **2. While-Like Loop**
```go
for condition {
    // Code block
}
```

Example:
```go
package main
import "fmt"

func main() {
    i := 1
    for i <= 5 {
        fmt.Println(i)
        i++
    }
}
```

#### **3. Infinite Loop**
```go
for {
    // Code block
}
```

Example:
```go
package main
import "fmt"

func main() {
    i := 1
    for {
        fmt.Println(i)
        i++
        if i > 5 {
            break
        }
    }
}
```

#### **4. Range-Based Loop**
Used to iterate over arrays, slices, maps, strings, or channels.

Example:
```go
package main
import "fmt"

func main() {
    nums := []int{1, 2, 3}
    for index, value := range nums {
        fmt.Printf("Index: %d, Value: %d\n", index, value)
    }
}
```

---
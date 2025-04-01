# **Functions in Golang**

### **What Are Functions in Golang?**
- A **function** is a block of reusable code that performs a specific task.
- Functions are the building blocks of Go programs and are used to organize code into logical, manageable units.
- The `main` function is the entry point of an executable Go program.

---

### **Key Points to Know About Functions**
- **Reusability**: Functions allow you to reuse code without duplicating it.
- **Parameters and Return Values**: Functions can accept inputs (parameters) and return outputs (return values).
- **Named Return Values**: Go supports named return values for clarity and convenience.
- **Multiple Return Values**: Functions can return multiple values, which is a unique feature of Go.
- **Variadic Functions**: Functions can accept a variable number of arguments.
- **Anonymous Functions**: Functions can be defined without a name (anonymous functions).
- **Higher-Order Functions**: Functions can accept other functions as arguments or return them as results.
- **Defer Statement**: The `defer` statement delays the execution of a function until the surrounding function completes.

---

### **Ways to Declare Functions**
Below are all possible ways to declare functions in Go:

#### **1. Basic Function Declaration**
```go
func functionName(parameters) returnType {
    // Function body
}
```

Example:
```go
func add(a int, b int) int {
    return a + b
}
```

#### **2. Multiple Parameters of the Same Type**
You can group parameters of the same type.
```go
func add(a, b int) int {
    return a + b
}
```

#### **3. No Parameters or Return Values**
```go
func greet() {
    fmt.Println("Hello, World!")
}
```

#### **4. Named Return Values**
Named return values are declared in the function signature and automatically returned at the end.
```go
func divide(a, b float64) (result float64, err error) {
    if b == 0 {
        err = fmt.Errorf("division by zero")
        return
    }
    result = a / b
    return
}
```

#### **5. Multiple Return Values**
Functions can return multiple values.
```go
func swap(a, b string) (string, string) {
    return b, a
}
```

#### **6. Variadic Functions**
Variadic functions accept a variable number of arguments using `...`.
```go
func sum(nums ...int) int {
    total := 0
    for _, num := range nums {
        total += num
    }
    return total
}
```

---

### **How to Call Each Function**
#### **1. Calling Basic Functions**
```go
result := add(5, 3)
fmt.Println(result) // Output: 8
```

#### **2. Calling Functions with Multiple Return Values**
```go
sum, difference := calculate(10, 5)
fmt.Println("Sum:", sum)       // Output: Sum: 15
fmt.Println("Difference:", difference) // Output: Difference: 5
```

#### **3. Calling Variadic Functions**
```go
total := sum(1, 2, 3, 4, 5)
fmt.Println(total) // Output: 15

// Using a slice with variadic functions
numbers := []int{1, 2, 3, 4, 5}
total = sum(numbers...)
fmt.Println(total) // Output: 15
```

#### **4. Calling Anonymous Functions**
Anonymous functions can be called immediately after declaration or assigned to variables.
```go
// Assigned to a variable
greet := func(name string) {
    fmt.Printf("Hello, %s!\n", name)
}
greet("Alice") // Output: Hello, Alice!

// Called directly
func() {
    fmt.Println("This is an anonymous function.")
}() // Output: This is an anonymous function.
```

#### **5. Calling Higher-Order Functions**
```go
add := func(a, b int) int {
    return a + b
}

result := applyOperation(3, 4, add)
fmt.Println(result) // Output: 7
```

#### **6. Using Defer**
```go
func main() {
    defer fmt.Println("World")
    fmt.Println("Hello")
    // Output:
    // Hello
    // World
}
```

---

### **Return Types in Functions**
#### **1. Single Return Value**
```go
func square(x int) int {
    return x * x
}
```

#### **2. Multiple Return Values**
```go
func calculate(a, b int) (int, int) {
    return a + b, a - b
}
```

#### **3. Named Return Values**
```go
func divide(a, b float64) (result float64, err error) {
    if b == 0 {
        err = fmt.Errorf("division by zero")
        return
    }
    result = a / b
    return
}
```

#### **4. Variadic Return Values**
```go
func getNumbers() (int, int, int) {
    return 1, 2, 3
}
```

---

### **Recursive Functions**
A recursive function calls itself to solve smaller instances of the same problem.

#### Example: Factorial Calculation
```go
func factorial(n int) int {
    if n == 0 {
        return 1
    }
    return n * factorial(n-1)
}

func main() {
    fmt.Println(factorial(5)) // Output: 120
}
```

---

### **Anonymous Functions**
#### **Theory**
- **Definition**: Anonymous functions are functions without a name. They are often used for short, one-off tasks.
- **Closures**: Anonymous functions can capture variables from their surrounding scope, creating closures.
- **Use Cases**:
  - Inline operations.
  - Callbacks.
  - Goroutines.

#### Example:
```go
func main() {
    // Anonymous function assigned to a variable
    greet := func(name string) {
        fmt.Printf("Hello, %s!\n", name)
    }
    greet("Alice")

    // Anonymous function used directly
    func() {
        fmt.Println("This is an anonymous function.")
    }()
}
```

---

### **Higher-Order Functions**
#### **Theory**
- **Definition**: Higher-order functions are functions that either:
  - Accept other functions as arguments.
  - Return functions as results.
- **Advantages**:
  - Promotes modularity and reusability.
  - Enables functional programming paradigms like map, filter, and reduce.

#### Example: Passing a Function as an Argument
```go
func applyOperation(a, b int, operation func(int, int) int) int {
    return operation(a, b)
}

func add(a, b int) int {
    return a + b
}

func multiply(a, b int) int {
    return a * b
}

func main() {
    fmt.Println(applyOperation(3, 4, add))      // Output: 7
    fmt.Println(applyOperation(3, 4, multiply)) // Output: 12
}
```

#### Example: Returning a Function
```go
func createMultiplier(multiplier int) func(int) int {
    return func(x int) int {
        return x * multiplier
    }
}

func main() {
    double := createMultiplier(2)
    fmt.Println(double(5)) // Output: 10
}
```

---

### **Defer Statement**
#### **Theory**
- **Definition**: The `defer` statement delays the execution of a function until the surrounding function completes.
- **Execution Order**: Deferred calls are executed in LIFO (Last-In-First-Out) order.
- **Use Cases**:
  - Resource cleanup (e.g., closing files, releasing locks).
  - Ensuring cleanup logic runs even if an error occurs.


#### Example:
```go
func main() {
    defer fmt.Println("World")
    fmt.Println("Hello")
    // Output:
    // Hello
    // World
}
```

#### Example: Resource Cleanup
```go
func main() {
    file, err := os.Open("example.txt")
    if err != nil {
        log.Fatal(err)
    }
    defer file.Close()

    // Perform file operations here
    fmt.Println("File opened successfully.")
}
```

---

### **Simple Examples of Functions**
#### **Example 1: Variadic Function**
```go
func sum(nums ...int) int {
    total := 0
    for _, num := range nums {
        total += num
    }
    return total
}

func main() {
    fmt.Println(sum(1, 2, 3, 4, 5)) // Output: 15
}
```

#### **Example 2: Recursive Function**
```go
func fibonacci(n int) int {
    if n <= 1 {
        return n
    }
    return fibonacci(n-1) + fibonacci(n-2)
}

func main() {
    fmt.Println(fibonacci(10)) // Output: 55
}
```

#### **Example 3: Higher-Order Function**
```go
func filter(numbers []int, condition func(int) bool) []int {
    var result []int
    for _, num := range numbers {
        if condition(num) {
            result = append(result, num)
        }
    }
    return result
}

func main() {
    even := func(x int) bool { return x%2 == 0 }
    fmt.Println(filter([]int{1, 2, 3, 4, 5}, even)) // Output: [2 4]
}
```

---

### **Summary Table: Function Features**
| Feature               | Description                                                                 |
|-----------------------|-----------------------------------------------------------------------------|
| **Basic Functions**   | Perform a specific task with optional parameters and return values.         |
| **Named Return Values** | Return values are declared in the function signature for clarity.          |
| **Multiple Return Values** | Functions can return more than one value.                                |
| **Variadic Functions** | Accept a variable number of arguments using `...`.                         |
| **Recursive Functions** | Functions that call themselves to solve problems iteratively.             |
| **Anonymous Functions** | Functions without a name, often used inline or as closures.               |
| **Higher-Order Functions** | Functions that accept or return other functions.                        |
| **Defer Statement**    | Delays the execution of a function until the surrounding function finishes.|

---

# General Structure of a Go Program

A Go program follows a well-defined structure that ensures clarity, modularity, and maintainability. Below is a detailed explanation of the general structure of a Go program, including its components and conventions.

---

## **1. Package Declaration**
Every Go program starts with a `package` declaration. This defines the package to which the file belongs.

- **Main Package**:
  - The `main` package is special because it indicates that the program is executable.
  - It must contain a `main` function, which serves as the entry point of the program.

```go
package main
```

- **Other Packages**:
  - Libraries or reusable modules are defined in non-main packages (e.g., `package math`, `package utils`).
  - These packages are imported and used in other programs.

---

## **2. Import Statements**
The `import` keyword is used to include external packages or libraries required by the program.

- **Standard Library Packages**:
  - Examples: `fmt`, `os`, `strconv`, `net/http`.

- **Third-Party Packages**:
  - Installed via `go get` or included in `go.mod`.
  - Example: `"github.com/gin-gonic/gin"`.

- **Local Packages**:
  - Relative paths or module paths for custom packages.

#### Syntax:
```go
import (
    "fmt" // Standard library package
    "net/http" // Standard library package
    "github.com/gin-gonic/gin" // Third-party package
)
```

#### Notes:
- Use grouped imports (`import (...)`) for better readability.
- Avoid unused imports; Go enforces this rule at compile time.

---

## **3. Complete Template**
Below is a complete template demonstrating the general structure of a Go program:

```go
package main

import (
    "fmt"
    "math"
)

// Main Function
func main() {
    // Variable Declaration
    var radius float64 = 5

    // Function Call and Output
    fmt.Printf("Radius of circle is %.2f", radius)
}
```

---
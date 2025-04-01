# **Core Packages in Golang**

## **[1. Strings](https://www.scaler.com/topics/golang/strings-in-golang/)**

### **Overview**
The `strings` package provides functions for manipulating and working with strings.

### **Key Features**
- **String Manipulation**:
  - Concatenation, trimming, splitting, and joining.
- **Searching and Replacing**:
  - Find substrings, replace text, and check prefixes/suffixes.
- **Case Conversion**:
  - Convert strings to uppercase or lowercase.

### **Commonly Used Functions**
| Function                  | Description                                                                 |
|---------------------------|-----------------------------------------------------------------------------|
| `strings.Contains(s, sub)`| Checks if `sub` is present in `s`.                                          |
| `strings.Split(s, sep)`   | Splits `s` into a slice using `sep` as the delimiter.                       |
| `strings.Join(slice, sep)`| Joins elements of `slice` into a single string separated by `sep`.          |
| `strings.ToUpper(s)`      | Converts `s` to uppercase.                                                  |
| `strings.TrimSpace(s)`    | Removes leading and trailing whitespace from `s`.                           |

### **Example Code**
```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s := "Hello, Golang!"

	// Contains
	fmt.Println(strings.Contains(s, "Golang")) // Output: true

	// Split and Join
	parts := strings.Split(s, ", ")
	fmt.Println(parts)                         // Output: ["Hello" "Golang!"]
	joined := strings.Join(parts, " ")
	fmt.Println(joined)                        // Output: "Hello Golang!"

	// ToUpper and TrimSpace
	fmt.Println(strings.ToUpper(s))           // Output: "HELLO, GOLANG!"
	fmt.Println(strings.TrimSpace("  Hello ")) // Output: "Hello"
}
```

---

## **2. Input/Output**

### **Overview**
The `fmt` and `io` packages handle input/output operations.

### **Key Features**
- **Formatted I/O**:
  - Print, scan, and format data using `fmt`.
- **File and Stream Operations**:
  - Read/write files and streams using `os` and `io`.

### **Commonly Used Functions**
| Function                     | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `fmt.Println(args...)`       | Prints arguments followed by a newline.                                     |
| `fmt.Printf(format, args...)`| Formats and prints arguments.                                               |
| `fmt.Scan(&vars...)`         | Reads input into variables.                                                 |
| `os.Open(filename)`          | Opens a file for reading.                                                   |
| `io.Copy(dst, src)`          | Copies data from `src` to `dst`.                                            |

### **Example Code**
```go
package main

import (
	"fmt"
	"io"
	"os"
)

func main() {
	// Basic I/O
	var name string
	fmt.Print("Enter your name: ")
	fmt.Scan(&name)
	fmt.Printf("Hello, %s!\n", name)

	// File I/O
	file, err := os.Open("example.txt")
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer file.Close()

	io.Copy(os.Stdout, file) // Print file content to stdout
}
```

---

## **3. File Handling**

### **Overview**
The `os` and `io/ioutil` (deprecated in Go 1.16, replaced by `os` and `io/fs`) packages handle file operations.

### **Key Features**
- **File Creation and Deletion**:
  - Create, open, close, and delete files.
- **Reading and Writing**:
  - Read/write files line-by-line or as a whole.
- **Directory Operations**:
  - List, create, and remove directories.

### **Commonly Used Functions**
| Function                     | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `os.Create(filename)`        | Creates a new file.                                                         |
| `os.Remove(filename)`        | Deletes a file.                                                             |
| `os.ReadFile(filename)`      | Reads the entire file into memory.                                          |
| `os.WriteFile(filename, data)`| Writes data to a file.                                                      |
| `os.Mkdir(name, perm)`       | Creates a directory.                                                        |

### **Example Code**
```go
package main

import (
	"fmt"
	"os"
)

func main() {
	// Create and write to a file
	err := os.WriteFile("example.txt", []byte("Hello, File Handling!"), 0644)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	// Read from a file
	data, err := os.ReadFile("example.txt")
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	fmt.Println(string(data)) // Output: "Hello, File Handling!"

	// Delete the file
	err = os.Remove("example.txt")
	if err != nil {
		fmt.Println("Error:", err)
	}
}
```

---

## **[4. Errors](https://www.scaler.com/topics/golang/golang-errors/)**

### **Overview**
Go uses the `error` interface for error handling. Errors are values that can be returned from functions.

### **Key Features**
- **Custom Errors**:
  - Use `errors.New` or `fmt.Errorf` to create custom errors.
- **Error Wrapping**:
  - Introduced in Go 1.13, allows adding context to errors.

### **Commonly Used Functions**
| Function                     | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `errors.New(message)`        | Creates a new error with the given message.                                 |
| `fmt.Errorf(format, args...)`| Creates a formatted error message.                                          |
| `errors.Is(err, target)`     | Checks if `err` matches `target`.                                           |
| `errors.As(err, target)`     | Asserts that `err` is of a specific type.                                   |

### **Example Code**
```go
package main

import (
	"errors"
	"fmt"
)

func divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, errors.New("division by zero")
	}
	return a / b, nil
}

func main() {
	result, err := divide(10, 0)
	if err != nil {
		fmt.Println("Error:", err) // Output: Error: division by zero
		return
	}
	fmt.Println("Result:", result)
}
```

---

## **[5. Logging](https://www.scaler.com/topics/golang/golang-log/)**

### **Overview**
The `log` package provides logging functionality.

### **Key Features**
- **Log Levels**:
  - Print informational, warning, and error logs.
- **Custom Loggers**:
  - Create loggers with custom prefixes and output destinations.

### **Commonly Used Functions**
| Function                     | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `log.Println(args...)`       | Logs messages with a timestamp.                                             |
| `log.Fatalf(format, args...)`| Logs a formatted message and exits the program.                             |
| `log.SetPrefix(prefix)`      | Sets a prefix for all log messages.                                         |

### **Example Code**
```go
package main

import (
	"log"
)

func main() {
	log.SetPrefix("[INFO] ")
	log.Println("Application started")

	log.SetPrefix("[ERROR] ")
	log.Fatalf("Failed to start: %s", "critical error")
}
```

---

## **6. Sorting**

### **Overview**
The `sort` package provides sorting algorithms for slices and user-defined types.

### **Key Features**
- **Sorting Primitives**:
  - Sort integers, floats, and strings.
- **Custom Sorting**:
  - Implement the `sort.Interface` for custom types.

### **Commonly Used Functions**
| Function                     | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `sort.Ints(slice)`           | Sorts a slice of integers in ascending order.                               |
| `sort.Strings(slice)`        | Sorts a slice of strings in lexicographical order.                          |
| `sort.Slice(slice, lessFunc)`| Sorts a slice using a custom comparison function.                            |

### **Example Code**
```go
package main

import (
	"fmt"
	"sort"
)

func main() {
	numbers := []int{5, 2, 8, 1}
	sort.Ints(numbers)
	fmt.Println("Sorted:", numbers) // Output: Sorted: [1 2 5 8]

	names := []string{"Alice", "Bob", "Charlie"}
	sort.Strings(names)
	fmt.Println("Sorted:", names) // Output: Sorted: [Alice Bob Charlie]
}
```

---

## **7. Hashing and Cryptography**

### **Overview**
The `crypto` and `hash` packages provide hashing and encryption functionalities.

### **Key Features**
- **Hashing**:
  - Generate hashes using algorithms like SHA256, MD5.
- **Encryption**:
  - Encrypt and decrypt data using AES, RSA.

### **Commonly Used Functions**
| Function                     | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `sha256.Sum256(data)`        | Computes the SHA256 hash of `data`.                                         |
| `hmac.New(hashFunc, key)`    | Creates a new HMAC hasher with the given hash function and key.             |

### **Example Code**
```go
package main

import (
	"crypto/sha256"
	"fmt"
)

func main() {
	data := "hello"
	hash := sha256.Sum256([]byte(data))
	fmt.Printf("SHA256: %x\n", hash)
}
```

---

## **[8. Testing](https://www.scaler.com/topics/golang/golang-testing/)**

### **Overview**
The `testing` package provides tools for writing unit tests.

### **Key Features**
- **Test Functions**:
  - Write test functions starting with `Test`.
- **Benchmarks**:
  - Measure performance using benchmark functions.

### **Commonly Used Functions**
| Function                     | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `t.Errorf(format, args...)`  | Logs an error message and marks the test as failed.                         |
| `t.Run(name, func)`          | Runs a subtest or sub-benchmark.                                            |

### **Example Code**
```go
package main

import (
	"testing"
)

func Add(a, b int) int {
	return a + b
}

func TestAdd(t *testing.T) {
	result := Add(2, 3)
	if result != 5 {
		t.Errorf("Expected 5, got %d", result)
	}
}
```
---
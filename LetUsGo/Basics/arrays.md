# **Arrays in Golang**

### **What Are Arrays in Golang?**
- An **array** is a fixed-size sequence of elements of the same type.
- The size of an array is part of its type, meaning arrays with different sizes are considered distinct types.
- Arrays are stored in contiguous memory locations.

---

### **Key Points to Know About Arrays**
- **Fixed Size**: The size of an array must be known at compile time and cannot be changed dynamically.
- **Zero-Based Indexing**: Array indices start from `0`.
- **Value Type**: Arrays are value types, meaning they are passed by value (copied) when assigned or passed to functions.
- **Immutable Size**: Once declared, the size of an array cannot be altered.
- **Default Values**: Uninitialized elements are set to the zero value of the array's type (e.g., `0` for integers, `""` for strings).

---

### **Ways to Declare and Initialize Arrays**
Below are all possible ways to declare and initialize arrays in Go:

#### **1. Declare Without Initialization**
```go
var arr [5]int // Declares an array of 5 integers, initialized to zero values.
```

#### **2. Declare and Initialize with Values**
```go
arr := [5]int{1, 2, 3, 4, 5} // Declares and initializes an array with specific values.
```

#### **3. Partial Initialization**
```go
arr := [5]int{1, 2} // Initializes first two elements; remaining elements are set to zero values.
```

#### **4. Use `...` to Infer Size**
```go
arr := [...]int{1, 2, 3, 4, 5} // Compiler infers the size based on the number of elements.
```

#### **5. Declare and Assign Later**
```go
var arr [3]string
arr[0] = "Go"
arr[1] = "Lang"
arr[2] = "Arrays"
```

---

### **Useful Methods and Operations with Arrays**
While Go does not have built-in methods specifically for arrays, you can use standard library functions like `len()` and looping constructs to manipulate arrays.

| **Function/Operation** | **Description**                                                                 |
|-------------------------|---------------------------------------------------------------------------------|
| `len(arr)`             | Returns the length of the array.                                                |
| `copy(dest, src)`      | Copies elements from one array to another (limited to overlapping arrays).      |
| `range`                | Used in loops to iterate over array elements.                                   |

---

### **Looping Techniques for Arrays**
#### **1. Using `for` Loop**
```go
arr := [5]int{1, 2, 3, 4, 5}
for i := 0; i < len(arr); i++ {
    fmt.Println("Element at index", i, "is", arr[i])
}
```

#### **2. Using `range`**
```go
arr := [5]int{1, 2, 3, 4, 5}
for index, value := range arr {
    fmt.Printf("Index: %d, Value: %d\n", index, value)
}
```

---

### **Multi-Dimensional Arrays**
A multi-dimensional array is an array of arrays.

#### **Declaration and Initialization**
```go
// 2D Array Declaration
var matrix [3][3]int

// 2D Array Initialization
matrix := [3][3]int{
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
}
```

#### **Accessing Elements**
```go
fmt.Println(matrix[0][0]) // Output: 1
fmt.Println(matrix[1][2]) // Output: 6
```

#### **Iterating Over Multi-Dimensional Arrays**
```go
matrix := [3][3]int{
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
}

for i := 0; i < len(matrix); i++ {
    for j := 0; j < len(matrix[i]); j++ {
        fmt.Printf("Element at [%d][%d]: %d\n", i, j, matrix[i][j])
    }
}
```

---

### **Simple Examples of Arrays**
#### **Example 1: Storing Grades**
```go
package main
import "fmt"

func main() {
    grades := [5]int{85, 90, 78, 92, 88}
    total := 0

    for _, grade := range grades {
        total += grade
    }

    average := total / len(grades)
    fmt.Println("Average Grade:", average)
}
```

#### **Example 2: Matrix Addition**
```go
package main
import "fmt"

func main() {
    matrix1 := [2][2]int{{1, 2}, {3, 4}}
    matrix2 := [2][2]int{{5, 6}, {7, 8}}
    result := [2][2]int{}

    for i := 0; i < 2; i++ {
        for j := 0; j < 2; j++ {
            result[i][j] = matrix1[i][j] + matrix2[i][j]
        }
    }

    fmt.Println("Resultant Matrix:")
    for _, row := range result {
        fmt.Println(row)
    }
}
```

---
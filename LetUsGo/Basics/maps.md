# **Maps in Golang**

### **What Are Maps in Golang?**
- A **map** is a built-in data structure in Go that stores key-value pairs.
- Maps are unordered collections, meaning the order of elements is not guaranteed.
- Keys in a map must be unique, and their values can be accessed or updated using the corresponding keys.

---

### **Key Points to Know About Maps**
- **Key-Value Pairs**: Maps store data as key-value pairs, where each key maps to a specific value.
- **Dynamic Size**: Maps grow dynamically as new key-value pairs are added.
- **Reference Type**: Maps are reference types, meaning they are passed by reference, and changes to a map affect the original data.
- **Zero Value**: The zero value of a map is `nil`.
- **Hashable Keys**: Keys must be of a type that supports equality comparison (e.g., integers, strings, pointers). Slices, maps, and functions cannot be used as keys.
- **Default Values**: Accessing a non-existent key returns the zero value of the value type (e.g., `0` for integers, `""` for strings).

---

### **Ways to Declare and Initialize Maps**
Below are all possible ways to declare and initialize maps in Go:

#### **1. Declare Without Initialization**
```go
var m map[string]int // Declares a nil map of string keys and integer values.
```

#### **2. Declare and Initialize with Values**
```go
m := map[string]int{
    "Alice": 25,
    "Bob":   30,
} // Declares and initializes a map with specific key-value pairs.
```

#### **3. Use `make` to Create a Map**
The `make` function allows you to create an empty map with a specified type.
```go
m := make(map[string]int) // Creates an empty map of string keys and integer values.
```

#### **4. Adding Key-Value Pairs**
You can add or update key-value pairs after declaring a map.
```go
m := make(map[string]int)
m["Alice"] = 25
m["Bob"] = 30
```

#### **5. Deleting Key-Value Pairs**
Use the `delete` function to remove a key-value pair from a map.
```go
delete(m, "Alice") // Removes the key "Alice" from the map.
```

---

### **Useful Methods and Operations with Maps**
Go provides several built-in operations for working with maps.

| **Operation**         | **Description**                                                                 |
|------------------------|---------------------------------------------------------------------------------|
| `len(map)`            | Returns the number of key-value pairs in the map.                               |
| `delete(map, key)`    | Deletes the key-value pair associated with the specified key.                   |
| `value, exists := map[key]` | Retrieves the value for a key and checks if the key exists (`exists` is `true` or `false`). |

---

### **Looping Techniques for Maps**
#### **1. Iterating Over All Key-Value Pairs**
```go
m := map[string]int{
    "Alice": 25,
    "Bob":   30,
}

for key, value := range m {
    fmt.Printf("Key: %s, Value: %d\n", key, value)
}
```

#### **2. Iterating Over Only Keys**
```go
for key := range m {
    fmt.Println("Key:", key)
}
```

#### **3. Iterating Over Only Values**
```go
for _, value := range m {
    fmt.Println("Value:", value)
}
```

#### **4. Checking for Key Existence**
```go
value, exists := m["Alice"]
if exists {
    fmt.Println("Alice's age is", value)
} else {
    fmt.Println("Alice not found")
}
```

---

### **Simple Examples of Maps**
#### **Example 1: Storing User Ages**
```go
package main
import "fmt"

func main() {
    ages := map[string]int{
        "Alice": 25,
        "Bob":   30,
    }

    // Add a new user
    ages["Charlie"] = 35

    // Iterate over the map
    for name, age := range ages {
        fmt.Printf("%s is %d years old.\n", name, age)
    }

    // Delete a user
    delete(ages, "Bob")
    fmt.Println("After deletion:", ages)
}
```

#### **Example 2: Counting Word Frequencies**
```go
package main
import (
    "fmt"
    "strings"
)

func main() {
    text := "hello world hello golang world"
    words := strings.Fields(text) // Split text into words
    frequency := make(map[string]int)

    // Count word frequencies
    for _, word := range words {
        frequency[word]++
    }

    // Print the result
    fmt.Println("Word Frequencies:")
    for word, count := range frequency {
        fmt.Printf("%s: %d\n", word, count)
    }
}
```

#### **Example 3: Checking Key Existence**
```go
package main
import "fmt"

func main() {
    scores := map[string]int{
        "Alice": 95,
        "Bob":   85,
    }

    // Check if a key exists
    score, exists := scores["Charlie"]
    if exists {
        fmt.Println("Charlie's score:", score)
    } else {
        fmt.Println("Charlie's score not found")
    }
}
```

---

### **Summary Table: Arrays, Slices, and Maps**
| Feature              | Arrays                          | Slices                         | Maps                           |
|----------------------|----------------------------------|---------------------------------|--------------------------------|
| **Type**            | Fixed-size sequence             | Dynamic-size sequence          | Key-value pairs               |
| **Size**            | Fixed                           | Dynamic                        | Dynamic                       |
| **Order**           | Ordered                         | Ordered                        | Unordered                     |
| **Declaration**     | `[size]Type`                    | `[]Type`                       | `map[KeyType]ValueType`       |
| **Initialization**  | Explicit size required          | Flexible initialization         | Flexible initialization        |
| **Underlying Data** | Stores its own data             | References an underlying array  | Stores key-value pairs         |
| **Methods**         | Limited                         | Rich set of methods (`append`, etc.) | Rich set of methods (`delete`, etc.) |

---
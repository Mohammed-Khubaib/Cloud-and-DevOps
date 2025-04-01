# **Structs in Golang**

### **What Are Structs in Golang?**
- A **struct** is a composite data type that groups together variables (called fields) of different types under a single name.
- Structs are used to represent real-world entities or complex data structures.

---

### **Why Use Structs?**
- **Organization**: Group related data into a single unit.
- **Custom Types**: Define custom types with specific fields and behaviors.
- **Reusability**: Structs can be reused across different parts of the program.

---

### **Key Points to Know About Structs**
- **Fields**: Structs consist of named fields, each with a specific type.
- **Zero Value**: Uninitialized struct fields are set to their zero values (e.g., `0` for integers, `""` for strings).
- **Mutability**: Structs are mutable by default unless explicitly passed as pointers.

---

### **Ways to Declare and Initialize Structs**
#### **1. Declare Without Initialization**
```go
type Person struct {
    Name string
    Age  int
}

var p Person // Declares a struct variable initialized to zero values.
```

#### **2. Initialize with Values**
```go
p := Person{Name: "Alice", Age: 30}
```

#### **3. Partial Initialization**
```go
p := Person{Name: "Bob"} // Age will be initialized to 0.
```

#### **4. Using Field Indexing**
```go
p := Person{"Charlie", 25} // Fields are assigned in order of declaration.
```

#### **5. Using Pointers**
```go
p := &Person{Name: "David", Age: 28} // Pointer to a struct.
fmt.Println(p.Name) // Access fields directly using pointer.
```

---

### **How to Access Fields Within a Struct**
Access fields using the dot (`.`) operator.

#### Example:
```go
type Person struct {
    Name string
    Age  int
}

func main() {
    p := Person{Name: "Alice", Age: 30}
    fmt.Println("Name:", p.Name) // Output: Name: Alice
    fmt.Println("Age:", p.Age)   // Output: Age: 30
}
```

---

### **Passing Structs to Functions**
Structs can be passed to functions either by value or by reference.

#### **1. Pass by Value**
```go
func printPerson(p Person) {
    fmt.Println("Name:", p.Name)
    fmt.Println("Age:", p.Age)
}

func main() {
    p := Person{Name: "Alice", Age: 30}
    printPerson(p)
}
```

#### **2. Pass by Reference**
```go
func updatePerson(p *Person) {
    p.Age = 31
}

func main() {
    p := Person{Name: "Alice", Age: 30}
    updatePerson(&p)
    fmt.Println("Updated Age:", p.Age) // Output: Updated Age: 31
}
```

---

### **Comparing Structs**
Structs can be compared if all their fields are comparable.

#### Example:
```go
type Point struct {
    X, Y int
}

func main() {
    p1 := Point{1, 2}
    p2 := Point{1, 2}
    fmt.Println(p1 == p2) // Output: true
}
```

---

## **2. Methods in Golang**

### **What Are Methods in Golang?**
- A **method** is a function with a special receiver argument that operates on a specific type (usually a struct).
- Methods allow you to define behavior associated with a type.

---

### **Why Use Methods?**
- **Encapsulation**: Methods encapsulate behavior within a type.
- **Reusability**: Methods can be reused across instances of the same type.
- **Polymorphism**: Methods enable polymorphic behavior when combined with interfaces.

---

### **Key Points to Know About Methods**
- **Receiver**: The receiver defines the type on which the method operates.
- **Value vs Pointer Receivers**:
  - **Value Receiver**: Operates on a copy of the receiver.
  - **Pointer Receiver**: Operates on the original receiver, allowing modifications.

---

### **Ways to Declare Methods**
#### **1. Value Receiver**
```go
type Rectangle struct {
    Width, Height float64
}

func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

func main() {
    rect := Rectangle{Width: 5, Height: 3}
    fmt.Println("Area:", rect.Area()) // Output: Area: 15
}
```

#### **2. Pointer Receiver**
```go
func (r *Rectangle) Scale(factor float64) {
    r.Width *= factor
    r.Height *= factor
}

func main() {
    rect := Rectangle{Width: 5, Height: 3}
    rect.Scale(2)
    fmt.Println("Scaled Dimensions:", rect.Width, rect.Height) // Output: Scaled Dimensions: 10 6
}
```

---

### **How to Make a Struct a Receiver of a Method**
- Define the method with a receiver argument of the struct type.

#### Example:
```go
type Circle struct {
    Radius float64
}

func (c Circle) Area() float64 {
    return math.Pi * c.Radius * c.Radius
}

func main() {
    c := Circle{Radius: 5}
    fmt.Println("Circle Area:", c.Area()) // Output: Circle Area: 78.5398...
}
```

---

### **What Is a Method Set?**
- The **method set** of a type defines the methods available for that type.
- For a value receiver, both value and pointer types can call the method.
- For a pointer receiver, only pointer types can call the method.

---

## **3. Interfaces in Golang**

### **What Are Interfaces in Golang?**
- An **interface** is a collection of method signatures that a type must implement to satisfy the interface.
- Interfaces enable abstraction and polymorphism.

---

### **Why Use Interfaces?**
- **Abstraction**: Hide implementation details behind a common interface.
- **Polymorphism**: Allow different types to be treated uniformly.
- **Decoupling**: Separate behavior from implementation.

---

### **Key Points to Know About Interfaces**
- **Implicit Implementation**: A type satisfies an interface by implementing its methods (no explicit declaration required).
- **Empty Interface**: The `interface{}` type can hold values of any type.

---

### **Ways to Declare Interfaces**
#### **1. Basic Declaration**
```go
type Shape interface {
    Area() float64
}
```

#### **2. Multiple Methods**
```go
type Speaker interface {
    Speak() string
    Listen(message string)
}
```

---

### **How to Implement Interfaces**
A type implements an interface by defining all its methods.

#### Example:
```go
type Rectangle struct {
    Width, Height float64
}

func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

type Circle struct {
    Radius float64
}

func (c Circle) Area() float64 {
    return math.Pi * c.Radius * c.Radius
}

func main() {
    var s1 Shape = Rectangle{Width: 5, Height: 3}
    var s2 Shape = Circle{Radius: 5}

    fmt.Println("Rectangle Area:", s1.Area()) // Output: Rectangle Area: 15
    fmt.Println("Circle Area:", s2.Area())    // Output: Circle Area: 78.5398...
}
```

---



### **Summary Table: Key Concepts**
| Concept               | Description                                                                 |
|-----------------------|-----------------------------------------------------------------------------|
| **Structs**           | Group related fields into a single unit.                                   |
| **Methods**           | Functions with a receiver argument to define behavior for a type.          |
| **Interfaces**        | Abstract types that define behavior through method signatures.            |

---
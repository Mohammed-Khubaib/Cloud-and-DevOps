# PromQL (Prometheus Query Language)

## Table of Contents

- [Introduction to PromQL](#introduction-to-promql)
- [Selectors & Matchers](#selectors--matchers)
- [Modifiers](#modifiers)
- [Operators](#operators)
- [Vector Matchers](#vector-matchers)
- [Aggregation](#aggregation)
- [Best Practices](#best-practices)

## Introduction to PromQL

PromQL (Prometheus Query Language) is the query language used by Prometheus to select and aggregate time series data in real time. It's a powerful language designed specifically for time series data and provides various operations to transform, filter, and aggregate metrics.

### Key Concepts

- **Instant Vector**: A set of time series, each containing a single sample for a specific timestamp
- **Range Vector**: A set of time series containing a range of data points over time
- **Scalar**: A simple numeric floating-point value
- **String**: A simple string value (rarely used)

## Selectors & Matchers

Selectors identify the time series you want to retrieve. Matchers filter the results based on label values.

### Basic Syntax

```
metric_name{label1="value1", label2="value2", ...}
```

### Matcher Types

| Matcher | Description | Example |
|---------|-------------|---------|
| `=` | Exact match | `http_requests_total{code="200"}` |
| `!=` | Not equal | `http_requests_total{code!="200"}` |
| `=~` | Regex match | `http_requests_total{code=~"2.."}` |
| `!~` | Regex not match | `http_requests_total{code!~"2.."}` |

### Examples

```promql
# Select all HTTP requests with status code 200
http_requests_total{status="200"}

# Select all HTTP requests with status code that's not 200
http_requests_total{status!="200"}

# Select all HTTP requests with status code starting with 2 (2xx)
http_requests_total{status=~"2.."}

# Select all HTTP requests except those with status code starting with 2
http_requests_total{status!~"2.."}

# Select HTTP requests with both method=GET and status=200
http_requests_total{method="GET", status="200"}
```

## Modifiers

Modifiers change how the selector behaves, most commonly by specifying a time range.

### Range Selector

The range selector `[time]` defines a time period, turning an instant vector into a range vector:

```promql
# Range of values over the last 5 minutes
http_requests_total{status="200"}[5m]

# Range of values over the last 1 hour
node_cpu_seconds_total{mode="idle"}[1h]

# Range of values over the last 2 days
node_memory_MemFree_bytes[2d]
```

### Offset Modifier

The `offset` modifier looks back in time:

```promql
# HTTP requests 5 minutes ago
http_requests_total offset 5m

# CPU usage one week ago for a 5-minute period
rate(node_cpu_seconds_total{mode="user"}[5m] offset 1w)
```

### @ Modifier (Prometheus 2.26+)

The `@` modifier allows querying at a specific timestamp:

```promql
# HTTP requests at a specific Unix timestamp
http_requests_total @ 1609459200

# HTTP requests on January 1st, 2021
http_requests_total @ 1609459200
```

## Operators

PromQL supports various operators to transform and combine time series data.

### Arithmetic Operators

| Operator | Description |
|----------|-------------|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
| `%` | Modulo |
| `^` | Power |

Examples:

```promql
# Calculate memory usage percentage
node_memory_MemFree_bytes / node_memory_MemTotal_bytes * 100

# Convert bytes to megabytes
node_disk_read_bytes_total / 1024 / 1024
```

### Comparison Operators

| Operator | Description |
|----------|-------------|
| `==` | Equal |
| `!=` | Not equal |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal |
| `<=` | Less than or equal |

Examples:

```promql
# Filter nodes with CPU usage higher than 80%
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80

# Find disks with less than 10% free space
node_filesystem_avail_bytes / node_filesystem_size_bytes * 100 < 10
```

### Logical Operators

Used with comparison operators:

| Operator | Description |
|----------|-------------|
| `and` | Intersection |
| `or` | Union |
| `unless` | Complement |

Examples:

```promql
# Nodes with high CPU AND high memory usage
(100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80) and (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100 < 20)

# Requests that are either POST or PUT
http_requests_total{method="POST"} or http_requests_total{method="PUT"}

# Successful requests excluding redirect status codes
http_requests_total{status=~"2.."} unless http_requests_total{status="204"}
```

## Vector Matchers

Vector matching allows you to combine or filter time series based on their labels.

### One-to-One Matching

Combines vectors where labels on the left and right side match:

```promql
# Calculate the ratio of HTTP errors to total requests
http_requests_total{status=~"5.."} / ignoring(status) http_requests_total

# Temperature difference between two sensors
temperature_celsius{location="outside"} - on(location) temperature_celsius{location="inside"}
```

### Many-to-One/One-to-Many Matching

Uses `group_left` or `group_right` to specify which side can have multiple entries:

```promql
# Attach server details to metrics
node_cpu_seconds_total{mode="user"} * on(instance) group_left(datacenter, rack) node_info

# Calculate error percentage with appropriate labels
sum by(job, instance) (rate(http_requests_total{status=~"5.."}[5m])) 
  / 
sum by(job, instance) (rate(http_requests_total[5m])) 
  * 100
```

### Matching Operators

| Operator | Description |
|----------|-------------|
| `on()` | Match with specified labels |
| `ignoring()` | Match while ignoring specified labels |
| `group_left()` | Many-to-one matching with left-side preservation |
| `group_right()` | One-to-many matching with right-side preservation |

## Aggregation

Aggregation operators combine multiple time series into fewer series or a single value.

### Aggregation Operators

| Operator | Description |
|----------|-------------|
| `sum` | Sum of all values |
| `min` | Minimum value |
| `max` | Maximum value |
| `avg` | Average value |
| `stddev` | Standard deviation |
| `stdvar` | Standard variance |
| `count` | Count of elements |
| `count_values` | Count of each distinct value |
| `bottomk` | K smallest elements |
| `topk` | K largest elements |
| `quantile` | φ-quantile (0 ≤ φ ≤ 1) |

### Without Grouping

```promql
# Total number of HTTP requests across all instances
sum(http_requests_total)

# Maximum CPU usage across all nodes
max(rate(node_cpu_seconds_total{mode="user"}[5m]))
```

### With Grouping

```promql
# Sum of HTTP requests by method
sum by(method) (http_requests_total)

# Average memory usage by datacenter
avg by(dc) (node_memory_MemUsage_bytes)

# Top 3 CPU-consuming processes
topk(3, sum by(process) (process_cpu_seconds_total))
```

### By vs Without

- `by`: Keep only the specified labels
- `without`: Drop the specified labels

```promql
# Group by job, dropping other labels
sum by(job) (node_cpu_seconds_total)

# Keep all labels except mode
sum without(mode) (node_cpu_seconds_total)
```

## Common PromQL Functions

### Rate Functions

For counters (metrics that only increase):

```promql
# Rate of HTTP requests over 5 minutes
rate(http_requests_total[5m])

# Increase in HTTP requests over 1 hour
increase(http_requests_total[1h])

# Per-second rate of HTTP requests over 5 minutes
irate(http_requests_total[5m])
```

### Histograms

For histogram metrics:

```promql
# 95th percentile of HTTP request durations
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))

# Average request duration
sum(rate(http_request_duration_seconds_sum[5m])) / sum(rate(http_request_duration_seconds_count[5m]))
```

### Time Functions

```promql
# Current time (seconds since epoch)
time()

# Timestamp of the day's start
day_of_month(vector(time()))

# Values from exactly 24 hours ago
http_requests_total offset 24h
```

## Best Practices

1. **Use rate() for counters**: Always use `rate()` or `increase()` for counter metrics over an appropriate time window
2. **Choose appropriate time ranges**: Shorter ranges are more precise but more affected by outliers
3. **Label carefully**: Use labels for meaningful grouping but avoid high cardinality
4. **Use aggregation**: Reduce metric cardinality with appropriate aggregations
5. **Avoid expensive operations**: Be cautious with operations like `topk` and regex matching on large datasets
6. **Test complex queries**: Start with simpler queries and build up to more complex ones

### Common Anti-patterns

❌ Using `rate()` on gauges
```promql
# Wrong: rate() on a gauge
rate(node_memory_MemFree_bytes[5m])

# Correct: just use the gauge directly
node_memory_MemFree_bytes
```

❌ Using short time windows
```promql
# Too short: susceptible to noise
rate(http_requests_total[10s])

# Better: smoother results
rate(http_requests_total[5m])
```

❌ Over-using regex matching
```promql
# Expensive: regex on high-cardinality label
http_requests_total{path=~"/api/.*"}

# Better: if possible, use more specific endpoints or pre-aggregation
```
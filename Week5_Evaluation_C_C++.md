# Week 5 Evaluation: Code Summarization / Comprehension (C and C++)

**Authors:** Basit Ali, Yiran Hu, Carter Ibach

---

## 1. Evaluation Criteria

This section defines how students can determine whether they solved the example problems correctly.

Criteria should be applicable to any problem in this topic.

* Documentation follows Doxygen format with proper tags (@brief, @param, @return, @pre, @post, @note, @warning, @tparam for templates)
* @brief provides a concise one-line summary of the function's purpose
* @param documents each parameter with its name and description of expected values/constraints (not just restating the type)
* @return clearly describes what the function returns, including edge cases (NULL, std::nullopt, etc.)
* @pre documents any preconditions that must be true before calling the function
* @post documents any postconditions guaranteed after the function completes
* Thread-safety considerations are documented where applicable
* Memory ownership and lifetime semantics are clearly explained (who allocates, who frees)
* Exception/error handling behavior is documented
* For C++ templates, @tparam documents template parameters and their requirements

---

## 2. Evaluation specifically for Example Problems

### Problem C_1: Memory Pool Allocator (C)

**Evaluation Description:**
Documentation must clearly explain the memory pool's allocation strategy (fixed-size blocks), ownership semantics, and the relationship between pool_alloc/pool_free. Each function should document preconditions (valid pool pointer) and postconditions (memory state changes).

**Applicable Guidelines:**
- **Guideline 2 (Constrain Summary Length):** @brief should be one concise sentence
- **Guideline 3 (Documentation Template):** Follow Doxygen format with @brief, @param, @return, @pre, @post
- **Guideline 4 (Document Purpose, Not Implementation):** Describe what the function does for callers, not how it works internally

**Criteria:**
- Document that blocks are fixed-size and pre-allocated
- Explain ownership: caller owns returned memory, must free via pool_free
- Include @pre/@post for state changes
- Clarify NULL return on allocation failure or exhaustion

**Good Example (with guidelines):**

```c
/**
 * @brief Creates a new memory pool with fixed-size blocks.
 *
 * Allocates and initializes a memory pool that manages a contiguous region
 * of memory divided into blocks of equal size.
 *
 * @param block_size Size in bytes of each block. Must be > 0.
 * @param block_count Number of blocks in the pool. Must be > 0.
 * @return Pointer to the created MemoryPool, or NULL if allocation fails.
 * @post Caller owns the returned pool and must call pool_destroy() to free it.
 */
MemoryPool* pool_create(size_t block_size, size_t block_count);

/**
 * @brief Allocates a single block from the memory pool.
 *
 * @param pool Pointer to the memory pool. Must not be NULL.
 * @return Pointer to the allocated block, or NULL if the pool is exhausted.
 * @pre pool must be a valid, non-destroyed MemoryPool.
 * @post Returned memory is uninitialized. Caller must call pool_free() when done.
 */
void* pool_alloc(MemoryPool* pool);
```

**Bad Example (without guidelines):**

```c
/**
 * Creates a memory pool.
 * @param block_size size_t for block size
 * @param block_count size_t for count
 * @return MemoryPool pointer
 */
MemoryPool* pool_create(size_t block_size, size_t block_count);

/**
 * Allocates from pool using a free list implementation that
 * iterates through available blocks and returns the first one.
 * @param pool the pool
 * @return void pointer
 */
void* pool_alloc(MemoryPool* pool);
```

**Why Bad Example Fails:**
- Violates **Guideline 4**: Describes implementation ("free list implementation that iterates") instead of purpose
- Violates **Guideline 3**: Missing @pre/@post tags, @param just restates types
- Missing ownership and error semantics

---

### Problem C_2: Ring Buffer (C)

**Evaluation Description:**
Documentation must explain the lock-free nature using atomics, the single-producer/single-consumer model, and the circular buffer semantics. Functions should document thread-safety guarantees and memory ordering considerations.

**Applicable Guidelines:**
- **Guideline 3 (Documentation Template):** Use @note for thread-safety guarantees
- **Guideline 4 (Document Purpose, Not Implementation):** Document the contract (SPSC model), not atomic operations used
- **Raw Guideline 5 (Exception/Thread Safety):** Thread-safety is one of the few implementation details that belongs in API docs

**Criteria:**
- Document SPSC (single-producer single-consumer) thread safety model
- Explain that ring_push is for producer thread only, ring_pop for consumer only
- Note that size/free_space values may be stale under concurrent access
- Clarify capacity vs usable space (capacity-1 due to full/empty distinction)

**Good Example (with guidelines):**

```c
/**
 * @brief A lock-free single-producer single-consumer ring buffer.
 *
 * Thread-safe for one producer thread and one consumer thread without locks.
 * Uses atomic operations for head/tail indices to ensure memory ordering.
 */
typedef struct { /* ... */ } RingBuffer;

/**
 * @brief Pushes data into the ring buffer (producer operation).
 *
 * Copies len bytes from data into the ring buffer. This operation is
 * lock-free and safe to call concurrently with ring_pop() from another thread.
 *
 * @param rb Pointer to the ring buffer. Must not be NULL.
 * @param data Pointer to the data to copy. Must not be NULL.
 * @param len Number of bytes to push.
 * @return true if data was successfully pushed, false if insufficient space.
 * @note Thread-safe for single producer. Do not call from multiple threads.
 */
bool ring_push(RingBuffer* rb, const void* data, size_t len);
```

**Bad Example (without guidelines):**

```c
/**
 * Ring buffer struct.
 */
typedef struct { /* ... */ } RingBuffer;

/**
 * Pushes data to the buffer by copying bytes to the head position
 * and incrementing head with atomic_fetch_add.
 * @param rb RingBuffer pointer
 * @param data void pointer to data
 * @param len size_t length
 * @return bool success
 */
bool ring_push(RingBuffer* rb, const void* data, size_t len);
```

**Why Bad Example Fails:**
- Violates **Guideline 4**: Describes implementation ("atomic_fetch_add") instead of thread-safety contract
- Violates **Raw Guideline 5**: Doesn't document thread-safety guarantees for users
- @param just restates types instead of constraints

---

### Problem C_3: Configuration Parser (C)

**Evaluation Description:**
Documentation must explain the INI file format support, error handling via ConfigError enum, and the getter functions' default value semantics. Section and key lookup behavior should be clearly documented.

**Applicable Guidelines:**
- **Guideline 2 (Constrain Summary Length):** Keep @brief concise, details in description
- **Guideline 3 (Documentation Template):** Use @note for ownership semantics
- **Guideline 4 (Document Purpose, Not Implementation):** Describe format support and behavior, not parsing algorithm

**Criteria:**
- Document INI format support ([sections], key=value, comments with ; or #)
- Explain default_val semantics (returned when key not found or parse fails)
- Clarify that returned strings are owned by Config (do not free)
- Document NULL section meaning (global/unnamed section)

**Good Example (with guidelines):**

```c
/**
 * @brief Loads configuration from a file path.
 *
 * Parses an INI-format configuration file. Supports [sections] and key=value pairs.
 * Lines starting with ; or # are treated as comments.
 *
 * @param filepath Path to the configuration file.
 * @param err Pointer to store error code. May be NULL if error details not needed.
 * @return Pointer to Config object, or NULL on failure (check err for details).
 * @post Caller must call config_free() to release the returned Config.
 */
Config* config_load(const char* filepath, ConfigError* err);

/**
 * @brief Retrieves a string value from the configuration.
 *
 * Looks up a key within the specified section. If the section is NULL or empty,
 * searches in the global (unnamed) section.
 *
 * @param cfg Pointer to the Config. Must not be NULL.
 * @param section Section name, or NULL for global section.
 * @param key Key name to look up. Must not be NULL.
 * @param default_val Value to return if key is not found.
 * @return The configuration value, or default_val if not found.
 * @note Returned string is owned by Config; do not free or modify it.
 */
const char* config_get_string(const Config* cfg, const char* section,
                              const char* key, const char* default_val);
```

**Bad Example (without guidelines):**

```c
/**
 * Loads config from file using fopen and parses line by line
 * with strtok to split on '=' character.
 * @param filepath char pointer
 * @param err ConfigError pointer
 * @return Config pointer
 */
Config* config_load(const char* filepath, ConfigError* err);

/**
 * Gets a string.
 * @param cfg Config pointer
 * @param section section name
 * @param key key name
 * @param default_val default value
 * @return string value
 */
const char* config_get_string(const Config* cfg, const char* section,
                              const char* key, const char* default_val);
```

**Why Bad Example Fails:**
- Violates **Guideline 4**: Describes implementation ("fopen", "strtok", "split on '='") instead of format support
- Violates **Guideline 3**: Missing @post for ownership, missing @note for memory semantics
- @brief too vague ("Gets a string" - what string? under what conditions?)

---

### Problem CPP_1: Smart Pointer with Custom Deleter (C++)

**Evaluation Description:**
Documentation must explain RAII semantics, move-only ownership model, and custom deleter support. Template parameters should be documented with @tparam. Special attention to noexcept specifications and deleted copy operations.

**Applicable Guidelines:**
- **Guideline 3 (Documentation Template):** Use @tparam for template parameters, @pre/@post for contracts
- **Guideline 4 (Document Purpose, Not Implementation):** Describe ownership semantics, not internal pointer manipulation
- **Raw Guideline 5 (Exception/Thread Safety):** Document exception safety (@exceptsafe)

**Criteria:**
- Document exclusive ownership semantics (move-only, no copying)
- Explain that deleter is invoked on destruction/reset
- Use @tparam for template parameters
- Document @pre for dereference operators (undefined if null)
- Explain release() transfers ownership to caller

**Good Example (with guidelines):**

```cpp
/**
 * @brief A smart pointer with exclusive ownership and customizable deletion.
 *
 * Similar to std::unique_ptr, UniqueHandle manages the lifetime of a dynamically
 * allocated object through RAII. When the UniqueHandle is destroyed or reset,
 * it automatically invokes the deleter on the managed pointer.
 *
 * @tparam T The type of object being managed.
 * @tparam Deleter Callable type used to destroy the object. Defaults to std::default_delete<T>.
 */
template<typename T, typename Deleter = std::default_delete<T>>
class UniqueHandle;

/**
 * @brief Releases ownership of the managed pointer.
 * @return The previously managed pointer.
 * @post get() returns nullptr. Caller is responsible for deletion.
 */
pointer release() noexcept;

/**
 * @brief Dereferences the managed pointer.
 * @return Reference to the managed object.
 * @pre get() != nullptr. Undefined behavior if empty.
 */
typename std::add_lvalue_reference<T>::type operator*() const;
```

**Bad Example (without guidelines):**

```cpp
/**
 * UniqueHandle class template for T with Deleter.
 */
template<typename T, typename Deleter = std::default_delete<T>>
class UniqueHandle;

/**
 * Releases the pointer by setting ptr_ to nullptr and returning
 * the old value using a temporary variable.
 * @return pointer type
 */
pointer release() noexcept;

/**
 * Dereferences.
 * @return T reference
 */
typename std::add_lvalue_reference<T>::type operator*() const;
```

**Why Bad Example Fails:**
- Violates **Guideline 4**: Describes implementation ("setting ptr_ to nullptr", "temporary variable")
- Violates **Guideline 3**: Missing @tparam, missing @pre/@post for contracts
- No explanation of ownership transfer or RAII semantics

---

### Problem CPP_2: Thread-Safe Event Queue (C++)

**Evaluation Description:**
Documentation must explain thread-safety guarantees, blocking vs non-blocking operations, and the close() mechanism for graceful shutdown. Timeout-based operations should document their behavior when timeout expires or queue is closed.

**Applicable Guidelines:**
- **Guideline 3 (Documentation Template):** Use @tparam, document all return conditions
- **Guideline 4 (Document Purpose, Not Implementation):** Describe blocking behavior, not mutex/condition_variable usage
- **Raw Guideline 5 (Exception/Thread Safety):** Document thread-safety for multi-producer/multi-consumer

**Criteria:**
- Document that queue is safe for multiple producers and consumers
- Distinguish blocking (pop) vs non-blocking (try_pop) operations
- Explain close() behavior: prevents new pushes, wakes waiting threads
- Document that pop returns nullopt when closed AND empty
- Clarify max_size=0 means unlimited

**Good Example (with guidelines):**

```cpp
/**
 * @brief A thread-safe bounded queue for inter-thread communication.
 *
 * EventQueue provides a producer-consumer queue with blocking and non-blocking
 * operations. Supports optional maximum size for backpressure. Safe to use
 * from multiple producer and consumer threads simultaneously.
 *
 * @tparam T Type of elements stored in the queue. Must be movable.
 */
template<typename T>
class EventQueue;

/**
 * @brief Removes and returns the front item (blocking).
 *
 * Blocks until an item is available or the queue is closed.
 *
 * @return The popped item, or std::nullopt if queue is closed and empty.
 */
std::optional<T> pop();

/**
 * @brief Closes the queue, preventing further pushes.
 *
 * Wakes all waiting threads. After closing, push operations return false.
 * Pop operations continue to work until the queue is empty.
 */
void close();
```

**Bad Example (without guidelines):**

```cpp
/**
 * Event queue template class.
 */
template<typename T>
class EventQueue;

/**
 * Pops from queue using unique_lock and condition_variable wait
 * with a lambda predicate checking closed_ and queue_.empty().
 * @return optional T
 */
std::optional<T> pop();

/**
 * Closes the queue.
 */
void close();
```

**Why Bad Example Fails:**
- Violates **Guideline 4**: Describes implementation ("unique_lock", "condition_variable", "lambda predicate")
- Violates **Raw Guideline 5**: Doesn't document thread-safety guarantees
- Missing @tparam, vague @return, doesn't explain close() semantics

---

### Problem CPP_3: LRU Cache (C++)

**Evaluation Description:**
Documentation must explain the LRU eviction policy, O(1) time complexity for get/put operations, and the internal data structure (list + hash map). Template parameters and custom hash support should be documented.

**Applicable Guidelines:**
- **Guideline 3 (Documentation Template):** Use @tparam for all template parameters including Hash
- **Guideline 4 (Document Purpose, Not Implementation):** Document eviction policy and complexity, not list splicing
- **Guideline 2 (Constrain Summary Length):** Keep @brief focused on what, details on complexity in description

**Criteria:**
- Document LRU eviction: least recently used item removed when full
- Explain O(1) complexity for get/put operations
- Note that get() updates LRU ordering, contains() does not
- Document that capacity must be > 0 (throws otherwise)
- Use @tparam for Key, Value, and Hash

**Good Example (with guidelines):**

```cpp
/**
 * @brief A fixed-capacity cache with Least Recently Used eviction policy.
 *
 * LRUCache provides O(1) average time complexity for get and put operations
 * using a combination of a doubly-linked list (for LRU ordering) and a hash
 * map (for fast key lookup). When the cache is full, the least recently
 * accessed item is automatically evicted to make room for new entries.
 *
 * @tparam Key Type of keys. Must be hashable and equality comparable.
 * @tparam Value Type of cached values.
 * @tparam Hash Hash function type for keys. Defaults to std::hash<Key>.
 */
template<typename Key, typename Value, typename Hash = std::hash<Key>>
class LRUCache;

/**
 * @brief Retrieves a value from the cache.
 *
 * If the key exists, marks it as most recently used.
 *
 * @param key Key to look up.
 * @return The cached value, or std::nullopt if not found.
 * @post If found, the entry becomes the most recently used.
 */
std::optional<Value> get(const Key& key);

/**
 * @brief Checks if a key exists in the cache.
 *
 * Does not modify LRU ordering.
 *
 * @param key Key to check.
 * @return true if the key exists, false otherwise.
 */
bool contains(const Key& key) const;
```

**Bad Example (without guidelines):**

```cpp
/**
 * LRU cache using list and unordered_map.
 */
template<typename Key, typename Value, typename Hash = std::hash<Key>>
class LRUCache;

/**
 * Gets value by finding in lookup_ map and calling touch() to
 * splice the iterator to front of items_ list.
 * @param key the key
 * @return optional Value
 */
std::optional<Value> get(const Key& key);

/**
 * Checks if key is in cache.
 * @param key the key
 * @return bool
 */
bool contains(const Key& key) const;
```

**Why Bad Example Fails:**
- Violates **Guideline 4**: Describes implementation ("lookup_ map", "touch()", "splice the iterator", "items_ list")
- Violates **Guideline 3**: Missing @tparam, missing @post for LRU ordering side effect
- Class description mentions data structures instead of behavior/guarantees

---

## 3. References

[1] Doxygen Manual: https://www.doxygen.nl/manual/docblocks.html
[2] C++ Core Guidelines: https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines
[3] LLVM Coding Standards - Doxygen Use: https://llvm.org/docs/CodingStandards.html
[4] LSST DM Developer Guide - Documenting C++ Code: https://developer.lsst.io/cpp/api-docs.html

---

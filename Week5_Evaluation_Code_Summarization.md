# Week 5 Evaluation: Code Summarization / Comprehension

**Authors:** Basit Ali, Yiran Hu, Carter Ibach

---

## 1. Evaluation Criteria
- DocStrings should match formatting of existing examples in each project
- DocStrings should match length of existing examples in each project
- DocStrings should include all critical information for code
- DocStrings should not be wordy and long

## 2. Evaluation Specifically for Problems

### Criteria for all C/C++ Problems
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

### Problem C_1: `memory_pool.h` / `memory_pool.c`

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

### Problem C_2: `ring_buffer.h` / `ring_buffer.c`

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

### Problem C_3: `config_parser.h`

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

### Problem CPP_1: `unique_handle.hpp`

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

### Problem CPP_2: `event_queue.hpp`

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

### Problem CPP_3: `lru_cache.hpp`

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

### Problem M_1: Matlab Functions

**Criteria for all Matlab Functions**
All Matlab functions should include approximately 3 lines of docstring. Initially a brief description of each input parameter, then a very short summary of what the function accomplishes, and finally a brief descrptions of the returned values.

#### buildBranches
Criteria:
- Take in starting index, flight usage, all data, current pairing, current cost, all combinations, max flight usage, max branch width, and if deadheads are allowed
- Recursively build branches of possible flight pairings
- Check all possible next flights and build new pairing for each one up to max width
- Return all created pairings with costs, and new flight usage

Good Example (with guidelines):

    % inputs: startIndex, flightUsage, numData, strData, pairing, cost, combinations, MFU, MBW, deadheads
    % does: recursively expands feasible connection branches from startIndex to build complete pairings and costs
    % outputs: pairings (legs x combos), costs (row vector), flightUsage (updated usage counts)


Bad Example (without guidelines):

    %BUILDBRANCHES  Recursively generate pairing branches.
    % Inputs: startIndex, flightUsage, numData, strData, pairing, cost, combinations, MFU, MBW, deadheads
    % Outputs: pairings, costs, flightUsage

**Why bad example fails:**
- Fails to give any description of input/returned parameters (even good example isn't perfect here)
- Description is too concise.
- This was not generated at all on the first attempt, this function was completely missed.


#### combineDuties
Criteria:
- Take pairing and its cost, index of the last flight in the pairing, set of combinations, duties, duty costs, and duties already covered
- Check what duties can be appended to the end of this pairing
- Return possibly updated pairing with cost and duties covered


Good Example (with guidelines):

    % inputs: pairing (legs x 1) — current pairing vector; cost (scalar) — current accumulated cost
    %         curIndex (scalar) — index of the duty to extend from; combinations (map) — duty -> feasible next duties
    %         duties (legs x duties) — duty coverage vectors; costs (1 x duties) — per-duty costs; dutiesCovered (vector) — indexes already used
    % does: recursively combine compatible duties (per `combinations`) into a single pairing and sum costs
    % outputs: pairing — updated pairing vector; cost — updated total cost; dutiesCovered — updated index list


Bad Example (without guidelines):

    %COMBINEDUTIES Recursively combine compatible duties into a pairing
    %   [pairing,cost,dutiesCovered] = COMBINEDUTIES(pairing,cost,curIndex,combinations,...) 
    %   attempts to append compatible duties (from `combinations`) to `pairing`
    %   and accumulates cost and covered-duty indices.
    %
    % Inputs
    %   pairing, duties    - column vectors indicating legs covered
    %   cost               - scalar cost for the `pairing` so far
    %   curIndex           - current duty index to consider
    %   combinations       - dictionary mapping duty -> feasible next duties
    %   costs              - 1xD vector of duty costs
    %   dutiesCovered      - vector of already-covered duty indices
    %
    % Outputs
    %   pairing, cost, dutiesCovered - updated pairing, cost and covered list
    %
    % Example
    %   [p,c,dc] = combineDuties(p,c,1,combinations,duties,costs,[]);

**Why bad example fails:**
- Far too long docstring
- Unnecessary information such as repeating header, and example of call


#### dutiestoPairings
Criteria:
- Take set of flight duties, costs, and all numeric data
- Find duties to combine to create pairings
- Use criteria from external case to identify combinable duties
- Return final pairings from duties with pairing costs


Good Example (with guidelines):

    % inputs: duties (legs x duties), costs (1 x duties), numData (legs x 4)
    % does: converts duty-level schedules into leg-based pairings by combining duties where feasible
    % outputs: finalPairings — matrix (legs x pairings); finalCosts — row vector of pairing costs


Bad Example (without guidelines):

    %DUTIESTOPAIRINGS Convert duty-based solutions into leg-based pairings
    %   [finalPairings,finalCosts] = DUTIESTOPAIRINGS(duties,costs,numData)
    %   converts duties (blocks of legs) into final pairing vectors and costs
    %   adjusted to the numeric `numData` indexing/format.
    %
    % Inputs
    %   duties   - MxD matrix, each column is a duty (legs covered)
    %   costs    - 1xD vector of costs for each duty
    %   numData  - Nx4 numeric flight data used to compute duty spans
    %
    % Outputs
    %   finalPairings - NxK matrix of pairings covering legs
    %   finalCosts    - 1xK vector of costs corresponding to finalPairings
    %
    % Example
    %   [fp,fc] = dutiestoPairings(duties,costs,numData);

**Why bad example fails:**
- Far too long docstring
- Unnecessary information such as repeating header, and example of call

#### findCombinations
Criteria:
- Take in all data, max # overnights, max layover time
- Return dictionary of feasible flight connections


Good Example (with guidelines):

    % inputs: numData, strData, overnights, maxLayover — flight numeric/string data, overnight flags, max layover (minutes)
    % does: finds all feasible downstream connections for each leg using isFeasibleCombo
    % outputs: combinations — dictionary mapping leg index -> vector of feasible destination indices


Bad Example (without guidelines):

    %FINDCOMBINATIONS Build feasible-next-leg mapping for each flight
    %   combinations = FINDCOMBINATIONS(numData,strData,overnights,maxLayover)
    %   returns a dictionary where key i maps to a vector of leg indices
    %   that are feasible immediate connections from leg i.
    %
    % Inputs
    %   numData    - Nx4 numeric matrix: [date, starttime, endtime, duration]
    %   strData    - NxM cell/string array with airport/location info
    %   overnights - allowed overnight gap (days)
    %   maxLayover - maximum same-day layover (minutes)
    %
    % Outputs
    %   combinations - dictionary mapping leg index -> vector of feasible next indices
    %
    % Example
    %   comb = findCombinations(numData,strData,1,240);

**Why bad example fails:**
- Far too long docstring
- Unnecessary information such as repeating header, and example of call

#### fixTimeZone
Criteria:
- Take in all numeric data
- Adjust time zone by 4 hours
- Adjust day if time is now negative
- Return updated numeric data


Good Example (with guidelines):

    % inputs: numData (Nx4) — [date, starttime, endtime, duration] in original timezone
    % does: shifts times by -240 minutes (timezone adjustment) and normalizes day/start/end
    % outputs: newData (Nx4) — timezone-corrected [date, starttime, endtime, duration]


Bad Example (without guidelines):

    %FIXTIMEZONE Adjust numeric flight times for timezone offset
    %   newData = FIXTIMEZONE(numData) subtracts a 240-minute timezone offset
    %   from start/end times and adjusts the travel day when needed.
    %
    % Inputs
    %   numData  - Nx4 numeric matrix: [date, starttime, endtime, duration]
    %
    % Outputs
    %   newData  - Nx4 numeric matrix with adjusted [date, starttime, endtime, duration]
    %
    % Example
    %   nd = fixTimeZone(numData);


#### isFeasibleCombo
Criteria:
- Take numeric and string data for both flights, max # overnights, and max layover
- Identify if possible for crew to work both flights using provided external constraints
- Return true if none of failing criteria met


Good Example (with guidelines):

    % inputs: nData1,nData2 (1x4) and sData1,sData2 (1x2) — numeric/string flight data for two legs; overnights, maxLayover (scalars)
    % does: returns whether leg2 is a feasible connection after leg1 (checks airport, layover, duty limits, overnight rules)
    % outputs: possible (logical) — true if the two legs can be legally paired


Bad Example (without guidelines):

    %ISFEASIBLECOMBO Check whether two flight legs can form a feasible connection
    %   possible = ISFEASIBLECOMBO(nData1,sData1,nData2,sData2,overnights,maxLayover)
    %   returns true if leg2 can follow leg1 subject to layover and overnight rules.
    %
    % Inputs
    %   nData1, nData2   - 1x4 numeric rows: [date, starttime, endtime, duration]
    %   sData1, sData2   - string/cell with airport names for the legs
    %   overnights       - integer allowed overnight gap (in days)
    %   maxLayover       - max allowed same-day layover in minutes
    %
    % Outputs
    %   possible - logical true if connection is allowed
    %
    % Example
    %   ok = isFeasibleCombo(n1,s1,n2,s2,1,240);

**Why bad example fails:**
- Far too long docstring
- Unnecessary information such as repeating header, and example of call

#### makePairings
Criteria:
- Take in all numeric and string data, feasible combinations, max flight usage, max branch width, and if deadheads are allowed
- Create pairings starting with each possible starting flight
- Return set of all possible pairings and costs for each pairing


Good Example (with guidelines):

    % inputs: numData, strData, combinations, MFU, MBW, deadheads — dataset, connection map, and numeric limits/flags
    % does: enumerates feasible pairings by seeding valid starts and expanding branches (calls buildBranches)
    % outputs: pairings — matrix (legs x combos) of coverage; costs — row vector of corresponding pairing costs


Bad Example (without guidelines):

    %MAKEPAIRINGS Generate candidate pairings and their costs from flight data
    %   [pairings,costs] = MAKEPAIRINGS(numData,strData,combinations,MFU,MBW,deadheads)
    %   builds pairing candidates (columns indicate legs included) and
    %   associated costs using connectivity constraints and parameters.
    %
    % Inputs
    %   numData      - Nx4 numeric matrix: [date, starttime, endtime, duration]
    %   strData      - NxM cell/string array with airport codes/strings
    %   combinations - dictionary mapping leg index -> feasible next-leg indices
    %   MFU, MBW     - numeric parameters controlling pairing generation
    %   deadheads    - integer, allowed deadhead count
    %
    % Outputs
    %   pairings - MxP matrix where each column is a pairing (legs covered)
    %   costs    - 1xP vector of costs for each pairing
    %
    % Example
    %   [p,c] = makePairings(numData,strData,combinations,inf,inf,0);

**Why bad example fails:**
- Far too long docstring
- Unnecessary information such as repeating header, and example of call

#### readData
Criteria:
- Take in filename
- Read in data and convert dates, times to minutes, and string data for flight data
- Return separated string and numeric data


Good Example (with guidelines):

    % inputs: fileName (string) — Excel file (e.g. 'flightLegs.xlsx') containing flight-leg rows
    % does: reads Excel and converts date/time strings to numeric arrays and extracts location strings
    % outputs: numData (Nx4) — [date, starttime, endtime, duration]; strData (Nx2) — [start, end] (locations)


Bad Example (without guidelines):

    %READDATA  Load flight spreadsheet into numeric and string matrices.
    % Inputs: fileName
    % Outputs: numData, strData

**Why bad example fails:**
- Gives no description of input parameters or return values
- Docstring initially not generated, function was missed completely
- Should mention location string specifically, that is important

#### reorderPairings
Criteria:
- Take in matrix of pairings, costs, and number to break up into
- Return new sets of pairings and costs split into provided number of sections, with list of section breakpoints

Good Example (with guidelines):

    % inputs: pairings (legs x combos), costs (1 x combos), newNumMatrices (scalar) — desired grouping width
    % does: reorders existing pairing columns into `newNumMatrices`-wide blocks and computes breakpoints
    % outputs: newPairings, newCosts — reordered matrices; breakPoints — start indices of each new block


Bad Example (without guidelines):

    %REORDERPAIRINGS Redistribute pairings into new matrix-grouping order
    %   [newPairings,newCosts,breakPoints] = REORDERPAIRINGS(pairings,costs,newNumMatrices)
    %   reorganizes columns of `pairings`/`costs` so they form `newNumMatrices`
    %   groups and returns break-point indices for each new group.
    %
    % Inputs
    %   pairings       - MxP logical/numeric matrix (legs x pairings)
    %   costs          - 1xP vector of pairing costs
    %   newNumMatrices - scalar number of pairings-per-group for reordering
    %
    % Outputs
    %   newPairings  - MxP reordered pairings
    %   newCosts     - 1xP reordered costs
    %   breakPoints  - 1x(newNumMatrices+1) indices marking group boundaries
    %
    % Example
    %   [np,nc,bp] = reorderPairings(pairings,costs,8);

**Why bad example fails:**
- Far too long docstring
- Unnecessary information such as repeating header, and example of call

#### timeStringtoMinutes
Criteria:
- Take in string of time in 24 hour format
- Convert to number of minutes, with 00:00 as 0 minutes

Good Example (with guidelines):

    % inputs: timeString — time string(s) in "HH:mm" format (string or cellstr)
    % does: parses HH:mm values and converts them to numeric minutes
    % outputs: minutes — column vector of minutes for each input time


Bad Example (without guidelines):

    %TIMESTRINGTOMINUTES Convert HH:mm time string(s) to minutes
    %   minutes = TIMESTRINGTOMINUTES(timeString) converts a single time
    %   string or a column of time strings in format 'HH:mm' to numeric
    %   minutes since midnight.
    %
    % Inputs
    %   timeString - char array or string array (Nx1) with format 'HH:mm'
    %
    % Outputs
    %   minutes    - numeric scalar or Nx1 vector of minutes
    %
    % Example
    %   m = timeStringtoMinutes("09:30");

**Why bad example fails:**
- Far too long docstring
- Unnecessary information such as repeating header, and example of call

### Criteria for all React ###
- Should indicate what props are accepted and what each one means
- Should briefly describe what is rendered with this component
- If certain fields or data points are shown, should indicate which (critical for expanded vs collapsed)
- Should be easy to read
- Don't focus on backend API calls

### Problem R_1: Landlord Profile ###

#### Edit Landlord Profile ####
Criteria:
- Form to edit landlord profile info (first name, last name, phone, not email)
- Item: dictionary with landlord info
- handleChangeMode: function reverting to profile view
- userID: landlord user id
- getProfile: function to refresh profile info


Good Example (with guidelines):

    Renders a form allowing a landlord to edit their profile (first name, last name, phone).
    item: object containing current profile fields { first_name, last_name, phone }
    handleChangeMode: function to toggle edit/view mode in parent
    userID: id of the current landlord
    getProfile: function to refresh profile data after a successful save


Bad Example (without guidelines):

    EditLandlordProfile Component
    
    Renders a form that allows a landlord to edit their profile information
    (first name, last name, phone). Accepts an `item` prop containing the
    current profile values and calls the backend API to persist changes.
    Props: { item, handleChangeMode, userID, getProfile } — `getProfile` is
    invoked after a successful save to refresh the parent view.

**Why bad example fails:**
- Gives no description of multiple props accepted
- Structure not easily readable
- Too much focus on API calls


#### Landlord Profile ####
Criteria:
- Landlord’s profile information or edit screen with:
- Name, email, phone number


Good Example (with guidelines):

    Renders the landlord profile page with navigation and an editable profile card.
    Props: none
    - uses UserContext to obtain `userId` for API calls
    - toggles Edit mode and mounts `EditLandlordProfile` for inline editing

Bad Example (without guidelines):

    LandlordProfile Component
    
    Parent view for landlord profile management. Fetches and displays the
    landlord's profile (name, email, phone), provides navigation for landlord
    actions (Add Posting, My Units), and toggles into an edit mode that
    mounts `EditLandlordProfile` for inline editing. Uses `UserContext` to
    determine the current user and calls the backend to retrieve/update data.

**Why bad example fails:**
- Gives no description of multiple props accepted
- Structure not easily readable
- All components use UserContext in the same way, not useful in this component

### Problem R_2: Search Units ###

#### Interested List ####
Criteria:
- List of renters interested in a unit
- unitID: id of the unit renters interested in
- userID: id of current user

Good Example (with guidelines):

    Renders a list of renters who expressed interest in a unit.
    unitID: posting id for the unit
    userId: current user's id (used for API filtering/context)


Bad Example (without guidelines):

    InterestedList Component
    
    Displays a list of renters who have expressed interest in a specific rental unit.
    Fetches interested renters from the backend API using the unit's posting ID and current user's ID.
    Only renders the list if there are interested renters, displaying them in a styled container
    with a purple header and utilizing the RenterList component for rendering individual renter profiles.

**Why bad example fails:**
- Gives no description of multiple props accepted
- Structure not easily readable
- Too much focus on API calls
- Describes colours and styles which are not important

#### ListUnits ####
Criteria:
- List of units which can be expanded, and list of renters interested in last expanded unit
- Units: list of unit objects to display
- userID: id of the current user

Good Example (with guidelines):

    Renders a list of units with single-unit expand/collapse behavior.
    units: array of unit objects to display
    userId: current user's id (used for interest/favourite actions)

Bad Example (without guidelines):

    ListofUnits Component
    
    Manages and displays a list of rental units with expandable/collapsible functionality.
    Shows "No Results" message when no units are available. Allows users to expand a single unit
    at a time to view detailed information including landlord contact details and pricing.
    When a unit is expanded, also displays the InterestedList showing renters interested in that unit.
    Coordinates between ExpandedUnitInfo and UnexpandedUnitInfo components to toggle unit display states.

**Why bad example fails:**
- Gives no description of multiple props accepted
- Structure not easily readable
- Too much detail for what is shown, can be more concise


#### SearchMenuUnits ####
Criteria:
- Search menu for user to find units
- How to sort, price range, bedrooms range, bathrooms range, and favourites only all selectable
- setUnitList: function settling list of units
- setUnitMode: function to switch to list display
- setAlertVisible: set an alert to visible
- setAlertMessage: set messages of alerts
- userID: id of current user


Good Example (with guidelines):

    This component renders the search & filter UI for units (sorting, price/bed/bath ranges,
    "Only Show Favourites" toggle) and validates inputs before requesting filtered results.
    Key UI elements shown: sort options, min/max price, min/max bedrooms, min/max bathrooms, reset button, validation alerts, "Only Show Favourites" checkbox.
    setUnitList: function to update parent with filtered units
    setUnitMode: function to switch parent view into unit-list mode
    setAlertVisible: function to show/hide validation alerts in parent
    setAlertMessage: function to set the alert text in parent
    userId: current user's id (included in filter API request for favourites/permissions)

Bad Example (without guidelines):

    SearchMenuUnits Component
    
    Provides a comprehensive search and filter interface for rental units.
    Features include: sorting options (oldest/newest, price ascending/descending),
    filtering by price range, number of bedrooms, and number of bathrooms.
    Includes validation to ensure maximum values exceed minimum values and displays
    appropriate error alerts. Offers a "Reset Filters" button to clear all selections
    and an "Only Show Favourites" checkbox to filter units the user has marked as interested.
    Calls the backend API with all filter parameters and updates the parent component's unit list.

**Why bad example fails:**
- Gives no description of multiple props accepted
- Structure not easily readable
- Too much detail for what is shown, can be more concise
- Description of text of buttons, and error alerts not useful

#### UnitInfoBoth ####
- Separate comment block for each component in file

ExpandedUnitInfo:
- Expanded view of unit
- Address, # bedrooms, # bathrooms, price/person, landlord contact info, if favourited by user
- Unit: dictionary with unit info
- unExpandUnit: function to collapse view
- userID: id of current user

UnExpandedUnitInfo:
- Collapsed view of unit’s info
- Address and if user has favourited unit
- Unit: dictionary with unit info
- expandUnit: function to expand view
- userID: id of current user

Good Example (with guidelines):

First Component

    This component renders the expanded unit details view (full address, # bedrooms, # bathrooms,
    per-person price, total price, and landlord contact) and a favourite/unfavourite control.
    unit: object containing unit details shown (posting_id, address, rooms, bathrooms, apt_price, phone, email, ...)
    unExpandUnit: function to collapse/hide the expanded view
    userId: current user's id (used for interest/favourite API calls)

Second Component

    Renders condensed unit info (address + favourite button).
    unit: object with unit details
    expandUnit: function to expand this unit's view
    userId: current user's id (used for interest/favourite API calls)



Bad Example (without guidelines):


    UnitInfoBoth Component
    
    Contains two exported components for displaying rental unit information:
    
    1. ExpandedUnitInfo: Shows complete unit details including address, number of bedrooms/bathrooms,
        pricing (per person and total), landlord contact information (phone and email), and a
        favourite/unfavourite button. Checks the user's interest status on mount and provides
        functionality to toggle interest. Includes a "Hide Details" button to collapse the view.
    
    2. UnexpandedUnitInfo: Shows condensed unit information with only the address and
        favourite/unfavourite button. Includes a "See Details" button to expand the view.
    
    Both components manage interest state independently, calling backend APIs to check and
    update whether the current user has marked the unit as a favourite.

**Why bad example fails:**
- Gives no description of multiple props accepted
- Put both component comments into same docstring
- Weirdly specific on description of what is included
- Information about what both do is unnecessary


### Problem P_1: Python Summary ###
Criteria:
- Organize the file summaries in a systematic and coherent manner rather than listing each file’s functionality in isolation.
- Describe the inputs and outputs, and provide an overall summary of the module’s functionality.

Good Example (with guidelines):

- The plm_retrieval package implements a PLM-based retrieval pipeline: data loading & batching, a pretrained-language-model wrapper for scoring, utilities for training/checkpointing, a distributed training entrypoint, and evaluation/inference scripts. Inputs are dataset files (text, query-document pairs, labels) and PLM checkpoints; outputs are trained model checkpoints, retrieval scores, and evaluation metrics.
- Core utilities
  - utils.py
Inputs: runtime args, model objects, optimizer, dataloaders, file paths, random seeds.
Outputs: saved checkpoints, log messages, helper return values (metrics, paths).
Responsibility: generic helpers (logging, checkpoint save/load, seed setting, small I/O and metric wrappers) used across training and evaluation.
  - Basic.py
Inputs: configuration values/constants, possibly simple objects passed by other modules.
Outputs: shared constants, small helper classes/structs.
Responsibility: lightweight shared abstractions and constants to avoid duplication.
- Data & preprocessing
  - MuserDataset.py
Inputs: dataset files (json/csv/txt), tokenizer or tokenization config, dataset split flags.
Outputs: items for indexing by PyTorch DataLoader (raw/tokenized examples, labels, metadata).
Responsibility: read/parse raw data, convert to example objects, handle indexing and dataset-level preprocessing.
  - MuserFormatter.py
Inputs: batch of raw/tokenized examples from MuserDataset, tokenizer/pad settings.
Outputs: batched tensors (input ids, attention masks, token type ids, label tensors) and any required masks/indices.
Responsibility: collate function / batch formatting, padding, packing multiple inputs into model-ready tensors.
Model
  - MuserPLM.py
Inputs: pretrained model id/path (e.g., HuggingFace name), tokenized input tensors from formatter, training/eval flags.
Outputs: logits/scores, loss tensor (during training), pooled embeddings (if used), model state for saving.
Responsibility: load PLM backbone, implement forward pass, compute losses and scoring logic specific to retrieval task (pairwise/listwise/scoring head), expose save/load hooks.
- Training & distributed runtime
  - distributed.py
Inputs: CLI args (model path, batch size, learning rate, epochs, GPU list, main_rank, workers, output path), environment for torch.distributed.
Outputs: trained model checkpoints in output_path, training logs, optional progress/metrics per epoch.
Responsibility: parse args, initialize distributed process group, build model/dataset/dataloaders/optimizer/scheduler, run training loop with gradient sync, evaluate and checkpoint.
  - train.sh
Inputs: environment variables / hard-coded settings inside script (WORKING_DIR, GPUS_PER_NODE, MODEL_PATH, BATCH_SIZE, LR, EPOCHS, OUTPUT_PATH).
Outputs: launches distributed.py via python -m torch.distributed.launch which produces checkpoints and logs.
Responsibility: example launcher that composes CLI options and starts multi-GPU distributed training.
Evaluation & inference
  - test.py
Inputs: trained checkpoint path, test/validation data files, tokenizer/model config, evaluation options.
Outputs: retrieval scores for queries, evaluation metrics (MAP, nDCG, precision/recall), and result files (ranked lists).
Responsibility: load checkpoint, run model in inference mode over dataset, compute and export metrics and ranked results.
- How the pieces interact (high level flow)
Data files -> MuserDataset -> batches via MuserFormatter -> fed to MuserPLM.
distributed.py wires dataset + model + optimizer, runs training, uses utils/Basic for checkpointing/logging.
After training, test.py loads checkpoints and produces retrieval output and metrics.
train.sh is a convenience script to launch the distributed training flow.

Bad Example (without guidelines):

    % Basic.py — core utilities and small abstractions used across the PLM code (common constants, simple helper classes, possibly a base Trainer or config loader).

    % distributed.py — distributed training entrypoint. Parses CLI options, initializes torch.distributed, builds model/dataset/dataloaders, runs the training loop and checkpointing across multiple GPUs/nodes.

    % MuserDataset.py — dataset loader: reads input files, preprocesses examples, tokenizes texts, implements __len__ / __getitem__ for PyTorch DataLoader.

    % MuserFormatter.py — batching and collation logic: converts raw dataset items into model-ready tensors (attention masks, token ids, labels), handles padding and any special input formatting used by the PLM.

    % MuserPLM.py — model wrapper around a pretrained language model: loads the backbone (via transformers), defines forward pass, scoring/loss computation, and any task-specific heads or pooling.

    % test.py — evaluation / inference script: loads a checkpoint, runs model inference on validation/test splits, produces retrieval scores and invokes metric computations (e.g., MAP, nDCG) or exports results.

    % train.sh — example shell launcher that prepares options and calls python -m torch.distributed.launch to run distributed.py with multi-GPU settings and output/checkpoint path.

    % utils.py — misc utilities: logging, seed setting, checkpoint save/load, metric helpers, and small I/O helpers used by training and evaluation.





### Problem P_2: Repository Summary  ###
Criteria:
- Specify the entry file and explain its role in the system.
- Classify all files appropriately and clearly identify their inputs and outputs.
- Provide a dependency list. 


Good Example (with guidelines):

- Purpose: implementations and experiments for document retrieval using classical IR baselines and pretrained language models (PLMs), plus tools for dataset generation, labeling and evaluation.

- Classic baselines:
  - solve_tfidf.py — TF–IDF retrieval pipeline.
  - solve_bm25.py — BM25 retrieval pipeline.
  - lmir.py / solve_lmir.py — language-model-based IR (LMIR) implementation and solver.

- Data preparation & labels:
  - gen_corpus.py — corpus generation / preprocessing.
  - solve_labels.py — create or apply relevance labels for training/eval.

- Evaluation:
  - metrics.py — retrieval metrics (e.g., precision/recall, MAP, nDCG).

- PLM-based retrieval:
  - plm_retrieval contains dataset, model and training utilities:
    - `MuserDataset.py`, `MuserFormatter.py` — dataset loading and batching/formatting for PLMs.
    - `MuserPLM.py` — model wrapper / forward logic for the PLM retrieval model.
    - `Basic.py`, `utils.py` — helper utilities.
    - `distributed.py` — distributed training entry point using PyTorch.
    - `test.py` — evaluation/inference for the PLM model.
    - `train.sh` — example shell launcher that runs `distributed.py` with `torch.distributed.launch` and writes checkpoints to an output path.

- Outputs: retrieval results, evaluation reports, and model checkpoints (e.g., `checkpoints_more/` in the training script).
- Brief dependency list (recommended)
Python: 3.8+
Core numeric / utils: numpy, pandas, scipy, tqdm
ML / DL:
torch (PyTorch) — required for model training and torch.distributed
transformers — PLM models & tokenizers
tokenizers (optional, if used separately)
Retrieval / IR:
scikit-learn (TF–IDF, metrics helpers)
gensim or rank_bm25 (BM25 / classical IR utilities) — at least one
faiss (optional, for ANN indexing / large-scale retrieval)
Text processing / NLP: nltk or jieba (depending on language), sentencepiece (if model requires)
Evaluation / tooling:
pytrec_eval (optional, for standard IR metrics)
Dev / distributed extras (optional but common):
accelerate or apex (optional optimization/FP16)
NCCL, CUDA drivers (for multi-GPU training)



Bad Example (without guidelines):

    % Implementations and experiments for document retrieval using classical IR baselines and pretrained language models (PLMs), plus tools for dataset generation, labeling and evaluation.

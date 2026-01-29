# Week 5 Raw Guidelines: Code Summarization / Comprehension

**Authors:** Basit Ali
**Readings:**   
- Few-shot training LLMs for project-specific code-summarization (Ahmed & Devanbu)
- Automatic Semantic Augmentation of Language Model Prompts - ASAP (Ahmed et al.)
- Automatic Code Summarization via ChatGPT: How Far Are We? (Sun et al.)
- What You Need is What You Get: Theory of Mind for an LLM-Based Code Understanding Assistant (Richards & Wessel)
- Icing on the Cake: Automatic Code Summarization at Ericsson (Sridhara et al.)
- Can Large Language Models Serve as Evaluators for Code Summarization? (Wu et al.)
- Is Multi-Agent Debate (MAD) the Silver Bullet? (Chun et al.)

---

## 1. Guidelines from Readings

> **Note:** Guidelines should be actionable, specific, and usable during real coding tasks.

### Guideline 1: Provide Training Examples and details from the Same Project

**Description:**  
When prompting an LLM to summarize code, include 5-10 example function-summary pairs from the same project or codebase. Retrieve these examples from version control history to ensure temporal validity. Providing details such as function name, or repository name can also aid when the code may seem versatile.

**Reasoning:**  
Ahmed & Devanbu found that same-project few-shot prompting improved performance by approximately 12.5% over cross-project examples. Project-specific identifiers, naming conventions, and coding styles are highly valuable context that LLMs can leverage effectively. Zero-shot and one-shot approaches performed poorly—the model needs about 10 examples to understand the code→comment mapping for a specific project [1]. The ASAP paper found that repository information was the single most impactful component in their ablation study, contributing significantly to BLEU score improvements across all languages tested. This context helps the LLM understand the domain and purpose of the code [2].

**Example (C++):**  
```
// Example from same project:
// Function: calculate_checksum(const uint8_t* data, size_t len)
// Summary: Computes CRC32 checksum for the given byte buffer.

// Now summarize this function:
uint32_t validate_packet(const Packet& pkt) {
    if (pkt.header.magic != MAGIC_NUMBER) return 0;
    return calculate_checksum(pkt.payload, pkt.length);
}
```

### Guideline 2: Instruct the LLM to Generate Concise Summaries with specific wording

**Description:**  
Explicitly request summaries under a specific word count (e.g., "Summarize in under 20 words" or "Generate a one-sentence summary").

**Reasoning:**  
Sun et al. found that ChatGPT tends to generate verbose summaries that, while semantically rich, perform poorly on n-gram metrics like BLEU because they differ significantly from typical ground-truth labels. The Ericsson study confirmed that a simple "WordRestrict" prompt (asking for <20 words) performed as well as or better than complex ASAP-style prompting [3, 5]. This also works to replace instructions such as "Ignore error handling" which has been shown to cause issues such as in the Ericsson paper [5]

**Example:**  
```
// Prompt: Summarize this function in one sentence (max 15 words):
void quicksort(int arr[], int low, int high) {
    if (low < high) {
        int pi = partition(arr, low, high);
        quicksort(arr, low, pi - 1);
        quicksort(arr, pi + 1, high);
    }
}
// Good: "Recursively sorts an array using the quicksort partitioning algorithm."
// Bad: "This function implements the quicksort algorithm, which is a divide-and-conquer sorting algorithm that works by selecting a pivot element and partitioning the array..."
```

---

### Guideline 3: Provide an Explicit Structure to Follow

**Description:**  
When generating docstrings or structured documentation, provide a template showing the expected format (e.g., @brief, @param, @return for Doxygen).

**Reasoning:**  
LLMs perform better when given explicit output structure. The Theory of Mind paper noted that formatting preferences significantly affected user satisfaction—users often preferred structured output over prose paragraphs [4]. Providing a template ensures consistency.

**Example (C++ Doxygen):**  
```
Generate documentation in this format:
/**
 * @brief [One-line description]
 * @param [param_name] [Description]
 * @return [Description of return value]
 */

Function to document:
int binary_search(const int* arr, int size, int target);
```

---

### Guideline 6: Tag Identifiers When Types Are Not Clearly Stated

**Description:**  
For dynamically-typed sections or unclear identifiers, annotate variables with their types in the prompt context.

**Reasoning:**  
ASAP showed that tagged identifiers (explicitly marking types and roles of variables) improved LLM comprehension, particularly for code where type information isn't immediately apparent from syntax. This provides semantic "lemmas" that help the LLM reason about the code [2].

**Example (C with unclear types):**  
```
Context: 
- ctx is a ConnectionContext struct containing socket_fd (int) and buffer (char*)
- flags is a bitmask of CONN_FLAGS (defined in connection.h)

Summarize:
int send_data(void* ctx, int flags, const char* data, size_t len);
```

---

### Guideline 8: Break Large Code into Smaller Sections Before Summarizing

**Description:**  
For functions longer than ~50 lines or files with multiple logical sections, decompose the code and summarize sections individually before generating an overall summary.

**Reasoning:**  
Shorter programs are easier to summarize accurately. The few-shot papers showed diminishing returns on very long functions. Breaking complex code into logical units allows the LLM to capture details that might be lost in a single-pass summary of large code blocks [1, 3].

**Example:**  
```
// For a 200-line function:
// Step 1: Summarize initialization (lines 1-30)
// Step 2: Summarize main processing loop (lines 31-150)  
// Step 3: Summarize cleanup/return (lines 151-200)
// Step 4: Combine into overall summary
```

---

## 2. Guidelines from Grey Literature (Practitioner/Developer Tool Blogs)

> **Note:** Guidelines sourced from GitHub Copilot documentation, Doxygen best practices, and industry blogs.

### Guideline 1: Keep Relevant Files Open for Context

**Description:**  
When using GitHub Copilot or similar tools, keep related header files, interface definitions, and dependent code files open in your editor tabs.

**Reasoning:**  
GitHub's documentation states that Copilot uses context from open tabs to inform suggestions. For C/C++, the C++ extension automatically includes directly-referenced header files for context. This reduces hallucinations and provides more relevant suggestions [GitHub Changelog, Aug 2024].

**Example:**  
```
// When generating docs for implementation.cpp, have these open:
// - interface.h (class declarations)
// - types.h (custom type definitions)
// - config.h (constants and macros)
```

---

### Guideline 2: Use Doxygen @brief for One-Line Summaries

**Description:**  
Always start C/C++ documentation blocks with a @brief tag containing a single-line summary that ends with a period.

**Reasoning:**  
Doxygen uses the @brief description for tooltips, member overviews, and search results. The LSST documentation standard and Doxygen manual emphasize that brief summaries should fit on one line and not reference variable names [Doxygen Manual, LSST Developer Guide].

**Example:**  
```cpp
/**
 * @brief Computes the factorial of a non-negative integer.
 * 
 * Uses iterative multiplication to avoid stack overflow for large inputs.
 * Returns 1 for n=0 by mathematical convention.
 *
 * @param n Non-negative integer to compute factorial for
 * @return The factorial of n, or -1 if n is negative
 */
long long factorial(int n);
```

---

### Guideline 3: Document the Purpose, Not the Implementation

**Description:**  
Focus summaries on what the function accomplishes (its contract with callers) rather than how it works internally.

**Reasoning:**  
Visual Studio Magazine's documentation guide emphasizes that API documentation should describe purpose, parameters, and return values—not design decisions or implementation details (unless warning about performance/security). Implementation details belong in inline comments, not docstrings [Visual Studio Magazine].

**Example:**  
```cpp
// BAD: "Iterates through the array using a for loop and compares each element"
// GOOD: "Searches for a target value in a sorted array using binary search"

/**
 * @brief Searches for a target value in a sorted array.
 * 
 * @param arr Pointer to sorted integer array
 * @param size Number of elements in array
 * @param target Value to search for
 * @return Index of target if found, -1 otherwise
 */
int binary_search(const int* arr, int size, int target);
```

---

### Guideline 4: Include @param Descriptions That Explain Purpose, Not Type

**Description:**  
Parameter documentation should explain what the parameter represents and any constraints, not just restate the type.

**Reasoning:**  
The type is already visible in the signature. Documentation standards (NIU, LSST) explicitly state that @param should explain meaning and constraints. For C++, since it's strongly typed, there's no need to describe types—focus on semantics [NIU Documentation Standards].

**Example:**  
```cpp
// BAD:
// @param buffer A char pointer

// GOOD:
// @param buffer Pre-allocated output buffer; must have capacity for at least max_len bytes

/**
 * @brief Reads data from the serial port into a buffer.
 *
 * @param buffer Pre-allocated output buffer; must have capacity for at least max_len bytes
 * @param max_len Maximum number of bytes to read
 * @param timeout_ms Read timeout in milliseconds; 0 for non-blocking
 * @return Number of bytes actually read, or -1 on error
 */
int serial_read(char* buffer, size_t max_len, int timeout_ms);
```

---

### Guideline 5: Document Exception Safety and Thread Safety

**Description:**  
For C++ functions, include @exceptsafe and note whether the function is thread-safe when relevant.

**Reasoning:**  
The LSST C++ documentation standard requires @exceptsafe tags describing the guarantee level (no-throw, strong, basic). Visual Studio Magazine notes that thread-safety and logging behavior are among the few implementation details that belong in API docs [LSST, Visual Studio Magazine].

**Example:**  
```cpp
/**
 * @brief Atomically increments the reference count.
 *
 * @exceptsafe No-throw guarantee.
 * @note Thread-safe; uses atomic operations internally.
 */
void add_ref() noexcept;
```

---

### Guideline 6: Use Comments to Help Copilot, Not Just Humans

**Description:**  
Add comments describing intent before complex logic blocks—these help both human readers and AI tools generate better suggestions.

**Reasoning:**  
GitHub's blog on legacy code documentation states: "Comments don't just help humans, they help Copilot too. The more your code is documented, the better Copilot can understand it and provide relevant suggestions" [GitHub Blog, Jan 2025].

**Example:**  
```cpp
// Calculate the optimal buffer size based on system page size
// and user-requested minimum, rounding up to page boundary
size_t calculate_buffer_size(size_t requested_min) {
    size_t page_size = sysconf(_SC_PAGESIZE);
    return ((requested_min + page_size - 1) / page_size) * page_size;
}
```

---

## 3. Guidelines from LLMs

> **Note:** Guidelines generated by prompting Claude, GPT-4, and Gemini with: "What are best practices for using LLMs to generate code summaries and documentation for C/C++ code?"

### Guideline 1: Specify the Target Audience

**Description:**  
Indicate whether the summary is for API consumers, maintainers, or beginners, and adjust detail level accordingly.

**Reasoning:**  
LLMs can tailor output complexity based on audience specification. A summary for library users differs from one for contributors debugging internals.

**Example:**  
```
// For API users:
"Summarize this public function for library consumers who won't read the implementation"

// For maintainers:
"Summarize this function for developers who will need to modify or debug it"
```

---

### Guideline 2: Request Both Brief and Detailed Descriptions

**Description:**  
Ask the LLM to generate both a one-line @brief and a detailed paragraph, then select appropriate level for context.

**Reasoning:**  
Having both levels allows flexible documentation. The brief serves tooltips and quick reference; detailed serves full documentation pages.

**Example:**  
```
Generate documentation with:
1. A one-line brief description (max 10 words)
2. A detailed description (2-3 sentences explaining behavior, edge cases, and usage)

void* memory_pool_alloc(MemoryPool* pool, size_t size, size_t alignment);
```

---

### Guideline 3: Include Preconditions and Postconditions

**Description:**  
Prompt the LLM to identify and document function preconditions (what must be true before calling) and postconditions (what will be true after).

**Reasoning:**  
Design-by-contract documentation improves code correctness. LLMs can infer preconditions from assert statements, null checks, and parameter validation code.

**Example:**  
```cpp
/**
 * @brief Removes and returns the top element from the stack.
 *
 * @pre Stack must not be empty (check with is_empty() first)
 * @post Stack size is decreased by one
 *
 * @return The value that was at the top of the stack
 */
int stack_pop(Stack* s);
```

---

### Guideline 4: Ask for Usage Examples in Documentation

**Description:**  
Request that the LLM include a brief usage example in the documentation, especially for functions with non-obvious parameter combinations.

**Reasoning:**  
Examples clarify intent better than descriptions alone. LLMs can generate realistic usage scenarios based on function signatures and context.

**Example:**  
```cpp
/**
 * @brief Formats a timestamp into a human-readable string.
 *
 * @param timestamp Unix timestamp in seconds
 * @param format strftime-compatible format string
 * @param buffer Output buffer for formatted string
 * @param buffer_size Size of output buffer
 * @return Number of characters written, or 0 on error
 *
 * @code
 * char buf[64];
 * format_timestamp(time(NULL), "%Y-%m-%d %H:%M:%S", buf, sizeof(buf));
 * // buf now contains "2025-01-28 14:30:00"
 * @endcode
 */
size_t format_timestamp(time_t timestamp, const char* format, char* buffer, size_t buffer_size);
```

---

### Guideline 5: Explicitly Request Identification of Side Effects

**Description:**  
Ask the LLM to identify and document any side effects (file I/O, global state modification, memory allocation).

**Reasoning:**  
Side effects are crucial for understanding function behavior but easy to overlook. Explicit prompting ensures they're captured.

**Example:**  
```cpp
/**
 * @brief Initializes the logging subsystem.
 *
 * @param log_path Path to log file
 * @return 0 on success, -1 on error
 *
 * @sideeffect Opens log_path for writing (creates if not exists)
 * @sideeffect Sets global log_initialized flag to true
 * @sideeffect Registers atexit handler to flush and close log on program exit
 */
int init_logging(const char* log_path);
```

---

### Guideline 6: Use Few-Shot Examples Matching Your Documentation Style

**Description:**  
Provide 2-3 examples of documentation from your codebase that follow your project's conventions before asking for new documentation.

**Reasoning:**  
LLMs adapt to demonstrated style. Showing your project's specific formatting (header style, level of detail, terminology) produces more consistent output than generic prompts.

**Example:**  
```
Here are examples of documentation style from our project:

/**
 * net_connect - Establishes TCP connection to remote host
 * @host: Hostname or IP address string
 * @port: Port number (1-65535)
 *
 * Returns socket file descriptor on success, -1 on failure.
 * Caller is responsible for closing the socket.
 */
int net_connect(const char* host, int port);

Now document this function in the same style:
int net_send(int sockfd, const void* data, size_t len, int flags);
```

---

## 4. References

[1] Ahmed, T., & Devanbu, P. "Few-shot training LLMs for project-specific code-summarization." arXiv.  
[2] Ahmed, T., et al. "Automatic Semantic Augmentation of Language Model Prompts (for Code Summarization)." arXiv.  
[3] Sun, W., et al. "Automatic Code Summarization via ChatGPT: How Far Are We?" arXiv.  
[4] Richards, N., & Wessel, M. "What You Need is What You Get: Theory of Mind for an LLM-Based Code Understanding Assistant." arXiv.  
[5] Sridhara, S., et al. "Icing on the Cake: Automatic Code Summarization at Ericsson." arXiv.  
[6] Wu, Y., et al. "Can Large Language Models Serve as Evaluators for Code Summarization?" arXiv.  
[7] Chun, S., et al. "Is Multi-Agent Debate (MAD) the Silver Bullet?" arXiv.  
[8] GitHub Docs. "Best practices for using GitHub Copilot." https://docs.github.com/en/copilot/get-started/best-practices  
[9] GitHub Blog. "Documenting and explaining legacy code with GitHub Copilot." January 2025.  
[10] GitHub Changelog. "Improving GitHub Copilot Completions in VS Code for C++ Developers." August 2024.  
[11] Doxygen Manual. "Documenting the code." https://www.doxygen.nl/manual/docblocks.html  
[12] LSST DM Developer Guide. "Documenting C++ Code." https://developer.lsst.io/cpp/api-docs.html  
[13] NIU Documentation Standards. https://faculty.cs.niu.edu/~winans/howto/doxygen/  
[14] Visual Studio Magazine. "Documenting C++ APIs with Doxygen."  
[15] Source Code Summarization in the Era of Large Language Models. arXiv:2407.07959.

---

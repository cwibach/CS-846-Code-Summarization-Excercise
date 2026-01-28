# Week 5 Guidelines: Code Summarization / Comprehension

**Authors:** Basit Ali  
**Readings Assigned:**  
- Few-shot training LLMs for project-specific code-summarization (Ahmed & Devanbu)
- Automatic Semantic Augmentation of Language Model Prompts - ASAP (Ahmed et al.)
- Automatic Code Summarization via ChatGPT: How Far Are We? (Sun et al.)
- What You Need is What You Get: Theory of Mind for an LLM-Based Code Understanding Assistant (Richards & Wessel)
- Icing on the Cake: Automatic Code Summarization at Ericsson (Sridhara et al.)
- Can Large Language Models Serve as Evaluators for Code Summarization? (Wu et al.)
- Is Multi-Agent Debate (MAD) the Silver Bullet? (Chun et al.)

---

## 1. Guidelines

> **Note:** Guidelines should be actionable, specific, and usable during real coding tasks.

### Guideline 1: Provide Project-Specific Examples in Your Prompt

**Description:**  
Include 5-10 example function-summary pairs from the same project when prompting an LLM to summarize code. Keep related header files and dependent code files open in your IDE for additional context.

**Reasoning:**  
Same-project few-shot prompting improves performance by ~12.5% over cross-project examples because the LLM can learn project-specific identifiers, naming conventions, and coding style [1]. GitHub Copilot documentation confirms that open tabs provide context that reduces hallucinations [8]. Zero-shot approaches perform poorly—models need multiple examples to understand a project's code→comment mapping.

**Example (C++):**  
```cpp
// Examples from this project's codebase:
// 1. uint32_t crc32_update(uint32_t crc, const uint8_t* data, size_t len)
//    Summary: Updates running CRC32 checksum with additional data bytes.
// 2. bool packet_validate(const Packet* pkt)
//    Summary: Validates packet header magic number and checksum.

// Now summarize:
int packet_send(int socket, const Packet* pkt, int flags);
```

---

### Guideline 2: Include Repository, File Path, and Namespace Context

**Description:**  
Augment your prompt with the repository name, file path, class/namespace, and any relevant type definitions that aren't immediately visible in the code snippet.

**Reasoning:**  
The ASAP paper found that repository information was the single most impactful context component, contributing more to BLEU improvements than even data flow graphs [2]. For C/C++ code where types may be defined elsewhere, explicitly tagging identifier types helps the LLM reason about semantics.

**Example (C):**  
```
Repository: linux-kernel
File: drivers/usb/core/hub.c
Context: hub_port_connect is called during USB device enumeration

Types:
- struct usb_hub contains hub descriptor and port status array
- port_status is a bitmask defined in include/linux/usb/ch11.h

Summarize this function:
static int hub_port_connect(struct usb_hub *hub, int port, ...);
```

---

### Guideline 3: Explicitly Constrain Summary Length

**Description:**  
Request summaries under a specific word count (e.g., "Summarize in one sentence, maximum 15 words") or match a target format like "@brief [one-line description]".

**Reasoning:**  
LLMs tend to generate verbose summaries that score poorly on BLEU metrics despite being semantically accurate [3]. The Ericsson study found that a simple "WordRestrict" prompt asking for <20 words performed as well as complex retrieval-augmented approaches while being far simpler to implement [5].

**Example:**  
```cpp
// Prompt: "Generate a @brief description in one sentence (max 15 words)"

void quicksort(int* arr, int low, int high);

// Good output:
// @brief Recursively sorts array elements between low and high indices.

// Bad output (too verbose):
// @brief This function implements the quicksort algorithm which is a 
// divide-and-conquer sorting technique that recursively partitions...
```

---

### Guideline 4: Provide a Documentation Template

**Description:**  
When generating structured documentation (docstrings, Doxygen blocks), provide an explicit template showing the expected format. Include 2-3 examples from your codebase that demonstrate your project's style conventions.

**Reasoning:**  
LLMs produce more consistent output when given explicit structure [4]. Few-shot examples matching your documentation style train the model on your terminology, formatting preferences, and level of detail. The ToMMY paper noted that formatting significantly affects perceived usefulness.

**Example (C++ Doxygen template):**  
```cpp
// Our project's documentation style:
/**
 * @brief [One-line description ending with period]
 *
 * [Optional detailed description, 1-2 sentences]
 *
 * @param [name] [Purpose and constraints, not just type]
 * @return [What the return value represents]
 *
 * @pre [Precondition if any]
 * @exceptsafe [No-throw | Strong | Basic]
 */

// Example from our codebase:
/**
 * @brief Allocates aligned memory from the pool.
 *
 * Returns NULL if the pool has insufficient contiguous space.
 *
 * @param pool Memory pool to allocate from
 * @param size Requested allocation size in bytes
 * @param align Alignment requirement (must be power of 2)
 * @return Pointer to allocated memory, or NULL on failure
 *
 * @pre pool must be initialized via pool_init()
 * @exceptsafe No-throw guarantee
 */
void* pool_alloc(MemoryPool* pool, size_t size, size_t align);

// Now document this function in the same style:
void pool_free(MemoryPool* pool, void* ptr);
```

---

### Guideline 5: Document Purpose and Contract, Not Implementation

**Description:**  
Focus summaries on what the function accomplishes (its contract with callers), what parameters represent, and what guarantees it provides—not how it works internally. Include preconditions, postconditions, side effects, and exception/thread safety when relevant.

**Reasoning:**  
API documentation serves consumers who don't read implementations. Documentation standards emphasize that @param should explain meaning and constraints, not restate types [13]. However, safety-critical information like thread safety, exception guarantees, and side effects (file I/O, global state) does belong in documentation [12, 14].

**Example:**  
```cpp
// BAD - describes implementation:
/**
 * @brief Uses a while loop to iterate through the linked list and 
 * compares each node's key field using strcmp until finding a match
 */

// GOOD - describes contract:
/**
 * @brief Searches for a key in the hash table.
 *
 * @param table Hash table to search (must not be NULL)
 * @param key Null-terminated string key to find
 * @return Pointer to value if found, NULL if key not present
 *
 * @exceptsafe No-throw guarantee
 * @note Thread-safe for concurrent reads; exclusive lock required for writes
 */
void* hashtable_get(const HashTable* table, const char* key);
```

---

### Guideline 6: Do NOT Instruct the LLM to Ignore Code Sections

**Description:**  
Avoid prompts like "ignore exception handling" or "skip error checking code." Include all code when requesting summaries.

**Reasoning:**  
The Ericsson paper tested an "IgnoreException" strategy and found it degraded summary quality [5]. Error handling is semantically important—it tells users what can go wrong and how failures are handled. Similarly, method names carry significant information; masking them severely impacts all summarization approaches.

**Example:**  
```cpp
// BAD prompt: "Summarize this function, ignoring the error handling"

// GOOD prompt: "Summarize this function including its error handling behavior"

// The error handling IS the interesting part:
FILE* safe_open(const char* path, const char* mode) {
    if (!path || !mode) return NULL;
    FILE* f = fopen(path, mode);
    if (!f) {
        log_error("Failed to open %s: %s", path, strerror(errno));
    }
    return f;
}
// Summary: Opens a file with the given mode, logging an error on failure.
```

---

### Guideline 7: Break Large Functions into Logical Sections

**Description:**  
For functions longer than ~50 lines or containing distinct logical phases, decompose the code and summarize sections individually before generating an overall summary.

**Reasoning:**  
Shorter code segments are easier to summarize accurately [1, 3]. Complex functions often have initialization, main processing, and cleanup phases that each merit documentation. This approach also produces more detailed documentation for maintainers.

**Example:**  
```cpp
// For a 150-line initialization function:
// Prompt sequence:
// 1. "Summarize lines 1-30 (configuration parsing)"
// 2. "Summarize lines 31-90 (resource allocation)"
// 3. "Summarize lines 91-150 (hardware initialization)"
// 4. "Combine these section summaries into an overall @brief"

/**
 * @brief Initializes the device driver with configuration from file.
 *
 * Parses the config file, allocates DMA buffers and IRQ handlers,
 * then programs hardware registers to operational state.
 */
int driver_init(const char* config_path);
```

---

### Guideline 8: Use Chain-of-Thought for Complex Code, Extract Final Summary

**Description:**  
For complex algorithms or non-obvious code, ask the LLM to first analyze the code step-by-step (inputs, operations, outputs, edge cases), then produce a concise final summary. Use only the final summary in documentation.

**Reasoning:**  
Multi-agent debate and extended reflection improved semantic alignment in summarization [7]. However, advanced prompting may not outperform simple zero-shot for models with built-in reasoning [15]. Use CoT selectively for genuinely complex code where a quick read doesn't reveal purpose.

**Example:**  
```cpp
// Prompt for complex algorithm:
"Analyze this function step by step:
1. What are the inputs and their constraints?
2. What algorithm or technique does it implement?
3. What are the edge cases?
4. What does it return?

Then provide a one-sentence @brief summary."

// Code to analyze:
int longest_palindrome_subseq(const char* s, int n);

// LLM reasoning (not in final doc):
// 1. Input: string s of length n
// 2. Uses dynamic programming, dp[i][j] = longest palindrome in s[i..j]
// 3. Edge cases: empty string returns 0, single char returns 1
// 4. Returns length of longest palindromic subsequence

// Final summary for documentation:
// @brief Computes the length of the longest palindromic subsequence using DP.
```

---

### Guideline 9: Specify Target Audience When Appropriate

**Description:**  
Indicate whether the summary is for API consumers (focus on usage), maintainers (include implementation hints), or beginners (add more context). Adjust detail level accordingly.

**Reasoning:**  
LLMs can tailor complexity based on audience [4]. Public API documentation differs from internal documentation. For complex codebases, consider generating both a brief consumer-facing summary and detailed maintainer notes.

**Example:**  
```cpp
// For API consumers:
"Summarize for library users who will call this function but won't read the implementation"

// For maintainers:
"Summarize for developers who may need to modify or debug this function"

// Consumer summary:
// @brief Compresses data using LZ4 algorithm.
// @return Number of bytes written to output buffer.

// Maintainer summary (in implementation file):
// Uses streaming LZ4 with 64KB blocks. See lz4_block_compress() for 
// the core algorithm. Hash table is allocated on first call and reused.
```

---

## 2. References

[1] Ahmed, T., & Devanbu, P. "Few-shot training LLMs for project-specific code-summarization." arXiv.  
[2] Ahmed, T., et al. "Automatic Semantic Augmentation of Language Model Prompts (ASAP)." arXiv.  
[3] Sun, W., et al. "Automatic Code Summarization via ChatGPT: How Far Are We?" arXiv.  
[4] Richards, N., & Wessel, M. "What You Need is What You Get: Theory of Mind for an LLM-Based Code Understanding Assistant." arXiv.  
[5] Sridhara, S., et al. "Icing on the Cake: Automatic Code Summarization at Ericsson." arXiv.  
[6] Wu, Y., et al. "Can Large Language Models Serve as Evaluators for Code Summarization?" arXiv.  
[7] Chun, S., et al. "Is Multi-Agent Debate (MAD) the Silver Bullet?" arXiv.  
[8] GitHub Docs. "Best practices for using GitHub Copilot."  
[9] GitHub Blog. "Documenting and explaining legacy code with GitHub Copilot." January 2025.  
[10] GitHub Changelog. "Improving GitHub Copilot Completions in VS Code for C++ Developers." August 2024.  
[11] Doxygen Manual. "Documenting the code."  
[12] LSST DM Developer Guide. "Documenting C++ Code."  
[13] NIU Documentation Standards.  
[14] Visual Studio Magazine. "Documenting C++ APIs with Doxygen."  
[15] Source Code Summarization in the Era of Large Language Models. arXiv:2407.07959.

---

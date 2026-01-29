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
Include 5-10 example function-summary pairs from the same project when prompting an LLM to summarize code. Keep related header files and dependent code files open in your IDE for additional context. Providing additional information for the project such as function, file, or repository names can also help provide useful context, and this also gives a good idea of what information this audience wants.

**Reasoning:**  
Same-project few-shot prompting improves performance by ~12.5% over cross-project examples because the LLM can learn project-specific identifiers, naming conventions, and coding style [1]. GitHub Copilot documentation confirms that open tabs provide context that reduces hallucinations [8]. Zero-shot approaches perform poorly—models need multiple examples to understand a project's code→comment mapping. The ASAP paper found that repository information was the single most impactful context component, contributing more to BLEU improvements than even data flow graphs [2]. LLMs can also tailor complexity based on audience [4] and public API documentation differs from internal documentation. Other papers also confirmed that proper training data, even few-shot made a significant impact [16, 18]

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

### Guideline 2: Explicitly Constrain Summary Length

**Description:**  
Request summaries under a specific word count (e.g., "Summarize in one sentence, maximum 15 words") or match a target format like "@brief [one-line description]". This assists in preventing unnecessary summaries such as error handling, which explicitly instructing to ignore this can hurt results.

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

### Guideline 3: Provide a Documentation Template for the Summary

**Description:**  
When generating structured documentation (docstrings, Doxygen blocks), provide an explicit template showing the expected format. Include 2-3 examples from your codebase that demonstrate your project's style conventions. Structure can include what to focus on in each section, detailing what aspects of the code are most important.

**Reasoning:**  
LLMs produce more consistent output when given explicit structure [4]. Few-shot examples matching your documentation style train the model on your terminology, formatting preferences, and level of detail. The ToMMY paper noted that formatting significantly affects perceived usefulness. The Ericsson paper found that expressing conciseness is much more valuable than telling the model to ignore error handling [5]

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

### Guideline 4: Document Purpose and Contract, Not Implementation

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


---

### Guideline 5: Break Large amounts of Code into Logical Sections

**Description:**  
The models can struggle to deal with an immense amount of code such as a full repository, or very complicated functions. Breaking up steps into sections of large complex functions, or into groupings of small simililar functions has been shown to provide better results when summarizing with LLMs.

**Reasoning:**  
Shorter code segments are easier to summarize accurately [1, 3] and longer sections have provided less useful and less accurate summaries [17]. Complex functions often have initialization, main processing, and cleanup phases that each merit documentation. This approach also produces more detailed documentation for maintainers.

**Example:**  
```
Bad: "Add comment blocks for all functions in folder Y"
Good: "Add a comment block for functions X & Z in folder Y" (where functions X & Z are similar, or work in tandem)

```

---


---

### Guideline 6: Develop a global plan for the entire repository.

**Description:**  
Repository-level code understanding is not about “writing comments,” but about reasoning through the repository’s causal structure.

**Reasoning:** 
The planning process should begin from a seed file—a clearly identified entry point—and expand to a plan for the entire project. This includes explicitly mapping, at the planning stage, which functions in the seed file call which functions in which files.

The plan should clearly answer questions such as: Which components call this function? Which classes inherit from this class? Where is this field used?

**Example:** 



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
[16] Haldar, R., & Hockenmaier, J. "Analyzing the Performance of Large Language Models on Code Summarization" arXiv.
[17] Sundaram, G., et al. "DocStringEval: Evaluating the Effectiveness of Language Models for Code Explanation Through DocString Generation" ieee Xplore.
[18] Poudel, B., et al. "DocuMint: DocString Generation for Python using Small Language Models" arXiv.

---

# Week 5 Example Problems: Code Summarization / Comprehension

**Authors:** Basit Ali, Yiran Hu, Carter Ibach

**Github Repo:** https://github.com/cwibach/CS-846-Code-Summarization-Excercise.git

**Model:** Please use Raptor Mini as the model to stay consistent with our results.

> **Instructions:** For each problem, generate documentation (docstrings/Doxygen comments) for the provided functions. Try first WITHOUT the guidelines, then WITH the guidelines to compare results.

## 1. C/C++ (15 minutes)

### Problem C_1: `memory_pool.h` / `memory_pool.c`

**Task Description:**
Generate Doxygen documentation for all functions in this memory pool implementation. Focus on the @brief, @param, @return, and any relevant @pre/@post conditions.

### Problem C_2: `ring_buffer.h` / `ring_buffer.c`

**Task Description:**
Generate Doxygen documentation for this lock-free single-producer single-consumer ring buffer. Pay attention to thread safety guarantees and memory ordering.

### Problem C_3: `config_parser.h`

**Task Description:**
Generate documentation for this INI-style configuration file parser. Include information about error handling and memory ownership.

### Problem CPP_1: `unique_handle.hpp`

**Task Description:**
Generate Doxygen documentation for this unique_ptr-like smart pointer with custom deleter support. Document exception safety and ownership semantics.

### Problem CPP_2: `event_queue.hpp`

**Task Description:**
Generate documentation for this thread-safe event queue with timeout support. Pay special attention to thread safety guarantees and blocking behavior.

### Problem CPP_3: `lru_cache.hpp`

**Task Description:**
Generate documentation for this LRU (Least Recently Used) cache implementation. Focus on time complexity guarantees and thread safety (or lack thereof).

---

## 2. Matlab (10 minutes)

All code for MatLab activities is in the Matlab directory in the github provided.

### Problem M_1: Comment Blocks

Add a comment block at the top of each Matlab function explaining the inputs, what the function does and the outputs. The following functions already have comment blocks and do not need new ones:
- dateStringtoDay
- expandPairings
- getBadLegs
- fullProgram

## 3. React (5 minutes)

All code for React activities is in the Node-React directory in the github provided. The Node Modules may help with the exercises, but the React components are what the exercises require.

### Problem R_1: LandlordProfile

Add block comments for each component in the LandlordProfile folder, with information about props passed, and what the component does. No specific mention of API's is needed.

### Problem R_2: SearchUnits

Add block comments for each component in the SearchUnits folder, with information about props passed, and what the component does. No specific mention of API's is needed.

## 4. Python (10 minutes)

All code for Python activities is in the Node-Python directory in the github provided. The folder contains the plm_retrieval file as well as multiple files related to evaluation metrics. Please complete the following tasks based on these files:

### Problem P_1: 

Provide a code summary for the files under the plm_retrieval folder.

PLM_retrieval constitutes the model component of the project. The files in this module lack detailed comments, and the invocation relationships between functions are not explicitly documented. When completing this task, please ensure that the following aspects are covered: (1) the specific functionalities implemented in each file, (2) the calling relationships among functions, and (3) an overall code summary of the PLM_retrieval module.

### Problem P_2:

Provide a code summary for the entire repository, and evaluate the code, including whether there are areas that could be optimized or improved.

In addition to the plm_retrieval module, the project also includes other baseline and evaluation modules. However, the execution relationships among the files are not clearly documented. Please first summarize the functionality of each file, then explain the overall calling relationships across the repository, and finally provide an overall summary of the repository.

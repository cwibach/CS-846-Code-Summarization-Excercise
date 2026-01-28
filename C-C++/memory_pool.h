// memory_pool.h
// A simple fixed-size block memory pool allocator

#ifndef MEMORY_POOL_H
#define MEMORY_POOL_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

typedef struct MemoryPool MemoryPool;

// TODO: Document this function
MemoryPool* pool_create(size_t block_size, size_t block_count);

// TODO: Document this function
void pool_destroy(MemoryPool* pool);

// TODO: Document this function
void* pool_alloc(MemoryPool* pool);

// TODO: Document this function
void pool_free(MemoryPool* pool, void* block);

// TODO: Document this function
size_t pool_available(const MemoryPool* pool);

// TODO: Document this function
bool pool_contains(const MemoryPool* pool, const void* ptr);

#endif // MEMORY_POOL_H

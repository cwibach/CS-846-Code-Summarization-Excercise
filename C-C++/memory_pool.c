// memory_pool.c
#include "memory_pool.h"
#include <stdlib.h>
#include <string.h>

struct MemoryPool {
    uint8_t* memory;
    uint8_t* free_list;
    size_t block_size;
    size_t block_count;
    size_t free_count;
};

MemoryPool* pool_create(size_t block_size, size_t block_count) {
    if (block_size < sizeof(void*)) {
        block_size = sizeof(void*);
    }

    MemoryPool* pool = malloc(sizeof(MemoryPool));
    if (!pool) return NULL;

    pool->memory = malloc(block_size * block_count);
    if (!pool->memory) {
        free(pool);
        return NULL;
    }

    pool->block_size = block_size;
    pool->block_count = block_count;
    pool->free_count = block_count;

    // Initialize free list - each block points to next
    pool->free_list = pool->memory;
    for (size_t i = 0; i < block_count - 1; i++) {
        uint8_t* current = pool->memory + (i * block_size);
        uint8_t* next = pool->memory + ((i + 1) * block_size);
        *((void**)current) = next;
    }
    *((void**)(pool->memory + (block_count - 1) * block_size)) = NULL;

    return pool;
}

void pool_destroy(MemoryPool* pool) {
    if (pool) {
        free(pool->memory);
        free(pool);
    }
}

void* pool_alloc(MemoryPool* pool) {
    if (!pool || !pool->free_list) {
        return NULL;
    }

    void* block = pool->free_list;
    pool->free_list = *((uint8_t**)pool->free_list);
    pool->free_count--;

    return block;
}

void pool_free(MemoryPool* pool, void* block) {
    if (!pool || !block) return;

    // Verify block belongs to this pool
    uint8_t* ptr = (uint8_t*)block;
    if (ptr < pool->memory || ptr >= pool->memory + (pool->block_size * pool->block_count)) {
        return; // Block not from this pool
    }

    *((void**)block) = pool->free_list;
    pool->free_list = block;
    pool->free_count++;
}

size_t pool_available(const MemoryPool* pool) {
    return pool ? pool->free_count : 0;
}

bool pool_contains(const MemoryPool* pool, const void* ptr) {
    if (!pool || !ptr) return false;
    const uint8_t* p = (const uint8_t*)ptr;
    return p >= pool->memory && p < pool->memory + (pool->block_size * pool->block_count);
}

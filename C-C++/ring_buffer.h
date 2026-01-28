// ring_buffer.h
#ifndef RING_BUFFER_H
#define RING_BUFFER_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdatomic.h>

typedef struct {
    uint8_t* buffer;
    size_t capacity;
    atomic_size_t head;  // Write position (producer)
    atomic_size_t tail;  // Read position (consumer)
} RingBuffer;

// TODO: Document this function
RingBuffer* ring_create(size_t capacity);

// TODO: Document this function
void ring_destroy(RingBuffer* rb);

// TODO: Document this function
bool ring_push(RingBuffer* rb, const void* data, size_t len);

// TODO: Document this function
bool ring_pop(RingBuffer* rb, void* data, size_t len);

// TODO: Document this function
size_t ring_size(const RingBuffer* rb);

// TODO: Document this function
size_t ring_free_space(const RingBuffer* rb);

// TODO: Document this function
bool ring_is_empty(const RingBuffer* rb);

// TODO: Document this function
bool ring_is_full(const RingBuffer* rb);

#endif

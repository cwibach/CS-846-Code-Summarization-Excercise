// ring_buffer.c
#include "ring_buffer.h"
#include <stdlib.h>
#include <string.h>

RingBuffer* ring_create(size_t capacity) {
    RingBuffer* rb = malloc(sizeof(RingBuffer));
    if (!rb) return NULL;

    // Allocate one extra byte to distinguish full from empty
    rb->buffer = malloc(capacity + 1);
    if (!rb->buffer) {
        free(rb);
        return NULL;
    }

    rb->capacity = capacity + 1;
    atomic_init(&rb->head, 0);
    atomic_init(&rb->tail, 0);

    return rb;
}

void ring_destroy(RingBuffer* rb) {
    if (rb) {
        free(rb->buffer);
        free(rb);
    }
}

bool ring_push(RingBuffer* rb, const void* data, size_t len) {
    if (!rb || !data || len == 0) return false;

    size_t head = atomic_load_explicit(&rb->head, memory_order_relaxed);
    size_t tail = atomic_load_explicit(&rb->tail, memory_order_acquire);

    size_t free = (tail - head - 1 + rb->capacity) % rb->capacity;
    if (len > free) return false;

    const uint8_t* src = (const uint8_t*)data;
    for (size_t i = 0; i < len; i++) {
        rb->buffer[(head + i) % rb->capacity] = src[i];
    }

    atomic_store_explicit(&rb->head, (head + len) % rb->capacity, memory_order_release);
    return true;
}

bool ring_pop(RingBuffer* rb, void* data, size_t len) {
    if (!rb || !data || len == 0) return false;

    size_t tail = atomic_load_explicit(&rb->tail, memory_order_relaxed);
    size_t head = atomic_load_explicit(&rb->head, memory_order_acquire);

    size_t available = (head - tail + rb->capacity) % rb->capacity;
    if (len > available) return false;

    uint8_t* dst = (uint8_t*)data;
    for (size_t i = 0; i < len; i++) {
        dst[i] = rb->buffer[(tail + i) % rb->capacity];
    }

    atomic_store_explicit(&rb->tail, (tail + len) % rb->capacity, memory_order_release);
    return true;
}

size_t ring_size(const RingBuffer* rb) {
    if (!rb) return 0;
    size_t head = atomic_load_explicit(&rb->head, memory_order_acquire);
    size_t tail = atomic_load_explicit(&rb->tail, memory_order_acquire);
    return (head - tail + rb->capacity) % rb->capacity;
}

size_t ring_free_space(const RingBuffer* rb) {
    if (!rb) return 0;
    return rb->capacity - 1 - ring_size(rb);
}

bool ring_is_empty(const RingBuffer* rb) {
    return ring_size(rb) == 0;
}

bool ring_is_full(const RingBuffer* rb) {
    return ring_free_space(rb) == 0;
}

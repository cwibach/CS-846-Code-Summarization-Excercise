// event_queue.hpp
#ifndef EVENT_QUEUE_HPP
#define EVENT_QUEUE_HPP

#include <queue>
#include <mutex>
#include <condition_variable>
#include <optional>
#include <chrono>

template<typename T>
class EventQueue {
public:
    // TODO: Document this constructor
    explicit EventQueue(size_t max_size = 0);

    // TODO: Document this destructor
    ~EventQueue();

    // TODO: Document this function
    bool push(const T& item);

    // TODO: Document this function
    bool push(T&& item);

    // TODO: Document this function
    template<typename... Args>
    bool emplace(Args&&... args);

    // TODO: Document this function
    std::optional<T> pop();

    // TODO: Document this function
    std::optional<T> try_pop();

    // TODO: Document this function
    template<typename Rep, typename Period>
    std::optional<T> pop_for(const std::chrono::duration<Rep, Period>& timeout);

    // TODO: Document this function
    template<typename Clock, typename Duration>
    std::optional<T> pop_until(const std::chrono::time_point<Clock, Duration>& deadline);

    // TODO: Document this function
    void close();

    // TODO: Document this function
    bool is_closed() const;

    // TODO: Document this function
    size_t size() const;

    // TODO: Document this function
    bool empty() const;

    // TODO: Document this function
    void clear();

    // Non-copyable, non-movable
    EventQueue(const EventQueue&) = delete;
    EventQueue& operator=(const EventQueue&) = delete;
    EventQueue(EventQueue&&) = delete;
    EventQueue& operator=(EventQueue&&) = delete;

private:
    mutable std::mutex mutex_;
    std::condition_variable not_empty_;
    std::condition_variable not_full_;
    std::queue<T> queue_;
    size_t max_size_;
    bool closed_ = false;
};

// Implementation
template<typename T>
EventQueue<T>::EventQueue(size_t max_size) : max_size_(max_size) {}

template<typename T>
EventQueue<T>::~EventQueue() {
    close();
}

template<typename T>
bool EventQueue<T>::push(const T& item) {
    std::unique_lock<std::mutex> lock(mutex_);

    if (max_size_ > 0) {
        not_full_.wait(lock, [this] {
            return closed_ || queue_.size() < max_size_;
        });
    }

    if (closed_) return false;

    queue_.push(item);
    not_empty_.notify_one();
    return true;
}

template<typename T>
bool EventQueue<T>::push(T&& item) {
    std::unique_lock<std::mutex> lock(mutex_);

    if (max_size_ > 0) {
        not_full_.wait(lock, [this] {
            return closed_ || queue_.size() < max_size_;
        });
    }

    if (closed_) return false;

    queue_.push(std::move(item));
    not_empty_.notify_one();
    return true;
}

template<typename T>
template<typename... Args>
bool EventQueue<T>::emplace(Args&&... args) {
    std::unique_lock<std::mutex> lock(mutex_);

    if (max_size_ > 0) {
        not_full_.wait(lock, [this] {
            return closed_ || queue_.size() < max_size_;
        });
    }

    if (closed_) return false;

    queue_.emplace(std::forward<Args>(args)...);
    not_empty_.notify_one();
    return true;
}

template<typename T>
std::optional<T> EventQueue<T>::pop() {
    std::unique_lock<std::mutex> lock(mutex_);
    not_empty_.wait(lock, [this] { return closed_ || !queue_.empty(); });

    if (queue_.empty()) return std::nullopt;

    T item = std::move(queue_.front());
    queue_.pop();
    not_full_.notify_one();
    return item;
}

template<typename T>
std::optional<T> EventQueue<T>::try_pop() {
    std::lock_guard<std::mutex> lock(mutex_);

    if (queue_.empty()) return std::nullopt;

    T item = std::move(queue_.front());
    queue_.pop();
    not_full_.notify_one();
    return item;
}

template<typename T>
template<typename Rep, typename Period>
std::optional<T> EventQueue<T>::pop_for(const std::chrono::duration<Rep, Period>& timeout) {
    std::unique_lock<std::mutex> lock(mutex_);

    if (!not_empty_.wait_for(lock, timeout, [this] { return closed_ || !queue_.empty(); })) {
        return std::nullopt;
    }

    if (queue_.empty()) return std::nullopt;

    T item = std::move(queue_.front());
    queue_.pop();
    not_full_.notify_one();
    return item;
}

template<typename T>
template<typename Clock, typename Duration>
std::optional<T> EventQueue<T>::pop_until(const std::chrono::time_point<Clock, Duration>& deadline) {
    std::unique_lock<std::mutex> lock(mutex_);

    if (!not_empty_.wait_until(lock, deadline, [this] { return closed_ || !queue_.empty(); })) {
        return std::nullopt;
    }

    if (queue_.empty()) return std::nullopt;

    T item = std::move(queue_.front());
    queue_.pop();
    not_full_.notify_one();
    return item;
}

template<typename T>
void EventQueue<T>::close() {
    {
        std::lock_guard<std::mutex> lock(mutex_);
        closed_ = true;
    }
    not_empty_.notify_all();
    not_full_.notify_all();
}

template<typename T>
bool EventQueue<T>::is_closed() const {
    std::lock_guard<std::mutex> lock(mutex_);
    return closed_;
}

template<typename T>
size_t EventQueue<T>::size() const {
    std::lock_guard<std::mutex> lock(mutex_);
    return queue_.size();
}

template<typename T>
bool EventQueue<T>::empty() const {
    std::lock_guard<std::mutex> lock(mutex_);
    return queue_.empty();
}

template<typename T>
void EventQueue<T>::clear() {
    std::lock_guard<std::mutex> lock(mutex_);
    std::queue<T> empty;
    std::swap(queue_, empty);
    not_full_.notify_all();
}

#endif // EVENT_QUEUE_HPP

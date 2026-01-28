// unique_handle.hpp
#ifndef UNIQUE_HANDLE_HPP
#define UNIQUE_HANDLE_HPP

#include <utility>
#include <type_traits>

template<typename T, typename Deleter = std::default_delete<T>>
class UniqueHandle {
public:
    using pointer = T*;
    using element_type = T;
    using deleter_type = Deleter;

    // TODO: Document this constructor
    constexpr UniqueHandle() noexcept;

    // TODO: Document this constructor
    explicit UniqueHandle(pointer ptr) noexcept;

    // TODO: Document this constructor
    UniqueHandle(pointer ptr, const Deleter& del) noexcept;

    // TODO: Document this constructor
    UniqueHandle(pointer ptr, Deleter&& del) noexcept;

    // TODO: Document this constructor (move)
    UniqueHandle(UniqueHandle&& other) noexcept;

    // TODO: Document this destructor
    ~UniqueHandle();

    // TODO: Document this operator
    UniqueHandle& operator=(UniqueHandle&& other) noexcept;

    // TODO: Document this operator
    UniqueHandle& operator=(std::nullptr_t) noexcept;

    // TODO: Document this function
    pointer release() noexcept;

    // TODO: Document this function
    void reset(pointer ptr = pointer()) noexcept;

    // TODO: Document this function
    void swap(UniqueHandle& other) noexcept;

    // TODO: Document this function
    pointer get() const noexcept;

    // TODO: Document this function
    Deleter& get_deleter() noexcept;

    // TODO: Document this function
    const Deleter& get_deleter() const noexcept;

    // TODO: Document this operator
    explicit operator bool() const noexcept;

    // TODO: Document this operator
    typename std::add_lvalue_reference<T>::type operator*() const;

    // TODO: Document this operator
    pointer operator->() const noexcept;

    // Deleted copy operations
    UniqueHandle(const UniqueHandle&) = delete;
    UniqueHandle& operator=(const UniqueHandle&) = delete;

private:
    pointer ptr_;
    Deleter deleter_;
};

// Implementation
template<typename T, typename Deleter>
constexpr UniqueHandle<T, Deleter>::UniqueHandle() noexcept
    : ptr_(nullptr), deleter_() {}

template<typename T, typename Deleter>
UniqueHandle<T, Deleter>::UniqueHandle(pointer ptr) noexcept
    : ptr_(ptr), deleter_() {}

template<typename T, typename Deleter>
UniqueHandle<T, Deleter>::UniqueHandle(pointer ptr, const Deleter& del) noexcept
    : ptr_(ptr), deleter_(del) {}

template<typename T, typename Deleter>
UniqueHandle<T, Deleter>::UniqueHandle(pointer ptr, Deleter&& del) noexcept
    : ptr_(ptr), deleter_(std::move(del)) {}

template<typename T, typename Deleter>
UniqueHandle<T, Deleter>::UniqueHandle(UniqueHandle&& other) noexcept
    : ptr_(other.release()), deleter_(std::move(other.deleter_)) {}

template<typename T, typename Deleter>
UniqueHandle<T, Deleter>::~UniqueHandle() {
    if (ptr_) {
        deleter_(ptr_);
    }
}

template<typename T, typename Deleter>
UniqueHandle<T, Deleter>& UniqueHandle<T, Deleter>::operator=(UniqueHandle&& other) noexcept {
    if (this != &other) {
        reset(other.release());
        deleter_ = std::move(other.deleter_);
    }
    return *this;
}

template<typename T, typename Deleter>
UniqueHandle<T, Deleter>& UniqueHandle<T, Deleter>::operator=(std::nullptr_t) noexcept {
    reset();
    return *this;
}

template<typename T, typename Deleter>
typename UniqueHandle<T, Deleter>::pointer UniqueHandle<T, Deleter>::release() noexcept {
    pointer tmp = ptr_;
    ptr_ = nullptr;
    return tmp;
}

template<typename T, typename Deleter>
void UniqueHandle<T, Deleter>::reset(pointer ptr) noexcept {
    pointer old = ptr_;
    ptr_ = ptr;
    if (old) {
        deleter_(old);
    }
}

template<typename T, typename Deleter>
void UniqueHandle<T, Deleter>::swap(UniqueHandle& other) noexcept {
    std::swap(ptr_, other.ptr_);
    std::swap(deleter_, other.deleter_);
}

template<typename T, typename Deleter>
typename UniqueHandle<T, Deleter>::pointer UniqueHandle<T, Deleter>::get() const noexcept {
    return ptr_;
}

template<typename T, typename Deleter>
Deleter& UniqueHandle<T, Deleter>::get_deleter() noexcept {
    return deleter_;
}

template<typename T, typename Deleter>
const Deleter& UniqueHandle<T, Deleter>::get_deleter() const noexcept {
    return deleter_;
}

template<typename T, typename Deleter>
UniqueHandle<T, Deleter>::operator bool() const noexcept {
    return ptr_ != nullptr;
}

template<typename T, typename Deleter>
typename std::add_lvalue_reference<T>::type UniqueHandle<T, Deleter>::operator*() const {
    return *ptr_;
}

template<typename T, typename Deleter>
typename UniqueHandle<T, Deleter>::pointer UniqueHandle<T, Deleter>::operator->() const noexcept {
    return ptr_;
}

#endif // UNIQUE_HANDLE_HPP

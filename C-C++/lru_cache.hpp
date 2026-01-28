// lru_cache.hpp
#ifndef LRU_CACHE_HPP
#define LRU_CACHE_HPP

#include <list>
#include <unordered_map>
#include <optional>
#include <functional>

template<typename Key, typename Value, typename Hash = std::hash<Key>>
class LRUCache {
public:
    using key_type = Key;
    using mapped_type = Value;
    using value_type = std::pair<const Key, Value>;
    using size_type = std::size_t;

    // TODO: Document this constructor
    explicit LRUCache(size_type capacity);

    // TODO: Document this function
    std::optional<Value> get(const Key& key);

    // TODO: Document this function
    void put(const Key& key, const Value& value);

    // TODO: Document this function
    void put(const Key& key, Value&& value);

    // TODO: Document this function
    bool contains(const Key& key) const;

    // TODO: Document this function
    bool erase(const Key& key);

    // TODO: Document this function
    void clear();

    // TODO: Document this function
    size_type size() const noexcept;

    // TODO: Document this function
    size_type capacity() const noexcept;

    // TODO: Document this function
    bool empty() const noexcept;

    // TODO: Document this function
    template<typename Func>
    void for_each(Func&& fn) const;

    // TODO: Document this function
    std::optional<std::pair<Key, Value>> peek_oldest() const;

    // TODO: Document this function
    std::optional<std::pair<Key, Value>> peek_newest() const;

private:
    using ListType = std::list<value_type>;
    using ListIterator = typename ListType::iterator;
    using MapType = std::unordered_map<Key, ListIterator, Hash>;

    void evict_oldest();
    void touch(ListIterator it);

    size_type capacity_;
    ListType items_;      // Front = newest, Back = oldest
    MapType lookup_;
};

// Implementation
template<typename Key, typename Value, typename Hash>
LRUCache<Key, Value, Hash>::LRUCache(size_type capacity) : capacity_(capacity) {
    if (capacity == 0) {
        throw std::invalid_argument("LRUCache capacity must be > 0");
    }
}

template<typename Key, typename Value, typename Hash>
std::optional<Value> LRUCache<Key, Value, Hash>::get(const Key& key) {
    auto it = lookup_.find(key);
    if (it == lookup_.end()) {
        return std::nullopt;
    }
    touch(it->second);
    return it->second->second;
}

template<typename Key, typename Value, typename Hash>
void LRUCache<Key, Value, Hash>::put(const Key& key, const Value& value) {
    auto it = lookup_.find(key);
    if (it != lookup_.end()) {
        it->second->second = value;
        touch(it->second);
        return;
    }

    if (items_.size() >= capacity_) {
        evict_oldest();
    }

    items_.emplace_front(key, value);
    lookup_[key] = items_.begin();
}

template<typename Key, typename Value, typename Hash>
void LRUCache<Key, Value, Hash>::put(const Key& key, Value&& value) {
    auto it = lookup_.find(key);
    if (it != lookup_.end()) {
        it->second->second = std::move(value);
        touch(it->second);
        return;
    }

    if (items_.size() >= capacity_) {
        evict_oldest();
    }

    items_.emplace_front(key, std::move(value));
    lookup_[key] = items_.begin();
}

template<typename Key, typename Value, typename Hash>
bool LRUCache<Key, Value, Hash>::contains(const Key& key) const {
    return lookup_.find(key) != lookup_.end();
}

template<typename Key, typename Value, typename Hash>
bool LRUCache<Key, Value, Hash>::erase(const Key& key) {
    auto it = lookup_.find(key);
    if (it == lookup_.end()) {
        return false;
    }
    items_.erase(it->second);
    lookup_.erase(it);
    return true;
}

template<typename Key, typename Value, typename Hash>
void LRUCache<Key, Value, Hash>::clear() {
    items_.clear();
    lookup_.clear();
}

template<typename Key, typename Value, typename Hash>
typename LRUCache<Key, Value, Hash>::size_type LRUCache<Key, Value, Hash>::size() const noexcept {
    return items_.size();
}

template<typename Key, typename Value, typename Hash>
typename LRUCache<Key, Value, Hash>::size_type LRUCache<Key, Value, Hash>::capacity() const noexcept {
    return capacity_;
}

template<typename Key, typename Value, typename Hash>
bool LRUCache<Key, Value, Hash>::empty() const noexcept {
    return items_.empty();
}

template<typename Key, typename Value, typename Hash>
template<typename Func>
void LRUCache<Key, Value, Hash>::for_each(Func&& fn) const {
    for (const auto& item : items_) {
        fn(item.first, item.second);
    }
}

template<typename Key, typename Value, typename Hash>
std::optional<std::pair<Key, Value>> LRUCache<Key, Value, Hash>::peek_oldest() const {
    if (items_.empty()) return std::nullopt;
    return items_.back();
}

template<typename Key, typename Value, typename Hash>
std::optional<std::pair<Key, Value>> LRUCache<Key, Value, Hash>::peek_newest() const {
    if (items_.empty()) return std::nullopt;
    return items_.front();
}

template<typename Key, typename Value, typename Hash>
void LRUCache<Key, Value, Hash>::evict_oldest() {
    if (items_.empty()) return;
    lookup_.erase(items_.back().first);
    items_.pop_back();
}

template<typename Key, typename Value, typename Hash>
void LRUCache<Key, Value, Hash>::touch(ListIterator it) {
    items_.splice(items_.begin(), items_, it);
}

#endif // LRU_CACHE_HPP

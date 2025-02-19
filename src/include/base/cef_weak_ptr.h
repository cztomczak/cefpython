// Copyright (c) 2014 Marshall A. Greenblatt. Portions copyright (c) 2012
// Google Inc. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//    * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//    * Neither the name of Google Inc. nor the name Chromium Embedded
// Framework nor the names of its contributors may be used to endorse
// or promote products derived from this software without specific prior
// written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

///
/// \file
/// Weak pointers are pointers to an object that do not affect its lifetime.
/// They may be invalidated (i.e. reset to nullptr) by the object, or its
/// owner, at any time, most commonly when the object is about to be deleted.
///
/// Weak pointers are useful when an object needs to be accessed safely by one
/// or more objects other than its owner, and those callers can cope with the
/// object vanishing and e.g. tasks posted to it being silently dropped.
/// Reference-counting such an object would complicate the ownership graph and
/// make it harder to reason about the object's lifetime.
///
/// EXAMPLE:
///
/// <pre>
///  class Controller {
///   public:
///    void SpawnWorker() { Worker::StartNew(weak_factory_.GetWeakPtr()); }
///    void WorkComplete(const Result& result) { ... }
///   private:
///    // Member variables should appear before the WeakPtrFactory, to ensure
///    // that any WeakPtrs to Controller are invalidated before its members
///    // variable's destructors are executed, rendering them invalid.
///    WeakPtrFactory<Controller> weak_factory_{this};
///  };
///
///  class Worker {
///   public:
///    static void StartNew(WeakPtr<Controller> controller) {
///      Worker* worker = new Worker(std::move(controller));
///      // Kick off asynchronous processing...
///    }
///   private:
///    Worker(WeakPtr<Controller> controller)
///        : controller_(std::move(controller)) {}
///    void DidCompleteAsynchronousProcessing(const Result& result) {
///      if (controller_)
///        controller_->WorkComplete(result);
///    }
///    WeakPtr<Controller> controller_;
///  };
/// </pre>
///
/// With this implementation a caller may use SpawnWorker() to dispatch multiple
/// Workers and subsequently delete the Controller, without waiting for all
/// Workers to have completed.
///
/// <b>IMPORTANT: Thread-safety</b>
///
/// Weak pointers may be passed safely between threads, but must always be
/// dereferenced and invalidated on the same ThreaddTaskRunner otherwise
/// checking the pointer would be racey.
///
/// To ensure correct use, the first time a WeakPtr issued by a WeakPtrFactory
/// is dereferenced, the factory and its WeakPtrs become bound to the calling
/// thread or current ThreaddWorkerPool token, and cannot be dereferenced or
/// invalidated on any other task runner. Bound WeakPtrs can still be handed
/// off to other task runners, e.g. to use to post tasks back to object on the
/// bound thread.
///
/// If all WeakPtr objects are destroyed or invalidated then the factory is
/// unbound from the ThreadedTaskRunner/Thread. The WeakPtrFactory may then be
/// destroyed, or new WeakPtr objects may be used, from a different thread.
///
/// Thus, at least one WeakPtr object must exist and have been dereferenced on
/// the correct thread to enforce that other WeakPtr objects will enforce they
/// are used on the desired thread.

#ifndef CEF_INCLUDE_BASE_CEF_WEAK_PTR_H_
#define CEF_INCLUDE_BASE_CEF_WEAK_PTR_H_
#pragma once

#if defined(USING_CHROMIUM_INCLUDES)
// When building CEF include the Chromium header directly.
#include "base/memory/weak_ptr.h"
#else  // !USING_CHROMIUM_INCLUDES
// The following is substantially similar to the Chromium implementation.
// If the Chromium implementation diverges the below implementation should be
// updated to match.

#include <cstddef>
#include <type_traits>

#include "include/base/cef_atomic_flag.h"
#include "include/base/cef_logging.h"
#include "include/base/cef_ref_counted.h"
#include "include/base/cef_thread_checker.h"

namespace base {

template <typename T>
class SupportsWeakPtr;
template <typename T>
class WeakPtr;

namespace cef_internal {
// These classes are part of the WeakPtr implementation.
// DO NOT USE THESE CLASSES DIRECTLY YOURSELF.

class WeakReference {
 public:
  // Although Flag is bound to a specific ThreaddTaskRunner, it may be
  // deleted from another via base::WeakPtr::~WeakPtr().
  class Flag : public RefCountedThreadSafe<Flag> {
   public:
    Flag();

    void Invalidate();
    bool IsValid() const;

    bool MaybeValid() const;

    void DetachFromThread();

   private:
    friend class base::RefCountedThreadSafe<Flag>;

    ~Flag();

    base::ThreadChecker thread_checker_;
    AtomicFlag invalidated_;
  };

  WeakReference();
  explicit WeakReference(const scoped_refptr<Flag>& flag);
  ~WeakReference();

  WeakReference(WeakReference&& other) noexcept;
  WeakReference(const WeakReference& other);
  WeakReference& operator=(WeakReference&& other) noexcept = default;
  WeakReference& operator=(const WeakReference& other) = default;

  bool IsValid() const;
  bool MaybeValid() const;

 private:
  scoped_refptr<const Flag> flag_;
};

class WeakReferenceOwner {
 public:
  WeakReferenceOwner();
  ~WeakReferenceOwner();

  WeakReference GetRef() const;

  bool HasRefs() const { return !flag_->HasOneRef(); }

  void Invalidate();

 private:
  scoped_refptr<WeakReference::Flag> flag_;
};

// This class simplifies the implementation of WeakPtr's type conversion
// constructor by avoiding the need for a public accessor for ref_.  A
// WeakPtr<T> cannot access the private members of WeakPtr<U>, so this
// base class gives us a way to access ref_ in a protected fashion.
class WeakPtrBase {
 public:
  WeakPtrBase();
  ~WeakPtrBase();

  WeakPtrBase(const WeakPtrBase& other) = default;
  WeakPtrBase(WeakPtrBase&& other) noexcept = default;
  WeakPtrBase& operator=(const WeakPtrBase& other) = default;
  WeakPtrBase& operator=(WeakPtrBase&& other) noexcept = default;

  void reset() {
    ref_ = cef_internal::WeakReference();
    ptr_ = 0;
  }

 protected:
  WeakPtrBase(const WeakReference& ref, uintptr_t ptr);

  WeakReference ref_;

  // This pointer is only valid when ref_.is_valid() is true.  Otherwise, its
  // value is undefined (as opposed to nullptr).
  uintptr_t ptr_;
};

// This class provides a common implementation of common functions that would
// otherwise get instantiated separately for each distinct instantiation of
// SupportsWeakPtr<>.
class SupportsWeakPtrBase {
 public:
  // A safe static downcast of a WeakPtr<Base> to WeakPtr<Derived>. This
  // conversion will only compile if there is exists a Base which inherits
  // from SupportsWeakPtr<Base>. See base::AsWeakPtr() below for a helper
  // function that makes calling this easier.
  //
  // Precondition: t != nullptr
  template <typename Derived>
  static WeakPtr<Derived> StaticAsWeakPtr(Derived* t) {
    static_assert(
        std::is_base_of<cef_internal::SupportsWeakPtrBase, Derived>::value,
        "AsWeakPtr argument must inherit from SupportsWeakPtr");
    return AsWeakPtrImpl<Derived>(t);
  }

 private:
  // This template function uses type inference to find a Base of Derived
  // which is an instance of SupportsWeakPtr<Base>. We can then safely
  // static_cast the Base* to a Derived*.
  template <typename Derived, typename Base>
  static WeakPtr<Derived> AsWeakPtrImpl(SupportsWeakPtr<Base>* t) {
    WeakPtr<Base> ptr = t->AsWeakPtr();
    return WeakPtr<Derived>(
        ptr.ref_, static_cast<Derived*>(reinterpret_cast<Base*>(ptr.ptr_)));
  }
};

}  // namespace cef_internal

template <typename T>
class WeakPtrFactory;

///
/// The WeakPtr class holds a weak reference to |T*|.
///
/// This class is designed to be used like a normal pointer.  You should always
/// null-test an object of this class before using it or invoking a method that
/// may result in the underlying object being destroyed.
///
/// EXAMPLE:
///
/// <pre>
///   class Foo { ... };
///   WeakPtr<Foo> foo;
///   if (foo)
///     foo->method();
/// </pre>
///
template <typename T>
class WeakPtr : public cef_internal::WeakPtrBase {
 public:
  WeakPtr() = default;
  WeakPtr(std::nullptr_t) {}

  ///
  /// Allow conversion from U to T provided U "is a" T. Note that this
  /// is separate from the (implicit) copy and move constructors.
  ///
  template <typename U>
  WeakPtr(const WeakPtr<U>& other) : WeakPtrBase(other) {
    // Need to cast from U* to T* to do pointer adjustment in case of multiple
    // inheritance. This also enforces the "U is a T" rule.
    T* t = reinterpret_cast<U*>(other.ptr_);
    ptr_ = reinterpret_cast<uintptr_t>(t);
  }
  template <typename U>
  WeakPtr(WeakPtr<U>&& other) noexcept : WeakPtrBase(std::move(other)) {
    // Need to cast from U* to T* to do pointer adjustment in case of multiple
    // inheritance. This also enforces the "U is a T" rule.
    T* t = reinterpret_cast<U*>(other.ptr_);
    ptr_ = reinterpret_cast<uintptr_t>(t);
  }

  T* get() const {
    return ref_.IsValid() ? reinterpret_cast<T*>(ptr_) : nullptr;
  }

  T& operator*() const {
    CHECK(ref_.IsValid());
    return *get();
  }
  T* operator->() const {
    CHECK(ref_.IsValid());
    return get();
  }

  ///
  /// Allow conditionals to test validity, e.g. `if (weak_ptr) {...}`;
  ///
  explicit operator bool() const { return get() != nullptr; }

  ///
  /// Returns false if the WeakPtr is confirmed to be invalid. This call is safe
  /// to make from any thread, e.g. to optimize away unnecessary work, but
  /// operator bool() must always be called, on the correct thread, before
  /// actually using the pointer.
  ///
  /// Warning: as with any object, this call is only thread-safe if the WeakPtr
  /// instance isn't being re-assigned or reset() racily with this call.
  ///
  bool MaybeValid() const { return ref_.MaybeValid(); }

  ///
  /// Returns whether the object |this| points to has been invalidated. This can
  /// be used to distinguish a WeakPtr to a destroyed object from one that has
  /// been explicitly set to null.
  ///
  bool WasInvalidated() const { return ptr_ && !ref_.IsValid(); }

 private:
  friend class cef_internal::SupportsWeakPtrBase;
  template <typename U>
  friend class WeakPtr;
  friend class SupportsWeakPtr<T>;
  friend class WeakPtrFactory<T>;

  WeakPtr(const cef_internal::WeakReference& ref, T* ptr)
      : WeakPtrBase(ref, reinterpret_cast<uintptr_t>(ptr)) {}
};

///
/// Allow callers to compare WeakPtrs against nullptr to test validity.
///
template <class T>
bool operator!=(const WeakPtr<T>& weak_ptr, std::nullptr_t) {
  return !(weak_ptr == nullptr);
}
template <class T>
bool operator!=(std::nullptr_t, const WeakPtr<T>& weak_ptr) {
  return weak_ptr != nullptr;
}
template <class T>
bool operator==(const WeakPtr<T>& weak_ptr, std::nullptr_t) {
  return weak_ptr.get() == nullptr;
}
template <class T>
bool operator==(std::nullptr_t, const WeakPtr<T>& weak_ptr) {
  return weak_ptr == nullptr;
}

namespace cef_internal {
class WeakPtrFactoryBase {
 protected:
  WeakPtrFactoryBase(uintptr_t ptr);
  ~WeakPtrFactoryBase();
  cef_internal::WeakReferenceOwner weak_reference_owner_;
  uintptr_t ptr_;
};
}  // namespace cef_internal

///
/// A class may be composed of a WeakPtrFactory and thereby control how it
/// exposes weak pointers to itself.  This is helpful if you only need weak
/// pointers within the implementation of a class.  This class is also useful
/// when working with primitive types.  For example, you could have a
/// WeakPtrFactory<bool> that is used to pass around a weak reference to a
/// bool.
///
template <class T>
class WeakPtrFactory : public cef_internal::WeakPtrFactoryBase {
 public:
  WeakPtrFactory() = delete;

  explicit WeakPtrFactory(T* ptr)
      : WeakPtrFactoryBase(reinterpret_cast<uintptr_t>(ptr)) {}

  WeakPtrFactory(const WeakPtrFactory&) = delete;
  WeakPtrFactory& operator=(const WeakPtrFactory&) = delete;

  ~WeakPtrFactory() = default;

  WeakPtr<T> GetWeakPtr() const {
    return WeakPtr<T>(weak_reference_owner_.GetRef(),
                      reinterpret_cast<T*>(ptr_));
  }

  ///
  /// Call this method to invalidate all existing weak pointers.
  ///
  void InvalidateWeakPtrs() {
    DCHECK(ptr_);
    weak_reference_owner_.Invalidate();
  }

  ///
  /// Call this method to determine if any weak pointers exist.
  ///
  bool HasWeakPtrs() const {
    DCHECK(ptr_);
    return weak_reference_owner_.HasRefs();
  }
};

///
/// A class may extend from SupportsWeakPtr to let others take weak pointers to
/// it. This avoids the class itself implementing boilerplate to dispense weak
/// pointers.  However, since SupportsWeakPtr's destructor won't invalidate
/// weak pointers to the class until after the derived class' members have been
/// destroyed, its use can lead to subtle use-after-destroy issues.
///
template <class T>
class SupportsWeakPtr : public cef_internal::SupportsWeakPtrBase {
 public:
  SupportsWeakPtr() = default;

  SupportsWeakPtr(const SupportsWeakPtr&) = delete;
  SupportsWeakPtr& operator=(const SupportsWeakPtr&) = delete;

  WeakPtr<T> AsWeakPtr() {
    return WeakPtr<T>(weak_reference_owner_.GetRef(), static_cast<T*>(this));
  }

 protected:
  ~SupportsWeakPtr() = default;

 private:
  cef_internal::WeakReferenceOwner weak_reference_owner_;
};

///
/// Helper function that uses type deduction to safely return a WeakPtr<Derived>
/// when Derived doesn't directly extend SupportsWeakPtr<Derived>, instead it
/// extends a Base that extends SupportsWeakPtr<Base>.
///
/// EXAMPLE:
/// <pre>
///   class Base : public base::SupportsWeakPtr<Producer> {};
///   class Derived : public Base {};
///
///   Derived derived;
///   base::WeakPtr<Derived> ptr = base::AsWeakPtr(&derived);
/// </pre>
///
/// Note that the following doesn't work (invalid type conversion) since
/// Derived::AsWeakPtr() is WeakPtr<Base> SupportsWeakPtr<Base>::AsWeakPtr(),
/// and there's no way to safely cast WeakPtr<Base> to WeakPtr<Derived> at
/// the caller.
///
/// <pre>
///   base::WeakPtr<Derived> ptr = derived.AsWeakPtr();  // Fails.
/// </pre>
///
template <typename Derived>
WeakPtr<Derived> AsWeakPtr(Derived* t) {
  return cef_internal::SupportsWeakPtrBase::StaticAsWeakPtr<Derived>(t);
}

}  // namespace base

#endif  // !USING_CHROMIUM_INCLUDES

#endif  // CEF_INCLUDE_BASE_CEF_WEAK_PTR_H_

// Copyright (c) 2012 Google Inc. All rights reserved.
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

// Do not include this header file directly. Use base/cef_bind.h or
// base/cef_callback.h instead.

// This file contains utility functions and classes that help the
// implementation, and management of the Callback objects.

#ifndef CEF_INCLUDE_BASE_INTERNAL_CEF_CALLBACK_INTERNAL_H_
#define CEF_INCLUDE_BASE_INTERNAL_CEF_CALLBACK_INTERNAL_H_

#include "include/base/cef_callback_forward.h"
#include "include/base/cef_ref_counted.h"

namespace base {

struct FakeBindState;

namespace cef_internal {

class BindStateBase;
class FinallyExecutorCommon;
class ThenAndCatchExecutorCommon;

template <typename ReturnType>
class PostTaskExecutor;

template <typename Functor, typename... BoundArgs>
struct BindState;

class CallbackBase;
class CallbackBaseCopyable;

struct BindStateBaseRefCountTraits {
  static void Destruct(const BindStateBase*);
};

template <typename T>
using PassingType = std::conditional_t<std::is_scalar<T>::value, T, T&&>;

// BindStateBase is used to provide an opaque handle that the Callback
// class can use to represent a function object with bound arguments.  It
// behaves as an existential type that is used by a corresponding
// DoInvoke function to perform the function execution.  This allows
// us to shield the Callback class from the types of the bound argument via
// "type erasure."
// At the base level, the only task is to add reference counting data. Avoid
// using or inheriting any virtual functions. Creating a vtable for every
// BindState template instantiation results in a lot of bloat. Its only task is
// to call the destructor which can be done with a function pointer.
class BindStateBase
    : public RefCountedThreadSafe<BindStateBase, BindStateBaseRefCountTraits> {
 public:
  REQUIRE_ADOPTION_FOR_REFCOUNTED_TYPE();

  enum CancellationQueryMode {
    IS_CANCELLED,
    MAYBE_VALID,
  };

  using InvokeFuncStorage = void (*)();

  BindStateBase(const BindStateBase&) = delete;
  BindStateBase& operator=(const BindStateBase&) = delete;

 private:
  BindStateBase(InvokeFuncStorage polymorphic_invoke,
                void (*destructor)(const BindStateBase*));
  BindStateBase(InvokeFuncStorage polymorphic_invoke,
                void (*destructor)(const BindStateBase*),
                bool (*query_cancellation_traits)(const BindStateBase*,
                                                  CancellationQueryMode mode));

  ~BindStateBase() = default;

  friend struct BindStateBaseRefCountTraits;
  friend class RefCountedThreadSafe<BindStateBase, BindStateBaseRefCountTraits>;

  friend class CallbackBase;
  friend class CallbackBaseCopyable;

  // Allowlist subclasses that access the destructor of BindStateBase.
  template <typename Functor, typename... BoundArgs>
  friend struct BindState;
  friend struct ::base::FakeBindState;

  bool IsCancelled() const {
    return query_cancellation_traits_(this, IS_CANCELLED);
  }

  bool MaybeValid() const {
    return query_cancellation_traits_(this, MAYBE_VALID);
  }

  // In C++, it is safe to cast function pointers to function pointers of
  // another type. It is not okay to use void*. We create a InvokeFuncStorage
  // that that can store our function pointer, and then cast it back to
  // the original type on usage.
  InvokeFuncStorage polymorphic_invoke_;

  // Pointer to a function that will properly destroy |this|.
  void (*destructor_)(const BindStateBase*);
  bool (*query_cancellation_traits_)(const BindStateBase*,
                                     CancellationQueryMode mode);
};

// Holds the Callback methods that don't require specialization to reduce
// template bloat.
// CallbackBase<MoveOnly> is a direct base class of MoveOnly callbacks, and
// CallbackBase<Copyable> uses CallbackBase<MoveOnly> for its implementation.
class CallbackBase {
 public:
  inline CallbackBase(CallbackBase&& c) noexcept;
  CallbackBase& operator=(CallbackBase&& c) noexcept;

  explicit CallbackBase(const CallbackBaseCopyable& c);
  CallbackBase& operator=(const CallbackBaseCopyable& c);

  explicit CallbackBase(CallbackBaseCopyable&& c) noexcept;
  CallbackBase& operator=(CallbackBaseCopyable&& c) noexcept;

  // Returns true if Callback is null (doesn't refer to anything).
  bool is_null() const { return !bind_state_; }
  explicit operator bool() const { return !is_null(); }

  // Returns true if the callback invocation will be nop due to an cancellation.
  // It's invalid to call this on uninitialized callback.
  //
  // Must be called on the Callback's destination sequence.
  bool IsCancelled() const;

  // If this returns false, the callback invocation will be a nop due to a
  // cancellation. This may(!) still return true, even on a cancelled callback.
  //
  // This function is thread-safe.
  bool MaybeValid() const;

  // Returns the Callback into an uninitialized state.
  void Reset();

 protected:
  friend class FinallyExecutorCommon;
  friend class ThenAndCatchExecutorCommon;

  template <typename ReturnType>
  friend class PostTaskExecutor;

  using InvokeFuncStorage = BindStateBase::InvokeFuncStorage;

  // Returns true if this callback equals |other|. |other| may be null.
  bool EqualsInternal(const CallbackBase& other) const;

  constexpr inline CallbackBase();

  // Allow initializing of |bind_state_| via the constructor to avoid default
  // initialization of the scoped_refptr.
  explicit inline CallbackBase(BindStateBase* bind_state);

  InvokeFuncStorage polymorphic_invoke() const {
    return bind_state_->polymorphic_invoke_;
  }

  // Force the destructor to be instantiated inside this translation unit so
  // that our subclasses will not get inlined versions.  Avoids more template
  // bloat.
  ~CallbackBase();

  scoped_refptr<BindStateBase> bind_state_;
};

constexpr CallbackBase::CallbackBase() = default;
CallbackBase::CallbackBase(CallbackBase&&) noexcept = default;
CallbackBase::CallbackBase(BindStateBase* bind_state)
    : bind_state_(AdoptRef(bind_state)) {}

// CallbackBase<Copyable> is a direct base class of Copyable Callbacks.
class CallbackBaseCopyable : public CallbackBase {
 public:
  CallbackBaseCopyable(const CallbackBaseCopyable& c);
  CallbackBaseCopyable(CallbackBaseCopyable&& c) noexcept = default;
  CallbackBaseCopyable& operator=(const CallbackBaseCopyable& c);
  CallbackBaseCopyable& operator=(CallbackBaseCopyable&& c) noexcept;

 protected:
  constexpr CallbackBaseCopyable() = default;
  explicit CallbackBaseCopyable(BindStateBase* bind_state)
      : CallbackBase(bind_state) {}
  ~CallbackBaseCopyable() = default;
};

// Helpers for the `Then()` implementation.
template <typename OriginalCallback, typename ThenCallback>
struct ThenHelper;

// Specialization when original callback returns `void`.
template <template <typename> class OriginalCallback,
          template <typename>
          class ThenCallback,
          typename... OriginalArgs,
          typename ThenR,
          typename... ThenArgs>
struct ThenHelper<OriginalCallback<void(OriginalArgs...)>,
                  ThenCallback<ThenR(ThenArgs...)>> {
  static_assert(sizeof...(ThenArgs) == 0,
                "|then| callback cannot accept parameters if |this| has a "
                "void return type.");

  static auto CreateTrampoline() {
    return [](OriginalCallback<void(OriginalArgs...)> c1,
              ThenCallback<ThenR(ThenArgs...)> c2, OriginalArgs... c1_args) {
      std::move(c1).Run(std::forward<OriginalArgs>(c1_args)...);
      return std::move(c2).Run();
    };
  }
};

// Specialization when original callback returns a non-void type.
template <template <typename> class OriginalCallback,
          template <typename>
          class ThenCallback,
          typename OriginalR,
          typename... OriginalArgs,
          typename ThenR,
          typename... ThenArgs>
struct ThenHelper<OriginalCallback<OriginalR(OriginalArgs...)>,
                  ThenCallback<ThenR(ThenArgs...)>> {
  static_assert(sizeof...(ThenArgs) == 1,
                "|then| callback must accept exactly one parameter if |this| "
                "has a non-void return type.");
  // TODO(dcheng): This should probably check is_convertible as well (same with
  // `AssertBindArgsValidity`).
  static_assert(std::is_constructible<ThenArgs..., OriginalR&&>::value,
                "|then| callback's parameter must be constructible from "
                "return type of |this|.");

  static auto CreateTrampoline() {
    return [](OriginalCallback<OriginalR(OriginalArgs...)> c1,
              ThenCallback<ThenR(ThenArgs...)> c2, OriginalArgs... c1_args) {
      return std::move(c2).Run(
          std::move(c1).Run(std::forward<OriginalArgs>(c1_args)...));
    };
  }
};

}  // namespace cef_internal
}  // namespace base

#endif  // CEF_INCLUDE_BASE_INTERNAL_CEF_CALLBACK_INTERNAL_H_

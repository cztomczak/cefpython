// Copyright (c) 2011 Google Inc. All rights reserved.
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

// Do not include this header file directly. Use base/cef_bind.h instead.

// See base/cef_callback.h for user documentation.
//
//
// CONCEPTS:
//  Functor -- A movable type representing something that should be called.
//             All function pointers and Callback<> are functors even if the
//             invocation syntax differs.
//  RunType -- A function type (as opposed to function _pointer_ type) for
//             a Callback<>::Run().  Usually just a convenience typedef.
//  (Bound)Args -- A set of types that stores the arguments.
//
// Types:
//  ForceVoidReturn<> -- Helper class for translating function signatures to
//                       equivalent forms with a "void" return type.
//  FunctorTraits<> -- Type traits used to determine the correct RunType and
//                     invocation manner for a Functor.  This is where function
//                     signature adapters are applied.
//  InvokeHelper<> -- Take a Functor + arguments and actully invokes it.
//                    Handle the differing syntaxes needed for WeakPtr<>
//                    support.  This is separate from Invoker to avoid creating
//                    multiple version of Invoker<>.
//  Invoker<> -- Unwraps the curried parameters and executes the Functor.
//  BindState<> -- Stores the curried parameters, and is the main entry point
//                 into the Bind() system.

#ifndef CEF_INCLUDE_BASE_INTERNAL_CEF_BIND_INTERNAL_H_
#define CEF_INCLUDE_BASE_INTERNAL_CEF_BIND_INTERNAL_H_

#include <stddef.h>

#include <functional>
#include <memory>
#include <tuple>
#include <type_traits>
#include <utility>

#include "include/base/cef_build.h"
#include "include/base/cef_compiler_specific.h"
#include "include/base/cef_logging.h"
#include "include/base/cef_weak_ptr.h"
#include "include/base/internal/cef_callback_internal.h"
#include "include/base/internal/cef_raw_scoped_refptr_mismatch_checker.h"

#if defined(OS_APPLE) && !HAS_FEATURE(objc_arc)
#include "include/base/internal/cef_scoped_block_mac.h"
#endif

#if defined(OS_WIN)
namespace Microsoft {
namespace WRL {
template <typename>
class ComPtr;
}  // namespace WRL
}  // namespace Microsoft
#endif

namespace base {

template <typename T>
struct IsWeakReceiver;

template <typename>
struct BindUnwrapTraits;

template <typename Functor, typename BoundArgsTuple, typename SFINAE = void>
struct CallbackCancellationTraits;

namespace cef_internal {

template <typename Functor, typename SFINAE = void>
struct FunctorTraits;

template <typename T>
class UnretainedWrapper {
 public:
  explicit UnretainedWrapper(T* o) : ptr_(o) {}
  T* get() const { return ptr_; }

 private:
  T* ptr_;
};

template <typename T>
class RetainedRefWrapper {
 public:
  explicit RetainedRefWrapper(T* o) : ptr_(o) {}
  explicit RetainedRefWrapper(scoped_refptr<T> o) : ptr_(std::move(o)) {}
  T* get() const { return ptr_.get(); }

 private:
  scoped_refptr<T> ptr_;
};

template <typename T>
struct IgnoreResultHelper {
  explicit IgnoreResultHelper(T functor) : functor_(std::move(functor)) {}
  explicit operator bool() const { return !!functor_; }

  T functor_;
};

template <typename T, typename Deleter = std::default_delete<T>>
class OwnedWrapper {
 public:
  explicit OwnedWrapper(T* o) : ptr_(o) {}
  explicit OwnedWrapper(std::unique_ptr<T, Deleter>&& ptr)
      : ptr_(std::move(ptr)) {}
  T* get() const { return ptr_.get(); }

 private:
  std::unique_ptr<T, Deleter> ptr_;
};

template <typename T>
class OwnedRefWrapper {
 public:
  explicit OwnedRefWrapper(const T& t) : t_(t) {}
  explicit OwnedRefWrapper(T&& t) : t_(std::move(t)) {}
  T& get() const { return t_; }

 private:
  mutable T t_;
};

// PassedWrapper is a copyable adapter for a scoper that ignores const.
//
// It is needed to get around the fact that Bind() takes a const reference to
// all its arguments.  Because Bind() takes a const reference to avoid
// unnecessary copies, it is incompatible with movable-but-not-copyable
// types; doing a destructive "move" of the type into Bind() would violate
// the const correctness.
//
// This conundrum cannot be solved without either C++11 rvalue references or
// a O(2^n) blowup of Bind() templates to handle each combination of regular
// types and movable-but-not-copyable types.  Thus we introduce a wrapper type
// that is copyable to transmit the correct type information down into
// BindState<>. Ignoring const in this type makes sense because it is only
// created when we are explicitly trying to do a destructive move.
//
// Two notes:
//  1) PassedWrapper supports any type that has a move constructor, however
//     the type will need to be specifically allowed in order for it to be
//     bound to a Callback. We guard this explicitly at the call of Passed()
//     to make for clear errors. Things not given to Passed() will be forwarded
//     and stored by value which will not work for general move-only types.
//  2) is_valid_ is distinct from NULL because it is valid to bind a "NULL"
//     scoper to a Callback and allow the Callback to execute once.
template <typename T>
class PassedWrapper {
 public:
  explicit PassedWrapper(T&& scoper)
      : is_valid_(true), scoper_(std::move(scoper)) {}
  PassedWrapper(PassedWrapper&& other)
      : is_valid_(other.is_valid_), scoper_(std::move(other.scoper_)) {}
  T Take() const {
    CHECK(is_valid_);
    is_valid_ = false;
    return std::move(scoper_);
  }

 private:
  mutable bool is_valid_;
  mutable T scoper_;
};

template <typename T>
using Unwrapper = BindUnwrapTraits<std::decay_t<T>>;

template <typename T>
decltype(auto) Unwrap(T&& o) {
  return Unwrapper<T>::Unwrap(std::forward<T>(o));
}

// IsWeakMethod is a helper that determine if we are binding a WeakPtr<> to a
// method.  It is used internally by Bind() to select the correct
// InvokeHelper that will no-op itself in the event the WeakPtr<> for
// the target object is invalidated.
//
// The first argument should be the type of the object that will be received by
// the method.
template <bool is_method, typename... Args>
struct IsWeakMethod : std::false_type {};

template <typename T, typename... Args>
struct IsWeakMethod<true, T, Args...> : IsWeakReceiver<T> {};

// Packs a list of types to hold them in a single type.
template <typename... Types>
struct TypeList {};

// Used for DropTypeListItem implementation.
template <size_t n, typename List>
struct DropTypeListItemImpl;

// Do not use enable_if and SFINAE here to avoid MSVC2013 compile failure.
template <size_t n, typename T, typename... List>
struct DropTypeListItemImpl<n, TypeList<T, List...>>
    : DropTypeListItemImpl<n - 1, TypeList<List...>> {};

template <typename T, typename... List>
struct DropTypeListItemImpl<0, TypeList<T, List...>> {
  using Type = TypeList<T, List...>;
};

template <>
struct DropTypeListItemImpl<0, TypeList<>> {
  using Type = TypeList<>;
};

// A type-level function that drops |n| list item from given TypeList.
template <size_t n, typename List>
using DropTypeListItem = typename DropTypeListItemImpl<n, List>::Type;

// Used for TakeTypeListItem implementation.
template <size_t n, typename List, typename... Accum>
struct TakeTypeListItemImpl;

// Do not use enable_if and SFINAE here to avoid MSVC2013 compile failure.
template <size_t n, typename T, typename... List, typename... Accum>
struct TakeTypeListItemImpl<n, TypeList<T, List...>, Accum...>
    : TakeTypeListItemImpl<n - 1, TypeList<List...>, Accum..., T> {};

template <typename T, typename... List, typename... Accum>
struct TakeTypeListItemImpl<0, TypeList<T, List...>, Accum...> {
  using Type = TypeList<Accum...>;
};

template <typename... Accum>
struct TakeTypeListItemImpl<0, TypeList<>, Accum...> {
  using Type = TypeList<Accum...>;
};

// A type-level function that takes first |n| list item from given TypeList.
// E.g. TakeTypeListItem<3, TypeList<A, B, C, D>> is evaluated to
// TypeList<A, B, C>.
template <size_t n, typename List>
using TakeTypeListItem = typename TakeTypeListItemImpl<n, List>::Type;

// Used for ConcatTypeLists implementation.
template <typename List1, typename List2>
struct ConcatTypeListsImpl;

template <typename... Types1, typename... Types2>
struct ConcatTypeListsImpl<TypeList<Types1...>, TypeList<Types2...>> {
  using Type = TypeList<Types1..., Types2...>;
};

// A type-level function that concats two TypeLists.
template <typename List1, typename List2>
using ConcatTypeLists = typename ConcatTypeListsImpl<List1, List2>::Type;

// Used for MakeFunctionType implementation.
template <typename R, typename ArgList>
struct MakeFunctionTypeImpl;

template <typename R, typename... Args>
struct MakeFunctionTypeImpl<R, TypeList<Args...>> {
  // MSVC 2013 doesn't support Type Alias of function types.
  // Revisit this after we update it to newer version.
  typedef R Type(Args...);
};

// A type-level function that constructs a function type that has |R| as its
// return type and has TypeLists items as its arguments.
template <typename R, typename ArgList>
using MakeFunctionType = typename MakeFunctionTypeImpl<R, ArgList>::Type;

// Used for ExtractArgs and ExtractReturnType.
template <typename Signature>
struct ExtractArgsImpl;

template <typename R, typename... Args>
struct ExtractArgsImpl<R(Args...)> {
  using ReturnType = R;
  using ArgsList = TypeList<Args...>;
};

// A type-level function that extracts function arguments into a TypeList.
// E.g. ExtractArgs<R(A, B, C)> is evaluated to TypeList<A, B, C>.
template <typename Signature>
using ExtractArgs = typename ExtractArgsImpl<Signature>::ArgsList;

// A type-level function that extracts the return type of a function.
// E.g. ExtractReturnType<R(A, B, C)> is evaluated to R.
template <typename Signature>
using ExtractReturnType = typename ExtractArgsImpl<Signature>::ReturnType;

template <typename Callable,
          typename Signature = decltype(&Callable::operator())>
struct ExtractCallableRunTypeImpl;

template <typename Callable, typename R, typename... Args>
struct ExtractCallableRunTypeImpl<Callable, R (Callable::*)(Args...)> {
  using Type = R(Args...);
};

template <typename Callable, typename R, typename... Args>
struct ExtractCallableRunTypeImpl<Callable, R (Callable::*)(Args...) const> {
  using Type = R(Args...);
};

// Evaluated to RunType of the given callable type.
// Example:
//   auto f = [](int, char*) { return 0.1; };
//   ExtractCallableRunType<decltype(f)>
//   is evaluated to
//   double(int, char*);
template <typename Callable>
using ExtractCallableRunType =
    typename ExtractCallableRunTypeImpl<Callable>::Type;

// IsCallableObject<Functor> is std::true_type if |Functor| has operator().
// Otherwise, it's std::false_type.
// Example:
//   IsCallableObject<void(*)()>::value is false.
//
//   struct Foo {};
//   IsCallableObject<void(Foo::*)()>::value is false.
//
//   int i = 0;
//   auto f = [i]() {};
//   IsCallableObject<decltype(f)>::value is false.
template <typename Functor, typename SFINAE = void>
struct IsCallableObject : std::false_type {};

template <typename Callable>
struct IsCallableObject<Callable, std::void_t<decltype(&Callable::operator())>>
    : std::true_type {};

// HasRefCountedTypeAsRawPtr inherits from true_type when any of the |Args| is a
// raw pointer to a RefCounted type.
template <typename... Ts>
struct HasRefCountedTypeAsRawPtr
    : std::disjunction<NeedsScopedRefptrButGetsRawPtr<Ts>...> {};

// ForceVoidReturn<>
//
// Set of templates that support forcing the function return type to void.
template <typename Sig>
struct ForceVoidReturn;

template <typename R, typename... Args>
struct ForceVoidReturn<R(Args...)> {
  using RunType = void(Args...);
};

// FunctorTraits<>
//
// See description at top of file.
template <typename Functor, typename SFINAE>
struct FunctorTraits;

// For empty callable types.
// This specialization is intended to allow binding captureless lambdas, based
// on the fact that captureless lambdas are empty while capturing lambdas are
// not. This also allows any functors as far as it's an empty class.
// Example:
//
//   // Captureless lambdas are allowed.
//   []() {return 42;};
//
//   // Capturing lambdas are *not* allowed.
//   int x;
//   [x]() {return x;};
//
//   // Any empty class with operator() is allowed.
//   struct Foo {
//     void operator()() const {}
//     // No non-static member variable and no virtual functions.
//   };
template <typename Functor>
struct FunctorTraits<Functor,
                     std::enable_if_t<IsCallableObject<Functor>::value &&
                                      std::is_empty<Functor>::value>> {
  using RunType = ExtractCallableRunType<Functor>;
  static constexpr bool is_method = false;
  static constexpr bool is_nullable = false;
  static constexpr bool is_callback = false;

  template <typename RunFunctor, typename... RunArgs>
  static ExtractReturnType<RunType> Invoke(RunFunctor&& functor,
                                           RunArgs&&... args) {
    return std::forward<RunFunctor>(functor)(std::forward<RunArgs>(args)...);
  }
};

// For functions.
template <typename R, typename... Args>
struct FunctorTraits<R (*)(Args...)> {
  using RunType = R(Args...);
  static constexpr bool is_method = false;
  static constexpr bool is_nullable = true;
  static constexpr bool is_callback = false;

  template <typename Function, typename... RunArgs>
  static R Invoke(Function&& function, RunArgs&&... args) {
    return std::forward<Function>(function)(std::forward<RunArgs>(args)...);
  }
};

#if defined(OS_WIN) && !defined(ARCH_CPU_64_BITS)

// For functions.
template <typename R, typename... Args>
struct FunctorTraits<R(__stdcall*)(Args...)> {
  using RunType = R(Args...);
  static constexpr bool is_method = false;
  static constexpr bool is_nullable = true;
  static constexpr bool is_callback = false;

  template <typename... RunArgs>
  static R Invoke(R(__stdcall* function)(Args...), RunArgs&&... args) {
    return function(std::forward<RunArgs>(args)...);
  }
};

// For functions.
template <typename R, typename... Args>
struct FunctorTraits<R(__fastcall*)(Args...)> {
  using RunType = R(Args...);
  static constexpr bool is_method = false;
  static constexpr bool is_nullable = true;
  static constexpr bool is_callback = false;

  template <typename... RunArgs>
  static R Invoke(R(__fastcall* function)(Args...), RunArgs&&... args) {
    return function(std::forward<RunArgs>(args)...);
  }
};

#endif  // defined(OS_WIN) && !defined(ARCH_CPU_64_BITS)

#if defined(OS_APPLE)

// Support for Objective-C blocks. There are two implementation depending
// on whether Automated Reference Counting (ARC) is enabled. When ARC is
// enabled, then the block itself can be bound as the compiler will ensure
// its lifetime will be correctly managed. Otherwise, require the block to
// be wrapped in a base::mac::ScopedBlock (via base::RetainBlock) that will
// correctly manage the block lifetime.
//
// The two implementation ensure that the One Definition Rule (ODR) is not
// broken (it is not possible to write a template base::RetainBlock that would
// work correctly both with ARC enabled and disabled).

#if HAS_FEATURE(objc_arc)

template <typename R, typename... Args>
struct FunctorTraits<R (^)(Args...)> {
  using RunType = R(Args...);
  static constexpr bool is_method = false;
  static constexpr bool is_nullable = true;
  static constexpr bool is_callback = false;

  template <typename BlockType, typename... RunArgs>
  static R Invoke(BlockType&& block, RunArgs&&... args) {
    // According to LLVM documentation (6.3), "local variables of automatic
    // storage duration do not have precise lifetime." Use objc_precise_lifetime
    // to ensure that the Objective-C block is not deallocated until it has
    // finished executing even if the Callback<> is destroyed during the block
    // execution.
    // https://clang.llvm.org/docs/AutomaticReferenceCounting.html#precise-lifetime-semantics
    __attribute__((objc_precise_lifetime)) R (^scoped_block)(Args...) = block;
    return scoped_block(std::forward<RunArgs>(args)...);
  }
};

#else  // HAS_FEATURE(objc_arc)

template <typename R, typename... Args>
struct FunctorTraits<base::mac::ScopedBlock<R (^)(Args...)>> {
  using RunType = R(Args...);
  static constexpr bool is_method = false;
  static constexpr bool is_nullable = true;
  static constexpr bool is_callback = false;

  template <typename BlockType, typename... RunArgs>
  static R Invoke(BlockType&& block, RunArgs&&... args) {
    // Copy the block to ensure that the Objective-C block is not deallocated
    // until it has finished executing even if the Callback<> is destroyed
    // during the block execution.
    base::mac::ScopedBlock<R (^)(Args...)> scoped_block(block);
    return scoped_block.get()(std::forward<RunArgs>(args)...);
  }
};

#endif  // HAS_FEATURE(objc_arc)
#endif  // defined(OS_APPLE)

// For methods.
template <typename R, typename Receiver, typename... Args>
struct FunctorTraits<R (Receiver::*)(Args...)> {
  using RunType = R(Receiver*, Args...);
  static constexpr bool is_method = true;
  static constexpr bool is_nullable = true;
  static constexpr bool is_callback = false;

  template <typename Method, typename ReceiverPtr, typename... RunArgs>
  static R Invoke(Method method,
                  ReceiverPtr&& receiver_ptr,
                  RunArgs&&... args) {
    return ((*receiver_ptr).*method)(std::forward<RunArgs>(args)...);
  }
};

// For const methods.
template <typename R, typename Receiver, typename... Args>
struct FunctorTraits<R (Receiver::*)(Args...) const> {
  using RunType = R(const Receiver*, Args...);
  static constexpr bool is_method = true;
  static constexpr bool is_nullable = true;
  static constexpr bool is_callback = false;

  template <typename Method, typename ReceiverPtr, typename... RunArgs>
  static R Invoke(Method method,
                  ReceiverPtr&& receiver_ptr,
                  RunArgs&&... args) {
    return ((*receiver_ptr).*method)(std::forward<RunArgs>(args)...);
  }
};

#if defined(OS_WIN) && !defined(ARCH_CPU_64_BITS)

// For __stdcall methods.
template <typename R, typename Receiver, typename... Args>
struct FunctorTraits<R (__stdcall Receiver::*)(Args...)> {
  using RunType = R(Receiver*, Args...);
  static constexpr bool is_method = true;
  static constexpr bool is_nullable = true;
  static constexpr bool is_callback = false;

  template <typename Method, typename ReceiverPtr, typename... RunArgs>
  static R Invoke(Method method,
                  ReceiverPtr&& receiver_ptr,
                  RunArgs&&... args) {
    return ((*receiver_ptr).*method)(std::forward<RunArgs>(args)...);
  }
};

// For __stdcall const methods.
template <typename R, typename Receiver, typename... Args>
struct FunctorTraits<R (__stdcall Receiver::*)(Args...) const> {
  using RunType = R(const Receiver*, Args...);
  static constexpr bool is_method = true;
  static constexpr bool is_nullable = true;
  static constexpr bool is_callback = false;

  template <typename Method, typename ReceiverPtr, typename... RunArgs>
  static R Invoke(Method method,
                  ReceiverPtr&& receiver_ptr,
                  RunArgs&&... args) {
    return ((*receiver_ptr).*method)(std::forward<RunArgs>(args)...);
  }
};

#endif  // defined(OS_WIN) && !defined(ARCH_CPU_64_BITS)

#ifdef __cpp_noexcept_function_type
// noexcept makes a distinct function type in C++17.
// I.e. `void(*)()` and `void(*)() noexcept` are same in pre-C++17, and
// different in C++17.
template <typename R, typename... Args>
struct FunctorTraits<R (*)(Args...) noexcept> : FunctorTraits<R (*)(Args...)> {
};

template <typename R, typename Receiver, typename... Args>
struct FunctorTraits<R (Receiver::*)(Args...) noexcept>
    : FunctorTraits<R (Receiver::*)(Args...)> {};

template <typename R, typename Receiver, typename... Args>
struct FunctorTraits<R (Receiver::*)(Args...) const noexcept>
    : FunctorTraits<R (Receiver::*)(Args...) const> {};
#endif

// For IgnoreResults.
template <typename T>
struct FunctorTraits<IgnoreResultHelper<T>> : FunctorTraits<T> {
  using RunType =
      typename ForceVoidReturn<typename FunctorTraits<T>::RunType>::RunType;

  template <typename IgnoreResultType, typename... RunArgs>
  static void Invoke(IgnoreResultType&& ignore_result_helper,
                     RunArgs&&... args) {
    FunctorTraits<T>::Invoke(
        std::forward<IgnoreResultType>(ignore_result_helper).functor_,
        std::forward<RunArgs>(args)...);
  }
};

// For OnceCallbacks.
template <typename R, typename... Args>
struct FunctorTraits<OnceCallback<R(Args...)>> {
  using RunType = R(Args...);
  static constexpr bool is_method = false;
  static constexpr bool is_nullable = true;
  static constexpr bool is_callback = true;

  template <typename CallbackType, typename... RunArgs>
  static R Invoke(CallbackType&& callback, RunArgs&&... args) {
    DCHECK(!callback.is_null());
    return std::forward<CallbackType>(callback).Run(
        std::forward<RunArgs>(args)...);
  }
};

// For RepeatingCallbacks.
template <typename R, typename... Args>
struct FunctorTraits<RepeatingCallback<R(Args...)>> {
  using RunType = R(Args...);
  static constexpr bool is_method = false;
  static constexpr bool is_nullable = true;
  static constexpr bool is_callback = true;

  template <typename CallbackType, typename... RunArgs>
  static R Invoke(CallbackType&& callback, RunArgs&&... args) {
    DCHECK(!callback.is_null());
    return std::forward<CallbackType>(callback).Run(
        std::forward<RunArgs>(args)...);
  }
};

template <typename Functor>
using MakeFunctorTraits = FunctorTraits<std::decay_t<Functor>>;

// InvokeHelper<>
//
// There are 2 logical InvokeHelper<> specializations: normal, WeakCalls.
//
// The normal type just calls the underlying runnable.
//
// WeakCalls need special syntax that is applied to the first argument to check
// if they should no-op themselves.
template <bool is_weak_call, typename ReturnType>
struct InvokeHelper;

template <typename ReturnType>
struct InvokeHelper<false, ReturnType> {
  template <typename Functor, typename... RunArgs>
  static inline ReturnType MakeItSo(Functor&& functor, RunArgs&&... args) {
    using Traits = MakeFunctorTraits<Functor>;
    return Traits::Invoke(std::forward<Functor>(functor),
                          std::forward<RunArgs>(args)...);
  }
};

template <typename ReturnType>
struct InvokeHelper<true, ReturnType> {
  // WeakCalls are only supported for functions with a void return type.
  // Otherwise, the function result would be undefined if the WeakPtr<>
  // is invalidated.
  static_assert(std::is_void<ReturnType>::value,
                "weak_ptrs can only bind to methods without return values");

  template <typename Functor, typename BoundWeakPtr, typename... RunArgs>
  static inline void MakeItSo(Functor&& functor,
                              BoundWeakPtr&& weak_ptr,
                              RunArgs&&... args) {
    if (!weak_ptr) {
      return;
    }
    using Traits = MakeFunctorTraits<Functor>;
    Traits::Invoke(std::forward<Functor>(functor),
                   std::forward<BoundWeakPtr>(weak_ptr),
                   std::forward<RunArgs>(args)...);
  }
};

// Invoker<>
//
// See description at the top of the file.
template <typename StorageType, typename UnboundRunType>
struct Invoker;

template <typename StorageType, typename R, typename... UnboundArgs>
struct Invoker<StorageType, R(UnboundArgs...)> {
  static R RunOnce(BindStateBase* base,
                   PassingType<UnboundArgs>... unbound_args) {
    // Local references to make debugger stepping easier. If in a debugger,
    // you really want to warp ahead and step through the
    // InvokeHelper<>::MakeItSo() call below.
    StorageType* storage = static_cast<StorageType*>(base);
    static constexpr size_t num_bound_args =
        std::tuple_size<decltype(storage->bound_args_)>::value;
    return RunImpl(std::move(storage->functor_),
                   std::move(storage->bound_args_),
                   std::make_index_sequence<num_bound_args>(),
                   std::forward<UnboundArgs>(unbound_args)...);
  }

  static R Run(BindStateBase* base, PassingType<UnboundArgs>... unbound_args) {
    // Local references to make debugger stepping easier. If in a debugger,
    // you really want to warp ahead and step through the
    // InvokeHelper<>::MakeItSo() call below.
    const StorageType* storage = static_cast<StorageType*>(base);
    static constexpr size_t num_bound_args =
        std::tuple_size<decltype(storage->bound_args_)>::value;
    return RunImpl(storage->functor_, storage->bound_args_,
                   std::make_index_sequence<num_bound_args>(),
                   std::forward<UnboundArgs>(unbound_args)...);
  }

 private:
  template <typename Functor, typename BoundArgsTuple, size_t... indices>
  static inline R RunImpl(Functor&& functor,
                          BoundArgsTuple&& bound,
                          std::index_sequence<indices...>,
                          UnboundArgs&&... unbound_args) {
    static constexpr bool is_method = MakeFunctorTraits<Functor>::is_method;

    using DecayedArgsTuple = std::decay_t<BoundArgsTuple>;
    static constexpr bool is_weak_call =
        IsWeakMethod<is_method,
                     std::tuple_element_t<indices, DecayedArgsTuple>...>();

    return InvokeHelper<is_weak_call, R>::MakeItSo(
        std::forward<Functor>(functor),
        Unwrap(std::get<indices>(std::forward<BoundArgsTuple>(bound)))...,
        std::forward<UnboundArgs>(unbound_args)...);
  }
};

// Extracts necessary type info from Functor and BoundArgs.
// Used to implement MakeUnboundRunType, BindOnce and BindRepeating.
template <typename Functor, typename... BoundArgs>
struct BindTypeHelper {
  static constexpr size_t num_bounds = sizeof...(BoundArgs);
  using FunctorTraits = MakeFunctorTraits<Functor>;

  // Example:
  //   When Functor is `double (Foo::*)(int, const std::string&)`, and BoundArgs
  //   is a template pack of `Foo*` and `int16_t`:
  //    - RunType is `double(Foo*, int, const std::string&)`,
  //    - ReturnType is `double`,
  //    - RunParamsList is `TypeList<Foo*, int, const std::string&>`,
  //    - BoundParamsList is `TypeList<Foo*, int>`,
  //    - UnboundParamsList is `TypeList<const std::string&>`,
  //    - BoundArgsList is `TypeList<Foo*, int16_t>`,
  //    - UnboundRunType is `double(const std::string&)`.
  using RunType = typename FunctorTraits::RunType;
  using ReturnType = ExtractReturnType<RunType>;

  using RunParamsList = ExtractArgs<RunType>;
  using BoundParamsList = TakeTypeListItem<num_bounds, RunParamsList>;
  using UnboundParamsList = DropTypeListItem<num_bounds, RunParamsList>;

  using BoundArgsList = TypeList<BoundArgs...>;

  using UnboundRunType = MakeFunctionType<ReturnType, UnboundParamsList>;
};

template <typename Functor>
std::enable_if_t<FunctorTraits<Functor>::is_nullable, bool> IsNull(
    const Functor& functor) {
  return !functor;
}

template <typename Functor>
std::enable_if_t<!FunctorTraits<Functor>::is_nullable, bool> IsNull(
    const Functor&) {
  return false;
}

// Used by QueryCancellationTraits below.
template <typename Functor, typename BoundArgsTuple, size_t... indices>
bool QueryCancellationTraitsImpl(BindStateBase::CancellationQueryMode mode,
                                 const Functor& functor,
                                 const BoundArgsTuple& bound_args,
                                 std::index_sequence<indices...>) {
  switch (mode) {
    case BindStateBase::IS_CANCELLED:
      return CallbackCancellationTraits<Functor, BoundArgsTuple>::IsCancelled(
          functor, std::get<indices>(bound_args)...);
    case BindStateBase::MAYBE_VALID:
      return CallbackCancellationTraits<Functor, BoundArgsTuple>::MaybeValid(
          functor, std::get<indices>(bound_args)...);
  }
  NOTREACHED();
  return false;
}

// Relays |base| to corresponding CallbackCancellationTraits<>::Run(). Returns
// true if the callback |base| represents is canceled.
template <typename BindStateType>
bool QueryCancellationTraits(const BindStateBase* base,
                             BindStateBase::CancellationQueryMode mode) {
  const BindStateType* storage = static_cast<const BindStateType*>(base);
  static constexpr size_t num_bound_args =
      std::tuple_size<decltype(storage->bound_args_)>::value;
  return QueryCancellationTraitsImpl(
      mode, storage->functor_, storage->bound_args_,
      std::make_index_sequence<num_bound_args>());
}

// The base case of BanUnconstructedRefCountedReceiver that checks nothing.
template <typename Functor, typename Receiver, typename... Unused>
std::enable_if_t<
    !(MakeFunctorTraits<Functor>::is_method &&
      std::is_pointer<std::decay_t<Receiver>>::value &&
      IsRefCountedType<std::remove_pointer_t<std::decay_t<Receiver>>>::value)>
BanUnconstructedRefCountedReceiver(const Receiver& receiver, Unused&&...) {}

template <typename Functor>
void BanUnconstructedRefCountedReceiver() {}

// Asserts that Callback is not the first owner of a ref-counted receiver.
template <typename Functor, typename Receiver, typename... Unused>
std::enable_if_t<
    MakeFunctorTraits<Functor>::is_method &&
    std::is_pointer<std::decay_t<Receiver>>::value &&
    IsRefCountedType<std::remove_pointer_t<std::decay_t<Receiver>>>::value>
BanUnconstructedRefCountedReceiver(const Receiver& receiver, Unused&&...) {
  DCHECK(receiver);

  // It's error prone to make the implicit first reference to ref-counted types.
  // In the example below, base::BindOnce() makes the implicit first reference
  // to the ref-counted Foo. If PostTask() failed or the posted task ran fast
  // enough, the newly created instance can be destroyed before |oo| makes
  // another reference.
  //   Foo::Foo() {
  //     base::PostTask(FROM_HERE, base::BindOnce(&Foo::Bar, this));
  //   }
  //
  //   scoped_refptr<Foo> oo = new Foo();
  //
  // Instead of doing like above, please consider adding a static constructor,
  // and keep the first reference alive explicitly.
  //   // static
  //   scoped_refptr<Foo> Foo::Create() {
  //     auto foo = base::WrapRefCounted(new Foo());
  //     base::PostTask(FROM_HERE, base::BindOnce(&Foo::Bar, foo));
  //     return foo;
  //   }
  //
  //   Foo::Foo() {}
  //
  //   scoped_refptr<Foo> oo = Foo::Create();
  DCHECK(receiver->HasAtLeastOneRef())
      << "base::Bind{Once,Repeating}() refuses to create the first reference "
         "to ref-counted objects. That typically happens around PostTask() in "
         "their constructor, and such objects can be destroyed before `new` "
         "returns if the task resolves fast enough.";
}

// BindState<>
//
// This stores all the state passed into Bind().
template <typename Functor, typename... BoundArgs>
struct BindState final : BindStateBase {
  using IsCancellable = std::bool_constant<
      CallbackCancellationTraits<Functor,
                                 std::tuple<BoundArgs...>>::is_cancellable>;
  template <typename ForwardFunctor, typename... ForwardBoundArgs>
  static BindState* Create(BindStateBase::InvokeFuncStorage invoke_func,
                           ForwardFunctor&& functor,
                           ForwardBoundArgs&&... bound_args) {
    // Ban ref counted receivers that were not yet fully constructed to avoid
    // a common pattern of racy situation.
    BanUnconstructedRefCountedReceiver<ForwardFunctor>(bound_args...);

    // IsCancellable is std::false_type if
    // CallbackCancellationTraits<>::IsCancelled returns always false.
    // Otherwise, it's std::true_type.
    return new BindState(IsCancellable{}, invoke_func,
                         std::forward<ForwardFunctor>(functor),
                         std::forward<ForwardBoundArgs>(bound_args)...);
  }

  Functor functor_;
  std::tuple<BoundArgs...> bound_args_;

 private:
  static constexpr bool is_nested_callback =
      MakeFunctorTraits<Functor>::is_callback;

  template <typename ForwardFunctor, typename... ForwardBoundArgs>
  explicit BindState(std::true_type,
                     BindStateBase::InvokeFuncStorage invoke_func,
                     ForwardFunctor&& functor,
                     ForwardBoundArgs&&... bound_args)
      : BindStateBase(invoke_func,
                      &Destroy,
                      &QueryCancellationTraits<BindState>),
        functor_(std::forward<ForwardFunctor>(functor)),
        bound_args_(std::forward<ForwardBoundArgs>(bound_args)...) {
    // We check the validity of nested callbacks (e.g., Bind(callback, ...)) in
    // release builds to avoid null pointers from ending up in posted tasks,
    // causing hard-to-diagnose crashes. Ideally we'd do this for all functors
    // here, but that would have a large binary size impact.
    if (is_nested_callback) {
      CHECK(!IsNull(functor_));
    } else {
      DCHECK(!IsNull(functor_));
    }
  }

  template <typename ForwardFunctor, typename... ForwardBoundArgs>
  explicit BindState(std::false_type,
                     BindStateBase::InvokeFuncStorage invoke_func,
                     ForwardFunctor&& functor,
                     ForwardBoundArgs&&... bound_args)
      : BindStateBase(invoke_func, &Destroy),
        functor_(std::forward<ForwardFunctor>(functor)),
        bound_args_(std::forward<ForwardBoundArgs>(bound_args)...) {
    // See above for CHECK/DCHECK rationale.
    if (is_nested_callback) {
      CHECK(!IsNull(functor_));
    } else {
      DCHECK(!IsNull(functor_));
    }
  }

  ~BindState() = default;

  static void Destroy(const BindStateBase* self) {
    delete static_cast<const BindState*>(self);
  }
};

// Used to implement MakeBindStateType.
template <bool is_method, typename Functor, typename... BoundArgs>
struct MakeBindStateTypeImpl;

template <typename Functor, typename... BoundArgs>
struct MakeBindStateTypeImpl<false, Functor, BoundArgs...> {
  static_assert(!HasRefCountedTypeAsRawPtr<std::decay_t<BoundArgs>...>::value,
                "A parameter is a refcounted type and needs scoped_refptr.");
  using Type = BindState<std::decay_t<Functor>, std::decay_t<BoundArgs>...>;
};

template <typename Functor>
struct MakeBindStateTypeImpl<true, Functor> {
  using Type = BindState<std::decay_t<Functor>>;
};

template <typename Functor, typename Receiver, typename... BoundArgs>
struct MakeBindStateTypeImpl<true, Functor, Receiver, BoundArgs...> {
 private:
  using DecayedReceiver = std::decay_t<Receiver>;

  static_assert(!std::is_array<std::remove_reference_t<Receiver>>::value,
                "First bound argument to a method cannot be an array.");
  static_assert(
      !std::is_pointer<DecayedReceiver>::value ||
          IsRefCountedType<std::remove_pointer_t<DecayedReceiver>>::value,
      "Receivers may not be raw pointers. If using a raw pointer here is safe"
      " and has no lifetime concerns, use base::Unretained() and document why"
      " it's safe.");
  static_assert(!HasRefCountedTypeAsRawPtr<std::decay_t<BoundArgs>...>::value,
                "A parameter is a refcounted type and needs scoped_refptr.");

 public:
  using Type = BindState<
      std::decay_t<Functor>,
      std::conditional_t<std::is_pointer<DecayedReceiver>::value,
                         scoped_refptr<std::remove_pointer_t<DecayedReceiver>>,
                         DecayedReceiver>,
      std::decay_t<BoundArgs>...>;
};

template <typename Functor, typename... BoundArgs>
using MakeBindStateType =
    typename MakeBindStateTypeImpl<MakeFunctorTraits<Functor>::is_method,
                                   Functor,
                                   BoundArgs...>::Type;

// Returns a RunType of bound functor.
// E.g. MakeUnboundRunType<R(A, B, C), A, B> is evaluated to R(C).
template <typename Functor, typename... BoundArgs>
using MakeUnboundRunType =
    typename BindTypeHelper<Functor, BoundArgs...>::UnboundRunType;

// The implementation of TransformToUnwrappedType below.
template <bool is_once, typename T>
struct TransformToUnwrappedTypeImpl;

template <typename T>
struct TransformToUnwrappedTypeImpl<true, T> {
  using StoredType = std::decay_t<T>;
  using ForwardType = StoredType&&;
  using Unwrapped = decltype(Unwrap(std::declval<ForwardType>()));
};

template <typename T>
struct TransformToUnwrappedTypeImpl<false, T> {
  using StoredType = std::decay_t<T>;
  using ForwardType = const StoredType&;
  using Unwrapped = decltype(Unwrap(std::declval<ForwardType>()));
};

// Transform |T| into `Unwrapped` type, which is passed to the target function.
// Example:
//   In is_once == true case,
//     `int&&` -> `int&&`,
//     `const int&` -> `int&&`,
//     `OwnedWrapper<int>&` -> `int*&&`.
//   In is_once == false case,
//     `int&&` -> `const int&`,
//     `const int&` -> `const int&`,
//     `OwnedWrapper<int>&` -> `int* const &`.
template <bool is_once, typename T>
using TransformToUnwrappedType =
    typename TransformToUnwrappedTypeImpl<is_once, T>::Unwrapped;

// Transforms |Args| into `Unwrapped` types, and packs them into a TypeList.
// If |is_method| is true, tries to dereference the first argument to support
// smart pointers.
template <bool is_once, bool is_method, typename... Args>
struct MakeUnwrappedTypeListImpl {
  using Type = TypeList<TransformToUnwrappedType<is_once, Args>...>;
};

// Performs special handling for this pointers.
// Example:
//   int* -> int*,
//   std::unique_ptr<int> -> int*.
template <bool is_once, typename Receiver, typename... Args>
struct MakeUnwrappedTypeListImpl<is_once, true, Receiver, Args...> {
  using UnwrappedReceiver = TransformToUnwrappedType<is_once, Receiver>;
  using Type = TypeList<decltype(&*std::declval<UnwrappedReceiver>()),
                        TransformToUnwrappedType<is_once, Args>...>;
};

template <bool is_once, bool is_method, typename... Args>
using MakeUnwrappedTypeList =
    typename MakeUnwrappedTypeListImpl<is_once, is_method, Args...>::Type;

// IsOnceCallback<T> is a std::true_type if |T| is a OnceCallback.
template <typename T>
struct IsOnceCallback : std::false_type {};

template <typename Signature>
struct IsOnceCallback<OnceCallback<Signature>> : std::true_type {};

// Helpers to make error messages slightly more readable.
template <int i>
struct BindArgument {
  template <typename ForwardingType>
  struct ForwardedAs {
    template <typename FunctorParamType>
    struct ToParamWithType {
      static constexpr bool kCanBeForwardedToBoundFunctor =
          std::is_constructible<FunctorParamType, ForwardingType>::value;

      // If the bound type can't be forwarded then test if `FunctorParamType` is
      // a non-const lvalue reference and a reference to the unwrapped type
      // *could* have been successfully forwarded.
      static constexpr bool kNonConstRefParamMustBeWrapped =
          kCanBeForwardedToBoundFunctor ||
          !(std::is_lvalue_reference<FunctorParamType>::value &&
            !std::is_const<std::remove_reference_t<FunctorParamType>>::value &&
            std::is_convertible<std::decay_t<ForwardingType>&,
                                FunctorParamType>::value);

      // Note that this intentionally drops the const qualifier from
      // `ForwardingType`, to test if it *could* have been successfully
      // forwarded if `Passed()` had been used.
      static constexpr bool kMoveOnlyTypeMustUseBasePassed =
          kCanBeForwardedToBoundFunctor ||
          !std::is_constructible<FunctorParamType,
                                 std::decay_t<ForwardingType>&&>::value;
    };
  };

  template <typename BoundAsType>
  struct BoundAs {
    template <typename StorageType>
    struct StoredAs {
      static constexpr bool kBindArgumentCanBeCaptured =
          std::is_constructible<StorageType, BoundAsType>::value;
      // Note that this intentionally drops the const qualifier from
      // `BoundAsType`, to test if it *could* have been successfully bound if
      // `std::move()` had been used.
      static constexpr bool kMoveOnlyTypeMustUseStdMove =
          kBindArgumentCanBeCaptured ||
          !std::is_constructible<StorageType,
                                 std::decay_t<BoundAsType>&&>::value;
    };
  };
};

// Helper to assert that parameter |i| of type |Arg| can be bound, which means:
// - |Arg| can be retained internally as |Storage|.
// - |Arg| can be forwarded as |Unwrapped| to |Param|.
template <int i,
          typename Arg,
          typename Storage,
          typename Unwrapped,
          typename Param>
struct AssertConstructible {
 private:
  // With `BindRepeating`, there are two decision points for how to handle a
  // move-only type:
  //
  // 1. Whether the move-only argument should be moved into the internal
  //    `BindState`. Either `std::move()` or `Passed` is sufficient to trigger
  //    move-only semantics.
  // 2. Whether or not the bound, move-only argument should be moved to the
  //    bound functor when invoked. When the argument is bound with `Passed`,
  //    invoking the callback will destructively move the bound, move-only
  //    argument to the bound functor. In contrast, if the argument is bound
  //    with `std::move()`, `RepeatingCallback` will attempt to call the bound
  //    functor with a constant reference to the bound, move-only argument. This
  //    will fail if the bound functor accepts that argument by value, since the
  //    argument cannot be copied. It is this latter case that this
  //    static_assert aims to catch.
  //
  // In contrast, `BindOnce()` only has one decision point. Once a move-only
  // type is captured by value into the internal `BindState`, the bound,
  // move-only argument will always be moved to the functor when invoked.
  // Failure to use std::move will simply fail the `kMoveOnlyTypeMustUseStdMove`
  // assert below instead.
  //
  // Note: `Passed()` is a legacy of supporting move-only types when repeating
  // callbacks were the only callback type. A `RepeatingCallback` with a
  // `Passed()` argument is really a `OnceCallback` and should eventually be
  // migrated.
  static_assert(
      BindArgument<i>::template ForwardedAs<Unwrapped>::
          template ToParamWithType<Param>::kMoveOnlyTypeMustUseBasePassed,
      "base::BindRepeating() argument is a move-only type. Use base::Passed() "
      "instead of std::move() to transfer ownership from the callback to the "
      "bound functor.");
  static_assert(
      BindArgument<i>::template ForwardedAs<Unwrapped>::
          template ToParamWithType<Param>::kNonConstRefParamMustBeWrapped,
      "Bound argument for non-const reference parameter must be wrapped in "
      "std::ref() or base::OwnedRef().");
  static_assert(
      BindArgument<i>::template ForwardedAs<Unwrapped>::
          template ToParamWithType<Param>::kCanBeForwardedToBoundFunctor,
      "Type mismatch between bound argument and bound functor's parameter.");

  static_assert(BindArgument<i>::template BoundAs<Arg>::template StoredAs<
                    Storage>::kMoveOnlyTypeMustUseStdMove,
                "Attempting to bind a move-only type. Use std::move() to "
                "transfer ownership to the created callback.");
  // In practice, this static_assert should be quite rare as the storage type
  // is deduced from the arguments passed to `BindOnce()`/`BindRepeating()`.
  static_assert(
      BindArgument<i>::template BoundAs<Arg>::template StoredAs<
          Storage>::kBindArgumentCanBeCaptured,
      "Cannot capture argument: is the argument copyable or movable?");
};

// Takes three same-length TypeLists, and applies AssertConstructible for each
// triples.
template <typename Index,
          typename Args,
          typename UnwrappedTypeList,
          typename ParamsList>
struct AssertBindArgsValidity;

template <size_t... Ns,
          typename... Args,
          typename... Unwrapped,
          typename... Params>
struct AssertBindArgsValidity<std::index_sequence<Ns...>,
                              TypeList<Args...>,
                              TypeList<Unwrapped...>,
                              TypeList<Params...>>
    : AssertConstructible<static_cast<int>(Ns),
                          Args,
                          std::decay_t<Args>,
                          Unwrapped,
                          Params>... {
  static constexpr bool ok = true;
};

template <typename T>
struct AssertBindArgIsNotBasePassed : public std::true_type {};

template <typename T>
struct AssertBindArgIsNotBasePassed<PassedWrapper<T>> : public std::false_type {
};

// Used below in BindImpl to determine whether to use Invoker::Run or
// Invoker::RunOnce.
// Note: Simply using `kIsOnce ? &Invoker::RunOnce : &Invoker::Run` does not
// work, since the compiler needs to check whether both expressions are
// well-formed. Using `Invoker::Run` with a OnceCallback triggers a
// static_assert, which is why the ternary expression does not compile.
// TODO(crbug.com/752720): Remove this indirection once we have `if constexpr`.
template <typename Invoker>
constexpr auto GetInvokeFunc(std::true_type) {
  return Invoker::RunOnce;
}

template <typename Invoker>
constexpr auto GetInvokeFunc(std::false_type) {
  return Invoker::Run;
}

template <template <typename> class CallbackT,
          typename Functor,
          typename... Args>
decltype(auto) BindImpl(Functor&& functor, Args&&... args) {
  // This block checks if each |args| matches to the corresponding params of the
  // target function. This check does not affect the behavior of Bind, but its
  // error message should be more readable.
  static constexpr bool kIsOnce = IsOnceCallback<CallbackT<void()>>::value;
  using Helper = BindTypeHelper<Functor, Args...>;
  using FunctorTraits = typename Helper::FunctorTraits;
  using BoundArgsList = typename Helper::BoundArgsList;
  using UnwrappedArgsList =
      MakeUnwrappedTypeList<kIsOnce, FunctorTraits::is_method, Args&&...>;
  using BoundParamsList = typename Helper::BoundParamsList;
  static_assert(
      AssertBindArgsValidity<std::make_index_sequence<Helper::num_bounds>,
                             BoundArgsList, UnwrappedArgsList,
                             BoundParamsList>::ok,
      "The bound args need to be convertible to the target params.");

  using BindState = MakeBindStateType<Functor, Args...>;
  using UnboundRunType = MakeUnboundRunType<Functor, Args...>;
  using Invoker = Invoker<BindState, UnboundRunType>;
  using CallbackType = CallbackT<UnboundRunType>;

  // Store the invoke func into PolymorphicInvoke before casting it to
  // InvokeFuncStorage, so that we can ensure its type matches to
  // PolymorphicInvoke, to which CallbackType will cast back.
  using PolymorphicInvoke = typename CallbackType::PolymorphicInvoke;
  PolymorphicInvoke invoke_func =
      GetInvokeFunc<Invoker>(std::bool_constant<kIsOnce>());

  using InvokeFuncStorage = BindStateBase::InvokeFuncStorage;
  return CallbackType(BindState::Create(
      reinterpret_cast<InvokeFuncStorage>(invoke_func),
      std::forward<Functor>(functor), std::forward<Args>(args)...));
}

}  // namespace cef_internal

// An injection point to control |this| pointer behavior on a method invocation.
// If IsWeakReceiver<> is true_type for |T| and |T| is used for a receiver of a
// method, base::Bind cancels the method invocation if the receiver is tested as
// false.
// E.g. Foo::bar() is not called:
//   struct Foo : base::SupportsWeakPtr<Foo> {
//     void bar() {}
//   };
//
//   WeakPtr<Foo> oo = nullptr;
//   base::BindOnce(&Foo::bar, oo).Run();
template <typename T>
struct IsWeakReceiver : std::false_type {};

template <typename T>
struct IsWeakReceiver<std::reference_wrapper<T>> : IsWeakReceiver<T> {};

template <typename T>
struct IsWeakReceiver<WeakPtr<T>> : std::true_type {};

// An injection point to control how objects are checked for maybe validity,
// which is an optimistic thread-safe check for full validity.
template <typename>
struct MaybeValidTraits {
  template <typename T>
  static bool MaybeValid(const T& o) {
    return o.MaybeValid();
  }
};

// An injection point to control how bound objects passed to the target
// function. BindUnwrapTraits<>::Unwrap() is called for each bound objects right
// before the target function is invoked.
template <typename>
struct BindUnwrapTraits {
  template <typename T>
  static T&& Unwrap(T&& o) {
    return std::forward<T>(o);
  }
};

template <typename T>
struct BindUnwrapTraits<cef_internal::UnretainedWrapper<T>> {
  static T* Unwrap(const cef_internal::UnretainedWrapper<T>& o) {
    return o.get();
  }
};

template <typename T>
struct BindUnwrapTraits<cef_internal::RetainedRefWrapper<T>> {
  static T* Unwrap(const cef_internal::RetainedRefWrapper<T>& o) {
    return o.get();
  }
};

template <typename T, typename Deleter>
struct BindUnwrapTraits<cef_internal::OwnedWrapper<T, Deleter>> {
  static T* Unwrap(const cef_internal::OwnedWrapper<T, Deleter>& o) {
    return o.get();
  }
};

template <typename T>
struct BindUnwrapTraits<cef_internal::OwnedRefWrapper<T>> {
  static T& Unwrap(const cef_internal::OwnedRefWrapper<T>& o) {
    return o.get();
  }
};

template <typename T>
struct BindUnwrapTraits<cef_internal::PassedWrapper<T>> {
  static T Unwrap(const cef_internal::PassedWrapper<T>& o) { return o.Take(); }
};

#if defined(OS_WIN)
template <typename T>
struct BindUnwrapTraits<Microsoft::WRL::ComPtr<T>> {
  static T* Unwrap(const Microsoft::WRL::ComPtr<T>& ptr) { return ptr.Get(); }
};
#endif

// CallbackCancellationTraits allows customization of Callback's cancellation
// semantics. By default, callbacks are not cancellable. A specialization should
// set is_cancellable = true and implement an IsCancelled() that returns if the
// callback should be cancelled.
template <typename Functor, typename BoundArgsTuple, typename SFINAE>
struct CallbackCancellationTraits {
  static constexpr bool is_cancellable = false;
};

// Specialization for method bound to weak pointer receiver.
template <typename Functor, typename... BoundArgs>
struct CallbackCancellationTraits<
    Functor,
    std::tuple<BoundArgs...>,
    std::enable_if_t<cef_internal::IsWeakMethod<
        cef_internal::FunctorTraits<Functor>::is_method,
        BoundArgs...>::value>> {
  static constexpr bool is_cancellable = true;

  template <typename Receiver, typename... Args>
  static bool IsCancelled(const Functor&,
                          const Receiver& receiver,
                          const Args&...) {
    return !receiver;
  }

  template <typename Receiver, typename... Args>
  static bool MaybeValid(const Functor&,
                         const Receiver& receiver,
                         const Args&...) {
    return MaybeValidTraits<Receiver>::MaybeValid(receiver);
  }
};

// Specialization for a nested bind.
template <typename Signature, typename... BoundArgs>
struct CallbackCancellationTraits<OnceCallback<Signature>,
                                  std::tuple<BoundArgs...>> {
  static constexpr bool is_cancellable = true;

  template <typename Functor>
  static bool IsCancelled(const Functor& functor, const BoundArgs&...) {
    return functor.IsCancelled();
  }

  template <typename Functor>
  static bool MaybeValid(const Functor& functor, const BoundArgs&...) {
    return MaybeValidTraits<Functor>::MaybeValid(functor);
  }
};

template <typename Signature, typename... BoundArgs>
struct CallbackCancellationTraits<RepeatingCallback<Signature>,
                                  std::tuple<BoundArgs...>> {
  static constexpr bool is_cancellable = true;

  template <typename Functor>
  static bool IsCancelled(const Functor& functor, const BoundArgs&...) {
    return functor.IsCancelled();
  }

  template <typename Functor>
  static bool MaybeValid(const Functor& functor, const BoundArgs&...) {
    return MaybeValidTraits<Functor>::MaybeValid(functor);
  }
};

}  // namespace base

#endif  // CEF_INCLUDE_BASE_INTERNAL_CEF_BIND_INTERNAL_H_

#include <assert.h>
#include <atomic>
#include <memory>
#include <string.h> // for memcpy
#include <vector>

#include "__quantum__rt.hpp"

/*==============================================================================
    The types and methods, expected by QIR for tuples:
    %TupleHeader = type { i32 }
    declare %TupleHeader* @__quantum__rt__tuple_create(i64)

    Argument passed to __quantum__rt__tuple_create is the size (in bytes) of the tuple.
    For example:
    ; to calculate the size of a tuple pretend having an array of them and get
    ; offset to the first element
    %t1 = getelementptr { %TupleHeader, %Callable*, %Array* }, { %TupleHeader, %Callable*, %Array* }* null, i32 1
    ; convert the offset to int and call __quantum__rt__tuple_create
    %t2 = ptrtoint { %TupleHeader, %Callable*, %Array* }* %t1 to i64
    %0 = call %TupleHeader* @__quantum__rt__tuple_create(i62 %t2)

    Notice, that the TupleHeader is placed part of the Tuple's buffer.
==============================================================================*/
struct QirTupleHeader
{
    int refCount = 0;
};

/*==============================================================================
    Example of creating a callable

    ; Single entry of a callable
    ; (a callable might provide entries for body, controlled, adjoint and controlled-adjoint)
    define void @UpdateAnsatz-body(
        %TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) { ... }

    ; Definition of the callable
    @UpdateAnsatz =
        constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]
        [
            void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @UpdateAnsatz-body,
            void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null,
            void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null,
            void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null
        ]

    %3 = call %Callable* @__quantum__rt__callable_create(
        [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @UpdateAnsatz,
        %TupleHeader* null)

==============================================================================*/
typedef void (*t_CallableEntry)(QirTupleHeader*, QirTupleHeader*, QirTupleHeader*);
struct QirCallable
{
    static int constexpr Adjoint = 1;
    static int constexpr Controlled = 1 << 1;

  private:
    static int constexpr TableSize = 4;

    std::atomic<long> refCount;
    t_CallableEntry function_table[QirCallable::TableSize];
    QirTupleHeader* const capture;
    int appliedFunctor = 0; // by default the callable is neither adjoint nor controlled

    // prevent stack allocations
    ~QirCallable()
    {
        assert(refCount == 0);
    }

  public:
    QirCallable(const t_CallableEntry* ft_entries, QirTupleHeader* capture)
        : refCount(1)
        , capture(capture)
        , appliedFunctor()
    {
        memcpy(this->function_table, ft_entries, QirCallable::TableSize * sizeof(void*));
    }

    QirCallable(const QirCallable* other)
        : refCount(1)
        , capture(other->capture)
    {
        memcpy(this->function_table, other->function_table, QirCallable::TableSize * sizeof(void*));
    }

    long AddRef()
    {
        int rc = ++this->refCount;
        assert(rc != 1); // not allowed to resurrect!
        return rc;
    }

    long Release()
    {
        assert(this->refCount > 0);

        long rc = --this->refCount;
        if (rc == 0)
        {
            delete this;
        }
        return rc;
    }

    void Invoke(QirTupleHeader* args, QirTupleHeader* result)
    {
        assert(this->appliedFunctor < QirCallable::TableSize);
        this->function_table[this->appliedFunctor](capture, args, result);
    }

    void ApplyFunctor(int functor)
    {
        assert(functor == QirCallable::Adjoint || functor == QirCallable::Controlled);
        this->appliedFunctor ^= functor;
    }
};

extern "C"
{
    QirTupleHeader* quantum__rt__tuple_create(int64_t size)
    {
        assert(size >= sizeof(QirTupleHeader));
        char* buffer = new char[size];

        // at the beginning of the buffer place QirTupleHeader
        QirTupleHeader* th = reinterpret_cast<QirTupleHeader*>(buffer);
        th->refCount = 1;

        return th;
    }

    void quantum__rt__tuple_reference(QirTupleHeader* th)
    {
        assert(th->refCount > 0); // no resurrection of deleted tuples
        ++th->refCount;
    }

    void quantum__rt__tuple_unreference(QirTupleHeader* th)
    {
        const long ref = --th->refCount;
        assert(ref >= 0);

        if (ref == 0)
        {
            char* buffer = reinterpret_cast<char*>(th);
            delete[] buffer;
        }
        th = nullptr;
    }

    void quantum__rt__callable_reference(QirCallable* callable)
    {
        callable->AddRef();
    }

    void quantum__rt__callable_unreference(QirCallable* callable)
    {
        const long ref = callable->Release();
        assert(ref >= 0);
    }

    QirCallable* quantum__rt__callable_create(t_CallableEntry* entries, QirTupleHeader* capture)
    {
        return new QirCallable(entries, capture);
    }

    void quantum__rt__callable_invoke(QirCallable* clb, QirTupleHeader* args, QirTupleHeader* result)
    {
        clb->Invoke(args, result);
    }

    QirCallable* quantum__rt__callable_copy(QirCallable* other)
    {
        return new QirCallable(other);
    }

    void quantum__rt__callable_make_adjoint(QirCallable* clb)
    {
        clb->ApplyFunctor(QirCallable::Adjoint);
    }

    void quantum__rt__callable_make_controlled(QirCallable* clb)
    {
        clb->ApplyFunctor(QirCallable::Controlled);
    }
}
using System;

namespace Microsoft.Quantum.EntryPointDriver
{
    internal abstract class Maybe<T>
    {
        private Maybe()
        {
        }

        internal abstract TResult Case<TResult>(Func<TResult> onNothing, Func<T, TResult> onJust);

        internal class Nothing : Maybe<T>
        {
            internal override TResult Case<TResult>(Func<TResult> onNothing, Func<T, TResult> onJust) => onNothing();
        }

        internal class Just : Maybe<T>
        {
            private readonly T value;

            internal Just(T value) => this.value = value;

            internal override TResult Case<TResult>(Func<TResult> onNothing, Func<T, TResult> onJust) => onJust(value);
        }
    }

    internal static class Maybe
    {
        internal static Maybe<T> Nothing<T>() => new Maybe<T>.Nothing();

        internal static Maybe<T> Just<T>(T value) => new Maybe<T>.Just(value);
    }
}

using System;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// Represents an optional value of type <typeparamref name="T"/>.
    /// </summary>
    /// <typeparam name="T">The value type.</typeparam>
    internal abstract class Maybe<T>
    {
        private Maybe()
        {
        }

        /// <summary>
        /// Case analysis on <see cref="Maybe{T}"/>.
        /// </summary>
        /// <param name="onNothing">Handles the case when this <see cref="Maybe{T}"/> is <see cref="Nothing"/>.</param>
        /// <param name="onJust">Handles the case when this <see cref="Maybe{T}"/> is <see cref="Just"/>.</param>
        /// <typeparam name="TResult"></typeparam>
        /// <returns>The result of handling the cases.</returns>
        internal abstract TResult Case<TResult>(Func<TResult> onNothing, Func<T, TResult> onJust);

        /// <summary>
        /// The case of <see cref="Maybe{T}"/> where no value is present.
        /// </summary>
        internal class Nothing : Maybe<T>
        {
            /// <summary>
            /// The singleton instance of <see cref="Nothing"/>.
            /// </summary>
            internal static Maybe<T> Instance { get; } = new Nothing();

            private Nothing()
            {
            }

            internal override TResult Case<TResult>(Func<TResult> onNothing, Func<T, TResult> onJust) => onNothing();
        }

        /// <summary>
        /// The case of <see cref="Maybe{T}"/> where a value is present.
        /// </summary>
        internal class Just : Maybe<T>
        {
            private readonly T value;

            /// <summary>
            /// Creates a <see cref="Just"/> instance.
            /// </summary>
            /// <param name="value">The value present.</param>
            internal Just(T value) => this.value = value;

            internal override TResult Case<TResult>(Func<TResult> onNothing, Func<T, TResult> onJust) => onJust(value);
        }
    }

    /// <summary>
    /// Static methods for <see cref="Maybe{T}"/>.
    /// </summary>
    internal static class Maybe
    {
        /// <summary>
        /// The <see cref="Maybe{T}.Nothing"/> case for a value of type <typeparamref name="T"/>.
        /// </summary>
        /// <typeparam name="T">The type of the value that is not present.</typeparam>
        /// <returns>The <see cref="Maybe{T}.Nothing"/> case.</returns>
        internal static Maybe<T> Nothing<T>() => Maybe<T>.Nothing.Instance;

        /// <summary>
        /// The <see cref="Maybe{T}.Just"/> case for a value of type <typeparamref name="T"/>.
        /// </summary>
        /// <param name="value">The value present.</param>
        /// <typeparam name="T">The type of the value.</typeparam>
        /// <returns>The <see cref="Maybe{T}.Just"/> case.</returns>
        internal static Maybe<T> Just<T>(T value) => new Maybe<T>.Just(value);
    }
}

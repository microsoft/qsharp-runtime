namespace @Namespace
{
    using Microsoft.Quantum.Simulation.Core;
    using System;
    using System.ComponentModel;
    using System.Globalization;
    using System.Linq;
    using System.Numerics;

    /// <summary>
    /// Converts a string to type <typeparamref name="T"/>.
    /// </summary>
    /// <typeparam name="T">The type of the value to convert from a string.</typeparam>
    internal abstract class FromStringConverter<T> : TypeConverter
    {
        public override bool CanConvertFrom(ITypeDescriptorContext context, Type sourceType) =>
            sourceType == typeof(string) || base.CanConvertFrom(context, sourceType);

        public override object ConvertFrom(ITypeDescriptorContext context, CultureInfo culture, object value) =>
            value is string s ? Convert(s) : base.ConvertFrom(context, culture, value);

        protected abstract T Convert(string value);
    }

    /// <summary>
    /// Converts a string to a <see cref="BigInteger"/>.
    /// </summary>
    internal class BigIntegerConverter : FromStringConverter<BigInteger>
    {
        protected override BigInteger Convert(string value) => BigInteger.Parse(value);
    }

    /// <summary>
    /// Converts a string to a <see cref="QRange"/>.
    /// </summary>
    internal class QRangeConverter : FromStringConverter<QRange>
    {
        protected override QRange Convert(string value)
        {
            var values = value.Split("..").Select(long.Parse);
            return values.Count() == 2
                ? new QRange(values.ElementAt(0), values.ElementAt(1))
                : values.Count() == 3
                ? new QRange(values.ElementAt(0), values.ElementAt(1), values.ElementAt(2))
                : throw new ArgumentException();
        }
    }

    /// <summary>
    /// Converts a string to <see cref="QVoid"/>.
    /// </summary>
    internal class QVoidConverter : FromStringConverter<QVoid>
    {
        protected override QVoid Convert(string value) =>
            value.Trim() == QVoid.Instance.ToString() ? QVoid.Instance : throw new ArgumentException();
    }

    /// <summary>
    /// Converts a string to a <see cref="Result"/>.
    /// </summary>
    internal class ResultConverter : FromStringConverter<Result>
    {
        protected override Result Convert(string value) =>
            Enum.Parse<ResultValue>(value, ignoreCase: true) switch
            {
                ResultValue.Zero => Result.Zero,
                ResultValue.One => Result.One,
                _ => throw new ArgumentException()
            };
    }
}

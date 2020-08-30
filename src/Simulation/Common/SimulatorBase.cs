// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using Microsoft.Quantum.Simulation.Core;

#nullable enable

namespace Microsoft.Quantum.Simulation.Common
{
    /// <summary>
    ///     A Base class for Simulators.
    ///     It provides the infrastructure that makes it easy for a Simulator
    ///     to become an OperationFactory (so the execution of an Operation
    ///     can be tied to this simulator) and
    ///     to manage the allocation of Qubits (via the QubitManager).
    /// </summary>
    public abstract class SimulatorBase : AbstractFactory<AbstractCallable>, IOperationFactory
    {
        public event Action<ICallable, IApplyData>? OnOperationStart = null;
        public event Action<ICallable, IApplyData>? OnOperationEnd = null;
        public event Action<System.Runtime.ExceptionServices.ExceptionDispatchInfo>? OnFail = null;
        public event Action<long>? OnAllocateQubits = null;
        public event Action<IQArray<Qubit>>? OnReleaseQubits = null;
        public event Action<long>? OnBorrowQubits = null;
        public event Action<IQArray<Qubit>>? OnReturnQubits = null;
        public event Action<string>? OnLog = null;
        public event Action<Exception, IEnumerable<StackFrame>>? OnException = null;


        protected readonly int randomSeed;
        protected readonly Lazy<System.Random> randomGenerator;
        public int Seed => randomSeed;
        protected System.Random RandomGenerator => randomGenerator.Value;


        
        /// <summary>
        ///     An event fired whenever a simulator has additional diagnostic data
        ///     available for display (e.g. state information, assertion details,
        ///     execution traces).
        /// </summary>
        public event Action<object>? OnDisplayableDiagnostic = null;

        public IQubitManager? QubitManager { get; }

        public abstract string Name { get; }


        /// <summary>
        /// If the execution finishes in failure, this method returns the call-stack of the Q# operations 
        /// executed up to the point when the failure happened.
        /// If the execution was successful, this method returns null.
        /// </summary>
        /// <remarks>
        /// Only Q# operations are tracked and reported in the stack trace. Q# functions or calls from 
        /// classical hosts like C# or Python are not included.
        /// </remarks>
        public StackFrame[]? CallStack { get; private set; }

        public SimulatorBase(IQubitManager? qubitManager = null, int? seed = null)
        {
            this.randomSeed = seed ?? Guid.NewGuid().GetHashCode();
            this.randomGenerator = new Lazy<System.Random>(
                () => new System.Random(Seed)
            );
            this.QubitManager = qubitManager;

            this.InitBuiltinOperations(this.GetType());

            EnableLogToConsole();
            EnableExceptionPrinting();

            if (this.QubitManager != null)
            {
                OnOperationStart += this.QubitManager.OnOperationStart;
                OnOperationEnd += this.QubitManager.OnOperationEnd;
            }
        }

        public virtual I Get<I>(Type T)
        {
            return (I)this.GetInstance(T);
        }

        /// <summary>
        /// Returns an instance of the given Type T.
        /// If an override has been defined for T, it will return an instance of the replacement Type,
        /// otherwise, it will try to create an instance of T and return it.
        /// 
        /// Instances are cached, thus calling this method for the same Operation more than once returns the same instance.
        /// 
        /// If the operation has no body in the Q# file, and no override has been defined in the Simulator,
        /// this method will throw an InvalidOperationException.
        /// </summary>
        public virtual I Get<I, T>() where T : AbstractCallable, I
        {
            var key = typeof(T);
            return (I)this.GetInstance(key);
        }

        public virtual void Init(AbstractCallable op)
        {
            op.__Init__();
        }

        public override AbstractCallable CreateInstance(Type t)
        {
            if (t.ContainsGenericParameters)
            {
                return new GenericCallable(this, t);
            }

            AbstractCallable? result = null;

            t = t.GetNativeImplementation() ?? t;

            if (t.IsUdt())
            {
                var udtType = typeof(UDTFactory<,>).MakeGenericType(t.BaseType.GenericTypeArguments[0], t);
                result = (AbstractCallable)Activator.CreateInstance(udtType, new object[] { this });
            }
            else
            {
                result = base.CreateInstance(t);
            }

            Init(result);
            return result;
        }

        protected void WriteStackTraceToLog(Exception exception, IEnumerable<StackFrame> callStack)
        {
            OnLog?.Invoke($"Unhandled exception. {exception.GetType().FullName}: {exception.Message}");
            var first = true;
            foreach (var sf in callStack)
            {
                var msg = (first ? " ---> " : "   at ") + sf.ToStringWithBestSourceLocation();
                OnLog?.Invoke(msg);
                first = false;
            }
            OnLog?.Invoke("");
        }

        public virtual O Execute<T, I, O>(I args) where T : AbstractCallable, ICallable
        {
            StackTraceCollector stackTraceCollector = new StackTraceCollector(this);
            var op = Get<ICallable, T>();

            try
            {
                var result = op.Apply<O>(args);
                this.CallStack = null;
                return result;
            }
            catch (Exception e) // Dumps q# call-stack in case of exception if CallStack tracking was enabled
            {
                this.CallStack = stackTraceCollector.CallStack;
                this.OnException?.Invoke(e, this.CallStack);
                throw;
            }
            finally
            {
                stackTraceCollector.Dispose();
            }
        }

        public virtual Task<O> Run<T, I, O>(I args) where T : AbstractCallable, ICallable
        {
            return Task<O>.Run(() => Execute<T, I, O>(args));
        }

        /// <summary>
        /// Enables that all Q# messages get logged to the Console output.
        /// Logging to the console is enabled by default.
        /// </summary>
        public void EnableLogToConsole()
        {
            OnLog += Console.WriteLine;
            OnDisplayableDiagnostic += Console.WriteLine;
        }


        /// <summary>
        /// Disables logging all Q# messages to the Console output.
        /// </summary>
        public void DisableLogToConsole()
        {
            OnLog -= Console.WriteLine;
            OnDisplayableDiagnostic -= Console.WriteLine;
        }

        /// <summary>
        ///     Adds an event to the OnException event that logs stack traces
        ///     as plain text via the OnLog event (e.g.: for console output).
        /// </summary>
        public void EnableExceptionPrinting()
        {
            OnException += WriteStackTraceToLog;
        }

        /// <summary>
        ///     Sends diagnostic data to any listening display handlers.
        ///     Display handlers may discard any unrecognized data, such that
        ///     no guarantee is made as to any particular action taken as a result
        ///     of calling this method.
        /// </summary>
        /// <param name="data">
        ///     The diagnostic object to be displayed.
        /// </param>
        public void MaybeDisplayDiagnostic(object data)
        {
            OnDisplayableDiagnostic?.Invoke(data);
        }


        /// <summary>
        ///     Disables default handling of stack traces, such that stack
        ///     traces are not written to the OnLog event handler.
        /// </summary>
        public void DisableExceptionPrinting()
        {
            OnException -= WriteStackTraceToLog;
        }

        /// <summary>
        /// Verifies that the Qubit can be used as part of an operation.
        /// </summary>
        public void CheckQubit(Qubit q, string qubitName)
        {
            if (q == null) throw new ArgumentNullException(qubitName, "Trying to perform an intrinsic operation on a null Qubit");

            if (!QubitManager.IsValid(q))
            {
                throw new ArgumentException($"Cannot use qubit {q.Id}. Qubit is invalid.", qubitName);
            }
            if (QubitManager.IsFree(q))
            {
                throw new ArgumentException($"Cannot use qubit {q.Id}. Qubit has already been released.", qubitName);
            }
            if (QubitManager.IsDisabled(q))
            {
                throw new ArgumentException($"Cannot use qubit {q.Id}. Qubit is disabled.", qubitName);
            }
        }

        /// <summary>
        /// Verifies that an array of Qubits can be used as part of an operation.
        /// </summary>
        public void CheckQubits(IQArray<Qubit> qubits, string arrayName)
        {
            if (qubits == null)
            {
                throw new ArgumentNullException(arrayName);
            }

            for (var i = 0; i < qubits.Length; i++)
            {
                var c = qubits[i];
                this.CheckQubit(c, $"{arrayName}[{i}]");
            }
        }

        /// <summary>
        ///     Implements the Allocate statement as an operation.
        ///     It just delegates the action to the Simulator's internal QubitManager
        /// </summary>
        public class Allocate : Intrinsic.Allocate
        {
            private SimulatorBase sim;
            private IQubitManager? manager;

            public Allocate(SimulatorBase m) : base(m)
            {
                this.sim = m;
                this.manager = m.QubitManager;
            }

            public override Qubit Apply()
            {
                sim.OnAllocateQubits?.Invoke(1);
                return manager.Allocate();
            }

            public override IQArray<Qubit> Apply(long count)
            {
                if (count < 0)
                {
                    throw new InvalidOperationException($"Trying to allocate {count} qubits.");
                }
                else if (count == 0)
                {
                    sim.OnAllocateQubits?.Invoke(count);
                    return new QArray<Qubit>();
                }
                else
                {
                    sim.OnAllocateQubits?.Invoke(count);
                    return manager.Allocate(count);
                }
            }
        }

        /// <summary>
        ///     Implements the Release statement as an operation.
        ///     It just delegates the action to the Simulator's internal QubitManager
        /// </summary>
        public class Release : Intrinsic.Release
        {
            private SimulatorBase sim;
            private IQubitManager manager;

            public Release(SimulatorBase m) : base(m)
            {
                this.sim = m;
                this.manager = m.QubitManager;
            }

            public override void Apply(Qubit q)
            {
                sim.OnReleaseQubits?.Invoke(new QArray<Qubit>(new[] { q }));
                manager.Release(q);
            }

            public override void Apply(IQArray<Qubit> qubits)
            {
                sim.OnReleaseQubits?.Invoke(qubits);
                manager.Release(qubits);
            }
        }

        /// <summary>
        ///     Implements the Borrow statement as an operation.
        ///     It just delegates the action to the Simulator's internal QubitManager
        /// </summary>
        public class Borrow : Intrinsic.Borrow
        {
            SimulatorBase sim;

            public Borrow(SimulatorBase m) : base(m)
            {
                sim = m;
            }

            public override Qubit Apply()
            {
                return sim.QubitManager.Allocate();
            }

            public override IQArray<Qubit> Apply(long count)
            {
                sim.OnBorrowQubits?.Invoke(count);
                return sim.QubitManager.Borrow(count);
            }
        }

        /// <summary>
        ///     Implements the Return statement as an operation.
        ///     It just delegates the action to the Simulator's internal QubitManager
        /// </summary>
        public class Return : Intrinsic.Return
        {
            SimulatorBase sim;

            public Return(SimulatorBase m) : base(m)
            {
                sim = m;
            }

            public override void Apply(Qubit q)
            {
                sim.OnReturnQubits?.Invoke(new QArray<Qubit>(new[] { q }));
                sim.QubitManager.Return(q);
            }

            public override void Apply(IQArray<Qubit> qubits)
            {
                sim.OnReturnQubits?.Invoke(qubits);
                sim.QubitManager.Return(qubits);
            }
        }

        /// <summary>
        ///     Implements the Log statement as an operation. It just calls Console.WriteLine.
        /// </summary>
        public class Message : Intrinsic.Message
        {
            private SimulatorBase sim;
            public Message(SimulatorBase m) : base(m)
            {
                sim = m;
            }

            public override Func<String, QVoid> __Body__ => (msg) =>
            {
                sim.OnLog?.Invoke(msg);
                return QVoid.Instance;
            };
        }

        /// <summary>
        /// Implements the GetQubitsAvailableToUse extension function.
        /// </summary>
        public class GetQubitsAvailableToUse : Environment.GetQubitsAvailableToUse
        {
            private SimulatorBase sim;

            public GetQubitsAvailableToUse(SimulatorBase m) : base(m)
            {
                sim = m;
            }

            public override Func<QVoid, long> __Body__ => (arg) => sim.QubitManager.GetFreeQubitsCount();
        }

        /// <summary>
        /// Implements the GetQubitsAvailableToBorrow extension function.
        /// </summary>
        public class GetQubitsAvailableToBorrow : Environment.GetQubitsAvailableToBorrow
        {
            private SimulatorBase sim;

            public GetQubitsAvailableToBorrow(SimulatorBase m) : base(m)
            {
                sim = m;
            }

            public override Func<QVoid, long> __Body__ => (arg) => sim.QubitManager.GetParentQubitsAvailableToBorrowCount() +
                                                               sim.QubitManager.GetFreeQubitsCount();
        }

        /// <summary>
        ///     Implements the DrawRandomInt operation from the
        ///     Microsoft.Quantum.Random namespace.
        /// </summary>
        public class DrawRandomInt : Random.DrawRandomInt
        {
            private SimulatorBase sim;

            public DrawRandomInt(SimulatorBase m) : base(m)
            {
                sim = m;
            }

            public override Func<(long, long), long> __Body__ => arg =>
            {
                var (min, max) = arg;
                if (max <= min)
                {
                    throw new ExecutionFailException($"Max must be greater than min, but {max} <= {min}.");
                }
                return sim.RandomGenerator.NextLong(min, max);
            };
        }

        /// <summary>
        ///     Implements the DrawRandomInt operation from the
        ///     Microsoft.Quantum.Random namespace.
        /// </summary>
        public class DrawRandomDouble : Random.DrawRandomDouble
        {
            private SimulatorBase sim;

            public DrawRandomDouble(SimulatorBase m) : base(m)
            {
                sim = m;
            }

            public override Func<(double, double), double> __Body__ => arg =>
            {
                var (min, max) = arg;
                if (max <= min)
                {
                    throw new ExecutionFailException($"Max must be greater than min, but {max} <= {min}.");
                }
                var delta = max - min;
                return min + delta * sim.RandomGenerator.NextDouble();
            };
        }

        public virtual void StartOperation(ICallable operation, IApplyData inputValue)
        {
            OnOperationStart?.Invoke(operation, inputValue);
        }

        public virtual void EndOperation(ICallable operation, IApplyData resultValue)
        {
            OnOperationEnd?.Invoke(operation, resultValue);
        }

        public virtual void Fail(System.Runtime.ExceptionServices.ExceptionDispatchInfo exceptionInfo )
        {
            OnFail?.Invoke(exceptionInfo);
        }
    }
}

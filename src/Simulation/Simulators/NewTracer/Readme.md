//TODO: write documentation

# Tracer

## Metric Collectors

### Depth Counter

Depth counter can be used to collect consistent depth-width pair.
Make sure UseDepthCounter is set to true in configuration.
Select mode of operation by setting OptimizeDepth to true or false.
Gate times can be set via TraceGateTimes in configuration.
Details and considerations are avilable in "Width and Depth in the Tracer.docx"

Collected metrics can be accessed via
sim.GetOperationMetric<TDepthWidth>("Width") and
sim.GetOperationMetric<TDepthWidth>("Depth").
See TDepthAndWidthTest in PrimitiveOperationsCounterTest.cs for example.

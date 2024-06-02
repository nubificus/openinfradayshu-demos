# Basic `vaccel-torch` example

We use a simple BERT speech classification example to benchmark the execution
of torch using CPU and GPU in native and sandbox container environments.

We extract data from Thomas Davidson's [data
set](https://raw.githubusercontent.com/t-davidson/hate-speech-and-offensive-language/master/data/labeled_data.csv)
and use 1000 tweets to run our benchmark.

## Requirements

- torch 2.0.1 (CPU and GPU)
- CUDA 11.8
- vaccel v0.5.0
- kata-containers v3.5.0 (downstream branch, vAccel-enabled)



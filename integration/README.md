# Datadog APM Ruby integration test suite

Integration tests for `ddtrace` that use a variety of real applications.

## Quickstart

1. Build Docker images:

    ```sh
    #!/bin/bash
    ./bin/build-images
    ```

2. *TODO: Run integration test suite*

## Demo applications

Ruby demo applications are configured with Datadog APM, which can be used to generate sample traces/profiles. These are used to drive tests in the integration suite.

### Applications

See `README.md` in each directory for more information:

- `apps/rack`: Rack application
- `apps/rails-five`: Rails 5 application
- `apps/rails-six`: Rails 6 application
- `apps/sinatra`: Sinatra application

### Base images

The `images/` folders hosts some images for Ruby applications.

- `datadog/dd-apm-demo:wrk` / `images/wrk/Dockerfile`: `wrk` load testing application (for generating load)
- `datadog/dd-apm-demo:rb-2.2` / `images/2.2/Dockerfile`: MRI Ruby 2.2 & `Datadog::DemoEnv`
- `datadog/dd-apm-demo:rb-2.5` / `images/2.5/Dockerfile`: MRI Ruby 2.5 & `Datadog::DemoEnv`
- `datadog/dd-apm-demo:rb-2.7` / `images/2.7/Dockerfile`: MRI Ruby 2.7 & `Datadog::DemoEnv`

Ruby base images include `Datadog::DemoEnv` and other helpers.

### Configuration

The `config/` folder contains configuration files used in demo applications.

 - `agent.yml`: Default agent configuration file.

### Debugging

#### Profiling memory

Create a memory heap dump via:

```sh
# Profile for 5 minutes, dump heap to /data/app/ruby-heap.dump
# Where PID = process ID
bundle exec rbtrace -p PID -e 'Thread.new{GC.start; require "objspace"; ObjectSpace.trace_object_allocations_start; sleep(300); io=File.open("/data/app/ruby-heap.dump", "w"); ObjectSpace.dump_all(output: io); io.close}'
```

Then analyze it using `analyzer.rb` (built into the Ruby base images) with:

```sh
# Group objects by generation
ruby /vendor/dd-demo/datadog/analyzer.rb /data/app/ruby-heap.dump

# List objects in GEN_NUM, group by source location
ruby /vendor/dd-demo/datadog/analyzer.rb /data/app/ruby-heap.dump GEN_NUM

# List objects in all generations, group by source location, descending.
ruby /vendor/dd-demo/datadog/analyzer.rb /data/app/ruby-heap.dump objects

# List objects in all generations, group by source location, descending.
# Up to generation END_GEN.
ruby /vendor/dd-demo/datadog/analyzer.rb /data/app/ruby-heap.dump objects END_GEN

# List objects in all generations, group by source location, descending.
# Between generations START_GEN to END_GEN inclusive.
ruby /vendor/dd-demo/datadog/analyzer.rb /data/app/ruby-heap.dump objects END_GEN START_GEN
```

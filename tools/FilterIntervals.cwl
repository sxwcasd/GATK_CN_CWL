#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: FilterIntervals

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: broadinstitute/gatk:latest
- class: ResourceRequirement
  ramMax: $(inputs.mem_gb*1000)
  coresMax: $(inputs.cpu)

inputs:
- id: intervals
  type: File
  inputBinding:
    prefix: -L
    shellQuote: false
- id: blacklist_intervals
  type: File?
  inputBinding:
    prefix: -XL
    shellQuote: false
- id: annotated_intervals
  type: File?
  inputBinding:
    prefix: --annotated-intervals
    shellQuote: false
- id: read_count_files
  type:
    type: array
    items: File
    inputBinding:
      prefix: --input
      separate: false
      shellQuote: false
- id: minimum_gc_content
  type: float?
  default: 0.1
  inputBinding:
    prefix: --minimum-gc-content
    shellQuote: false
- id: maximum_gc_content
  type: float?
  default: 0.9
  inputBinding:
    prefix: --maximum-gc-content
    shellQuote: false
- id: minimum_mappability
  type: float?
  default: 0.9
  inputBinding:
    prefix: --minimum-mappability
    shellQuote: false
- id: maximum_mappability
  type: float?
  default: 1.0
  inputBinding:
    prefix: --maximum-mappability
    shellQuote: false
- id: minimum_segmental_duplication_content
  type: float?
  default: 0.0
  inputBinding:
    prefix: --minimum-segmental_duplication_content
    shellQuote: false
- id: maximum_segmental_duplication_content
  type: float?
  default: 0.5
  inputBinding:
    prefix: --maximum-segmental-duplication-content
    shellQuote: false
- id: low_count_filter_count_threshold
  type: int?
  default: 5
  inputBinding:
    prefix: --low-count-filter-count-threshold
    shellQuote: false
- id: low_count_filter_percentage_of_samples
  type: float?
  default: 90.0
  inputBinding:
    prefix: --low-count-filter-percentage-of-samples
    shellQuote: false
- id: extreme_count_filter_minimum_percentile
  type: float?
  default: 1.0
  inputBinding:
    prefix: --extreme-count-filter-minimum-percentile
    shellQuote: false
- id: extreme_count_filter_maximum_percentile
  type: float?
  default: 99.0
  inputBinding:
    prefix: --extreme-count-filter-maximum-percentile
    shellQuote: false
- id: extreme_count_filter_percentage_of_samples
  type: float?
  default: 90.0
  inputBinding:
    prefix: --extreme-count-filter-percentage-of-samples
    shellQuote: false
- id: gatk4_jar_override
  type:
  - File?
  - string?
  default: /gatk/gatk.jar
- id: gatk_docker
  type: string
- id: mem_gb
  type: int?
  default: 7
- id: disk_space_gb
  type: int?
- id: use_ssd
  type: boolean
  default: false
- id: cpu
  type: int?
  default: 1
- id: preemptible_attempts
  type: int?

outputs:
- id: filter_intervals
  type: File
  outputBinding:
    glob: $(inputs.intervals.nameroot).filtered.interval_list


baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: >-
    set -eu

    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    gatk --java-options -Xmx$((inputs.mem_gb*1000)-500)m FilterIntervals \
        --interval-merging-rule OVERLAPPING_ONLY \
        --output $(inputs.intervals.nameroot).filtered.interval_list

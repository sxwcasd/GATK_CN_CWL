#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: CreateReadCountPanelOfNormals

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: broadinstitute/gatk:latest

inputs:
- id: pon_entity_id
  type: string
- id: read_count_files
  type:
    type: array
    items: File
    inputBinding:
      prefix: --input
      shellQuote: false
- id: minimum_interval_median_percentile
  type: float?
  default: 10.0
  inputBinding:
    prefix: --minimum-interval-median-percentile
    shellQuote: false
- id: maximum_zeros_in_sample_percentage
  type: float?
  default: 5.0
  inputBinding:
    prefix: --maximum-zeros-in-sample-percentage
    shellQuote: false
- id: maximum_zeros_in_interval_percentage
  type: float?
  default: 5.0
  inputBinding:
    prefix: --maximum-zeros-in-interval-percentage
    shellQuote: false
- id: extreme_sample_median_percentile
  type: float?
  default: 2.5
  inputBinding:
    prefix: --extreme-sample-median-percentile
    shellQuote: false
- id: do_impute_zeros
  type: string?
  default: "true"
  inputBinding:
    prefix: --do-impute-zeros
    shellQuote: false
- id: extreme_outlier_truncation_percentile
  type: float?
  default: 0.1
  inputBinding:
    prefix: --extreme-outlier-truncation-percentile
    shellQuote: false
- id: number_of_eigensamples
  type: int?
  default: 20
  inputBinding:
    prefix: --number-of-eigensamples
    shellQuote: false
- id: maximum_chunk_size
  type: int?
  default: 16777216
  inputBinding:
    prefix: --maximum-chunk-size
    shellQuote: false
- id: annotated_intervals
  type: File?
  inputBinding:
    prefix: --annotated-intervals
    shellQuote: false
- id: gatk4_jar_override
  label: gatk4_jar_override
  type:
  - File?
  - string?
  default: "/gatk/gatk.jar"
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
- id: preemptible_attempts
  type: int?

outputs:
- id: read_count_pon
  type: File
  outputBinding:
    glob: $(inputs.pon_entity_id).pon.hdf5


baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: >-
    set -e

    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    gatk --java-options -Xmx$((inputs.mem_gb*1000)-500)m CreateReadCountPanelOfNormals \
    --output $(inputs.pon_entity_id).pon.hdf5

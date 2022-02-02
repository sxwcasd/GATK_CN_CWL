#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: AnnotateIntervals

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
- id: ref_fasta
  type: File
  secondaryFiles:
  - ^.dict
  - .fai
  inputBinding:
    prefix: --reference
    shellQuote: false
- id: mappability_track_bed
  type: File?
  secondaryFiles:
  - ^.idx
  inputBinding:
    prefix: --mappability-track
    shellQuote: false
- id: segmental_duplication_track_bed
  type: File?
  secondaryFiles:
  - ^.idx
  inputBinding:
    prefix: --segmental-duplication-track
    shellQuote: false
- id: feature_query_lookahead
  type: int?
  default: 1000000
  inputBinding:
    prefix: --feature-query-lookahead
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
  default: 2
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
- id: annotated_intervals
  type: File
  outputBinding:
    glob: $(inputs.intervals.nameroot).annotated.tsv


baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: >-
    set -eu

    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    gatk --java-options -Xmx$((inputs.mem_gb*1000)-500)m AnnotateIntervals \
    --interval-merging-rule OVERLAPPING_ONLY \
    --output $(inputs.intervals.nameroot).annotated.tsv

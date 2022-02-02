#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: CallCopyRatioSegments

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: broadinstitute/gatk:latest

inputs:
- id: entity_id
  type: string
- id: copy_ratio_segments
  type: File
  inputBinding:
    prefix: --input
    shellQuote: false
- id: neutral_segment_copy_ratio_lower_bound
  type: float?
  default: .9
  inputBinding:
    prefix: --neutral-segment-copy-ratio-lower-bound
    shellQuote: false
- id: neutral_segment_copy_ratio_upper_bound
  type: float?
  default: 1.1
  inputBinding:
    prefix: --neutral-segment-copy-ratio-upper-bound
    shellQuote: false
- id: outlier_neutral_segment_copy_ratio_z_score_threshold
  type: float
  default: 2.0
  inputBinding:
    prefix: --outlier-neutral-segment-copy-ratio-z-score-threshold
    shellQuote: false
- id: calling_copy_ratio_z_score_threshold
  type: float?
  default: 2.0
  inputBinding:
    prefix: --calling-copy-ratio-z-score-threshold
    shellQuote: false
- id: gatk4_jar_override
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
- id: called_copy_ratio_segments
  type: File
  outputBinding:
    glob: $(inputs.entity_id).called.seg
    loadContents: false
- id: called_copy_ratio_legacy_segments
  type: File
  outputBinding:
    glob: $(inputs.entity_id).called.igv.seg
    loadContents: false



baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: |-
    set -e
    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    gatk --java-options -Xmx$((inputs.mem_gb*1000)-1000)m CallCopyRatioSegments --output $(inputs.entity_id).called.seg

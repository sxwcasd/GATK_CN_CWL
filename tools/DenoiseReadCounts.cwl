#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: DenoiseReadCounts

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: broadinstitute/gatk:latest

inputs:
- id: entity_id
  type: string
- id: read_counts
  type: File
  inputBinding:
    prefix: --input
    shellQuote: false
- id: read_count_pon
  type: File
  inputBinding:
    prefix: --count-panel-of-normals
    shellQuote: false
- id: number_of_eigensamples
  type: int?
  inputBinding:
    prefix: --number-of-eigensamples
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
  default: 13
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
- id: standardized_copy_ratios
  type: File
  outputBinding:
    glob: $(inputs.entity_id).standardizedCR.tsv
- id: denoised_copy_ratios
  type: File
  outputBinding:
    glob: $(inputs.entity_id).denoisedCR.tsv


baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: |-
    set -e
    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    gatk --java-options -Xmx$((inputs.mem_gb*1000)-1000)m DenoiseReadCounts  --standardized-copy-ratios $(inputs.entity_id).standardizedCR.tsv --denoised-copy-ratios $(inputs.entity_id).denoisedCR.tsv

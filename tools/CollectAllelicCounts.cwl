#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: CollectAllelicCounts

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: broadinstitute/gatk:latest
- class: ResourceRequirement
  ramMax: $(inputs.mem_gb*1000)
  coresMax: $(inputs.cpu)

inputs:
- id: common_sites
  type: File
  inputBinding:
    prefix: -L
    shellQuote: false
- id: bam
  type: File
  secondaryFiles:
  - ^.bai
  inputBinding:
    prefix: --input
    shellQuote: false
- id: ref_fasta
  type: File
  secondaryFiles:
  - ^.dict
  - .fai
  inputBinding:
    prefix: --reference
    shellQuote: false
- id: minimum_base_quality
  type: int?
  default: 20
  inputBinding:
    prefix: --minimum-base-quality
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
  default: 13
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
- id: entity_id
  type: string
  outputBinding:
    outputEval: $(inputs.bam.nameroot)
- id: allelic_counts
  type: File
  outputBinding:
    glob: $(inputs.bam.nameroot).allelicCounts.tsv


baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: >-
    set -eu

    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    gatk --java-options -Xmx$((inputs.mem_gb*1000)-1000)m CollectAllelicCounts --output $(inputs.bam.nameroot).allelicCounts.tsv

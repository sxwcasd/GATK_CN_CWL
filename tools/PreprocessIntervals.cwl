#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: PreprocessIntervals

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
  type: File?
  inputBinding:
    prefix: -L
    shellQuote: false
- id: blacklist_intervals
  type: File?
  inputBinding:
    prefix: -XL
    shellQuote: false
- id: ref_fasta
  type: File
  secondaryFiles:
  - ^.dict
  - .fai
  inputBinding:
    prefix: --reference
    shellQuote: false
- id: padding
  type: int?
  default: 250
  inputBinding:
    prefix: --padding
    shellQuote: false
- id: bin_length
  type: int?
  default: 1000
  inputBinding:
    prefix: --bin-length
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

baseCommand: []
arguments:
- position: -1
  shellQuote: false
  valueFrom: >-
    set -eu

    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    gatk --java-options -Xmx$((inputs.mem_gb*1000)-500)m PreprocessIntervals \
    --interval-merging-rule OVERLAPPING_ONLY
- position: 0
  shellQuote: false
  valueFrom: |-
    ${
      var basename
      if(inputs.intervals){
        basename = inputs.intervals.nameroot
      } else {
        basename = "wgs"
      }
      return ("--output " + basename + ".preprocessed.interval_list")
    }

outputs:
- id: preprocessed_intervals
  type: File
  outputBinding:
    glob: |-
      ${
        var basename
        if(inputs.intervals){
          basename = inputs.intervals.nameroot
        } else {
          basename = "wgs"
        }
        return (basename + ".preprocessed.interval_list")
      }

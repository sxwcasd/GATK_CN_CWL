#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: PlotModeledSegments

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: broadinstitute/gatk:latest

inputs:
- id: entity_id
  type: string
  inputBinding:
    prefix: --output-prefix
    shellQuote: false
- id: denoised_copy_ratios
  type: File
  inputBinding:
    prefix: --denoised-copy-ratios
    shellQuote: false
- id: het_allelic_counts
  type: File
  inputBinding:
    prefix: --allelic-counts
    shellQuote: false
- id: modeled_segments
  type: File
  inputBinding:
    prefix: --segments
    shellQuote: false
- id: ref_fasta_dict
  type: File
  inputBinding:
    prefix: --sequence-dictionary
    shellQuote: false
- id: minimum_contig_length
  type: int?
  default: 1000000
  inputBinding:
    prefix: --minimum-contig-length
    shellQuote: false
- id: output_dir
  type: string?
  default: "out"
  inputBinding:
    prefix: --output
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
- id: modeled_segments_plot
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).modeled.png
    loadContents: false


baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: |-
    set -e
    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    gatk --java-options -Xmx$((inputs.mem_gb*1000)-1000)m PlotModeledSegments

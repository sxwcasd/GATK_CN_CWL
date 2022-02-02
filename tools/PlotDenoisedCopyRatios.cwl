#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: PlotDenoisedCopyRatios

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
- id: standardized_copy_ratios
  type: File
  inputBinding:
    prefix: --standardized-copy-ratios
    shellQuote: false
- id: denoised_copy_ratios
  type: File
  inputBinding:
    prefix: --denoised-copy-ratios
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
- id: denoised_copy_ratios_plot
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).denoised.png
    loadContents: false
- id: standardized_MAD
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).standardizedMAD.txt
    loadContents: true
- id: standardized_MAD_value
  type: float
  outputBinding:
    glob: $(inputs.output_dir + "/" + inputs.entity_id + ".standardizedMAD.txt")
    loadContents: true
    outputEval: $(parseFloat(self[0].contents))
- id: denoised_MAD
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).denoisedMAD.txt
    loadContents: true
- id: denoised_MAD_value
  type: float
  outputBinding:
    glob: $(inputs.output_dir + "/" + inputs.entity_id + ".denoisedMAD.txt")
    loadContents: true
    outputEval: $(parseFloat(self[0].contents))
- id: delta_MAD
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).deltaMAD.txt
    loadContents: true
- id: delta_MAD_value
  type: float
  outputBinding:
    glob: $(inputs.output_dir + "/" + inputs.entity_id + ".deltaMAD.txt")
    loadContents: true
    outputEval: $(parseFloat(self[0].contents))
- id: scaled_delta_MAD
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).scaledDeltaMAD.txt
    loadContents: true
- id: scaled_delta_MAD_value
  type: float
  outputBinding:
    glob: $(inputs.output_dir + "/" + inputs.entity_id + ".scaledDeltaMAD.txt")
    loadContents: true
    outputEval: $(parseFloat(self[0].contents))


baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: |-
    set -e
    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    gatk --java-options -Xmx$((inputs.mem_gb*1000)-1000)m PlotDenoisedCopyRatios

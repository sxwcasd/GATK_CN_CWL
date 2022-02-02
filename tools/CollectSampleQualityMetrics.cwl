#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: CollectSampleQualityMetrics

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: broadinstitute/gatk:latest
- class: ResourceRequirement
  ramMax: $(inputs.mem_gb*1000)
  coresMax: $(inputs.cpu)

inputs:
- id: genotyped_segments_vcf
  type: File
- id: entity_id
  type: string
- id: maximum_number_events
  type: int
- id: gatk_docker
  type: string
- id: mem_gb
  type: int?
  default: 1
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
- id: qc_status_file
  type: File
  outputBinding:
    glob: $(inputs.entity_id).qcStatus.txt
- id: qc_status_string
  type: string
  # outputBinding:
  #   glob: $(inputs.entity_id).qcStatus.txt


baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: |-
    set -eu
    NUM_SEGMENTS=\$(gunzip -c $(inputs.genotyped_segments_vcf) | grep -v '#' | wc -l)
    if [ $NUM_SEGMENTS -lt $(inputs.maximum_number_events) ]; then
        echo "PASS" >> $(inputs.entity_id).qcStatus.txt
    else
        echo "EXCESSIVE_NUMBER_OF_EVENTS" >> $(inputs.entity_id).qcStatus.txt
    fi

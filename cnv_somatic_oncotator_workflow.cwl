#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0
id: CNVOncotatorWorkflow

requirements:
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement

inputs:
- id: called_file
  type: File
- id: additional_args
  type: string?
- id: oncotator_docker
  type: string?
- id: mem_gb_for_oncotator
  type: int?
- id: boot_disk_space_gb_for_oncotator
  type: int?
- id: preemptible_attempts
  type: int?

outputs:
- id: oncotated_called_file
  type: File
  outputSource: OncotateSegments/oncotated_called_file
- id: oncotated_called_gene_list_file
  type: File
  outputSource: OncotateSegments/oncotated_called_gene_list_file

steps:
- id: OncotateSegments
  in:
  - id: called_file
    source: called_file
  - id: additional_args
    source: additional_args
  - id: oncotator_docker
    source: oncotator_docker
  - id: mem_gb
    source: mem_gb_for_oncotator
  - id: boot_disk_space_gb
    source: boot_disk_space_gb_for_oncotator
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/OncotateSegments.cwl
  out:
  - id: oncotated_called_file
  - id: oncotated_called_gene_list_file

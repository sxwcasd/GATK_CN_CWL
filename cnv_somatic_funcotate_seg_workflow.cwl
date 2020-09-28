#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0
id: CNVFuncotateSegmentsWorkflow

requirements:
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement

inputs:
- id: input_seg_file
  type: File
- id: ref_fasta
  type: File
  secondaryFiles:
  - ^.dict
  - ^.fai
- id: funcotator_ref_version
  type: string
- id: gatk4_jar_override
  type:
  - File?
  - string?
- id: funcotator_data_sources_tar_gz
  type: File?
- id: transcript_selection_mode
  type: string?
- id: transcript_selection_list
  type: File?
- id: annotation_defaults
  type: string[]?
- id: annotation_overrides
  type: string[]?
- id: funcotator_excluded_fields
  type: string[]?
- id: interval_list
  type: File?
- id: extra_args
  type: string?
- id: is_removing_untared_datasources
  type: boolean?
- id: gatk_docker
  type: string
- id: mem_gb
  type: int?
- id: disk_space_gb
  type: int?
- id: use_ssd
  type: boolean?
  default: false
- id: cpu
  type: int?
- id: preemptible_attempts
  type: int?

outputs:
- id: funcotated_seg_simple_tsv
  type: File
  outputSource: FuncotateSegments/funcotated_seg_simple_tsv
- id: funcotated_gene_list_tsv
  type: File
  outputSource: FuncotateSegments/funcotated_gene_list_tsv

steps:
- id: FuncotateSegments
  in:
  - id: input_seg_file
    source: input_seg_file
  - id: ref_fasta
    source: ref_fasta
  - id: funcotator_ref_version
    source: funcotator_ref_version
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: funcotator_data_sources_tar_gz
    source: funcotator_data_sources_tar_gz
  - id: transcript_selection_mode
    source: transcript_selection_mode
  - id: transcript_selection_list
    source: transcript_selection_list
  - id: annotation_defaults
    source: annotation_defaults
  - id: annotation_overrides
    source: annotation_overrides
  - id: funcotator_excluded_fields
    source: funcotator_excluded_fields
  - id: interval_list
    source: interval_list
  - id: extra_args
    source: extra_args
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb
  - id: disk_space_gb
    source: disk_space_gb
  - id: use_ssd
    source: use_ssd
  - id: cpu
    source: cpu
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/FuncotateSegments.cwl
  out:
  - id: funcotated_seg_simple_tsv
  - id: funcotated_gene_list_tsv

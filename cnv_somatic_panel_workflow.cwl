class: Workflow
cwlVersion: v1.0
id: CNVSomaticPanelWorkflow

requirements:
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement
- class: ScatterFeatureRequirement

inputs:
- id: intervals
  type: File
- id: blacklist_intervals
  type: File?
- id: normal_bams
  type:
    type: array
    items: File
  secondaryFiles:
  - ^.bai
- id: pon_entity_id
  type: string
- id: ref_fasta
  type: File
  secondaryFiles:
  - ^.dict
  - .fai
- id: gatk_docker
  type: string
- id: do_explicit_gc_correction
  type: int[]?
  default: [1]
- id: gatk4_jar_override
  type:
  - File?
  - string?
- id: preemptible_attempts
  type: int?
- id: padding
  type: int?
- id: bin_length
  type: int?
- id: mem_gb_for_preprocess_intervals
  type: int?
- id: mappability_track_bed
  type: File?
  secondaryFiles:
  - ^.tabix
- id: segmental_duplication_track_bed
  type: File?
  secondaryFiles:
  - ^.tabix
- id: feature_query_lookahead
  type: int?
- id: mem_gb_for_annotate_intervals
  type: int?
- id: collect_counts_format
  type: string?
- id: mem_gb_for_collect_counts
  type: int?
- id: minimum_interval_median_percentile
  type: float?
- id: maximum_zeros_in_sample_percentage
  type: float?
- id: maximum_zeros_in_interval_percentage
  type: float?
- id: extreme_sample_median_percentile
  type: float?
- id: do_impute_zeros
  type: boolean?
- id: extreme_outlier_truncation_percentile
  type: float?
- id: number_of_eigensamples
  type: int?
- id: maximum_chunk_size
  type: int?
- id: mem_gb_for_create_read_count_pon
  type: int?

outputs:
- id: preprocessed_intervals
  type: File
  outputSource: PreprocessIntervals/preprocessed_intervals
- id: read_counts_entity_ids
  type:
    type: array
    items: string
  outputSource: CollectCounts/entity_id
- id: read_counts
  type:
    type: array
    items: File
  outputSource: CollectCounts/counts
- id: read_count_pon
  type: File
  outputSource: CreateReadCountPanelOfNormals/read_count_pon

steps:
- id: PreprocessIntervals
  in:
  - id: intervals
    source: intervals
  - id: blacklist_intervals
    source: blacklist_intervals
  - id: ref_fasta
    source: ref_fasta
  - id: padding
    source: padding
  - id: bin_length
    source: bin_length
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_preprocess_intervals
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/PreprocessIntervals.cwl
  out:
  - id: preprocessed_intervals

- id: AnnotateIntervals
  #use scatter to make conditional
  scatter: explicit_correction
  in:
  - id: explicit_correction
    source: do_explicit_gc_correction
  - id: intervals
    source: PreprocessIntervals/preprocessed_intervals
  - id: ref_fasta
    source: ref_fasta
  - id: mappability_track_bed
    source: mappability_track_bed
  - id: segmental_duplication_track_bed
    source: segmental_duplication_track_bed
  - id: feature_query_lookahead
    source: feature_query_lookahead
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_annotate_intervals
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/AnnotateIntervals.cwl
  out:
  - id: annotated_intervals
- id: UnScatter_annotated_intervals
  in:
  - id: input_array
    source: AnnotateIntervals/annotated_intervals
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: CollectCounts
  in:
  - id: intervals
    source: PreprocessIntervals/preprocessed_intervals
  - id: bam
    source: normal_bams
  - id: ref_fasta
    source: ref_fasta
  - id: format
    source: collect_counts_format
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_collect_counts
  - id: preemptible_attempts
    source: preemptible_attempts
  scatter: bam
  scatterMethod: dotproduct
  run: tools/CollectCounts.cwl
  out:
  - id: entity_id
  - id: counts
- id: CreateReadCountPanelOfNormals
  in:
  - id: pon_entity_id
    source: pon_entity_id
  - id: read_count_files
    source: CollectCounts/counts
  - id: minimum_interval_median_percentile
    source: minimum_interval_median_percentile
  - id: maximum_zeros_in_sample_percentage
    source: maximum_zeros_in_sample_percentage
  - id: maximum_zeros_in_interval_percentage
    source: maximum_zeros_in_interval_percentage
  - id: extreme_sample_median_percentile
    source: extreme_sample_median_percentile
  - id: do_impute_zeros
    source: do_impute_zeros
  - id: extreme_outlier_truncation_percentile
    source: extreme_outlier_truncation_percentile
  - id: number_of_eigensamples
    source: number_of_eigensamples
  - id: maximum_chunk_size
    source: maximum_chunk_size
  - id: annotated_intervals
    source: UnScatter_annotated_intervals/File_
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_create_read_count_pon
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/CreateReadCountPanelOfNormals.cwl
  out:
  - id: read_count_pon

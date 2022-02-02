#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: ModelSegments

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
- id: allelic_counts
  type: File
  inputBinding:
    prefix: --allelic-counts
    shellQuote: false
- id: normal_allelic_counts
  type: File?
  inputBinding:
    prefix: --normal-allelic-counts
    shellQuote: false
- id: max_num_segments_per_chromosome
  type: int?
  default: 1000
  inputBinding:
    prefix: --maximum-number-of-segments-per-chromosome
    shellQuote: false
- id: min_total_allele_count
  type: int?
  default: 30
  inputBinding:
    prefix: --minimum-total-allele-count-case
    shellQuote: false
- id: min_total_allele_count_normal
  type: int?
  default: 30
  inputBinding:
    prefix: --minimum-total-allele-count-normal
    shellQuote: false
- id: genotyping_homozygous_log_ratio_threshold
  type: float?
  default: -10.0
  inputBinding:
    prefix: --genotyping-homozygous-log-ratio-threshold
    shellQuote: false
- id: genotyping_base_error_rate
  type: float?
  default: 0.05
  inputBinding:
    prefix: --genotyping-base-error-rate
    shellQuote: false
- id: kernel_variance_copy_ratio
  type: float?
  default: 0.0
  inputBinding:
    prefix: --kernel-variance-copy-ratio
    shellQuote: false
- id: kernel_variance_allele_fraction
  type: float?
  default: 0.025
  inputBinding:
    prefix: --kernel-variance-allele-fraction
    shellQuote: false
- id: kernel_scaling_allele_fraction
  type: float?
  default: 1.0
  inputBinding:
    prefix: --kernel-scaling-allele-fraction
    shellQuote: false
- id: kernel_approximation_dimension
  type: int?
  default: 100
  inputBinding:
    prefix: --kernel-approximation-dimension
    shellQuote: false
- id: window_sizes
  type: int[]?
  default: [8, 16, 32, 64, 128, 256]
  inputBinding:
    prefix: --window-size
    shellQuote: false
    itemSeparator: " --window-size "
- id: num_changepoints_penalty_factor
  type: float?
  default: 1.0
  inputBinding:
    prefix: --number-of-changepoints-penalty-factor
    shellQuote: false
- id: minor_allele_fraction_prior_alpha
  type: float?
  default: 25.0
  inputBinding:
    prefix: --minor-allele-fraction-prior-alpha
    shellQuote: false
- id: num_samples_copy_ratio
  type: int?
  default: 100
  inputBinding:
    prefix: --number-of-samples-copy-ratio
    shellQuote: false
- id: num_burn_in_copy_ratio
  type: int?
  default: 50
  inputBinding:
    prefix: --number-of-burn-in-samples-copy-ratio
    shellQuote: false
- id: num_samples_allele_fraction
  type: int?
  default: 100
  inputBinding:
    prefix: --number-of-samples-allele-fraction
    shellQuote: false
- id: num_burn_in_allele_fraction
  type: int?
  default: 50
  inputBinding:
    prefix: --number-of-burn-in-samples-allele-fraction
    shellQuote: false
- id: smoothing_threshold_copy_ratio
  type: float?
  default: 2.0
  inputBinding:
    prefix: --smoothing-credible-interval-threshold-copy-ratio
    shellQuote: false
- id: smoothing_threshold_allele_fraction
  type: float?
  default: 2.0
  inputBinding:
    prefix: --smoothing-credible-interval-threshold-allele-fraction
    shellQuote: false
- id: max_num_smoothing_iterations
  type: int?
  default: 10
  inputBinding:
    prefix: --maximum-number-of-smoothing-iterations
    shellQuote: false
- id: num_smoothing_iterations_per_fit
  type: int?
  default: 0
  inputBinding:
    prefix: --number-of-smoothing-iterations-per-fit
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
- id: het_allelic_counts
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).hets.tsv
    loadContents: false
- id: normal_het_allelic_counts
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).hets.normal.tsv
    loadContents: false
- id: copy_ratio_only_segments
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).cr.seg
    loadContents: false
- id: copy_ratio_legacy_segments
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).cr.igv.seg
    loadContents: false
- id: allele_fraction_legacy_segments
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).af.igv.seg
    loadContents: false
- id: modeled_segments_begin
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).modelBegin.seg
    loadContents: false
- id: copy_ratio_parameters_begin
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).modelBegin.cr.param
    loadContents: false
- id: allele_fraction_parameters_begin
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).modelBegin.af.param
    loadContents: false
- id: modeled_segments
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).modelFinal.seg
    loadContents: false
- id: copy_ratio_parameters
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).modelFinal.cr.param
    loadContents: false
- id: allele_fraction_parameters
  type: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.entity_id).modelFinal.af.param
    loadContents: false


baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: |-
    set -e
    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    gatk --java-options -Xmx$((inputs.mem_gb*1000)-3000)m ModelSegments

- position: 2
  shellQuote: false
  valueFrom: |-
    && touch $(inputs.output_dir)/$(inputs.entity_id).hets.normal.tsv

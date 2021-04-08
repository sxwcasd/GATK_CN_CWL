#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0
id: CNVSomaticPairWorkflow

requirements:
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement
- class: SubworkflowFeatureRequirement
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement

inputs:
- id: common_sites
  type: File
- id: intervals
  type: File
- id: blacklist_intervals
  type: File?
- id: tumor_bam
  type: File
  secondaryFiles:
  - ^.bai
- id: normal_bam
  type:
    type: array
    items: File
  secondaryFiles:
  - ^.bai
- id: read_count_pon
  type: File
- id: ref_fasta
  type: File
  secondaryFiles:
  - .fai
  - ^.dict
- id: gatk_docker
  type: string
- id: is_run_oncotator
  type: boolean?
- id: is_run_funcotator
  type: boolean?
- id: gatk4_jar_override
  type:
  - File
  - string?
- id: preemptible_attempts
  type: int?
- id: emergency_extra_disk
  type: int?
- id: padding
  type: int?
- id: bin_length
  type: int?
- id: mem_gb_for_preprocess_intervals
  type: int?
- id: collect_counts_format
  type: string?
- id: mem_gb_for_collect_counts
  type: int?
- id: minimum_base_quality
  type: string?
- id: mem_gb_for_collect_allelic_counts
  type: int?
- id: number_of_eigensamples
  type: int?
- id: mem_gb_for_denoise_read_counts
  type: int?
- id: max_num_segments_per_chromosome
  type: int?
- id: min_total_allele_count
  type: int?
- id: min_total_allele_count_normal
  type: int?
- id: genotyping_homozygous_log_ratio_threshold
  type: float?
- id: genotyping_base_error_rate
  type: float?
- id: kernel_variance_copy_ratio
  type: float?
- id: kernel_variance_allele_fraction
  type: float?
- id: kernel_scaling_allele_fraction
  type: float?
- id: kernel_approximation_dimension
  type: int?
- id: window_sizes
  type: int[]?
  default: [8, 16, 32, 64, 128, 256]
- id: num_changepoints_penalty_factor
  type: float?
- id: minor_allele_fraction_prior_alpha
  type: float?
- id: num_samples_copy_ratio
  type: int?
- id: num_burn_in_copy_ratio
  type: int?
- id: num_samples_allele_fraction
  type: int?
- id: num_burn_in_allele_fraction
  type: int?
- id: smoothing_threshold_copy_ratio
  type: float?
- id: smoothing_threshold_allele_fraction
  type: float?
- id: max_num_smoothing_iterations
  type: int?
- id: num_smoothing_iterations_per_fit
  type: int?
- id: mem_gb_for_model_segments
  type: int?
- id: neutral_segment_copy_ratio_lower_bound
  type: float?
- id: neutral_segment_copy_ratio_upper_bound
  type: float?
- id: outlier_neutral_segment_copy_ratio_z_score_threshold
  type: float?
- id: calling_copy_ratio_z_score_threshold
  type: float?
- id: mem_gb_for_call_copy_ratio_segments
  type: int?
- id: minimum_contig_length
  type: int?
- id: mem_gb_for_plotting
  type: int?
- id: additional_args_for_oncotator
  type: string?
- id: oncotator_docker
  type: string?
- id: mem_gb_for_oncotator
  type: int?
- id: boot_disk_space_gb_for_oncotator
  type: int?
- id: additional_args_for_funcotator
  type: string?
- id: funcotator_ref_version
  type: string?
  default: hg19
- id: mem_gb_for_funcotator
  type: int?
- id: funcotator_transcript_selection_list
  type: File?
- id: funcotator_data_sources_tar_gz
  type: File?
- id: funcotator_transcript_selection_mode
  type: string?
- id: funcotator_annotation_defaults
  type: string[]?
- id: funcotator_annotation_overrides
  type: string[]?
- id: funcotator_excluded_fields
  type: string[]?
- id: funcotator_is_removing_untared_datasources
  type: boolean?
- id: funcotator_disk_space_gb
  type: int?
- id: funcotator_use_ssd
  type: boolean?
- id: funcotator_cpu
  type: int?

outputs:
- id: preprocessed_intervals
  type: File
  outputSource: PreprocessIntervals/preprocessed_intervals
- id: read_counts_entity_ids
  type: string
  outputSource: CollectCountsTumor/entity_id
- id: read_counts_tumor
  type: File
  outputSource: CollectCountsTumor/counts
- id: allelic_counts_entity_id_tumor
  type: string
  outputSource: CollectAllelicCountsTumor/entity_id
- id: allelic_counts_tumor
  type: File
  outputSource: CollectAllelicCountsTumor/allelic_counts
- id: denoised_copy_ratios_tumor
  type: File
  outputSource: DenoiseReadCountsTumor/denoised_copy_ratios
- id: standardized_copy_ratios_tumor
  type: File
  outputSource: DenoiseReadCountsTumor/standardized_copy_ratios
- id: het_allelic_counts_tumor
  type: File
  outputSource: ModelSegmentsTumor/het_allelic_counts
- id: normal_het_allelic_counts_tumor
  type: File
  outputSource: ModelSegmentsTumor/normal_het_allelic_counts
- id: copy_ratio_only_segments_tumor
  type: File
  outputSource: ModelSegmentsTumor/copy_ratio_only_segments
- id: copy_ratio_legacy_segments_tumor
  type: File
  outputSource: ModelSegmentsTumor/copy_ratio_legacy_segments
- id: allele_fraction_legacy_segments_tumor
  type: File
  outputSource: ModelSegmentsTumor/allele_fraction_legacy_segments
- id: modeled_segments_begin_tumor
  type: File
  outputSource: ModelSegmentsTumor/modeled_segments_begin
- id: copy_ratio_parameters_begin_tumor
  type: File
  outputSource: ModelSegmentsTumor/copy_ratio_parameters_begin
- id: allele_fraction_parameters_begin_tumor
  type: File
  outputSource: ModelSegmentsTumor/allele_fraction_parameters_begin
- id: modeled_segments_tumor
  type: File
  outputSource: ModelSegmentsTumor/modeled_segments
- id: copy_ratio_parameters_tumor
  type: File
  outputSource: ModelSegmentsTumor/copy_ratio_parameters
- id: allele_fraction_parameters_tumor
  type: File
  outputSource: ModelSegmentsTumor/allele_fraction_parameters
- id: called_copy_ratio_segments_tumor
  type: File
  outputSource: CallCopyRatioSegmentsTumor/called_copy_ratio_segments
- id: called_copy_ratio_legacy_segments_tumor
  type: File
  outputSource: CallCopyRatioSegmentsTumor/called_copy_ratio_legacy_segments
- id: denoised_copy_ratios_plot_tumor
  type: File
  outputSource: PlotDenoisedCopyRatiosTumor/denoised_copy_ratios_plot
# - id: denoised_copy_ratios_lim_4_plot_tumor
#   type: File
#   outputSource: PlotDenoisedCopyRatiosTumor/denoised_copy_ratios_lim_4_plot
- id: standardized_MAD_tumor
  type: File
  outputSource: PlotDenoisedCopyRatiosTumor/standardized_MAD
# - id: standardized_MAD_value_tumor
#   type: float
#  outputSource: PlotDenoisedCopyRatiosTumor/standardized_MAD_value
- id: denoised_MAD_tumor
  type: File
  outputSource: PlotDenoisedCopyRatiosTumor/denoised_MAD
# - id: denoised_MAD_value_tumor
#   type: float
#  outputSource: PlotDenoisedCopyRatiosTumor/denoised_MAD_value
- id: delta_MAD_tumor
  type: File
  outputSource: PlotDenoisedCopyRatiosTumor/delta_MAD
# - id: delta_MAD_value_tumor
#   type: float
#  outputSource: PlotDenoisedCopyRatiosTumor/delta_MAD_value
- id: scaled_delta_MAD_tumor
  type: File
  outputSource: PlotDenoisedCopyRatiosTumor/scaled_delta_MAD
# - id: scaled_delta_MAD_value_tumor
#   type: float
#  outputSource: PlotDenoisedCopyRatiosTumor/scaled_delta_MAD_value
- id: modeled_segments_plot_tumor
  type: File
  outputSource: PlotModeledSegmentsTumor/modeled_segments_plot
- id: read_counts_entity_id_normal
  type: string?
  outputSource: UnScatter_read_counts_entity_id_normal/string_
- id: read_counts_normal
  type: File?
  outputSource: UnScatter_read_counts_normal/File_
- id: allelic_counts_entity_id_normal
  type: string?
  outputSource: UnScatter_allelic_counts_entity_id_normal/string_
- id: allelic_counts_normal
  type: File?
  outputSource: UnScatter_allelic_counts_normal/File_
- id: denoised_copy_ratios_normal
  type: File?
  outputSource: UnScatter_denoised_copy_ratios_normal/File_
- id: standardized_copy_ratios_normal
  type: File?
  outputSource: UnScatter_standardized_copy_ratios_normal/File_
- id: het_allelic_counts_normal
  type: File?
  outputSource: UnScatter_het_allelic_counts_normal/File_
- id: normal_het_allelic_counts_normal
  type: File?
  outputSource: UnScatter_normal_het_allelic_counts_normal/File_
- id: copy_ratio_only_segments_normal
  type: File?
  outputSource: UnScatter_copy_ratio_only_segments_normal/File_
- id: copy_ratio_legacy_segments_normal
  type: File?
  outputSource: UnScatter_copy_ratio_legacy_segments_normal/File_
- id: allele_fraction_legacy_segments_normal
  type: File?
  outputSource: UnScatter_allele_fraction_legacy_segments_normal/File_
- id: modeled_segments_begin_normal
  type: File?
  outputSource: UnScatter_modeled_segments_begin_normal/File_
- id: copy_ratio_parameters_begin_normal
  type: File?
  outputSource: UnScatter_copy_ratio_parameters_begin_normal/File_
- id: allele_fraction_parameters_begin_normal
  type: File?
  outputSource: UnScatter_allele_fraction_parameters_begin_normal/File_
- id: modeled_segments_normal
  type: File?
  outputSource: UnScatter_modeled_segments_normal/File_
- id: copy_ratio_parameters_normal
  type: File?
  outputSource: UnScatter_copy_ratio_parameters_normal/File_
- id: allele_fraction_parameters_normal
  type: File?
  outputSource: UnScatter_allele_fraction_parameters_normal/File_
- id: called_copy_ratio_segments_normal
  type: File?
  outputSource: UnScattercalled_copy_ratio_segments_normal/File_
- id: called_copy_ratio_legacy_segments_normal
  type: File?
  outputSource:  UnScattercalled_copy_ratio_legacy_segments_normal/File_
- id: denoised_copy_ratios_plot_normal
  type: File?
  outputSource: UnScatterdenoised_copy_ratios_plot/File_
# - id: denoised_copy_ratios_lim_4_plot_normal
#   type: File?
#   outputSource: UnScatterdenoised_copy_ratios_lim_4_plot/File_
- id: standardized_MAD_normal
  type: File?
  outputSource: UnScatterstandardized_MAD/File_
# - id: standardized_MAD_value_normal
#   type: float?
#   outputSource: UnScatterstandardized_MAD_value/float_
- id: denoised_MAD_normal
  type: File?
  outputSource: UnScatterdenoised_MAD/File_
# - id: denoised_MAD_value_normal
#   type: float?
#   outputSource: UnScatterdenoised_MAD_value/float_
- id: delta_MAD_normal
  type: File?
  outputSource: UnScatterdelta_MAD/File_
# - id: delta_MAD_value_normal
#   type: float?
#   outputSource: UnScatterdelta_MAD_value/float_
- id: scaled_delta_MAD_normal
  type: File?
  outputSource: UnScatterscaled_delta_MAD/File_
# - id: scaled_delta_MAD_value_normal
#   type: float?
#   outputSource: UnScatterscaled_delta_MAD_value/float_
- id: modeled_segments_plot_normal
  type: File?
  outputSource: UnScattermodeled_segments_plot/File_
- id: oncotated_called_file_tumor
  type: File?
  outputSource: CNVOncotatorWorkflow/oncotated_called_file
- id: oncotated_called_gene_list_file_tumor
  type: File?
  outputSource: CNVOncotatorWorkflow/oncotated_called_gene_list_file
- id: funcotated_called_file_tumor
  type: File?
  outputSource: CNVFuncotateSegmentsWorkflow/funcotated_seg_simple_tsv
- id: funcotated_called_gene_list_file_tumor
  type: File?
  outputSource: CNVFuncotateSegmentsWorkflow/funcotated_gene_list_tsv

steps:
- id: PreprocessIntervals
  in:
  - id: intervals
    source: intervals
  - id: common_sites
    source: common_sites
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
  - id: disk_space_gb
    valueFrom:
      ${
        var ref_size = Math.ceil(inputs.ref_fasta.size + inputs.ref_fasta.secondaryFiles[0].size + inputs.ref_fasta.secondaryFiles[1].size);
        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }
        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        return(ref_size+disk_pad);
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/PreprocessIntervals.cwl
  out:
  - id: preprocessed_intervals
- id: CollectCountsTumor
  in:
  - id: intervals
    source: PreprocessIntervals/preprocessed_intervals
  - id: bam
    source: tumor_bam
  - id: ref_fasta
    source: ref_fasta
  - id: enable_indexing
    default: false
  - id: format
    source: collect_counts_format
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_collect_counts
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: common_sites
    source: common_sites
  - id: disk_space_gb
    valueFrom:
      ${
        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }

        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        var tumor_bam_size = Math.ceil(inputs.bam.size + inputs.bam.secondaryFiles[0].size);

        return(tumor_bam_size + Math.ceil(inputs.intervals.size) + disk_pad);
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/CollectCounts.cwl
  out:
  - id: entity_id
  - id: counts
- id: CollectAllelicCountsTumor
  in:
  - id: intervals
    source: intervals
  - id: common_sites
    source: common_sites
  - id: bam
    source: tumor_bam
  - id: ref_fasta
    source: ref_fasta
  - id: minimum_base_quality
    source: minimum_base_quality
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_collect_allelic_counts
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: disk_space_gb
    valueFrom:
      ${
        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }

        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        var ref_size = Math.ceil(inputs.ref_fasta.size + inputs.ref_fasta.secondaryFiles[0].size + inputs.ref_fasta.secondaryFiles[1].size);

        var tumor_bam_size = Math.ceil(inputs.bam.size + inputs.bam.secondaryFiles[0].size);

        return(tumor_bam_size + ref_size + disk_pad);
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/CollectAllelicCounts.cwl
  out:
  - id: entity_id
  - id: allelic_counts
- id: DenoiseReadCountsTumor
  in:
  - id: entity_id
    source: CollectCountsTumor/entity_id
  - id: read_counts
    source: CollectCountsTumor/counts
  - id: read_count_pon
    source: read_count_pon
  - id: number_of_eigensamples
    source: number_of_eigensamples
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_denoise_read_counts
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: intervals
    source: intervals
  - id: common_sites
    source: common_sites
  - id: disk_space_gb
    valueFrom:
      ${
        var read_count_pon_size = Math.ceil(inputs.read_count_pon.size);

        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }

        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        return(read_count_pon_size + Math.ceil(inputs.read_counts.size) + disk_pad)
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/DenoiseReadCounts.cwl
  out:
  - id: standardized_copy_ratios
  - id: denoised_copy_ratios
- id: CollectAllelicCountsNormal
  scatter: bam
  in:
  # - id: run_normal
  #   valueFrom: |
  #     ${
  #       return [inputs.bam];
  #     }
  - id: common_sites
    source: common_sites
  - id: bam
    source: normal_bam
  - id: ref_fasta
    source: ref_fasta
  - id: minimum_base_quality
    source: minimum_base_quality
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_collect_allelic_counts
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: intervals
    source: intervals
  - id: disk_space_gb
    valueFrom:
      ${
        var ref_size = Math.ceil(inputs.ref_fasta.size + inputs.ref_fasta.secondaryFiles[0].size + inputs.ref_fasta.secondaryFiles[1].size);
        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }
        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        var normal_bam_size = 0;
        if (inputs.bam){
          normal_bam_size = Math.ceil(inputs.bam.size + inputs.bam.secondaryFiles[0].size);
        }
        return(normal_bam_size + ref_size + disk_pad);
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/CollectAllelicCounts.cwl
  out:
  - id: entity_id
  - id: allelic_counts
- id: UnScatter_allelic_counts_entity_id_normal
  in:
  - id: input_array
    source: CollectAllelicCountsNormal/entity_id
  run: tools/UnScatterString.cwl
  out:
  - id: string_
- id: UnScatter_allelic_counts_normal
  in:
  - id: input_array
    source: CollectAllelicCountsNormal/allelic_counts
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: ModelSegmentsTumor
  in:
  - id: entity_id
    source: CollectCountsTumor/entity_id
  - id: denoised_copy_ratios
    source: DenoiseReadCountsTumor/denoised_copy_ratios
  - id: allelic_counts
    source: CollectAllelicCountsTumor/allelic_counts
  - id: normal_allelic_counts
    source: UnScatter_allelic_counts_normal/File_
  - id: max_num_segments_per_chromosome
    source: max_num_segments_per_chromosome
  - id: min_total_allele_count
    source: min_total_allele_count
  - id: min_total_allele_count_normal
    source: min_total_allele_count_normal
  - id: genotyping_homozygous_log_ratio_threshold
    source: genotyping_homozygous_log_ratio_threshold
  - id: genotyping_base_error_rate
    source: genotyping_base_error_rate
  - id: kernel_variance_copy_ratio
    source: kernel_variance_copy_ratio
  - id: kernel_variance_allele_fraction
    source: kernel_variance_allele_fraction
  - id: kernel_scaling_allele_fraction
    source: kernel_scaling_allele_fraction
  - id: kernel_approximation_dimension
    source: kernel_approximation_dimension
  - id: window_sizes
    source: window_sizes
  - id: num_changepoints_penalty_factor
    source: num_changepoints_penalty_factor
  - id: minor_allele_fraction_prior_alpha
    source: minor_allele_fraction_prior_alpha
  - id: num_samples_copy_ratio
    source: num_samples_copy_ratio
  - id: num_burn_in_copy_ratio
    source: num_burn_in_copy_ratio
  - id: num_samples_allele_fraction
    source: num_samples_allele_fraction
  - id: num_burn_in_allele_fraction
    source: num_burn_in_allele_fraction
  - id: smoothing_threshold_copy_ratio
    source: smoothing_threshold_copy_ratio
  - id: smoothing_threshold_allele_fraction
    source: smoothing_threshold_allele_fraction
  - id: max_num_smoothing_iterations
    source: max_num_smoothing_iterations
  - id: num_smoothing_iterations_per_fit
    source: num_smoothing_iterations_per_fit
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_model_segments
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: intervals
    source: intervals
  - id: common_sites
    source: common_sites
  - id: normal_bam
    source: normal_bam
  - id: disk_space_gb
    source: [UnScatter_allelic_counts_normal/File_, DenoiseReadCountsTumor/denoised_copy_ratios, CollectAllelicCountsTumor/allelic_counts]
    valueFrom:
      ${
        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }
        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        var model_segments_normal_portion = 0;
        if (inputs.normal_bam){
          model_segments_normal_portion = Math.ceil(self[0].size);
        }

        return(Math.ceil(self[1].size) + Math.ceil(self[2].size) + model_segments_normal_portion + disk_pad);
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/ModelSegments.cwl
  out:
  - id: het_allelic_counts
  - id: normal_het_allelic_counts
  - id: copy_ratio_only_segments
  - id: copy_ratio_legacy_segments
  - id: allele_fraction_legacy_segments
  - id: modeled_segments_begin
  - id: copy_ratio_parameters_begin
  - id: allele_fraction_parameters_begin
  - id: modeled_segments
  - id: copy_ratio_parameters
  - id: allele_fraction_parameters
- id: CallCopyRatioSegmentsTumor
  in:
  - id: entity_id
    source: CollectCountsTumor/entity_id
  - id: copy_ratio_segments
    source: ModelSegmentsTumor/copy_ratio_only_segments
  - id: neutral_segment_copy_ratio_lower_bound
    source: neutral_segment_copy_ratio_lower_bound
  - id: neutral_segment_copy_ratio_upper_bound
    source: neutral_segment_copy_ratio_upper_bound
  - id: outlier_neutral_segment_copy_ratio_z_score_threshold
    source: outlier_neutral_segment_copy_ratio_z_score_threshold
  - id: calling_copy_ratio_z_score_threshold
    source: calling_copy_ratio_z_score_threshold
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_call_copy_ratio_segments
  - id: ref_fasta
    source: ref_fasta
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: intervals
    source: intervals
  - id: common_sites
    source: common_sites
  - id: disk_space_gb
    source: [DenoiseReadCountsTumor/denoised_copy_ratios, ModelSegmentsTumor/copy_ratio_only_segments]
    valueFrom:
      ${
        var ref_size = Math.ceil(inputs.ref_fasta.size + inputs.ref_fasta.secondaryFiles[0].size + inputs.ref_fasta.secondaryFiles[1].size);
        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }
        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        return(Math.ceil(self[0].size) + Math.ceil(self[1].size) + disk_pad);
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/CallCopyRatioSegments.cwl
  out:
  - id: called_copy_ratio_segments
  - id: called_copy_ratio_legacy_segments
- id: PlotDenoisedCopyRatiosTumor
  in:
  - id: entity_id
    source: CollectCountsTumor/entity_id
  - id: standardized_copy_ratios
    source: DenoiseReadCountsTumor/standardized_copy_ratios
  - id: denoised_copy_ratios
    source: DenoiseReadCountsTumor/denoised_copy_ratios
  - id: ref_fasta_dict
    valueFrom: $(inputs.ref_fasta.secondaryFiles[1])
  - id: minimum_contig_length
    source: minimum_contig_length
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: ref_fasta
    source: ref_fasta
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: intervals
    source: intervals
  - id: common_sites
    source: common_sites
  - id: disk_space_gb
    source: [DenoiseReadCountsTumor/standardized_copy_ratios, DenoiseReadCountsTumor/denoised_copy_ratios, ModelSegmentsTumor/het_allelic_counts, ModelSegmentsTumor/modeled_segments]
    valueFrom:
      ${
        var ref_size = Math.ceil(inputs.ref_fasta.size + inputs.ref_fasta.secondaryFiles[0].size + inputs.ref_fasta.secondaryFiles[1].size);
        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }
        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        return(ref_size + Math.ceil(self[0].size) + Math.ceil(self[1].size) + Math.ceil(self[2].size) + Math.ceil(self[3].size) + disk_pad)
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/PlotDenoisedCopyRatios.cwl
  out:
  - id: denoised_copy_ratios_plot
  #- id: denoised_copy_ratios_lim_4_plot
  - id: standardized_MAD
  #- id: standardized_MAD_value
  - id: denoised_MAD
  #- id: denoised_MAD_value
  - id: delta_MAD
  #- id: delta_MAD_value
  - id: scaled_delta_MAD
  #- id: scaled_delta_MAD_value
- id: PlotModeledSegmentsTumor
  in:
  - id: entity_id
    source: CollectCountsTumor/entity_id
  - id: denoised_copy_ratios
    source: DenoiseReadCountsTumor/denoised_copy_ratios
  - id: het_allelic_counts
    source: ModelSegmentsTumor/het_allelic_counts
  - id: modeled_segments
    source: ModelSegmentsTumor/modeled_segments
  - id: ref_fasta
    source: ref_fasta
  - id: ref_fasta_dict
    valueFrom: $(inputs.ref_fasta.secondaryFiles[1])
  - id: minimum_contig_length
    source: minimum_contig_length
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/PlotModeledSegments.cwl
  out:
  - id: modeled_segments_plot
- id: CollectCountsNormal
  scatter: bam
  in:
  # - id: run_normal
  #   valueFrom:
  #     ${
  #       if(inputs.normal_bam){
  #         return[1]
  #       }else{
  #         []
  #       }
  #     }
  - id: intervals
    source: PreprocessIntervals/preprocessed_intervals
  - id: bam
    source: normal_bam
  - id: ref_fasta
    source: ref_fasta
  - id: enable_indexing
    default: false
  - id: format
    source: collect_counts_format
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_collect_counts
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: common_sites
    source: common_sites
  - id: disk_space_gb
    valueFrom:
      ${
        var normal_bam_size = 0;
        if (inputs.bam){
          normal_bam_size = Math.ceil(inputs.bam.size + inputs.bam.secondaryFiles[0].size);
        }

        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }
        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        return(normal_bam_size + Math.ceil(inputs.intervals.size) + disk_pad);
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/CollectCounts.cwl
  out:
  - id: entity_id
  - id: counts
- id: UnScatter_read_counts_entity_id_normal
  in:
  - id: input_array
    source: CollectCountsNormal/entity_id
  run: tools/UnScatterString.cwl
  out:
  - id: string_
# - id: UnScatter_read_counts_entity_id_normal_file
#   in:
#   - id: input_array
#     source: CollectCountsNormal/entity_id
#   run: tools/UnScatterString_File.cwl
#   out:
#   - id: file_
- id: UnScatter_read_counts_normal
  in:
  - id: input_array
    source: CollectCountsNormal/counts
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: DenoiseReadCountsNormal
  scatter: read_counts
  in:
  # - id: run_normal
  #   valueFrom:
  #     ${
  #       if(inputs.normal_bam){
  #         return[1]
  #       }else{
  #         []
  #       }
  #     }
  - id: entity_id
    source: UnScatter_read_counts_entity_id_normal/string_
  - id: read_counts
    source: CollectCountsNormal/counts
  - id: read_count_pon
    source: read_count_pon
  - id: number_of_eigensamples
    source: number_of_eigensamples
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_denoise_read_counts
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: intervals
    source: intervals
  - id: common_sites
    source: common_sites
  - id: disk_space_gb
    valueFrom:
      ${
        var read_count_pon_size = Math.ceil(inputs.read_count_pon.size)

        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }
        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        return(read_count_pon_size + Math.ceil(inputs.read_counts.size) + disk_pad)
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/DenoiseReadCounts.cwl
  out:
  - id: standardized_copy_ratios
  - id: denoised_copy_ratios
- id: UnScatter_standardized_copy_ratios_normal
  in:
  - id: input_array
    source: DenoiseReadCountsNormal/standardized_copy_ratios
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: UnScatter_denoised_copy_ratios_normal
  in:
  - id: input_array
    source: DenoiseReadCountsNormal/denoised_copy_ratios
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: ModelSegmentsNormal
  scatter: allelic_counts
  in:
  # - id: run_normal
  #   valueFrom:
  #     ${
  #       if(inputs.normal_bam){
  #         return[1]
  #       }else{
  #         []
  #       }
  #     }
  - id: entity_id
    source: UnScatter_read_counts_entity_id_normal/string_
  - id: denoised_copy_ratios
    source: UnScatter_denoised_copy_ratios_normal/File_
  - id: allelic_counts
    source: CollectAllelicCountsNormal/allelic_counts
  - id: max_num_segments_per_chromosome
    source: max_num_segments_per_chromosome
  - id: min_total_allele_count
    source: min_total_allele_count
  - id: min_total_allele_count_normal
    source: min_total_allele_count_normal
  - id: genotyping_homozygous_log_ratio_threshold
    source: genotyping_homozygous_log_ratio_threshold
  - id: genotyping_base_error_rate
    source: genotyping_base_error_rate
  - id: kernel_variance_copy_ratio
    source: kernel_variance_copy_ratio
  - id: kernel_variance_allele_fraction
    source: kernel_variance_allele_fraction
  - id: kernel_scaling_allele_fraction
    source: kernel_scaling_allele_fraction
  - id: kernel_approximation_dimension
    source: kernel_approximation_dimension
  - id: window_sizes
    source: window_sizes
  - id: num_changepoints_penalty_factor
    source: num_changepoints_penalty_factor
  - id: minor_allele_fraction_prior_alpha
    source: minor_allele_fraction_prior_alpha
  - id: num_samples_copy_ratio
    source: num_samples_copy_ratio
  - id: num_burn_in_copy_ratio
    source: num_burn_in_copy_ratio
  - id: num_samples_allele_fraction
    source: num_samples_allele_fraction
  - id: num_burn_in_allele_fraction
    source: num_burn_in_allele_fraction
  - id: smoothing_threshold_copy_ratio
    source: smoothing_threshold_copy_ratio
  - id: smoothing_threshold_allele_fraction
    source: smoothing_threshold_allele_fraction
  - id: max_num_smoothing_iterations
    source: max_num_smoothing_iterations
  - id: num_smoothing_iterations_per_fit
    source: num_smoothing_iterations_per_fit
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_model_segments
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: intervals
    source: intervals
  - id: common_sites
    source: common_sites
  - id: disk_space_gb
    source: [DenoiseReadCountsNormal/denoised_copy_ratios, UnScatter_allelic_counts_normal/File_]
    valueFrom:
      ${
        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }
        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        return(Math.ceil(self[0].size) + Math.ceil(self[1].size) + disk_pad)
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/ModelSegments.cwl
  out:
  - id: het_allelic_counts
  - id: normal_het_allelic_counts
  - id: copy_ratio_only_segments
  - id: copy_ratio_legacy_segments
  - id: allele_fraction_legacy_segments
  - id: modeled_segments_begin
  - id: copy_ratio_parameters_begin
  - id: allele_fraction_parameters_begin
  - id: modeled_segments
  - id: copy_ratio_parameters
  - id: allele_fraction_parameters
- id: UnScatter_het_allelic_counts_normal
  in:
  - id: input_array
    source: ModelSegmentsNormal/het_allelic_counts
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: UnScatter_normal_het_allelic_counts_normal
  in:
  - id: input_array
    source: ModelSegmentsNormal/normal_het_allelic_counts
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: UnScatter_copy_ratio_only_segments_normal
  in:
  - id: input_array
    source: ModelSegmentsNormal/copy_ratio_only_segments
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: UnScatter_copy_ratio_legacy_segments_normal
  in:
  - id: input_array
    source: ModelSegmentsNormal/copy_ratio_legacy_segments
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: UnScatter_allele_fraction_legacy_segments_normal
  in:
  - id: input_array
    source: ModelSegmentsNormal/allele_fraction_legacy_segments
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: UnScatter_modeled_segments_begin_normal
  in:
  - id: input_array
    source: ModelSegmentsNormal/modeled_segments_begin
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: UnScatter_copy_ratio_parameters_begin_normal
  in:
  - id: input_array
    source: ModelSegmentsNormal/copy_ratio_parameters_begin
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: UnScatter_allele_fraction_parameters_begin_normal
  in:
  - id: input_array
    source: ModelSegmentsNormal/allele_fraction_parameters_begin
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: UnScatter_modeled_segments_normal
  in:
  - id: input_array
    source: ModelSegmentsNormal/modeled_segments
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: UnScatter_copy_ratio_parameters_normal
  in:
  - id: input_array
    source: ModelSegmentsNormal/copy_ratio_parameters
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: UnScatter_allele_fraction_parameters_normal
  in:
  - id: input_array
    source: ModelSegmentsNormal/allele_fraction_parameters
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: CallCopyRatioSegmentsNormal
  scatter: bam
  in:
  #- id: run_normal
  #  valueFrom:
  #    ${
  #      if(inputs.normal_bam){
  #        return[1]
  #      }else{
  #        []
  #      }
  #    }
  - id: bam
    source: normal_bam
  - id: entity_id
    source: UnScatter_read_counts_entity_id_normal/string_
  - id: copy_ratio_segments
    source: UnScatter_copy_ratio_only_segments_normal/File_
  - id: neutral_segment_copy_ratio_lower_bound
    source: neutral_segment_copy_ratio_lower_bound
  - id: neutral_segment_copy_ratio_upper_bound
    source: neutral_segment_copy_ratio_upper_bound
  - id: outlier_neutral_segment_copy_ratio_z_score_threshold
    source: outlier_neutral_segment_copy_ratio_z_score_threshold
  - id: calling_copy_ratio_z_score_threshold
    source: calling_copy_ratio_z_score_threshold
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_call_copy_ratio_segments
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: intervals
    source: intervals
  - id: common_sites
    source: common_sites
  - id: disk_space_gb
    source: [DenoiseReadCountsNormal/denoised_copy_ratios, UnScatter_copy_ratio_only_segments_normal/File_]
    valueFrom:
      ${
        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }
        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        return(Math.ceil(self[0].size) + Math.ceil(self[1].size) + disk_pad)
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/CallCopyRatioSegments.cwl
  out:
  - id: called_copy_ratio_segments
  - id: called_copy_ratio_legacy_segments
- id: UnScattercalled_copy_ratio_segments_normal
  in:
  - id: input_array
    source: CallCopyRatioSegmentsNormal/called_copy_ratio_segments
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: UnScattercalled_copy_ratio_legacy_segments_normal
  in:
  - id: input_array
    source: CallCopyRatioSegmentsNormal/called_copy_ratio_legacy_segments
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: PlotDenoisedCopyRatiosNormal
  scatter: bam
  in:
  # - id: run_normal
  #   valueFrom:
  #     ${
  #       if(inputs.normal_bam){
  #         return[1]
  #       }else{
  #         []
  #       }
  #     }
  - id: bam
    source: normal_bam
  - id: entity_id
    source: UnScatter_read_counts_entity_id_normal/string_
  - id: standardized_copy_ratios
    source: UnScatter_standardized_copy_ratios_normal/File_
  - id: denoised_copy_ratios
    source: UnScatter_denoised_copy_ratios_normal/File_
  - id: ref_fasta
    source: ref_fasta
  - id: ref_fasta_dict
    valueFrom: $(inputs.ref_fasta.secondaryFiles[1])
  - id: minimum_contig_length
    source: minimum_contig_length
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: intervals
    source: intervals
  - id: common_sites
    source: common_sites
  - id: disk_space_gb
    source: [DenoiseReadCountsNormal/standardized_copy_ratios, DenoiseReadCountsNormal/denoised_copy_ratios, UnScatter_het_allelic_counts_normal/File_, UnScatter_modeled_segments_normal/File_]
    valueFrom:
      ${
        var ref_size = Math.ceil(inputs.ref_fasta.size + inputs.ref_fasta.secondaryFiles[0].size + inputs.ref_fasta.secondaryFiles[1].size);
        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }
        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        return(ref_size + Math.ceil(self[0].size) + Math.ceil(self[1].size) + Math.ceil(self[2].size) + Math.ceil(self[3].size) + disk_pad)
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/PlotDenoisedCopyRatios.cwl
  out:
  - id: denoised_copy_ratios_plot
  #- id: denoised_copy_ratios_lim_4_plot
  - id: standardized_MAD
  #- id: standardized_MAD_value
  - id: denoised_MAD
  #- id: denoised_MAD_value
  - id: delta_MAD
  #- id: delta_MAD_value
  - id: scaled_delta_MAD
  #- id: scaled_delta_MAD_value
- id: UnScatterdenoised_copy_ratios_plot
  in:
  - id: input_array
    source: PlotDenoisedCopyRatiosNormal/denoised_copy_ratios_plot
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
# - id: UnScatterdenoised_copy_ratios_lim_4_plot
#   in:
#   - id: input_array
#     source: PlotDenoisedCopyRatiosNormal/denoised_copy_ratios_lim_4_plot
#   run: tools/UnScatterFile.cwl
#   out:
#   - id: File_
- id: UnScatterstandardized_MAD
  in:
  - id: input_array
    source: PlotDenoisedCopyRatiosNormal/standardized_MAD
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
# - id: UnScatterstandardized_MAD_value
#   in:
#   - id: input_array
#     source: PlotDenoisedCopyRatiosNormal/standardized_MAD_value
#   run: tools/UnScatterFloat.cwl
#   out:
#   - id: float_
- id: UnScatterdenoised_MAD
  in:
  - id: input_array
    source: PlotDenoisedCopyRatiosNormal/denoised_MAD
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
# - id: UnScatterdenoised_MAD_value
#   in:
#   - id: input_array
#     source: PlotDenoisedCopyRatiosNormal/denoised_MAD_value
#   run: tools/UnScatterFloat.cwl
#   out:
#   - id: float_
- id: UnScatterdelta_MAD
  in:
  - id: input_array
    source: PlotDenoisedCopyRatiosNormal/delta_MAD
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
# - id: UnScatterdelta_MAD_value
#   in:
#   - id: input_array
#     source: PlotDenoisedCopyRatiosNormal/delta_MAD_value
#   run: tools/UnScatterFloat.cwl
#   out:
#   - id: float_
- id: UnScatterscaled_delta_MAD
  in:
  - id: input_array
    source: PlotDenoisedCopyRatiosNormal/scaled_delta_MAD
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
# - id: UnScatterscaled_delta_MAD_value
#   in:
#   - id: input_array
#     source: PlotDenoisedCopyRatiosNormal/scaled_delta_MAD_value
#   run: tools/UnScatterFloat.cwl
#   out:
#   - id: float_
- id: PlotModeledSegmentsNormal
  scatter: bam
  in:
  #- id: run_normal
  #  valueFrom:
  #    ${
  #      if(inputs.normal_bam){
  #        return[1]
  #      }else{
  #        []
  #      }
  #    }
  - id: bam
    source: normal_bam
  - id: entity_id
    source: UnScatter_read_counts_entity_id_normal/string_
  - id: denoised_copy_ratios
    source: UnScatter_denoised_copy_ratios_normal/File_
  - id: het_allelic_counts
    source: UnScatter_het_allelic_counts_normal/File_
  - id: modeled_segments
    source: UnScatter_modeled_segments_normal/File_
  - id: ref_fasta
    source: ref_fasta
  - id: ref_fasta_dict
    valueFrom: $(inputs.ref_fasta.secondaryFiles[1])
  - id: minimum_contig_length
    source: minimum_contig_length
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: gatk_docker
    source: gatk_docker
  - id: emergency_extra_disk
    source: emergency_extra_disk
  - id: intervals
    source: intervals
  - id: common_sites
    source: common_sites
  - id: disk_space_gb
    source: [DenoiseReadCountsNormal/standardized_copy_ratios, DenoiseReadCountsNormal/denoised_copy_ratios, UnScatter_het_allelic_counts_normal/File_, UnScatter_modeled_segments_normal/File_]
    valueFrom:
      ${
        var gatk4_override_size = 0;
        if(inputs.gatk4_jar_override){
          var gatk4_override_size = Math.ceil(inputs.gatk4_jar_override.size);
        }
        var emergency_extra_disk_size = 0;
        if(inputs.emergency_extra_disk){
          var emergency_extra_disk_size = inputs.emergency_extra_disk;
        }
        var disk_pad = 20 + Math.ceil(inputs.intervals.size) + Math.ceil(inputs.common_sites.size) + gatk4_override_size + emergency_extra_disk_size;

        var ref_size = Math.ceil(inputs.ref_fasta.size + inputs.ref_fasta.secondaryFiles[0].size + inputs.ref_fasta.secondaryFiles[1].size);

        return(ref_size + Math.ceil(self[0].size) + Math.ceil(self[1].size) + Math.ceil(self[2].size) + Math.ceil(self[3].size) + disk_pad)
      }
  - id: preemptible_attempts
    source: preemptible_attempts
  run: tools/PlotModeledSegments.cwl
  out:
  - id: modeled_segments_plot
- id: UnScattermodeled_segments_plot
  in:
  - id: input_array
    source: PlotModeledSegmentsNormal/modeled_segments_plot
  run: tools/UnScatterFile.cwl
  out:
  - id: File_
- id: CNVOncotatorWorkflow
  #scatter: run_onco
  in:
  # - id: run_onco
  #   valueFrom:
  #     ${
  #       if(inputs.is_run_oncotator){
  #         return[1]
  #       }else{
  #         []
  #       }
  #     }
  - id: called_file
    source: CallCopyRatioSegmentsTumor/called_copy_ratio_segments
  - id: additional_args
    source: additional_args_for_oncotator
  - id: oncotator_docker
    source: oncotator_docker
  - id: mem_gb_for_oncotator
    source: mem_gb_for_oncotator
  - id: boot_disk_space_gb_for_oncotator
    source: boot_disk_space_gb_for_oncotator
  - id: preemptible_attempts
    source: preemptible_attempts
  run: cnv_somatic_oncotator_workflow.cwl
  out:
  - id: oncotated_called_file
  - id: oncotated_called_gene_list_file
# - id: UnScatterOncotate_genelist
#   in:
#   - id: input_array
#     source: CNVOncotatorWorkflow/oncotated_called_gene_list_file
#   run: tools/UnScatterFile.cwl
#   out:
#   - id: File_
# - id: UnScatterOncotate_called
#   in:
#   - id: input_array
#     source: CNVOncotatorWorkflow/oncotated_called_file
#   run: tools/UnScatterFile.cwl
#   out:
#   - id: File_
- id: CNVFuncotateSegmentsWorkflow
#  scatter: run_funco
  in:
  # - id: run_funco
  #   valueFrom:
  #     ${
  #       if(inputs.is_run_funcotator){
  #         return[1]
  #       }else{
  #         []
  #       }
  #     }
  - id: input_seg_file
    source: CallCopyRatioSegmentsTumor/called_copy_ratio_segments
  - id: ref_fasta
    source: ref_fasta
  - id: funcotator_ref_version
    source: funcotator_ref_version
  - id: gatk4_jar_override
    source: gatk4_jar_override
  - id: funcotator_data_sources_tar_gz
    source: funcotator_data_sources_tar_gz
  - id: transcript_selection_mode
    source: funcotator_transcript_selection_mode
  - id: transcript_selection_list
    source: funcotator_transcript_selection_list
  - id: annotation_defaults
    source: funcotator_annotation_defaults
  - id: annotation_overrides
    source: funcotator_annotation_overrides
  - id: funcotator_excluded_fields
    source: funcotator_excluded_fields
  - id: extra_args
    source: additional_args_for_funcotator
  - id: is_removing_untared_datasources
    source: funcotator_is_removing_untared_datasources
  - id: gatk_docker
    source: gatk_docker
  - id: mem_gb
    source: mem_gb_for_funcotator
  - id: use_ssd
    source: funcotator_use_ssd
  - id: cpu
    source: funcotator_cpu
  - id: preemptible_attempts
    source: preemptible_attempts
  run: cnv_somatic_funcotate_seg_workflow.cwl
  out:
  - id: funcotated_seg_simple_tsv
  - id: funcotated_gene_list_tsv
# - id: UnScatterFuncotate_genelist
#   in:
#   - id: input_array
#     source: CNVFuncotateSegmentsWorkflow/funcotated_gene_list_tsv
#   run: tools/UnScatterFile.cwl
#   out:
#   - id: File_
# - id: UnScatterFuncotate_seg
#   in:
#   - id: input_array
#     source: CNVFuncotateSegmentsWorkflow/funcotated_seg_simple_tsv
#   run: tools/UnScatterFile.cwl
#   out:
#   - id: File_

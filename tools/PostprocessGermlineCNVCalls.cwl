#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: PostprocessGermlineCNVCalls

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: broadinstitute/gatk:latest
- class: ResourceRequirement
  ramMax: $(inputs.mem_gb*1000)
  coresMax: $(inputs.cpu)


inputs:
- id: entity_id
  type: string
- id: gcnv_calls_tars
  type:
    type: array
    items: File
- id: gcnv_model_tars
  type:
    type: array
    items: File
- id: calling_configs
  type:
    type: array
    items: File
- id: denoising_configs
  type:
    type: array
    items: File
- id: gcnvkernel_version
  type:
    type: array
    items: File
- id: sharded_interval_lists
  type:
    type: array
    items: File
- id: contig_ploidy_calls_tar
  type: File
- id: allosomal_contigs
  type: string[]?
  inputBinding:
    prefix: --allosomal-contig
    itemSeparator: " "
    separate: false
    shellQuote: false
- id: ref_copy_number_autosomal_contigs
  type: int
  inputBinding:
    prefix: --autosomal-ref-copy-number
    shellQuote: false
- id: sample_index
  type: int
  inputBinding:
    prefix: --sample-index
    shellQuote: false
- id: gatk4_jar_override
  type:
  - File?
  - string?
  default: /gatk/gatk.jar
- id: gatk_docker
  label: gatk_docker
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
  default: 1
- id: preemptible_attempts
  type: int?

outputs:
- id: genotyped_intervals_vcf
  type: File
  outputBinding:
    glob: genotyped-intervals-$(inputs.entity_id).vcf.gz
- id: genotyped_segments_vcf
  type: File
  outputBinding:
    glob: genotyped-segments-$(inputs.entity_id).vcf.gz
- id: denoised_copy_ratios
  type: File
  outputBinding:
    glob: denoised_copy_ratios-$(inputs.entity_id).tsv




baseCommand: []
arguments:
- position: -1
  shellQuote: false
  valueFrom: |-
    set -eu
    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    sharded_interval_lists_array=$(inputs.sharded_interval_lists)

    # untar calls to CALLS_0, CALLS_1, etc directories and build the command line
    # also copy over shard config and interval files
    gcnv_calls_tar_array=($(inputs.gcnv_calls_tars))
    calling_configs_array=($(inputs.calling_configs))
    denoising_configs_array=($(inputs.denoising_configs))
    gcnvkernel_version_array=($(inputs.gcnvkernel_version))
    sharded_interval_lists_array=($(inputs.sharded_interval_lists))
    calls_args=""
    for index in \${!gcnv_calls_tar_array[@]}; do
        gcnv_calls_tar=\${gcnv_calls_tar_array[$index]}
        mkdir -p CALLS_$index/SAMPLE_$(inputs.sample_index)
        tar xzf $gcnv_calls_tar -C CALLS_$index/SAMPLE_$(inputs.sample_index)
        cp \${calling_configs_array[$index]} CALLS_$index/
        cp \${denoising_configs_array[$index]} CALLS_$index/
        cp \${gcnvkernel_version_array[$index]} CALLS_$index/
        cp \${sharded_interval_lists_array[$index]} CALLS_$index/
        calls_args="$calls_args --calls-shard-path CALLS_$index"
    done

    # untar models to MODEL_0, MODEL_1, etc directories and build the command line
    gcnv_model_tar_array=($(inputs.gcnv_model_tars))
    model_args=""
    for index in \${!gcnv_model_tar_array[@]}; do
        gcnv_model_tar=\${gcnv_model_tar_array[$index]}
        mkdir MODEL_$index
        tar xzf $gcnv_model_tar -C MODEL_$index
        model_args="$model_args --model-shard-path MODEL_$index"
    done

    mkdir contig-ploidy-calls
    tar xzf $(inputs.contig_ploidy_calls_tar) -C contig-ploidy-calls

    gatk --java-options -Xmx$((inputs.mem_gb*1000)-1000)m PostprocessGermlineCNVCalls \
        $calls_args \
        $model_args \
        --contig-ploidy-calls contig-ploidy-calls \
        --output-genotyped-intervals genotyped-intervals-$(inputs.entity_id).vcf.gz \
        --output-genotyped-segments genotyped-segments-$(inputs.entity_id).vcf.gz \
        --output-denoised-copy-ratios denoised_copy_ratios-$(inputs.entity_id).tsv

- position: 1
  shellQuote: false
  valueFrom: |-


    rm -rf CALLS_*
    rm -rf MODEL_*
    rm -rf contig-ploidy-calls

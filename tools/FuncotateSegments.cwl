#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: FuncotateSegments

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: broadinstitute/gatk:latest

inputs:
- id: input_seg_file
  type: File
  inputBinding:
    prefix: --segments
    shellQuote: false
- id: ref_fasta
  type: File
  secondaryFiles:
  - ^.dict
  - .fai
  inputBinding:
    prefix: -R
    shellQuote: false
- id: funcotator_ref_version
  type: string
- id: gatk4_jar_override
  type:
  - File?
  - string?
  default: "/gatk/gatk.jar"
- id: funcotator_data_sources_tar_gz
  type:
  - File?
  #default:
    #gs://broad-public-datasets/funcotator/funcotator_dataSources.v1.6.20190124s.tar.gz
- id: transcript_selection_mode
  type: string?
  default: CANONICAL
  inputBinding:
    prefix: --transcript-selection-mode
    shellQuote: false
- id: transcript_selection_list
  type: File?
  inputBinding:
    prefix: --transcript-list
    shellQuote: false
- id: annotation_defaults
  label: annotation_defaults
  type: string[]?
  inputBinding:
    prefix: --annotation-default
    shellQuote: false
- id: annotation_overrides
  type: string[]?
  inputBinding:
    prefix: --annotation-override
    shellQuote: false
- id: funcotator_excluded_fields
  type: string[]?
  inputBinding:
    prefix: --exclude-field
    shellQuote: false
- id: interval_list
  type: File?
  inputBinding:
    prefix: -L
    shellQuote: false
- id: extra_args
  type: string?
  inputBinding:
    position: 1
    shellQuote: false
- id: is_removing_untared_datasources
  type: boolean?
  default: true
- id: gatk_docker
  type: string
- id: mem_gb
  type: int?
  default: 3
- id: disk_space_gb
  type: int?
  default: 100
- id: use_ssd
  type: boolean
  default: false
- id: cpu
  type: int?
- id: preemptible_attempts
  type: int?

outputs:
- id: funcotated_seg_simple_tsv
  type: File
  outputBinding:
    glob: $(inputs.input_seg_file.nameroot).funcotated.tsv
- id: funcotated_gene_list_tsv
  type: File
  outputBinding:
    glob: $(inputs.input_seg_file.nameroot).funcotated.tsv.gene_list.txt


baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: |-
    set -eu
    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

     # Extract our data sources:
     echo "Extracting data sources zip file..."
     mkdir datasources_dir
     tar zxvf $(inputs.funcotator_data_sources_tar_gz) -C datasources_dir --strip-components 1
     DATA_SOURCES_FOLDER="$PWD/datasources_dir"

     # Run FuncotateSegments:
     gatk --java-options -Xmx$((inputs.mem_gb*1000)-1000)m FuncotateSegments \
         --data-sources-path $DATA_SOURCES_FOLDER \
         --ref-version $(inputs.funcotator_ref_version) \
         --output-file-format SEG \
         -O $(inputs.input_seg_file.nameroot).funcotated.tsv
- position: 2
  shellQuote: false
  valueFrom: |-
   ${
       var DATA_SOURCES_FOLDER="$PWD/datasources_dir"
       if(inputs.is_removing_untared_datasources){
         return("echo Removing $DATA_SOURCES_FOLDER && rm -Rf $DATA_SOURCES_FOLDER ")
       }else{
         return(" echo Not bothering to remove datasources.")
       }
     }

#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: CollectCounts

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: broadinstitute/gatk:latest
- class: ResourceRequirement
  ramMax: $(inputs.mem_gb*1000)
  coresMax: $(inputs.cpu)

inputs:
- id: intervals
  type: File
  inputBinding:
    prefix: -L
    shellQuote: false
- id: bam
  type: File
  secondaryFiles:
  - ^.bai
  inputBinding:
    prefix: --input
    shellQuote: false
- id: ref_fasta
  type: File
  secondaryFiles:
  - ^.dict
  - .fai
  inputBinding:
    prefix: --reference
    shellQuote: false
- id: enable_indexing
  type: boolean?
  default: false
- id: format
  type: string?
  default: "HDF5"
- id: gatk4_jar_override
  type:
  - File?
  - string?
  default: /gatk/gatk.jar
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
  default: 1
- id: preemptible_attempts
  type: int?

outputs:
- id: entity_id
  type: string
  outputBinding:
    outputEval: $(inputs.bam.nameroot)
- id: counts
  type: File
  outputBinding:
    glob: |-
      ${
        var extension
        if(inputs.format == "HDF5"){
          extension = "counts.hdf5"
        } else if(inputs.format == "TSV"){
          extension = "counts.tsv"
        } else if(inputs.format == "TSV_GZ"){
            extension = "counts.tsv.gz"
        }else{
          extension = "null"
        }
        return ((inputs.bam.nameroot) + "." + extension)
      }


baseCommand: []
arguments:
- position: -1
  shellQuote: false
  valueFrom: >-
    set -eu

    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    gatk --java-options -Xmx$((inputs.mem_gb*1000)-500)m CollectReadCounts
    --interval-merging-rule OVERLAPPING_ONLY
- position: 0
  shellQuote: false
  valueFrom: |-
    ${
      var extension
      if(inputs.format == "HDF5"){
        extension = "counts.hdf5"
      } else if(inputs.format == "TSV"){
        extension = "counts.tsv"
      } else if(inputs.format == "TSV_GZ"){
          extension = "counts.tsv"
      }else{
        extension = "null"
      }
      return ("--output " + (inputs.bam.nameroot) + "." + extension)
    }
- position: 2
  shellQuote: false
  valueFrom: |-
    ${
      if(inputs.format == "TSV_GZ"){
        return("bgzip " + (inputs.bam.nameroot) + ".counts.tsv")
      }else{
        return("")
      }
    }
- position: 3
  shellQuote: false
  valueFrom: |-
    ${
      var extension
      if(inputs.format == "HDF5"){
        extension = "counts.hdf5"
      } else if(inputs.format == "TSV"){
        extension = "counts.tsv"
      } else if(inputs.format == "TSV_GZ"){
          extension = "counts.tsv.gz"
      }else{
        extension = "null"
      }
      if(inputs.enable_indexing){
        return ("gatk --java-options -Xmx" + ((inputs.mem_gb*1000)-1000) + "m IndexFeatureFile -I " + (inputs.bam.nameroot) + "." + extension)
      }else{
        return("")
      }
    }

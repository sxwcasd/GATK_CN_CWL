#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: CollectModelQualityMetrics

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: broadinstitute/gatk:latest

inputs:
- id: gcnv_model_tars
  type:
    type: array
    items: File
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
    glob: qcStatus.txt
    loadContents: false
- id: qc_status_string
  type: string
  outputBinding:
    glob: qcStatus.txt


baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: |-
    sed -e
    qc_status="PASS"

    gcnv_model_tar_array=($(inputs.gcnv_model_tars))
    for index in \${!gcnv_model_tar_array[@]}; do
        gcnv_model_tar=\${gcnv_model_tar_array[$index]}
        mkdir MODEL_$index
        tar xzf $gcnv_model_tar -C MODEL_$index
        ard_file=MODEL_$index/mu_ard_u_log__.tsv

        #check whether all values for ARD components are negative
        NUM_POSITIVE_VALUES=\$(awk '{ if (index($0, "@") == 0) {if ($1 > 0.0) {print $1} }}' MODEL_$index/mu_ard_u_log__.tsv | wc -l)
        if [ $NUM_POSITIVE_VALUES -eq 0 ]; then
            qc_status="ALL_PRINCIPAL_COMPONENTS_USED"
            break
        fi
    done
    echo $qc_status >> qcStatus.txt

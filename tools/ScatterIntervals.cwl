#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
id: ScatterIntervals

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: broadinstitute/gatk:latest
- class: ResourceRequirement
  ramMax: $(inputs.mem_gb*1000)
  coresMax: $(inputs.cpu)

inputs:
- id: interval_list
  type: File
- id: num_intervals_per_scatter
  type: int
- id: output_dir
  type: string?
  default: "out"
- id: gatk4_jar_override
  type:
  - File?
  - string?
- id: gatk_docker
  type: string
- id: mem_gb
  type: int?
  default: 2
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
- id: scattered_interval_lists
  type:
    type: array
    items: File
  outputBinding:
    glob: $(inputs.output_dir)/$(inputs.interval_list.nameroot).scattered.*.interval_list
    loadContents: false


baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: |-
    set -eu

    mkdir $(inputs.output_dir)

    NUM_INTERVALS=\$(grep -v '@' $(inputs.interval_list) | wc -l)

    NUM_SCATTERS=\$(echo \$((NUM_INTERVALS / $(inputs.num_intervals_per_scatter))))

    export GATK_LOCAL_JAR=$(inputs.gatk4_jar_override)

    if [ $NUM_SCATTERS -le 1 ]; then
        # if only a single shard is required, then we can just rename the original interval list
        >&2 echo "Not running IntervalListTools because only a single shard is required. Copying original interval list..."
        cp $(inputs.interval_list) $(inputs.output_dir)/$(inputs.interval_list.nameroot).scattered.0001.interval_list
    else
        gatk --java-options -Xmx$((inputs.mem_gb*1000)-500)m IntervalListTools \
            --INPUT $(inputs.interval_list) \
            --SUBDIVISION_MODE INTERVAL_COUNT \
            --SCATTER_CONTENT $(inputs.num_intervals_per_scatter) \
            --OUTPUT $(inputs.output_dir)

        # output files are named output_dir_/temp_0001_of_N/scattered.interval_list, etc. (N = number of scatters);
        # we rename them as output_dir_/base_filename.scattered.0001.interval_list, etc.
        ls -v $(inputs.output_dir)/*/scattered.interval_list | \
            cat -n | \
            while read n filename; do mv $filename $(inputs.output_dir)/$(inputs.interval_list.nameroot).scattered.\$(printf "%04d" $n).interval_list; done
        rm -rf $(inputs.output_dir)/temp_*_of_*
    fi

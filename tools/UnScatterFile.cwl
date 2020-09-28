#!/usr/bin/env cwl-runner
class: ExpressionTool
cwlVersion: v1.0
id: UnScatter

requirements:
- class: InlineJavascriptRequirement

inputs:
- id: input_array
  type: File[]

outputs:
- id: File_
  type: File


expression: |
  ${
    if(inputs.input_array.length == 1){
      return({"File_": inputs.input_array[0]})
    }else{
      return({"File_": null})
    }
  }

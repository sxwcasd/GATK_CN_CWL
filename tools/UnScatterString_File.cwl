#!/usr/bin/env cwl-runner
class: ExpressionTool
cwlVersion: v1.0
id: UnScatter

requirements:
- class: InlineJavascriptRequirement

inputs:
- id: input_array
  type: string[]

outputs:
- id: file_
  type: File


expression: |
  ${
    if(inputs.input_array.length == 1){
      return({ "class": "File",
               "contents": inputs.input_array[0]})
    }else{
      return({"file_": null})
    }
  }

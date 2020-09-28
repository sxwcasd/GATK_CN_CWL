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
- id: string_
  type: string


expression: |
  ${
    if(inputs.input_array.length == 1){
      return({"string_": inputs.input_array[0]})
    }else{
      return({"string_": null})
    }
  }

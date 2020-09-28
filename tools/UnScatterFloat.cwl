#!/usr/bin/env cwl-runner
class: ExpressionTool
cwlVersion: v1.0
id: UnScatter

requirements:
- class: InlineJavascriptRequirement

inputs:
- id: input_array
  type: float[]

outputs:
- id: float_
  type: float


expression: |
  ${
    if(inputs.input_array.length == 1){
      return({"float_": inputs.input_array[0]})
    }else{
      return({"float_": null})
    }
  }

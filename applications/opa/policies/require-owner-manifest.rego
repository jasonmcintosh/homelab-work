  package spinnaker.execution.stages.before.deployManifest
  required_annotations:=["owner"]
  deny["Manifest is missing a required annotation"] {
      metadata :=input.stage.context.manifests[_].metadata
      annotations := object.get(metadata,"annotations",{})
      # Use object.get to check if data exists
      object.get(annotations,required_annotations[_],null)==null
  }{
      metadata :=input.stage.context.manifests[_].spec.template.metadata
      annotations := object.get(metadata,"annotations",{})
      # Use object.get to check if data exists
      object.get(annotations,required_annotations[_],null)==null
  }

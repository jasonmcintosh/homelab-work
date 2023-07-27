package  spinnaker.deployment.tasks.before.deleteManifest

import future.keywords

blockedKinds := ["namespace"]

deny contains denyKindMsg if {
	some kind in input.deploy.kinds
	some blockedKind in blockedKinds
	blockedKind == kind

	denyKindMsg = sprintf("Delete Stage with found kind '%s' cannot run with any of the following kinds: %v.", [blockedKind, blockedKinds])
}

deny contains denyKindMsg if {
	some blockedKind in blockedKinds
	regex.match(concat("", ["^", blockedKind]), input.deploy.manifestName)

	denyKindMsg = sprintf("Delete Stage with found kind '%s' cannot run with any of the following kinds: %v.", [blockedKind, blockedKinds])
}


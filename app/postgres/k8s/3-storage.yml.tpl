# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-{{SPF_SERVICE_AZ1}}
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  csi.storage.k8s.io/fstype: ext4
  type: gp2
  encrypted: "true"
allowedTopologies:
- matchLabelExpressions:
  - key: topology.kubernetes.io/zone
    values:
      - {{SPF_SERVICE_AZ1}}
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-{{SPF_SERVICE_AZ2}}
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  csi.storage.k8s.io/fstype: ext4
  type: gp2
  encrypted: "true"
allowedTopologies:
- matchLabelExpressions:
  - key: topology.kubernetes.io/zone
    values:
      - {{SPF_SERVICE_AZ2}}

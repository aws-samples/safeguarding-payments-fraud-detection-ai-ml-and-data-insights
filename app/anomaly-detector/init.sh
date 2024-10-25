#!/bin/bash
#
# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# Run python script to create database objects and insert records if required
echo "Running python script to create database objects and insert records if required"
time python3 embeddings_loader.py

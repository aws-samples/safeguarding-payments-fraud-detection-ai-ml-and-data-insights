# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import logging

LOGGER: str = logging.getLogger(__name__)

def lambda_handler(event, context):
    # log time, event and context
    LOGGER.debug(f'got event: {event}')
    LOGGER.debug(f'got context: {context}')

    return True

if __name__ == '__main__':
    lambda_handler(event=None, context=None)

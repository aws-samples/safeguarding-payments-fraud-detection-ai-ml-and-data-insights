version: 0.2

phases:
  build:
    commands:
      - PATH="$PATH:$CODEBUILD_SRC_DIR/safeguarding-payments-fraud-detection-ai-ml-and-data-insights/bin" && export PATH
      - if [ -d "$CODEBUILD_SRC_DIR/safeguarding-payments-fraud-detection-ai-ml-and-data-insights" ]; then mv $CODEBUILD_SRC_DIR/safeguarding-payments-fraud-detection-ai-ml-and-data-insights/ temp/; fi
      - git clone https://github.com/aws-samples/safeguarding-payments-fraud-detection-ai-ml-and-data-insights
      - if [ -d "temp" ]; then cp -R temp/ $CODEBUILD_SRC_DIR/safeguarding-payments-fraud-detection-ai-ml-and-data-insights/; rm -rf temp; fi
      - cd $CODEBUILD_SRC_DIR/safeguarding-payments-fraud-detection-ai-ml-and-data-insights/
      - if [ -n "$SPF_GITHUB_BRANCH" ]; then git checkout $SPF_GITHUB_BRANCH; fi
      - AWS_ASSUME_ROLE=$(aws sts assume-role --role-arn ${role_arn} --role-session-name spf-`date '+%Y-%m-%d-%H-%M-%S'`) && export AWS_ASSUME_ROLE
      - AWS_ACCESS_KEY_ID=$(echo "$AWS_ASSUME_ROLE" | jq -r '.Credentials.AccessKeyId') && export AWS_ACCESS_KEY_ID
      - AWS_SECRET_ACCESS_KEY=$(echo "$AWS_ASSUME_ROLE" | jq -r '.Credentials.SecretAccessKey') && export AWS_SECRET_ACCESS_KEY
      - AWS_SESSION_TOKEN=$(echo "$AWS_ASSUME_ROLE" | jq -r '.Credentials.SessionToken') && export AWS_SESSION_TOKEN
      - mkdir -p $HOME/.aws/ && touch $HOME/.aws/config && touch $HOME/.aws/credentials
      - echo "[default]" >> $HOME/.aws/config
      - echo "region=$AWS_DEFAULT_REGION" >> $HOME/.aws/config
      - echo "[default]" >> $HOME/.aws/credentials
      - echo "aws_access_key_id=$AWS_ACCESS_KEY_ID" >> $HOME/.aws/credentials
      - echo "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" >> $HOME/.aws/credentials
      - echo "aws_session_token=$AWS_SESSION_TOKEN" >> $HOME/.aws/credentials
      - /bin/bash ./bin/deploy.sh -d $SPF_DIR -r $SPF_REGION -s $SPF_BUCKET -b $SPF_BACKEND -i $SPF_GID

cache:
  paths:
    - $CODEBUILD_SRC_DIR/safeguarding-payments-fraud-detection-ai-ml-and-data-insights

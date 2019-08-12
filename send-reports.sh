#!/bin/bash

# Ensure any non-zero exit terminates the script immediately
set -e
set -o pipefail

echo "Travis event type is $TRAVIS_EVENT_TYPE"
echo "Travis commit message is $TRAVIS_COMMIT_MESSAGE"

# Only run the build if it was triggered by Travis CI's cron facility
if [ "$TRAVIS_EVENT_TYPE" != "cron" ] && [[ $TRAVIS_COMMIT_MESSAGE != "FORCE_RUN"* ]]; then
    echo "ℹ️ This build was not triggered by cron - skipping."
    exit 0
fi

# Check that we have all the necessary env vars (configured in .travis.yml)
declare -a vars=(GITHUB_USER GITHUB_PASSWORD BITERGIA_USER BITERGIA_PASSWORD SMTP_USER SMTP_PASSWORD)

for var_name in "${vars[@]}"
do
  if [ -z "$(eval "echo \$$var_name")" ]; then
    echo "⚠️ Missing environment variable $var_name - terminating."
    exit 1
  fi
done

function uriencode()
{
  s="${1//'%'/%25}"
  s="${s//' '/%20}"
  s="${s//'"'/%22}"
  s="${s//'#'/%23}"
  s="${s//'$'/%24}"
  s="${s//'&'/%26}"
  s="${s//'+'/%2B}"
  s="${s//','/%2C}"
  s="${s//'/'/%2F}"
  s="${s//':'/%3A}"
  s="${s//';'/%3B}"
  s="${s//'='/%3D}"
  s="${s//'?'/%3F}"
  s="${s//'@'/%40}"
  s="${s//'['/%5B}"
  s="${s//']'/%5D}"
  printf %s "$s"
}

# Ok we're good to go!
mkdir -p target
cd target
git clone https://$(uriencode ${GITHUB_USER}):$(uriencode ${GITHUB_PASSWORD})@github.com/finos/metadata-tool.git
cd metadata-tool
lein deps
lein run -- --email-override email-pmc-reports

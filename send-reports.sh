#!/bin/bash
# Only run the build if it was triggered by Travis CI's cron facility
if [ "$TRAVIS_EVENT_TYPE" != "cron" ]; then
    echo "This build was not triggered by cron - skipping."
    exit 0
fi

# Check that we have all the necessary env vars (configured in .travis.yml)
declare -a vars=(GITHUB_USER GITHUB_PASSWORD BITERGIA_USER BITERGIA_PASSWORD SMTP_USER SMTP_PASSWORD)

for var_name in "${vars[@]}"
do
  if [ -z "$(eval "echo \$$var_name")" ]; then
    echo "Missing environment variable $var_name"
    exit 1
  fi
done

# Ok we're good to go!
mkdir -p target
cd target
git clone https://$GITHUB_USER:$GITHUB_PASSWORD@github.com/finos/metadata-tool.git
cd metadata-tool
lein deps
# TODO: USE THIS ONCE EVERYTHING IS KNOWN TO BE WORKING!
#lein run -- --email-override email-pmc-reports
lein run -- email-pmc-reports

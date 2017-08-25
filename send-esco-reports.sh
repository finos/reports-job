#!/bin/bash
# Only run the build if it was triggered by Travis CI's cron facility
# ####TEST COMMENTED OUT DURING TESTING OF TRAVIS SETUP!!!!
#if [ "$TRAVIS_EVENT_TYPE" != "cron" ]; then
#    echo "This build was not triggered by cron - skipping."
#    exit 0
#fi

# Check that we have all the necessary env vars (configured in .travis.yml)
declare -a vars=(GITHUB_USER GITHUB_PASSWORD JIRA_USER JIRA_PASSWORD BITERGIA_USER BITERGIA_PASSWORD SMTP_USER SMTP_PASSWORD ESCO_EMAIL_ADDRESS)

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
git clone https://$GITHUB_USER:$GITHUB_PASSWORD@github.com/symphonyoss/ssf-metadata.git
cd ssf-metadata/tools/metadata-tool
lein deps
lein run -- email-active-projects-with-unactioned-prs-report email-inactive-projects-report

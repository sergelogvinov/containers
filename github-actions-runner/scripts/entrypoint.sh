#!/bin/bash -e

if [[ -z $RUNNER_NAME ]]; then
    export RUNNER_NAME=`hostname`
fi

if [[ -z $RUNNER_REPOSITORY_URL && -z $RUNNER_ORGANIZATION_URL ]]; then
    echo "Error : You need to set the RUNNER_REPOSITORY_URL environment variable."
    exit 1
fi

if [[ -z $RUNNER_TOKEN ]] && [[ -z $GITHUB_ACCESS_TOKEN ]]; then
    echo "Error : You need to set the RUNNER_TOKEN or GITHUB_ACCESS_TOKEN environment variable."
    exit 1
fi

if [[ -f ".runner" ]]; then
    echo "Runner already configured. Skipping config."
else
    if [[ ! -z $RUNNER_ORGANIZATION_URL ]]; then
        SCOPE="orgs"
        RUNNER_URL="${RUNNER_ORGANIZATION_URL}"
    else
        SCOPE="repos"
        RUNNER_URL="${RUNNER_REPOSITORY_URL}"
    fi

    if [[ -z $RUNNER_TOKEN ]]; then
        _PATH_="$(echo $RUNNER_URL | cut -d/ -f4-)"

        RUNNER_TOKEN="$(curl -XPOST -fsSL \
            -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/${SCOPE}/${_PATH_}/actions/runners/registration-token" \
            | jq -r '.token')"
    fi

    /home/runner/config.sh \
        --url $RUNNER_URL \
        --token $RUNNER_TOKEN \
        --name $RUNNER_NAME \
        --work $RUNNER_WORK_FOLDER \
        --replace \
        --unattended

    unset RUNNER_TOKEN
    unset GITHUB_ACCESS_TOKEN
fi

nodever=${GITHUB_ACTIONS_RUNNER_FORCED_NODE_VERSION:-node16}
exec /home/runner/externals/$nodever/bin/node /home/runner/bin/RunnerService.js

#!/bin/bash

readonly allEnvs="alln-stg rcdn-prd sjc-prd sjc-stg"

function usage(){
  echo "Usage: $0 -a hmsapp-on-alln-stg -e alln-stg -g https://wwwin-github.cisco.com/devx/opex-backend -r master -p k8s/* -pr onedevx-alln-stg -t appset
  exit 2
}

[[ $# -ge 8 ]] || usage

while [[ $# -gt 0 ]]; do
  case "$1" in
    "-a" ) inputApp=$2 ;;
    "-e" ) inputEnv=$2 ;;
    "-t" ) inputType=$2 ;;
    "-g" ) inputGitUrl=$2 ;;
    "-r" ) inputGitRev=$2 ;;
    "-p" ) inputAppCfgPath=$2 ;;
    "-pr" ) inputProjectName=$2 ;;
    * ) usage ;;
  esac
  shift 2
done

echo ${allEnvs} | grep -qs ${inputEnv} || { echo "Error: Invalid env:${inputEnv}. Valid environments are: ${allEnvs}"; exit 1; }

echo ${inputType} | egrep -qs "helm|yml|appset" || { echo "Error: Invalid type:${inputType}. Valid types are: helm or yml"; exit 1; }

topDir=$(dirname $(dirname $(realpath $0)))
nsDir="${topDir}/namespaces/"

[[ -d ${nsDir} ]] || { echo "InternalError: Unable to find namespaces dir ${nsDir}"; exit 3; }
[[ -d "${nsDir}/${inputApp}" ]] || cp -Rf ${topDir}/scripts/templates/${inputType}/ ${nsDir}/${inputApp}
[[ -d "${nsDir}/${inputApp}/apps/${inputApp}" ]] || mv ${nsDir}/${inputApp}/apps/APP_NAME ${nsDir}/${inputApp}/apps/${inputApp}
[[ -d "${nsDir}/${inputApp}/env/${inputEnv}" ]] || mv ${nsDir}/${inputApp}/env/CLUSTER_NAME ${nsDir}/${inputApp}/env/${inputEnv}

find ${nsDir}/${inputApp} -type f -name '*.yml' -print | while read i; do
  sed -i.bak "s#APP_NAME#${inputApp}#g" $i && rm ${i}.bak
  sed -i.bak "s#APP_GIT_URL#${inputGitUrl}#g" $i && rm ${i}.bak
  sed -i.bak "s#APP_GIT_REVISION#${inputGitRev}#g" $i && rm ${i}.bak
  sed -i.bak "s#APP_CONFIG_PATH#${inputAppCfgPath}#g" $i && rm ${i}.bak
  sed -i.bak "s#PROJECT_NAME#${inputProjectName}#g" $i && rm ${i}.bak
done

tree ${nsDir}/${inputApp}


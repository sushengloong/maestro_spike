#!/usr/bin/env bash

function setup() {
  GIT_URL=$1
  if [ -z "$GIT_URL" ]; then
    echo "Must provide a Git repository URL!"
    exit 11
  fi
  LOCAL_DIRNAME=$(basename $GIT_URL | cut -d'.' -f1)
}

function update_scanners() {
  bundle update
  rbenv rehash
  # update the ruby-advisory-db that bundle-audit uses
  bundle-audit update
}

function clone_or_pull_remote_repo() {
  if [ -d "$LOCAL_DIRNAME" ]; then
    (cd $LOCAL_DIRNAME && git pull -r)
    if [ $? -ne 0 ]; then
      echo "Failed to update $LOCAL_DIRNAME"
      exit 12
    fi
  else
    git clone $GIT_URL $LOCAL_DIRNAME
    if [ $? -ne 0 ]; then
      echo "Failed to clone from $GIT_URL into $LOCAL_DIRNAME"
      exit 13
    fi
  fi
}

function parse_current_revision() {
  GIT_CURRENT_REVISION=$(cd $LOCAL_DIRNAME && git rev-parse --verify HEAD)
  if [ $? -ne 0 -o -z "$GIT_CURRENT_REVISION" ]; then
    echo "Failed to parse latest revision hash"
    exit 14
  fi
}

function run_brakeman() {
  BRAKEMAN_OUTPUT="brakeman_$LOCAL_DIRNAME_$GIT_CURRENT_REVISION.json"
  (cd $LOCAL_DIRNAME && brakeman -o ../$BRAKEMAN_OUTPUT)
  # if [ $? -ne 0 ]; then
  #   echo "Failed to run brakeman"
  #   exit 15
  # fi
}

function run_rubocop() {
  RUBOCOP_OUTPUT="rubocop_$LOCAL_DIRNAME_$GIT_CURRENT_REVISION.json"
  (cd $LOCAL_DIRNAME && rubocop --format progress --format json --out ../$RUBOCOP_OUTPUT)
  # if [ $? -ne 0 ]; then
  #   echo "Failed to run rubocop"
  #   exit 16
  # fi
}

function run_bundle_audit() {
  BUNDLE_AUDIT_OUTPUT="bundle_audit_$LOCAL_DIRNAME_$GIT_CURRENT_REVISION.txt"
  (cd $LOCAL_DIRNAME && bundle-audit > ../$BUNDLE_AUDIT_OUTPUT)
}

function run_scanners() {
  run_brakeman
  run_rubocop
  run_bundle_audit
}

function persist_outputs() {
  ./persist.rb $LOCAL_DIRNAME $BRAKEMAN_OUTPUT $RUBOCOP_OUTPUT $BUNDLE_AUDIT_OUTPUT
}

setup $1
update_scanners
clone_or_pull_remote_repo
parse_current_revision
run_scanners
persist_outputs

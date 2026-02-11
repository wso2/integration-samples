#!/bin/bash

# Get changed files based on event type
# Outputs: changed_files (newline-separated list of changed files)
#
# Required environment variables:
#   EVENT_NAME  - GitHub event name (push or workflow_dispatch)
#   BEFORE_SHA  - SHA before the push event
#   AFTER_SHA - Current SHA

if [ "$EVENT_NAME" == "push" ]; then
  # For push events, compare before and after
  if [ "$BEFORE_SHA" == "0000000000000000000000000000000000000000" ]; then
    # Initial push, get all files
    CHANGED_FILES=$(git ls-files)
  else
    CHANGED_FILES=$(git diff --name-only "$BEFORE_SHA" "$AFTER_SHA")
  fi
else
  # For workflow_dispatch, fall back to HEAD~1
  CHANGED_FILES=""
fi

echo "Changed files:"
echo "$CHANGED_FILES"

# Output for GitHub Actions
echo "changed_files<<EOF" >> "$GITHUB_OUTPUT"
echo "$CHANGED_FILES" >> "$GITHUB_OUTPUT"
echo "EOF" >> "$GITHUB_OUTPUT"

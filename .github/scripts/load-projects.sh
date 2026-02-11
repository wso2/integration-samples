#!/bin/bash

# Load and filter projects based on changed files and new project additions
#
# Required environment variables:
#   EVENT_NAME    - GitHub event name (push or workflow_dispatch)
#   BUILD_PATH    - Specific project path to build, or * to build all projects
#   CHANGED_FILES - Newline-separated list of changed files
#   BEFORE_SHA    - SHA before the push event

ALL_PROJECTS=$(cat .github/workflows/projects.json)

# Handle workflow_dispatch with BUILD_PATH
if [ "$EVENT_NAME" == "workflow_dispatch" ]; then
  if [ "$BUILD_PATH" == "*" ]; then
    echo "Building all projects (manual trigger with build_path=*)"
    echo "projects=$(echo "$ALL_PROJECTS" | jq -c '.')" >> "$GITHUB_OUTPUT"
    exit 0
  else
    # Build specific project by path
    MATCHED_PROJECT=$(echo "$ALL_PROJECTS" | jq -c --arg path "$BUILD_PATH" '[.[] | select(.path == $path)]')
    if [ "$MATCHED_PROJECT" == "[]" ]; then
      echo "Error: No project found matching path '$BUILD_PATH'"
      exit 1
    fi
    echo "Building specific project: $BUILD_PATH"
    echo "projects=$MATCHED_PROJECT" >> "$GITHUB_OUTPUT"
    exit 0
  fi
fi

# For push events: filter projects to only those with changes
FILTERED_PROJECTS=$(echo "$ALL_PROJECTS" | jq -c --arg changed "$CHANGED_FILES" '
  [.[] | select(.path as $p | $changed | split("\n") | any(startswith($p + "/") or . == $p))]
')

echo "Filtered projects (by file changes): $FILTERED_PROJECTS"

# Check for newly added projects in projects.json (push events only)
NEW_PROJECTS="[]"
if [ "$BEFORE_SHA" != "0000000000000000000000000000000000000000" ]; then
  # Get previous projects.json
  OLD_PROJECTS=$(git show "$BEFORE_SHA:.github/workflows/projects.json" 2>/dev/null || echo "[]")
  # Find projects that exist in current but not in previous (by path)
  NEW_PROJECTS=$(jq -c --argjson old "$OLD_PROJECTS" '
    [.[] | select(.path as $p | $old | map(.path) | index($p) | not)]
  ' .github/workflows/projects.json)
  echo "Newly added projects: $NEW_PROJECTS"
fi

# Merge filtered projects with new projects (avoiding duplicates)
MERGED_PROJECTS=$(jq -c --argjson filtered "$FILTERED_PROJECTS" --argjson new "$NEW_PROJECTS" -n '
  ($filtered + $new) | unique_by(.path)
')

echo "Final projects to build: $MERGED_PROJECTS"

if [ "$MERGED_PROJECTS" == "[]" ]; then
  echo "No projects have changes, skipping build"
  echo "projects=[]" >> "$GITHUB_OUTPUT"
else
  echo "projects=$MERGED_PROJECTS" >> "$GITHUB_OUTPUT"
fi

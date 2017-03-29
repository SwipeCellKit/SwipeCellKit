#!/bin/bash

jazzy \
    --clean \
    --author 'Jeremy Koch' \
    --author_url 'https://twitter.com/jerkoch' \
    --github_url 'https://github.com/jerkoch/SwipeCellKit' \
    --module 'SwipeCellKit' \
    --source-directory . \
    --readme 'README.md' \
    --documentation 'Guides/*.md' \
    --output docs/ \
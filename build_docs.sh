#!/bin/bash

jazzy \
    --clean \
    --author 'Mohammad Kurabi' \
    --author_url 'https://twitter.com/mkurabi' \
    --github_url 'https://github.com/SwipeCellKit/SwipeCellKit' \
    --module 'SwipeCellKit' \
    --source-directory . \
    --readme 'README.md' \
    --documentation 'Guides/*.md' \
    --output docs/ \
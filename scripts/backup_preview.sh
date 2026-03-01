#!/bin/bash
cd /home/hsieh89t/.openclaw/workspace/config || exit 1

git status
echo "----- DIFF -----"
git diff

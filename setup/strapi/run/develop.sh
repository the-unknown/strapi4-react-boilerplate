#!/bin/bash
if [ -f "/app/strapi/package.json" ]; then
  yarn --cwd /app/strapi && yarn --cwd /app/strapi develop
else
  tail -f /dev/null
fi
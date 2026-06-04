#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec bootsnap precompile --gemfile
bundle exec bootsnap precompile app/ lib/

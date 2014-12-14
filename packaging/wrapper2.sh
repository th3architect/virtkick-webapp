#!/bin/bash
set -e

# Figure out where this script is located.
SELFDIR="`dirname \"$0\"`"
SELFDIR="`cd \"$SELFDIR\" && pwd`"

# Tell Bundler where the Gemfile and gems are.
export BUNDLE_GEMFILE="$SELFDIR/lib/vendor/Gemfile"
unset BUNDLE_IGNORE_CONFIG

cd "$SELFDIR/lib/app"
export PATH="$SELFDIR/lib/ruby/bin:$SELFDIR/lib/vendor/ruby/2.1.0/bin:$PATH"
export DEVISE_SECRET_KEY="something1" # TODO: fixme, generate something random
export SECRET_KEY_BASE="something2" # TODO: fixme, generate something random
export PACKAGING=1
exec "$SELFDIR/lib/ruby/bin/bundle" exec rake jobs:work $*

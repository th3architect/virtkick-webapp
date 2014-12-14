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
export PACKAGING=1 # prevent errors from missing development/test dependencies
"$SELFDIR/lib/ruby/bin/bundle" exec rake db:migrate
exec "$SELFDIR/lib/ruby/bin/ruby" -rbundler/setup "$SELFDIR/lib/app/bin/rails" s $*

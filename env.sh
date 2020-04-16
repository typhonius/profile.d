#!/bin/bash

set +e
set +u

# Make the root of Boxen available.

export HOME=~

# Add any binaries specific to Boxen to the path.

PATH=$HOME/bin:$PATH

for f in $HOME/profile.d/env.d/*.sh ; do
  if [ -f $f ] ; then
    source $f
  fi
done


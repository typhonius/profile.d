# Bash completion of SSH hostnames
if [ -f $HOME/.ssh/config ]; then
  complete -o default -o nospace -W "$(awk '/^Host / {print $2}' < $HOME/.ssh/config)" scp sftp ssh
fi

## Environment Variables
# Timestamps bash history files. Format: YYYY-MM-DD HH:mm:SS
export HISTTIMEFORMAT='%F %T '

# No duplicate entries in bash history
export HISTCONTROL=ignoredups:erasedups

# Keep a large history
export HISTSIZE=10000000
export HISTFILESIZE=10000000

# Ensure terminal displays text correctly by setting locale variables.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Editors
export EDITOR=vim

# Append to history, don't overwrite it, ensure * includes dot files
/bin/bash -c 'shopt -s histappend checkwinsize dotglob'

# We're not a login shell
if ! /bin/bash -c 'shopt -q login_shell' ; then

  # By default, we want umask to get set. This sets it for non-login shell.
  # Current threshold for system reserved uid/gids is 200
  # You could check uidgid reservation validity in
  # /usr/share/doc/setup-*/uidgid file
  if [ $UID -gt 199 ] && [ "`id -gn`" = "`id -un`" ]; then
     umask 002
  else
     umask 022
  fi
fi


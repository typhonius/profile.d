# Anything to do with the prompt

LGREEN='\[\033[1;32m\]'
GREEN='\[\033[32m\]'
DGREEN='\[\033[0;32m\]'
ORANGE='\[\033[33m\]'
YELLOW='\[\033[1;33m\]'
LRED='\[\033[1;31m\]'
RED='\[\033[31m\]'
YELLOWONRED='\[\033[1;33;41m\]'
DBLUE='\[\033[34m\]'
BLUE='\[\033[1;34m\]'
LBLUE='\[\033[1;36m\]'
TURQUOISE='\[\033[36m\]'
PURPLE='\[\033[35m\]'
LPURPLE='\[\033[1;35m\]'
WHITE='\[\033[1;37m\]'
NORMAL='\[\033[00m\]'

# These functions adapted from: http://hocuspokus.net/2009/07/add-git-and-svn-branch-to-bash-prompt/
function parse_git_branch () {
  git rev-parse --symbolic-full-name --abbrev-ref HEAD 2> /dev/null | sed 's#\(.*\)# (git::\1)#'
}
function parse_svn_branch() {
  parse_svn_url | sed -e 's#^'" $(parse_svn_repository_root)"'##g' | awk '{print " (svn::"$1")" }'
}
function parse_svn_url() {
  svn info 2>/dev/null | sed -ne 's#^URL: ##p' | awk '{print " "$1"" }'
}
function parse_svn_repository_root() {
  svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p'
}
function ropath() {
  if [ ! -w . ] ; then
    echo -e '\033[1;33;41m'
  else
    echo -e '\033[1;31m'
  fi
}
   
# Check to see if the user is root or not.
if [ $EUID -ne 0 ] ; then
  PS1="${LBLUE}[${GREEN}\$(date +'%Y-%m-%d %H:%M:%S')${LBLUE}] ${RED}\u${BLUE}@${DGREEN}\h${LBLUE}:\$(ropath)\w${NORMAL}${TURQUOISE}\$(parse_git_branch)\$(parse_svn_branch)\n${PURPLE} \\$ ${NORMAL}"
else
  PS1="${YELLOWONRED}\u@\h${NORMAL}${LBLUE}:${LRED}\w${TURQUOISE}\$(parse_git_branch)\$(parse_svn_branch)${PURPLE} \\$ ${NORMAL}"
fi

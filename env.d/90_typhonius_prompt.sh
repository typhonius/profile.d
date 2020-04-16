# Prompt specifically for typhonius extending what is in the default prompt.

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

# Snippet shamelessly taken and adapted from https://github.com/revans/bash-it/blob/1ec1c938b17f6947d4f0706d848b4abdd81dfcf3/themes/base.theme.bash
SCM_THEME_PROMPT_DIRTY=" \033[1;31m✗"
SCM_THEME_PROMPT_CLEAN=" \033[32m✓"
SCM_THEME_PROMPT_PREFIX=' |'
SCM_THEME_PROMPT_SUFFIX='|'

SCM_GIT='git'
SCM_GIT_CHAR='⎇'

SCM_SVN='svn'
SCM_SVN_CHAR='⑆'

SCM_NONE='NONE'
SCM_NONE_CHAR='○'

function scm {
  if [[ -f .git/HEAD ]]; then SCM=$SCM_GIT ; SCMCH=$SCM_GIT_CHAR ; SCMW=$SCM_GIT
  elif which git &> /dev/null && [[ -n "$(git symbolic-ref HEAD 2> /dev/null)" ]]; then SCM=$SCM_GIT ; SCMCH=$SCM_GIT_CHAR ; SCMW=$SCM_GIT
  elif [[ -d .svn ]]; then SCM=$SCM_SVN ; SCMCH=$SCM_SVN_CHAR ; SCMW=$SCM_SVN
  else SCM=$SCM_NONE ; SCMCH=$SCM_NONE_CHAR ; SCMW=$SCM_NONE
  fi
}


function ropath() {
  if [ ! -w . ]; then
    echo -e '\033[1;33;41m'
  else
    echo -e '\033[1;31m'
  fi
}

function get_vcs_info() {
  scm
  build_prompt
  echo -e "$SCMCH $SCMW::$SCM_BRANCH$SCM_STATE"
}

function build_prompt() {
  [[ $SCM == $SCM_GIT ]] && git_prompt_vars && return
  [[ $SCM == $SCM_SVN ]] && svn_prompt_vars && return
}

function git_prompt_vars {
  local status="$(git status -bs --porcelain 2> /dev/null)"
  if [[ -n "$(grep -v ^# <<< "${status}")" ]]; then
    SCM_STATE=$SCM_THEME_PROMPT_DIRTY
  else
    SCM_STATE=$SCM_THEME_PROMPT_CLEAN
  fi
  local ref=$(git symbolic-ref HEAD 2> /dev/null)
  SCM_BRANCH=${ref#refs/heads/}
}

function svn_prompt_vars {
  if [[ -n $(svn status 2> /dev/null) ]]; then
    SCM_STATE=$SCM_THEME_PROMPT_DIRTY
  else
    SCM_STATE=$SCM_THEME_PROMPT_CLEAN
  fi
#  SCM_BRANCH="`parse_svn_url` | sed -e 's#^'\" `parse_svn_repository_root`\"'##g' | awk '{print $1 }'"
  SCM_BRANCH=$(svn info 2> /dev/null | awk -F/ '/^URL:/ { for (i=0; i<=NF; i++) { if ($i == "branches" || $i == "tags" ) { print $(i+1); break }; if ($i == "trunk") { print $i; break } } }') || return
}

# Check to see if the user is root or not.
if [[ $EUID -ne 0 ]]; then
#  export PS1="┌─${LBLUE}[${GREEN}\$(date -u)${LBLUE}][${GREEN}\D{%Z} \d \t${LBLUE}] ${RED}\u${BLUE}@${DGREEN}\h ${LBLUE}(\$(ropath)\w${NORMAL}${LBLUE})${TURQUOISE} \$(get_vcs_info)\n${PURPLE}└─(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧*:･ﾟ✧ ${WHITE}"
  export PS1="${PURPLE}┌─${LBLUE}[${GREEN}\D{%Z} \D{%F} \D{%T}${LBLUE}] ${RED}\u${BLUE}@${DGREEN}\h ${LBLUE}(\$(ropath)\w${NORMAL}${LBLUE})\n${PURPLE}|${TURQUOISE} \$(get_vcs_info)${TURQUOISE}\$(__drush_ps1) \n${PURPLE}└─$ ${WHITE}"
else
  export PS1="${YELLOWONRED}\u@\h${NORMAL} ${LBLUE}(${LRED}\w${LBLUE})${TURQUOISE}\$(parse_git_branch)\$(parse_svn_branch) ${PURPLE}\$ ${NORMAL}"
fi

# Have some fun with my PS2
export PS2="and then...? > "

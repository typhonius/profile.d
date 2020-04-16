# Contains all custom functions

# Returns a random MAC address
newmac() {
  MAC=`openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//'`
  echo "Setting MAC address to $MAC"
  sudo ifconfig en0 ether $MAC
}

# Runs a du -h and orders the results by actual size rather than numeric size
dusort() {
  TOTAL=`du -sh .`
  perl -e'%h=map{/.\s/;99**(ord$&&7)-$`,$_}`du -sh *`;print@h{sort%h}';
  echo "\nTotal size: $TOTAL"
}

# Runs the dos2unix command recursively through all subdirectories.
d2u() {
  find . -type f \! -path \*/\.svn/\* -exec dos2unix {} \;
}

# Returns your external IP
myip() {
  dig +short myip.opendns.com @resolver1.opendns.com
}

# Returns local and UTC time for a given epoch time
when() {
  if [ "$#" -eq 0 ]; then
    TIME=`date +%s`
    echo "Using current time: $TIME"
  else
    TIME=$1
  fi
  perl -e "print 'Local: '. scalar(localtime($TIME))"; echo
  perl -e "print 'UTC: ' . scalar(gmtime($TIME))"; echo
}

# Finds process IDs for named processes
psgrep() {
  if [ ! -z $1 ] ; then
    echo "Grepping for processes matching $1..."
    ps aux | grep $1 | grep -v grep
  else
    echo "!! Need name to grep for"
  fi
}

# Kills named processes
pskill() {
  local pid
  pid=$(ps -ax | grep $1 | grep -v grep | gawk '{ print $1 }')
  echo -n "killing $1 (process $pid)..."
  kill -9 $pid
  echo "slaughtered."
}

# Extracts files of most formats
x () {
  if [[ -z "$1" ]] ; then
    print "No files given."
    return
  fi

  for f in $* ; do
    if [[ -f $f ]]; then
      case $f in
        *.tar.bz2) command tar xjf $f  ;;
        *.tar.gz)  command tar xzf $f  ;;
        *.bz2)     command bunzip2 $f  ;;
        *.rar)     command unrar x $f  ;;
        *.gz)      command gunzip $f   ;;
        *.tar)     command tar xf $f   ;;
        *.tbz2)    command tar xjf $f  ;;
        *.tgz)     command tar xzf $f  ;;
        *.zip)     command unzip $f    ;;
        *.Z)       command uncompress $f ;;
        *.7z)      command 7z x $f     ;;
        *.xz)      command unxz -vk $f   ;;
        *.lzma)    command unlzma -vk $f ;;
        *)     print "'$f' cannot be extracted via x()" ;;
      esac
    else
      print "'$f' is not a valid file"
    fi
  done
}

# Compresses into a .tar.gz archive
com() {
  if [[ -z "$1" ]] ; then
    print "No files given."
    return
  fi
  for f in $* ; do
    if [[ -f $f ]]; then
      command tar -cvzf $f.tar.gz $f
    else
      print "'$f' is not a valid file"
    fi
  done
}

# Find directory sizes and list them for the current directory
dirsize () {
  du -shx * .[a-zA-Z0-9_]* 2> /dev/null | \
  egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
  egrep '^ *[0-9.]*M' /tmp/list
  egrep '^ *[0-9.]*G' /tmp/list
  rm -rf /tmp/list
}

# Copy a file then follow it
cpg (){
  if [ -d "$2" ];then
    cp $1 $2 && cd $2
  else
    cp $1 $2
  fi
}

# Move a file then follow it
mvg (){
  if [ -d "$2" ];then
    mv $1 $2 && cd $2
  else
    mv $1 $2
  fi
}


# Contains all custom functions

# Checks the MaxMind db for which country an IP address originates
geo() {
  if [ -z `which geoiplookup` ]; then
    echo "geoiplookup must be installed before using geo."
    exit 1
  fi

  geoiplookup -f /usr/local/share/GeoIP/GeoIP.dat $1
}

# Downloads and phpizes composer
compose() {
  curl -sS https://getcomposer.org/installer | php
	echo "Use 'php composer.phar install' to install."
}

# Starts a simple http server at the current path
http() {
  python -m SimpleHTTPServer
}

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

# Executes commands against a number of servers
apdsh() {
  if [ -z `which pdsh` ]; then
    echo "pdsh must be installed before using apdsh."
    exit 1
  fi
  OPTIND=1
  sitename=
  type=
  command=
    while getopts "s:t:c:" opt; do
      case "$opt" in
      s)
        sitename=$OPTARG
        ;;
      c)
        command=$OPTARG
        ;;
      t)
        type=$OPTARG
        ;;
      esac
    done
    if [[ -z $command ]] || [ -z $type ] || [ -z $sitename ]; then
      echo 'Enter a sitename a command and a server type. The server type may be web, db, or bal.'
      echo 'Usage should be:'
      echo '* apdsh -s eeamalone -t web -c "ls" #To execute ls against all eeamalone webs'
      echo '* apdsh -s eeconeill.dev -t bal -c "netstat -nlept" #To execute netstat against all eeconeill bals'
      echo '* apdsh -s eescooper.prod -t db -c "touch foo" #To touch the file foo on all eescooper prod db class servers.'
    else
      echo "Running $command against all $type servers on $sitename :>"
      filter=$type
      if [ $type == 'web' ] || [ $type == 'staging' ] || [ $type == 'ded' ] || [ $type == 'managed' ]; then
        filter='web'
        servermatch='(web|staging|ded|managed)'
      fi
      if [ $type == 'db' ]; then
        filter='db'
        servermatch='(ded|fsdb|fsdbmesh|dbmaster)'
      fi
      pdsh -w `aht @$sitename --show=$filter | awk {'print $1'} | egrep "^${servermatch}" | sed -e 's/^[ \t]*//' | tr '\n' ','` $command
    fi

  shift $((OPTIND-1))
}

# Text to speech
t2s() { 
  wget -q -U Mozilla -O /tmp/$(tr ' ' _ <<< "$1"| cut -b 1-15).mp3 "http://translate.google.com/translate_tts?ie=UTF-8&tl=en-au&q=$(tr ' ' + <<< "$1")";
  if hash afplay 2>/dev/null; then
    afplay /tmp/$(tr ' ' _ <<< "$1"| cut -b 1-15).mp3
  else
    mplayer /tmp/$(tr ' ' _ <<< "$1"| cut -b 1-15).mp3
  fi
}

# Returns your external IP
myip() {
  curl ifconfig.me
}

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

# Puts an ls with your cd
cd () 
{ 
    if [[ -z "$1" ]] ; then
      builtin cd "$HOME";
    else
      builtin cd "$*";
    fi
    if [ $? -ne 0 ]; then
        if [ ! -x "$1" ] && [ -d "$1" ]; then
            echo -n "Cannot access dir, become root? ";
            read foo;
            if [[ $foo = "y" ]] || [[ $foo = "Y" ]]; then
                sudo bash;
                return;
            else
                builtin cd "$*";
                return;
            fi;
        fi;
    else
        echo;
        ls -lrtha;
    fi
}

pskill() {
        local pid
        pid=$(ps -ax | grep $1 | grep -v grep | gawk '{ print $1 }')
        echo -n "killing $1 (process $pid)..."
        kill -9 $pid
        echo "slaughtered."
}

ttl () {
  echo "Finding TTL for $1"
  NS=`dig $1 NS +noall +short`
  arr=$(echo $NS | tr " " "\n")
  for x in $arr
    do
     # if [ "$x" != "$1." ]; then
        echo NameServer: $x
        dig @$x $1 +noall +answer | grep $1 | awk {'print $2'}
     # fi
    done
}

sshcheck () {
  if [ "$#" -eq 0 ]; then
    echo "Enter some servers"
  else
    for arg; do
      echo "Checking $arg" ;
      ssh $arg "uptime" ;
    done
  fi
}

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

# create .tar.gz archive
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

#dirsize - finds directory sizes and lists them for the current directory
dirsize ()
{
du -shx * .[a-zA-Z0-9_]* 2> /dev/null | \
egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
egrep '^ *[0-9.]*M' /tmp/list
egrep '^ *[0-9.]*G' /tmp/list
rm -rf /tmp/list
}

psgrep() {
        if [ ! -z $1 ] ; then
                echo "Grepping for processes matching $1..."
                ps aux | grep $1 | grep -v grep
        else
                echo "!! Need name to grep for"
        fi
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

# Contains all custom functions

# Checks the MaxMind db for which country an IP address originates
geo() {
  if [ -z `which geoiplookup` ]; then
    echo "geoiplookup must be installed before using geo."
    exit 1
  fi

  geoiplookup -f /usr/local/share/geoip/geoipcountry.dat $1
}

geoc() {
  if [ -z `which geoiplookup` ]; then
    echo "geoiplookup must be installed before using geo."
    exit 1
  fi

  geoiplookup -f /usr/local/share/geoip/geoipcity.dat $1
}

# Downloads and phpizes composer
compose() {
  curl -sS https://getcomposer.org/installer | php
	echo "Use 'php composer.phar install' to install."
}

# Starts a simple http server at the current path
httpserver() {
  python -m SimpleHTTPServer
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

# Gets an SSL cert from a website so the user may check information within.
function sslcertcheck() {
  if [[ -z $1 ]]; then
    echo "Please use a website address as a parameter"
    echo "eg. sslcertcheck example.com"
    return
  fi
  # We have to pipe something in or we get a wait from openssl s_client
  echo "" | 2>/dev/null openssl s_client -crlf -showcerts -connect $1:443 | openssl x509 -text | grep -v 'X509v3' | egrep '(Issuer|Subject|Not After)'
}

# Bash completion of ssh hosts
_complete_ssh_hosts ()
{
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        comp_ssh_hosts=`cat ~/.ssh/known_hosts | \
                        cut -f 1 -d ' ' | \
                        sed -e s/,.*//g | \
                        grep -v ^# | \
                        uniq | \
                        grep -v "\[" ;
                cat ~/.ssh/config | \
                        grep "^Host " | \
                        awk '{print $2}'
                `
        COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
        return 0
}
complete -F _complete_ssh_hosts ssh


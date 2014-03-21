profile.d
=========

Useful things that my command line has

Instructions
------------
- Clone the repo into your /etc/profile.d/includes directory
- Add the following to your ~/.profile or ~/.bashrc depending on OS

```
if [ -d /etc/profile.d/includes ]; then
  for file in /etc/profile.d/includes/*.sh ; do
    if [ -f $file ] ; then
      source $file
    fi
  done
fi
```

- Add in any additional functionality you'd like by adding files to your /etc/profile.d/includes directory
- Ensure the files you add end in .sh to get picked up by the auto-loader

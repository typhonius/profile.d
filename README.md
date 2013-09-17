profile.d
=========

Useful things that my command line has

Instructions
------------
- Clone the repo into your /etc directory
- Add the following to your ~/.profile or ~/.bashrc depending on OS

```
if [ -d /etc/profile.d ]; then
  for file in /etc/profile.d/*
    do
      if [[ $file == *rc ]] ; then
        echo "Loading $file"
        . $file
      fi
    done
fi
```

- Add in any additional functionality you'd like by adding files to your /etc/profile.d directory
- Ensure the files you add end in rc to get picked up by the auto-loader

set-executionpolicy remotesigned -s cu
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
scoop install 7zip git openssh concfg

Push-Location ~
# Backup current console settings
concfg export console-backup.json

# use solarized color theme
concfg import solarized-dark

# You'll see this warning:
#     overrides in the registry and shortcut files might interfere with
#     your concfg settings.
#     would you like to search for and remove them? (Y/n):
# Enter 'n' if you're not sure yet: you can always run 'concfg clean' later

scoop install pshazz

Pop-Location
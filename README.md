# dotfiles repository 

## how to set it up?

- [Archlinux Wiki](https://wiki.archlinux.org/title/Dotfiles)
- [Atlassian tutorial](https://www.atlassian.com/git/tutorials/dotfiles)

### basically:

```bash
git init --bare $HOME/.dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
echo "alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc
```

but I added the alias (the last line) in my .bashrc-personal

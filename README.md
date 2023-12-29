# Skipper's Boostrapping Scripts

A Set of Scripts for Configuring OSX and Ubuntu.

## Config Files

Public configuration files are installed from my [dotfiles](https://github.com/onesmallskipforman/dotfiles) repo.

## OSX Defaults

Thank you to [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) for mapping out most of the OS X preference commands.


## Syncing with current device

Get all manually-installed brew packages:

```
$ brew leaves --installed-on-request
```


```
$ brew deps --tree --installed
$ brew leaves
$ brew leaves --installed-on-request
$ brew leaves --installed-as-dependency
$ brew leaves --installed-on-request | xargs -n1 brew deps --tree --installed
$ brew leaves --installed-on-request | xargs -n1 brew desc --eval-all

```

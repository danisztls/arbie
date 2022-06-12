# Development
## Manpages

Generate man from markdown file
```shell
$ mandown MAN.md ARB > doc/arb.1
```

*Note: Later edit to remove bad formatted TOC.*

Try to follow [manpage style guide](https://liw.fi/manpages/).

## ToDo 
### Improve
- Improve documentation to cover common tasks like initing borg/gocrypts, list, fsck, mounting.
- Improve README to describe the program in a more direct/honest way. Arbie is a script to integrate and automate Borg, Gocryptfs and Rclone. Batteries includes.
- Improve maintenance burden. Simplify things. Drop system backup. It's fragile and too specific for Arch. Should be a new script.
- Update exclude rules to reflect change made on local config.
- Describe the common use cases (vault, full, lite) and include batteries (initial config is an issue).

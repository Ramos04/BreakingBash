# Breaking Bash
Bash Script tips, tricks, functions, templates, best practices, etc.

## General 


#### BASH STRICT MODE
``` bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
```
``` bash
-e 		Immediately exit upon any non-zero exit code, just like c exits 
		after a seg fault or syntax error in python
-u 		Throws an error and immediately exits when you refernce a 
		variable that is undefined
-o pipefail	Prevents errors in a pipeline from being masked

IFS
names=(
   "Aaron Maxwell"
   "Wayne Gretzky"
   "David Beckham"
   "Anderson da Silva"
 )
```

| WITHOUT STRICT | WITH STRICT-MODE IFS |
| :------------: | :------------------: |
| Aaron          | Aaron Maxwell        |
| Maxwell        | Wayne Gretzky        |
| Wayne          | David Beckham        |
| Gretzky        | Anderson da Silva    |
| David          |                      |
| Beckham        |                      |
| Anderson       |                      |
| da             |                      |
| Silva          |                      |

## Style Guide

## Resources
1. [Advanced Scripting Guide](http://tldp.org/LDP/abs/html/)
2. [Bash Guide](http://mywiki.wooledge.org/BashGuide)
3. [Bash Style Guide](https://github.com/bahamas10/bash-style-guide)
4. [Linting](https://www.shellcheck.net/)
5. [Strict-Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/)
6. [Exit Traps](http://redsymbol.net/articles/bash-exit-traps/)
7. [Template](https://www.uxora.com/unix/shell-script/18-shell-script-template)
8. [Argument Handling](https://www.assertnotmagic.com/2019/03/08/bash-advanced-arguments/)


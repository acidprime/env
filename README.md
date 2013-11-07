# Simple yaml cache hack
This is a puppet face that will display a node or list of nodes last checked in environment.

# Usage
1. Install the module into your modulepath
2. On puppet 2.7 and lower export your RUBYLIB to this folder

```shell
export RUBYLIB=`puppet config print modulepath | awk -F':' '{print $1}'`/lib
puppet node env <node_name>
```

For a list of all nodes use '*'  

```shell
puppet node env '*'
```
An example use would be monitoring students checking into the puppet master in the fundamentals class

```shell
while :; do clear; puppet node env '*' ; sleep 2; done
# or if you have a newer version of watch
watch  --color 'puppet node env "*"'
```

WeMo Light Switch API
=====================

Some code snippets coppied from https://github.com/ballantyne/wemo and 
https://github.com/bobbrodie/siriproxy-wemo

Rewritten to use `upnp` because `simple_upnp` wasn't working for me.

## Usage

```ruby
require 'wemo'

# Find all WeMo light switches on your network
#
switches = WeMo.light_switches

# Pick one you'd like to work with
#
basement_floods = switches.find {|s| s.name == "Basement Floods" }

# Find out if it's on of off
#
basement_floods.status
# => true

# Turn it off
#
basement_floods.off
```

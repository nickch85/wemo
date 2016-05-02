WeMo Device API
===============

Some code snippets coppied from https://github.com/ballantyne/wemo and
https://github.com/bobbrodie/siriproxy-wemo

Rewritten to use `playful` because `simple_upnp` wasn't working for me.

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

# Get an outlet instead
#
outlets = WeMo.outlets.first

# Get all WeMo devices on the network
#
WeMo.all
```

Pull requests welcome :smile:




Nick: TODO
=================
WeMo Link: Implement End Device and Group GetStatus
WeMo Link: Implement Pretty Names and Group Statuses
Implement Lightbulb capabilities: Change colour
Update README with additional code snippets and describe Bridge -> Device (EndDevice & Group status)


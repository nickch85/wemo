WeMo Device API
===============

Forked from: https://github.com/jordanbyron/wemo

```
WeMo -----> Device
     -----> Bridge ------> EndDevice
                   ------> Group
```

## Usage

```ruby
require 'wemo'

# Find all WeMo light switches on your network
#
switches = WeMo.light_switches

# Find all WeMo Link devices
#
bridges = WeMo.bridges

# Find all devices under a WeMo Link
#
end_devices = bridges.first.devices

# Pick one you'd like to work with
#
basement_floods = switches.find {|s| s.name == "Basement Floods" }
light_group = bridges.devices.find{|s| s.name == "Kitchen"}

# Find out if a normal switch is on or off
#
basement_floods.status
# => true

# Find out the current status of a WeMo Link Device
#
light_group.status
# => {
#    "10006" => "1",   # on/off state
#    "10008" => "153:0", # dimmer level: transition time [0-255]:[time-in-seconds]
#    "30008" => "0:0", # sleep timer
#    "30009" => nil,
#    "3000A" => nil
}


# Turn it off
#
basement_floods.off

# Turn it on
#
basement_floods.on

# Dim the light bulb / group
#
kitchen.dim(0.5, 5) # brightness in 0.0-1.0 fractions, transition time in seconds

# Get the current brightness of a light bulb / group
#
kitchen.brightness

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
Implement Lightbulb capabilities: Change colour




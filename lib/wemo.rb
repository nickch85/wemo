require 'bundler'
Bundler.require
require 'upnp/ssdp'
require 'wemo/device'

UPnP.log = false

module WeMo
  def self.light_switches
    @devices ||= begin
      devices = UPnP::SSDP.search('urn:Belkin:device:lightswitch:1')
      devices.uniq.map do |device|
        uri      = URI.parse(device[:location])
        location = "#{uri.scheme}://#{uri.host}:#{uri.port}"

        Device.new(location)
      end
    end
  end
end

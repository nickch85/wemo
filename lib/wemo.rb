require 'playful/ssdp'
require 'wemo/device'
require 'wemo/bridge'

Playful.log = false

module WeMo
  def self.all
    light_switches + switches + sensors + bridges.collect(&:devices).flatten
  end

  def self.light_switches
    @light_switches ||= devices("lightswitch")
  end

  def self.bridges
    @bridges ||= services("bridge")
  end

  def self.switches
    @switches ||= devices("controllee")
  end

  def self.sensors
    @sensors ||= devices("sensors")
  end

  def self.rescan()
    clear
    all
  end

  def self.clear
    @light_switches = nil
    @bridges = nil
    @switches = nil
    @sensors = nil
  end

  private

  def self.devices(type)
    devices = Playful::SSDP.search("urn:Belkin:device:#{type}:1")
    devices.uniq.map do |device|
      uri      = URI.parse(device[:location])
      location = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      Device.new(location)
    end
  end

  def self.services(type)
    devices = Playful::SSDP.search("urn:Belkin:service:#{type}:1")
    devices.uniq{|d| d[:usn]}.map do |device|
      uri      = URI.parse(device[:location])
      location = "#{uri.scheme}://#{uri.host}:#{uri.port}"

      Bridge.new(location)
    end
  end
end

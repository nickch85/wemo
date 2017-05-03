require 'rest-client'
require 'crack'
require 'builder'
# both the end device and group classes ended up being almost the
# same. Keeping separate anyway just incase  of other
# specific funtionality

module WeMo
  class Group
    PATH = 'upnp/control/bridge1'
    URN = 'urn:Belkin:service:bridge:1'
    attr_reader :location, :capabilities

    def initialize(x, location)
      @location = location
      @name = x["GroupName"]
      @product = 'Group'
      @group_id = x["GroupID"]
      set_capabilities(x["GroupCapabilityIDs"], x["GroupCapabilityValues"])
    end

    def name
      @name
    end

    def model_name
      @product
    end

    def to_s
      "<#{@product}> #{@name}"
    end

    def can_toggle?
      return @capabilities.include?('10006')
    end

    def can_dim?
      return @capabilities.include?('10008')
    end

    def can_change_colour?
      return @capabilities.include?('10300')
    end

    def can_sleep?
      return @capabilities.include?('30008')
    end

    def on
      return 'Cannot on' unless can_toggle?
      set_device_status('10008', @capabilities['10008'])
      set_device_status('10006', 1)
    end

    def off
      return 'Cannot off' unless can_toggle?
      set_device_status('10006', 0)
    end

    def sleep(time)
      return 'Cannot sleep' unless can_sleep?
      set_device_status('30008', "#{time*10}:#{Time.now.to_i}")
    end

    def dim(fraction, fade_time=5)
      return 'Cannot dim' unless can_dim?
      value = fraction * 255
      set_device_status('10008', "#{value}:#{fade_time}")
    end

    def status
      get_device_status
      return @capabilities
    end

    def brightness
      get_device_status
      return @capabilities['10008'].split(":")[0].to_f/255.0
    end

    private

    def set_capabilities(ids, values)
      ids = ids.split(",")
      values = values.split(",")
      h = {}
      ids.each_with_index do |id, index|
        h[id] = values[index]
      end
      @capabilities = h
    end

    def get_device_status
      soap_action = %Q|"#{URN}#GetDeviceStatus"|
      request = ''
      x = ::Builder::XmlMarkup.new :target => request
      x.instruct! :xml, :version => "1.0"
      x.s :Envelope, "xmlns:s" => "http://schemas.xmlsoap.org/soap/envelope/", "s:encodingStyle" => "http://schemas.xmlsoap.org/soap/encoding/" do
        x.s :Body do
          x.u :GetDeviceStatus, "xmlns:u"=>URN do
            x.DeviceIDs @group_id
          end
        end
      end
      result = make_request soap_action, request
      xml = Crack::XML.parse(result)
      sub_xml = Crack::XML.parse(xml["s:Envelope"]["s:Body"]["u:GetDeviceStatusResponse"]["DeviceStatusList"])
      set_capabilities(sub_xml["DeviceStatusList"]["DeviceStatus"]["CapabilityID"],sub_xml["DeviceStatusList"]["DeviceStatus"]["CapabilityValue"])
      true
    end

    def set_device_status(capability, value)
      soap_action = %Q|"#{URN}#SetDeviceStatus"|
      subrequest = ''
      x = ::Builder::XmlMarkup.new :target => subrequest
      x.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
      x.DeviceStatus do
        x.IsGroupAction 'YES'
        x.DeviceID @group_id, :available => "YES"
        x.CapabilityID capability
        x.CapabilityValue value
      end
      request = ''
      x = ::Builder::XmlMarkup.new :target => request
      x.instruct! :xml, :version => "1.0"
      x.s :Envelope, "xmlns:s" => "http://schemas.xmlsoap.org/soap/envelope/", "s:encodingStyle" => "http://schemas.xmlsoap.org/soap/encoding/" do
        x.s :Body do
          x.u :SetDeviceStatus, "xmlns:u"=>URN do
            x.DeviceStatusList subrequest
          end
        end
      end
      result = make_request soap_action, request
      xml = Crack::XML.parse(result)
      xml["s:Envelope"]["s:Body"]["u:SetDeviceStatusResponse"]["ErrorDeviceIDs"] == nil
    end

    def rest_client
      @rest_client ||= RestClient::Resource.new(location)
    end

    def make_request soap_action, request
      return rest_client[PATH].post(request, "SOAPACTION" => soap_action, :content_type => 'text/xml; charset="utf-8"')
    end

  end
end

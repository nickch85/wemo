require 'rest-client'
require 'crack'
require 'builder'


module WeMo
  class Group
    PATH = 'upnp/control/bridge1'
    URN = 'urn:Belkin:service:bridge:1'
    attr_reader :location

    def initialize(x, location)
      @location = location
      @name = x["GroupName"]
      @product = 'Group'
      @group_id = x["GroupID"]
      @capabilites = x["GroupCapabilityIDs"].split(",")
      @capability_values = x["GroupCapabilityValues"].split(",")
    end

	def model_name
	  @product
	end

    def to_s
      "<#{@product}> #{@name}"
    end

    def can_dim?
      return @capabilities.include?('10008')
    end

    def can_change_colour?
      return @capabilities.include?('10300')
    end

    def on
      set_device_status('10006', 1)
    end

    def off
      set_device_status('10006', 0)
    end

    def dim(fraction, fade_time=5)
      value = fraction * 255
      set_device_status('10008', "#{value}:#{fade_time}")
    end


    private


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

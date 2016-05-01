require 'rest-client'
require 'crack'
require 'builder'
require 'wemo/light'


module WeMo
  class Bridge
    attr_reader :location, :lights

    def initialize(location)
      @location = location
      get_lights
    end

    def name
      device_info["device"]["friendlyName"]
    end

    def model_name
      device_info["device"]["modelName"]
    end

    def udn
      device_info["device"]["UDN"]
    end

    def status
      get_binary_state
    end

    def get_lights
      xml = Crack::XML.parse(get_end_devices["s:Envelope"]["s:Body"]["u:GetEndDevicesResponse"]["DeviceLists"])
      xml["DeviceLists"]["DeviceList"]["DeviceInfos"].each do |x|
        l =Light.new(x["FriendlyName"], x["DeviceID"], x["CurrentState"])
      end
    end

    def to_s
      "<#{model_name}> #{name}"
    end

    def on
      set_binary_state 1
    end

    def off
      set_binary_state 0
    end

   private

   def get_end_devices
      soap_action = '"urn:Belkin:service:bridge:1#GetEndDevices"'
      path = "upnp/control/bridge1"
      request = ''
      x = ::Builder::XmlMarkup.new :target => request
      x.instruct! :xml, :version => "1.0"
      x.s :Envelope, "xmlns:s" => "http://schemas.xmlsoap.org/soap/envelope/", "s:encodingStyle" => "http://schemas.xmlsoap.org/soap/encoding/" do
        x.s :Body do
          x.u :GetEndDevices, "xmlns:u"=>"urn:Belkin:service:bridge:1" do
            x.DevUDN self.udn
            x.ReqListType 'PAIRED_LIST'
          end
        end
      end
      result = make_request path, soap_action, request
      ap result
      xml = Crack::XML.parse(result)
      return xml
   end

    def set_binary_state(signal)
      soap_action = '"urn:Belkin:service:basicevent:1#SetBinaryState"'
      path = "upnp/control/basicevent1"
      request = ''
      x = ::Builder::XmlMarkup.new :target => request
      x.instruct! :xml, :version => "1.0"
      x.s :Envelope, "xmlns:s" => "http://schemas.xmlsoap.org/soap/envelope/", "s:encodingStyle" => "http://schemas.xmlsoap.org/soap/encoding/" do
        x.s :Body do
          x.u :SetBinaryState, "xmlns:u"=>"urn:Belkin:service:basicevent:1" do
            x.BinaryState signal
          end
        end
      end
      result = make_request path, soap_action, request
      xml = Crack::XML.parse(result)
      xml["s:Envelope"]["s:Body"]["u:SetBinaryStateResponse"]["BinaryState"] == "1"
    end

    def get_binary_state
      soap_action = '"urn:Belkin:service:basicevent:1#GetBinaryState"'
      path = "upnp/control/basicevent1"
      request = ''
      x = ::Builder::XmlMarkup.new :target => request
      x.instruct! :xml, :version => "1.0"
      x.s :Envelope, "xmlns:s" => "http://schemas.xmlsoap.org/soap/envelope/", "s:encodingStyle" => "http://schemas.xmlsoap.org/soap/encoding/" do
        x.s :Body do
          x.u :GetBinaryState, "xmlns:u"=>"urn:Belkin:service:basicevent:1" do
          end
        end
      end
      result = make_request path, soap_action, request
      xml = Crack::XML.parse(result)
      xml["s:Envelope"]["s:Body"]["u:GetBinaryStateResponse"]["BinaryState"] == "1"
    end

    def device_info
      @device_info ||= Crack::XML.parse(rest_client["setup.xml"].get)["root"]
    end

    def rest_client
      @rest_client ||= RestClient::Resource.new(location)
    end

    def make_request path, soap_action, request
      return rest_client[path].post(request, "SOAPACTION" => soap_action, :content_type => 'text/xml; charset="utf-8"')
    end
  end
end

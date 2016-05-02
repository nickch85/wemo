require 'rest-client'
require 'crack'
require 'builder'

module WeMo
  class Device
    PATH ='upnp/control/basicevent1'
    URN = "urn:Belkin:service:basicevent:1"
    attr_reader :location

    def initialize(location)
      @location = location
    end

    def name
      device_info["device"]["friendlyName"]
    end

    def model_name
      device_info["device"]["modelName"]
    end

    def status
      get_binary_state
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

    def set_binary_state(signal)
      soap_action = %Q|"#{URN}#SetBinaryState"|
      request = ''
      x = ::Builder::XmlMarkup.new :target => request
      x.instruct! :xml, :version => "1.0"
      x.s :Envelope, "xmlns:s" => "http://schemas.xmlsoap.org/soap/envelope/", "s:encodingStyle" => "http://schemas.xmlsoap.org/soap/encoding/" do
        x.s :Body do
          x.u :SetBinaryState, "xmlns:u"=>URN do
            x.BinaryState signal
          end
        end
      end
      result = make_request soap_action, request
      xml = Crack::XML.parse(result)
      xml["s:Envelope"]["s:Body"]["u:SetBinaryStateResponse"]["BinaryState"] == "1"
    end

    def get_binary_state
      soap_action = %Q|"#{URN}#GetBinaryState"|
      request = ''
      x = ::Builder::XmlMarkup.new :target => request
      x.instruct! :xml, :version => "1.0"
      x.s :Envelope, "xmlns:s" => "http://schemas.xmlsoap.org/soap/envelope/", "s:encodingStyle" => "http://schemas.xmlsoap.org/soap/encoding/" do
        x.s :Body do
          x.u :GetBinaryState, "xmlns:u"=>URN do
          end
        end
      end
      result = make_request soap_action, request
      xml = Crack::XML.parse(result)
      xml["s:Envelope"]["s:Body"]["u:GetBinaryStateResponse"]["BinaryState"] == "1"
    end

    def device_info
      @device_info ||= Crack::XML.parse(rest_client["setup.xml"].get)["root"]
    end

    def rest_client
      @rest_client ||= RestClient::Resource.new(location)
    end

    def make_request soap_action, request
      return rest_client[PATH].post(request, "SOAPACTION" => soap_action, :content_type => 'text/xml; charset="utf-8"')
    end
  end
end

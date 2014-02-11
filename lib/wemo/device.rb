module WeMo
  class Device
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
      result = rest_client["upnp/control/basicevent1"].post(%{<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>#{signal}</BinaryState></u:SetBinaryState></s:Body></s:Envelope>},
        "SOAPACTION"   => '"urn:Belkin:service:basicevent:1#SetBinaryState"',
        "Content-type" => 'text/xml; charset="utf-8"')

      xml = Crack::XML.parse(result)

      xml["s:Envelope"]["s:Body"]["u:SetBinaryStateResponse"]["BinaryState"] == "1"
    end

    def get_binary_state
      result = rest_client["upnp/control/basicevent1"].post(%{<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"></u:GetBinaryState></s:Body></s:Envelope>},
        "SOAPACTION"   => '"urn:Belkin:service:basicevent:1#GetBinaryState"',
        "Content-type" => 'text/xml; charset="utf-8"')

      xml = Crack::XML.parse(result)

      xml["s:Envelope"]["s:Body"]["u:GetBinaryStateResponse"]["BinaryState"] == "1"
    end

    def device_info
      @device_info ||= Crack::XML.parse(rest_client["setup.xml"].get)["root"]
    end

    def rest_client
      @rest_client ||= RestClient::Resource.new(location)
    end
  end
end

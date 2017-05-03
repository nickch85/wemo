require 'rest-client'
require 'crack'
require 'builder'
require 'wemo/end_device'
require 'wemo/group'


module WeMo
  class Bridge
      PATH = 'upnp/control/bridge1'
      URN = 'urn:Belkin:service:bridge:1'
      attr_reader :location

    def initialize(location)
      @location = location
    end

    def devices
      xml = Crack::XML.parse(get_end_devices["s:Envelope"]["s:Body"]["u:GetEndDevicesResponse"]["DeviceLists"])

      devices = []
      if xml["DeviceLists"]["DeviceList"]["DeviceInfos"]
        xml["DeviceLists"]["DeviceList"]["DeviceInfos"]["DeviceInfo"].each do |x|
          devices << EndDevice.new(x, @location)
        end
      end
      # Not sure if a single WeMo Link can support more than 1 group
      # 03/05/2017: Looks like it does. patched to iterate through multiple groups
      if xml["DeviceLists"]["DeviceList"]["GroupInfos"]
        xml["DeviceLists"]["DeviceList"]["GroupInfos"]["GroupInfo"].each do |group_info|
          devices << Group.new(group_info, @location) unless group_info["DeviceInfos"].nil?
        end
      end
      devices
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

    def to_s
      "<#{model_name}> #{name}"
    end


    private

    def get_end_devices
      soap_action = %Q|"#{URN}#GetEndDevices"|
      request = ''
      x = ::Builder::XmlMarkup.new :target => request
      x.instruct! :xml, :version => "1.0"
      x.s :Envelope, "xmlns:s" => "http://schemas.xmlsoap.org/soap/envelope/", "s:encodingStyle" => "http://schemas.xmlsoap.org/soap/encoding/" do
        x.s :Body do
          x.u :GetEndDevices, "xmlns:u"=>URN do
            x.DevUDN self.udn
            x.ReqListType 'PAIRED_LIST'
          end
        end
      end
      result = make_request soap_action, request
      xml = Crack::XML.parse(result)
      return xml
    end

    def device_info
      @device_info ||= Crack::XML.parse(rest_client["setup.xml"].get)["root"]
    end

    def rest_client
      @rest_client ||= RestClient::Resource.new(location)
    end

    def make_request  soap_action, request
      return rest_client[PATH].post(request, "SOAPACTION" => soap_action, :content_type => 'text/xml; charset="utf-8"')
    end
  end
end

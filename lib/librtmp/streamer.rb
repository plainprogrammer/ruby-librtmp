require 'librtmp/ffi'

module Librtmp
  class Streamer
    attr_reader :url
    attr_reader :writable
    attr_reader :session

    def initialize()
      @session = nil
    end

    def writable?
      @writable
    end

    def connect(connection_url, connection_writable = false)
      @url = connection_url
      @writable = connection_writable

      setup_session

      FFI::RTMP_EnableWrite(@session_ptr) if writable?

      unless FFI::RTMP_Connect(@session_ptr, nil)
        raise 'Unable to connect to RTMP server'
      end

      unless FFI::RTMP_ConnectStream(@session_ptr, 0)
        raise 'Unable to connect to RTMP stream'
      end
    end

    def send(data)
      return if data.nil? || data == ''

      if data.is_a?(Hash)
        send_metadata_packet(data)
      elsif is_flv?(data)
        FFI::RTMP_Write(@session_ptr, data, data.size)
      end
    end

    def disconnect
      FFI::RTMP_Close(@session_ptr)
      FFI::RTMP_Free(@session_ptr)
    end

  private
    def setup_session
      @session_ptr = FFI::RTMP_Alloc()
      FFI::RTMP_Init(@session_ptr)

      unless FFI::RTMP_SetupURL(@session_ptr, self.url)
        FFI::RTMP_Free(@session_ptr)
        raise 'Unable to setup RTMP session'
      end

      @session = FFI::RTMP.new @session_ptr
    end

    def send_metadata_packet(data)
      packet = FFI::RTMPPacket.new
      amf_object = FFI::AMFObject.new
      amf_object_ptr = amf_object.pointer

      data.each do |key, value|
        amf_prop = FFI::AMFObjectProperty.new
        amf_prop_ptr = amf_prop.pointer

        prop_name = key.to_s
        aval = FFI::AVal.new
        aval.av_len = prop_name.bytes.to_a.size
        aval.av_val = ::FFI::MemoryPointer.from_string(prop_name)

        amf_prop.p_name = name_aval

        case value
          when is_a?(String)
            amf_prop.p_type = :amf_string

            aval = FFI::AVal.new
            aval.av_len = value.bytes.to_a.size
            aval.av_val = ::FFI::MemoryPointer.from_string(value)

            amf_prop.p_vu.p_aval = aval
          else
            #???
        end

        FFI::AMF_AddProp(amf_object_ptr, amf_prop_ptr)
      end

      packet
    end

    def is_flv?(data)
      data[0..2] == 'FLV'
    end
  end
end

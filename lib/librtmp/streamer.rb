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
  end
end

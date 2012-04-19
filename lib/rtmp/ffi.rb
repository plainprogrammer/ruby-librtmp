module RTMP
  module FFI
    require 'ffi'
    
    extend ::FFI::Library
  
    ffi_lib 'librtmp'
    
    require './lib/rtmp/ffi/amf'
    require './lib/rtmp/ffi/rtmp'
  end
end

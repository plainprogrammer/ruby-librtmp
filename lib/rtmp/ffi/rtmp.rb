require 'ffi'
require './lib/rtmp/ffi/amf'

module RTMP
  module FFI
    module RTMP
      extend ::FFI::Library

      ffi_lib 'librtmp'
      
      RTMP_MAX_HEADER_SIZE   = 18
      RTMP_BUFFER_CACHE_SIZE = (16*1024)
      RTMP_CHANNELS	         = 65600
      RTMP_DEFAULT_CHUNKSIZE = 128
      
      class RTMPChunk < ::FFI::Struct
        layout :c_headerSize, :int,
               :c_chunkSize,  :int,
               :c_chunk,      :pointer,
               :c_header,     [:char, RTMP_MAX_HEADER_SIZE]
      end

      class RTMPPacket < ::FFI::Struct
        layout :m_headerType,      :uint8,
               :m_packetType,      :uint8,
               :m_hasAbsTimestamp, :uint8,
               :m_nChannel,        :int,
               :m_nTimestamp,      :uint32,
               :m_nInfoField2,     :int32,
               :m_nBodySize,       :uint32,
               :m_nBytesRead,      :uint32,
               :m_chunk,           RTMPChunk,
               :m_body,            :pointer
      end

      class RTMPSockBuf < ::FFI::Struct
        layout :sb_socket,   :int,
               :sb_size,     :int,
               :sb_start,    :pointer,
               :sb_buf,      [:char, RTMP_BUFFER_CACHE_SIZE],
               :sb_timedout, :int,
               :sb_ssl,      :pointer
      end
      
      RTMP_LF_AUTH = 0x0001
      RTMP_LF_LIVE = 0x0002
      RTMP_LF_SWFV = 0x0004
      RTMP_LF_PLST = 0x0008
      RTMP_LF_BUFX = 0x0010
      RTMP_LF_FTCU = 0x0020
      
      # typedef struct RTMP_LNK
      #   {
      # #ifdef CRYPTO
      # #define RTMP_SWF_HASHLEN  32
      #     void *dh;     /* for encryption */
      #     void *rc4keyIn;
      #     void *rc4keyOut;
      # 
      #     uint32_t SWFSize;
      #     uint8_t SWFHash[RTMP_SWF_HASHLEN];
      #     char SWFVerificationResponse[RTMP_SWF_HASHLEN+10];
      # #endif
      #   } RTMP_LNK;
      class RTMP_LNK < ::FFI::Struct
        layout :hostname,             AVal,
               :sockshost,            AVal,
               :playpath0,            AVal,
               :playpath,             AVal,
               :tcUrl,                AVal,
               :swfUrl,               AVal,
               :swfHash,              AVal,
               :pageUrl,              AVal,
               :app,                  AVal,
               :auth,                 AVal,
               :flashVer,             AVal,
               :subscribepath,        AVal,
               :usherToken,           AVal,
               :WeebToken,            AVal,
               :token,                AVal,
               :extras,               AMFObject,
               :depth,                :int,
               :seekTime,             :int,
               :stopTime,             :int,
               :lFlags,               :int,
               :swfAge,               :int,
               :swfSize,              :int,
               :protocol,             :int,
               :ConnectPacket,        :int,
               :CombineConnectPacket, :int,
               :redirected,           :int,
               :timeout,              :int,
               :Extras,               AVal,
               :HandshakeResponse,    AVal,
               :socksport,            :ushort,
               :port,                 :ushort
      end

      RTMP_READ_HEADER    = 0x01
      RTMP_READ_RESUME    = 0x02
      RTMP_READ_NO_IGNORE = 0x04
      RTMP_READ_GOTKF     = 0x08
      RTMP_READ_GOTFLVK   = 0x10
      RTMP_READ_SEEKING   = 0x20

      RTMP_READ_COMPLETE = -3
      RTMP_READ_ERROR    = -2
      RTMP_READ_EOF      = -1
      RTMP_READ_IGNORE   = 0

      class RTMP_READ < ::FFI::Struct
        layout :buf,                      :pointer,
               :bufpos,                   :pointer,
               :buflen,                   :uint,
               :timestamp,                :uint32,
               :dataType,                 :uint8,
               :flags,                    :uint8,
               :status,                   :int8,
               :initialFrameType,         :uint8,
               :nResumeTS,                :uint32,
               :metaHeader,               :pointer,
               :initialFrame,             :pointer,
               :nMetaHeaderSize,          :uint32,
               :nInitialFrameSize,        :uint32,
               :nIgnoredFrameCounter,     :uint32,
               :nIgnoredFlvFrameCounter,  :uint32
      end

      class RTMP_METHOD < ::FFI::Struct
        layout :name, AVal,
               :num,  :int
      end
      
      class RTMP < ::FFI::Struct
        layout :m_inChunkSize,      :int,
               :m_outChunkSize,     :int,
               :m_nBWCheckCounter,  :int,
               :m_nBytesIn,         :int,
               :m_nBytesInSent,     :int,
               :m_nBufferMS,        :int,
               :m_stream_id,        :int,
               :m_mediaChannel,     :int,
               :m_mediaStamp,       :uint32,
               :m_pauseStamp,       :uint32,
               :m_pausing,          :int,
               :m_nServerBW,        :int,
               :m_nClientBW,        :int,
               :m_nClientBW2,       :uint8,
               :m_bPlaying,         :uint8,
               :m_bSendEncoding,    :uint8,
               :m_bSendCounter,     :uint8,
               :m_numInvoke,        :int,
               :m_numCalls,         :int,
               :m_methodCalls,      RTMP_METHOD,
               :m_vecChannelsIn,    [RTMPPacket, RTMP_CHANNELS],
               :m_vecChannelsOut,   [RTMPPacket, RTMP_CHANNELS],
               :m_channelTimestamp, [:int, RTMP_CHANNELS],
               :m_fAudioCodecs,     :double,
               :m_fVideoCodecs,     :double,
               :m_fEncoding,        :double,
               :m_fDuration,        :double,
               :m_msgCounter,       :int,
               :m_polling,          :int,
               :m_resplen,          :int,
               :m_unackd,           :int,
               :m_clientID,         AVal,
               :m_read,             RTMP_READ,
               :m_write,            RTMPPacket,
               :m_sb,               RTMPSockBuf,
               :Link,               RTMP_LNK
      end

      attach_function :RTMPPacket_Reset, [RTMPPacket], :void
      attach_function :RTMPPacket_Dump, [RTMPPacket], :void
      attach_function :RTMPPacket_Alloc, [RTMPPacket, :int], :int
      attach_function :RTMPPacket_Free, [RTMPPacket], :void
      
      attach_function :RTMP_ParseURL, [:string, :pointer, AVal, :pointer, AVal, AVal], :int

      attach_function :RTMP_ParsePlaypath, [AVal, AVal], :void
      attach_function :RTMP_SetBufferMS, [RTMP, :int], :void
      attach_function :RTMP_UpdateBufferMS, [RTMP], :void
       
      attach_function :RTMP_SetOpt, [RTMP, AVal, AVal], :int
      attach_function :RTMP_SetupURL, [RTMP, :pointer], :int
      attach_function :RTMP_SetupStream, [RTMP, :int, AVal, :uint, AVal, AVal,
                                          AVal, AVal, AVal, AVal, AVal, AVal,
                                          :uint32, AVal, AVal, AVal, AVal, :int,
                                          :int, :int, :long], :void

      attach_function :RTMP_Connect, [RTMP, RTMPPacket], :int
      attach_function :RTMP_Connect0, [RTMP, :pointer], :int
      attach_function :RTMP_Connect1, [RTMP, RTMPPacket], :int
      attach_function :RTMP_Serve, [RTMP], :int

      attach_function :RTMP_ReadPacket, [RTMP, RTMPPacket], :int
      attach_function :RTMP_SendPacket, [RTMP, RTMPPacket, :int], :int
      attach_function :RTMP_SendChunk, [RTMP, RTMPChunk], :int
      attach_function :RTMP_IsConnected, [RTMP], :int
      attach_function :RTMP_Socket, [RTMP], :int
      attach_function :RTMP_IsTimedout, [RTMP], :int
      attach_function :RTMP_GetDuration, [RTMP], :double
      attach_function :RTMP_ToggleStream, [RTMP], :int
      
      attach_function :RTMP_ConnectStream, [RTMP, :int], :int
      attach_function :RTMP_ReconnectStream, [RTMP, :int], :int
      attach_function :RTMP_DeleteStream, [RTMP], :void
      attach_function :RTMP_GetNextMediaPacket, [RTMP, RTMPPacket], :int
      attach_function :RTMP_ClientPacket, [RTMP, RTMPPacket], :int
      
      attach_function :RTMP_Init, [RTMP], :void
      attach_function :RTMP_Close, [RTMP], :void
      attach_function :RTMP_Alloc, [RTMP], RTMP
      attach_function :RTMP_Free, [RTMP], :void
      attach_function :RTMP_EnableWrite, [RTMP], :void
      
      attach_function :RTMP_LibVersion, [], :int
      attach_function :RTMP_UserInterrupt, [], :int
      
      attach_function :RTMP_SendCtrl, [RTMP, :short, :uint, :uint], :int
      
      attach_function :RTMP_SendPause, [RTMP, :int, :int], :int
      attach_function :RTMP_Pause, [RTMP, :int], :int
      
      attach_function :RTMP_FindFirstMatchingProperty, [AMFObject, AVal, AMFObjectProperty], :int
      
      attach_function :RTMPSockBuf_Fill, [RTMPSockBuf], :int
      attach_function :RTMPSockBuf_Send, [RTMPSockBuf, :string, :int], :int
      attach_function :RTMPSockBuf_Close, [RTMPSockBuf], :int
      
      attach_function :RTMP_SendCreateStream, [RTMP], :int
      attach_function :RTMP_SendSeek, [RTMP, :int], :int
      attach_function :RTMP_SendServerBW, [RTMP], :int
      attach_function :RTMP_SendClientBW, [RTMP], :int
      attach_function :RTMP_DropRequest, [RTMP, :int, :int], :void
      attach_function :RTMP_Read, [RTMP, :pointer, :int], :int
      attach_function :RTMP_Write, [RTMP, :string, :int], :int
      
      attach_function :RTMP_HashSWF, [:string, :pointer, :pointer, :int], :int
    end
  end
end

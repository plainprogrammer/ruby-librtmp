require 'ffi'

module Librtmp
  module FFI
    extend ::FFI::Library

    ffi_lib 'librtmp'

    AMFDataType = enum(
      :amf_number, 0,
      :amf_boolean, :amf_string, :amf_object,
      :amf_movieclip, :amf_null, :amf_undefined,
      :amf_reference, :amf_ecma_array, :amf_object_end,
      :amf_strict_array, :amf_date, :amf_long_string,
      :amf_unsupported, :amf_recordset, :amf_xml_doc,
      :amf_typed_object, :amf_avmplus, :amf_invalid, 0xff
    )

    AMF3DataType = enum(
      :amf3_undefined, 0,
      :amf3_null, :amf3_false, :amf3_true,
      :amf3_integer, :amf3_double, :amf3_string,
      :amf3_xml_doc, :amf3_date, :amf3_array,
      :amf3_object, :amf3_xml, :amf3_byter_array
    )
    
    class AVal < ::FFI::Struct
      layout :av_val, :pointer,
             :av_len, :int
    end
         
    class AMFObject < ::FFI::Struct
      layout :o_num,   :int
    end
          
    class AMFObjectPropertyPVu < ::FFI::Union
      layout :p_number, :double,
             :p_aval,   AVal,
             :p_object, AMFObject
    end
    
    class AMFObjectProperty < ::FFI::Struct
      layout :p_name,       AVal,
             :p_type,       AMFDataType,
             :p_vu,         AMFObjectPropertyPVu,
             :p_UTCoffset, :int16
    end
    
    class AMFObject < ::FFI::Struct
      layout :o_props, AMFObjectProperty
    end
    
    class AMF3ClassDef < ::FFI::Struct
      layout :cd_name,           AVal,
             :cd_externalizable, :char,
             :cd_dynamic,        :char,
             :cd_num,            :int,
             :cd_props,          :pointer
    end
    
    # char *AMF_EncodeString(char *output, char *outend, const AVal * str);
    # char *AMF_EncodeNumber(char *output, char *outend, double dVal);
    # char *AMF_EncodeInt16(char *output, char *outend, short nVal);
    # char *AMF_EncodeInt24(char *output, char *outend, int nVal);
    # char *AMF_EncodeInt32(char *output, char *outend, int nVal);
    # char *AMF_EncodeBoolean(char *output, char *outend, int bVal);
    attach_function :AMF_EncodeString, [:pointer, :pointer, :pointer], :pointer
    attach_function :AMF_EncodeNumber, [:pointer, :pointer, :double], :pointer
    attach_function :AMF_EncodeInt16, [:pointer, :pointer, :short], :pointer
    attach_function :AMF_EncodeInt24, [:pointer, :pointer, :int], :pointer
    attach_function :AMF_EncodeInt32, [:pointer, :pointer, :int], :pointer
    attach_function :AMF_EncodeBoolean, [:pointer, :pointer, :int], :pointer
    
    # /* Shortcuts for AMFProp_Encode */
    # char *AMF_EncodeNamedString(char *output, char *outend, const AVal * name, const AVal * value);
    # char *AMF_EncodeNamedNumber(char *output, char *outend, const AVal * name, double dVal);
    # char *AMF_EncodeNamedBoolean(char *output, char *outend, const AVal * name, int bVal);
    attach_function :AMF_EncodeNamedString, [:pointer, :pointer, AVal, AVal], :pointer
    attach_function :AMF_EncodeNamedNumber, [:pointer, :pointer, AVal, :double], :pointer
    attach_function :AMF_EncodeNamedBoolean, [:pointer, :pointer, AVal, :int], :pointer

    # unsigned short AMF_DecodeInt16(const char *data);
    # unsigned int AMF_DecodeInt24(const char *data);
    # unsigned int AMF_DecodeInt32(const char *data);
    # void AMF_DecodeString(const char *data, AVal * str);
    # void AMF_DecodeLongString(const char *data, AVal * str);
    # int AMF_DecodeBoolean(const char *data);
    # double AMF_DecodeNumber(const char *data);
    attach_function :AMF_DecodeInt16, [:string], :ushort
    attach_function :AMF_DecodeInt24, [:string], :uint
    attach_function :AMF_DecodeInt32, [:string], :uint
    attach_function :AMF_DecodeString, [:string, AVal], :void
    attach_function :AMF_DecodeLongString, [:string, AVal], :void
    attach_function :AMF_DecodeBoolean, [:string], :int
    attach_function :AMF_DecodeNumber, [:string], :double

    # char *AMF_Encode(AMFObject * obj, char *pBuffer, char *pBufEnd);
    # int AMF_Decode(AMFObject * obj, const char *pBuffer, int nSize, int bDecodeName);
    # int AMF_DecodeArray(AMFObject * obj, const char *pBuffer, int nSize, int nArrayLen, int bDecodeName);
    # int AMF3_Decode(AMFObject * obj, const char *pBuffer, int nSize, int bDecodeName);
    # void AMF_Dump(AMFObject * obj);
    # void AMF_Reset(AMFObject * obj);
    attach_function :AMF_Encode, [AMFObject, :pointer, :pointer], :pointer
    attach_function :AMF_Decode, [AMFObject, :string, :int, :int], :int
    attach_function :AMF_DecodeArray, [AMFObject, :string, :int, :int, :int], :int
    attach_function :AMF3_Decode, [AMFObject, :string, :int, :int], :int
    attach_function :AMF_Dump, [AMFObject], :void
    attach_function :AMF_Reset, [AMFObject], :void

    # void AMF_AddProp(AMFObject * obj, const AMFObjectProperty * prop);
    # int AMF_CountProp(AMFObject * obj);
    # AMFObjectProperty *AMF_GetProp(AMFObject * obj, const AVal * name, int nIndex);
    attach_function :AMF_AddProp, [AMFObject, AMFObjectProperty], :void
    attach_function :AMF_CountProp, [AMFObject], :int
    attach_function :AMF_GetProp, [AMFObject, AVal, :int], AMFObjectProperty
    
    # AMFDataType AMFProp_GetType(AMFObjectProperty * prop);
    # void AMFProp_SetNumber(AMFObjectProperty * prop, double dval);
    # void AMFProp_SetBoolean(AMFObjectProperty * prop, int bflag);
    # void AMFProp_SetString(AMFObjectProperty * prop, AVal * str);
    # void AMFProp_SetObject(AMFObjectProperty * prop, AMFObject * obj);
    attach_function :AMFProp_GetType, [AMFObjectProperty], AMFDataType
    #attach_function :AMFProp_SetNumber, [AMFObjectProperty, :double], :void
    #attach_function :AMFProp_SetBoolean, [AMFObjectProperty, :int], :void
    #attach_function :AMFProp_SetString, [AMFObjectProperty, AVal], :void
    #attach_function :AMFProp_SetObject, [AMFObjectProperty, AMFObject], :void

    # void AMFProp_GetName(AMFObjectProperty * prop, AVal * name);
    # void AMFProp_SetName(AMFObjectProperty * prop, AVal * name);
    # double AMFProp_GetNumber(AMFObjectProperty * prop);
    # int AMFProp_GetBoolean(AMFObjectProperty * prop);
    # void AMFProp_GetString(AMFObjectProperty * prop, AVal * str);
    # void AMFProp_GetObject(AMFObjectProperty * prop, AMFObject * obj);
    attach_function :AMFProp_GetName, [AMFObjectProperty, AVal], :void
    attach_function :AMFProp_SetName, [AMFObjectProperty, AVal], :void
    attach_function :AMFProp_GetNumber, [AMFObjectProperty], :double
    attach_function :AMFProp_GetBoolean, [AMFObjectProperty], :int
    attach_function :AMFProp_GetString, [AMFObjectProperty, AVal], :void
    attach_function :AMFProp_GetObject, [AMFObjectProperty, AMFObject], :void

    # int AMFProp_IsValid(AMFObjectProperty * prop);
    attach_function :AMFProp_IsValid, [AMFObjectProperty], :int

    # char *AMFProp_Encode(AMFObjectProperty * prop, char *pBuffer, char *pBufEnd);
    # int AMF3Prop_Decode(AMFObjectProperty * prop, const char *pBuffer, int nSize, int bDecodeName);
    # int AMFProp_Decode(AMFObjectProperty * prop, const char *pBuffer, int nSize, int bDecodeName);
    attach_function :AMFProp_Encode, [AMFObjectProperty, :pointer, :pointer], :pointer
    attach_function :AMF3Prop_Decode, [AMFObjectProperty, :pointer, :int, :int], :int
    attach_function :AMFProp_Decode, [AMFObjectProperty, :pointer, :int, :int], :int

    # void AMFProp_Dump(AMFObjectProperty * prop);
    # void AMFProp_Reset(AMFObjectProperty * prop);
    attach_function :AMFProp_Dump, [AMFObjectProperty], :void
    attach_function :AMFProp_Reset, [AMFObjectProperty], :void

    # void AMF3CD_AddProp(AMF3ClassDef * cd, AVal * prop);
    # AVal *AMF3CD_GetProp(AMF3ClassDef * cd, int idx);
    attach_function :AMF3CD_AddProp, [AMF3ClassDef, AVal], :void
    attach_function :AMF3CD_GetProp, [AMF3ClassDef, :int], AVal
  end
end

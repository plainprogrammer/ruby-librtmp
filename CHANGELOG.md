NEXT
====
* Added check to make sure we only use RTMP_Write() when we are sending FLV data.

v0.1.3
======
* Added nil check before sending data in Streamer#send.

v0.1.2
======
* Fixed issue with Streamer#send not handling null bytes well for binary data;
  required adjusting Librtmp::FFI#RTMP_Write() implementation to expect a
  pointer instead of a string.
* Stubbed out implementation for converting a Hash sent to Streamer#send into
  an AMF Object to send over the stream.

v0.1.1
======

* Added Streamer class to encapsulate the most common use cases of a RTMP
  client.

v0.1.0
======

* Initial implementation of FFI interface to librtmp.

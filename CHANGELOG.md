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

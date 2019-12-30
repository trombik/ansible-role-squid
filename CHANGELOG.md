## Release 3.0.0

* 6c65df6 bugfix: QA
* 51d10b2 backward incompatible: change the meaning of squid_flags
* c41edfe bugfix: bump platform versions
* 3b31b5d bugfix: update gems
* d0f153a bugfix: QA

`squid_flags` is now the content of startup scripts, or simply a flag
(OpenBSD).  You should change `squid_flags`.

## Release 2.0.0

* 7560a95 [bugfix] QA (#6)
* a028785 [backward-incompatible] make `squid_config` a string (#5)

This release introduce backward-incompatibility.

`squid_config` had been a list, but now it is a string.

## Release 1.1.1

The previous release does not include any changes.

## Release 1.1.0

* 57bc30c Support debian (#3)

## Release 1.0.0

* Initial release

#!/usr/bin/bash

##
# Convert string to hex with max line size of 256
# $1 string to convert
##
HEX256() {
  printf "$1" | xxd -p -c 256
}

##
# Convert string to sha256 hash
# $1 string to convert
##
SHA256Hash() {
  local output=$(printf "$1" | shasum -a 256)
  echo "${output%% *}"
}

##
# Generate HMAC signature using SHA256
# $1 signing key in hex
# $2 string data to sign
##
HMAC-SHA256() {
  HEX256 `printf "$2" | openssl dgst -binary -sha256 -mac HMAC -macopt hexkey:$1`
}

##
# Generate HMAC signature using SHA256 and output as HEX
# $1 signing key in hex
# $2 string data to sign
##
HMAC-SHA256-HEX() {
  printf "$2" | openssl dgst -binary -hex -sha256 -mac HMAC -macopt hexkey:$1 | sed 's/^.* //'
}

##
# Sign data using AWS Signature Version 4
# $1 AWS Secret Access Key
# $2 yyyymmdd
# $3 AWS Region
# $4 AWS Service
# $5 string data to sign
##
Sign() {
  local kSigning=$(HMAC-SHA256 $(HMAC-SHA256 $(HMAC-SHA256 $(HMAC-SHA256 $(HEX256 "AWS4$1") $2) $3) $4) "aws4_request")
  HMAC-SHA256-HEX ${kSigning} $5
}

##
# Get endpoint of specified region
# $1 region
##
S3RegionToEndpoint() {
  case "$1" in
    us-east-1) echo "s3.amazonaws.com"
      ;;
    *) echo s3-${1}.amazonaws.com
      ;;
    esac
}


#!/bin/bash
#
# Common functions for s3 commands

##
# Write error to stderr
# Arguments:
#   $1 string to output
##
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

##
# Convert string to hex with max line size of 256
# Arguments:
#   $1 string to convert
# Returns:
#   hex string
##
hex256() {
  printf "$1" | xxd -p -c 256
}

##
# Convert string to sha256 hash
# Arguments:
#   $1 string to convert
# Returns:
#   hash string
##
sha256hash() {
  local output=$(printf "$1" | shasum -a 256)
  echo "${output%% *}"
}

##
# Generate HMAC signature using SHA256
# Arguments:
#   $1 signing key in hex
#   $2 string data to sign
# Returns:
#   signature
##
hmac_sha256() {
  printf "$2" | openssl dgst -binary -hex -sha256 -mac HMAC -macopt hexkey:$1 | sed 's/^.* //'
}

##
# Sign data using AWS Signature Version 4
# Arguments:
#   $1 AWS Secret Access Key
#   $2 yyyymmdd
#   $3 AWS Region
#   $4 AWS Service
#   $5 string data to sign
# Returns:
#   signature
##
sign() {
  local kSigning=$(hmac_sha256 $(hmac_sha256 $(hmac_sha256 $(hmac_sha256 $(hex256 "AWS4$1") $2) $3) $4) "aws4_request")
  hmac_sha256 "${kSigning}" "$5"
}

##
# Get endpoint of specified region
# Arguments:
#   $1 region
# Returns:
#   amazon andpoint
##
convS3RegionToEndpoint() {
  case "$1" in
    us-east-1) echo "s3.amazonaws.com"
      ;;
    *) echo s3-${1}.amazonaws.com
      ;;
    esac
}


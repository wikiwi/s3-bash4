#!/bin/bash
#
# Common functions for s3 commands

# Constants
readonly VERSION="0.1"

# Exit codes
readonly INVALID_USAGE_EXIT_CODE=1
readonly INVALID_USER_DATA_EXIT_CODE=2
readonly INTERNAL_ERROR_EXIT_CODE=3
readonly INVALID_ENVIRONMENT_EXIT_CODE=4

##
# Write error to stderr
# Arguments:
#   $1 string to output
##
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] Error: $@" >&2
}


##
# Display version and exit
##
showVersionAndExit() {
  printf "$VERSION\n"
  exit
}

##
# Helper for parsing the command line.
##
assertArgument() {
  if [[ $# < 2 ]]; then
    err "Option $1 needs an argument."
    exit $INVALID_USAGE_EXIT_CODE
  fi
}

##
# Asserts given resource path
# Arguments:
#   $1 string resource path
##
assertResourcePath() {
  if [[ $1 = !(/*) ]]; then
    err "Resource should start with / e.g. /bucket/file.ext"
    exit $INVALID_USAGE_EXIT_CODE
  fi
}

##
# Reads, validates and return aws secret stored in a file
# Arguments:
#   $1 path to secret file
# Output:
#   string AWS secret
##
processAWSSecretFile() {
  local errStr="The Amazon AWS secret key must be 40 bytes long. Make sure that there is no carriage return at the end of line."
  if ! [[ -f $1 ]]; then
    err "The file $1 does not exist."
    exit $INVALID_USER_DATA_EXIT_CODE
  fi

  # limit file size to max 41 characters. 40 + potential null terminating character.
  local fileSize="$(ls -l "$1" | awk '{ print $5 }')"
  if [[ $fileSize -gt 41 ]]; then
    err $errStr
    exit $INVALID_USER_DATA_EXIT_CODE
  fi

  secret=$(<$1)
  # exact string size should be 40.
  if [[ ${#secret} != 40 ]]; then
    err $errStr
    exit $INVALID_USER_DATA_EXIT_CODE
  fi
  echo $secret
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
  printf "$2" | openssl dgst -binary -hex -sha256 -mac HMAC -macopt hexkey:$1 \
              | sed 's/^.* //'
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
  local kSigning=$(hmac_sha256 $(hmac_sha256 $(hmac_sha256 \
                 $(hmac_sha256 $(hex256 "AWS4$1") $2) $3) $4) "aws4_request")
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


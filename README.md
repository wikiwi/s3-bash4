# s3-bash4

_s3-bash4_ is a small collection of Bash scripts to do simple interaction with _Amazon S3_ using [AWS Signature Version 4](http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html). The advantage of using _s3-bash4_ is that it's extremly lightweight and easy to setup. No need to setup _Python_, _Java_, _Ruby_ and co.

### Usage
    # Get file from bucket:
    s3-get -k {accesskey} -s /{path}/{secretid} -r {region} /{bucketname}/{filename} > {filename}

    # Upload file to bucket:
    s3-put -k {accesskey} -s /{path}/{secretid} -r {region} -T /{path}/{filename} /{bucketname}/{filename}

    # Delete from bucket:
    s3-delete -k {accesskey} -s /{path}/{secretid} -r {region} /{bucketname}/{filename}

### Environment Variables
  - AWS_DEFAULT_REGION will be used as the default AWS Region
  - AWS_ACCESS_KEY_ID will be used as the default AWS Key ID
  - AWS_SECRET_ACCESS_KEY will be used as the default AWS Secret Access Key

### Requirements
  - OpenSSL
  - cUrl

### License
Apache License Version 2.0

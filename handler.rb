require 'json'
require 'aws-sdk'
require 'aws-sdk-s3'

def hello(event:, context:)
  logger = Logger.new($stdout)
  logger.info('## ENVIRONMENT VARIABLES')
  logger.info(ENV.to_a)
  logger.info('## EVENT')
  logger.info(event)
  logger.info(context)

  if event['Records'] && event['Records'].first && event['Records'].first["eventSource"] == "aws:s3"   #S3 PUT Event驱动
    logger.info(event['Records'].first["s3"])
    bucket_name = event['Records'].first["s3"]['bucket']['name']
    object_key  = event['Records'].first['s3']['object']['key']
    logger.info(bucket_name)
    logger.info(object_key)
      
    s3 = Aws::S3::Client.new()

    resp = s3.get_object(bucket: bucket_name, key: object_key)
    streams = resp.body.read.split("\n")
  else                                                                                      #API GateWay驱动
    streams = event["body"].split("\n")
  end
  logger.info(streams)
  if right_format?(streams)
    dynamoDB = Aws::DynamoDB::Resource.new(region: 'us-east-2')
    table = dynamoDB.table('address')
    1.upto(streams.size - 1) do |i|
        streams[i].scan(/^([-|\d|.]+),([-|\d|.]+),"([\W|\w]+)"$/)
        table.put_item({
          item:
            {
              latitude: $1.to_f,
              longitude: $2.to_f,
              address: $3
            }} 
        )
    end

    {
      statusCode: 200,
      body: {
        code: 0,
        message: "right_format"
      }.to_json
    }
  else
    sns = Aws::SNS::Client.new(region: 'us-east-2')
    sns.publish(topic_arn: "arn:aws:sns:us-east-2:555543092407:address_put_error", message: "收到一个异常文件，敬请留意")

    {
      statusCode: 200,
      body: {
        code: -1,
        message: "wrong_format"
      }.to_json
    }
  end
end

def right_format?(streams)
    return false if streams.size == 0
    return false unless streams[0] == "latitude,longitude,address"
    return true if streams.size == 1
    1.upto(streams.size-1) do |i|
        line = streams[i]
        return false unless line.match(/^([-|\d|.]+),([-|\d|.]+),("[\W|\w]+")$/)
    end

    return true
end

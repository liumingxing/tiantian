require 'json'
require 'test/unit'
require 'mocha/test_unit'
require 'httparty'

require_relative '../../handler'

class HelloWorldTest < Test::Unit::TestCase
  def event(file_path)
    JSON.parse({
      "Records": [
        {
          "eventVersion": "2.0",
          "eventSource": "aws:s3",
          "awsRegion": "us-east-2",
          "eventTime": "1970-01-01T00:00:00.000Z",
          "eventName": "ObjectCreated:Put",
          "userIdentity": {
            "principalId": "*"
          },
          "requestParameters": {
            "sourceIPAddress": "127.0.0.1"
          },
          "responseElements": {
            "x-amz-request-id": "EXAMPLE123456789",
            "x-amz-id-2": "EXAMPLE123/5678abcdefghijklambdaisawesome/mnopqrstuvwxyzABCDEFGH"
          },
          "s3": {
            "s3SchemaVersion": "1.0",
            "configurationId": "testConfigRule",
            "bucket": {
              "name": "my-custom-bucket-name1",
              "ownerIdentity": {
                "principalId": "*"
              },
              "arn": "arn:aws:s3:::example-bucket"
            },
            "object": {
              "key": file_path,
              "size": 1024,
              "eTag": "0123456789abcdef0123456789abcdef",
              "sequencer": "0A1B2C3D4E5F678901"
            }
          }
        }
      ]
    }.to_json)
  end

  def test_lambda_handler
    right_result = {
      statusCode: 200,
      body: {
        code: 0,
        message: "right_format"
      }.to_json
    }
    wrong_result = {
      statusCode: 200,
      body: {
        code: -1,
        message: "wrong_format"
      }.to_json
    }
    assert_equal(hello(event: event("address_right.csv"), context: ''), right_result)
    assert_equal(hello(event: event("address_wrong.csv"), context: ''), wrong_result)


    #测试API GateWay发送请求
    content = File.read('./data/address_right.csv')
    event = Hash.new
    event["body"] = content
    context = Hash.new
    result = hello(event: event, context: context)
    assert_match(right_result.to_json, result.to_json, 'Should match')
  end
end

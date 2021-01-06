# tiantian

AWS Lambda小项目

## 发布

发布项目使用如下命令

```bash
sls deploy 
```

## 本地测试
```bash
 sls invoke local --function hello --path events/s3_right.json
 sls invoke local --function hello --path events/s3_wrong.json
```

## 单元测试
```bash
 ruby tests/unit/test_handler.rb
```

## API Gateway测试
代码中有判断请求来自API Gateway还是来自S3。用curl模拟一个http请求，通过API Gateway发送文件
```bash
  curl -X PUT -T data/address_right.csv "https://sj3xdzh03m.execute-api.us-east-2.amazonaws.com/dev/hello"
```
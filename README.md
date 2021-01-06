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

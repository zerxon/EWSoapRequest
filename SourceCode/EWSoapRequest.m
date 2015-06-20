//
//  SoapObject.m
//  SoapObject
//
//  Created by 江承諭 on 9/24/14.
//  Copyright (c) 2014 happiness9721. All rights reserved.
//

#import "EWSoapRequest.h"

@implementation EWSoapRequest

static EWSoapRequest *instance;

+ (instancetype)shareInstance
{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[EWSoapRequest alloc] init];
        }
    }
    
    return instance;
}

- (NSTimeInterval)timeout
{
    if (_timeout == 0) {
        return 60;
    }
    
    return _timeout;
}

- (NSString *)buildSoapMsgWithUrl:(NSString *)url action:(NSString *)action params:(NSDictionary *)params
{
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                         "<soap:Body>"
                         "<%@ xmlns=\"%@\">", action, (self.nameSpace ? self.nameSpace : @"http://www.w3.org")];
    for (NSString *key in [params allKeys])
    {
        soapMsg = [soapMsg stringByAppendingFormat:@"<%@>%@</%@>", key, [params objectForKey:key], key];
    }
    
    soapMsg = [soapMsg stringByAppendingFormat:@"</%@>"
               "</soap:Body>"
               "</soap:Envelope>", action];
    
    return soapMsg;
}

- (void)requestUrl:(NSString *)url
            action:(NSString *)action
            params:(NSDictionary *)params
           success:(EWSoapSuccessBlock)success
           failure:(EWSoapFailureBlock)failure
{
    
    NSString *soapMsg = [self buildSoapMsgWithUrl:url
                                           action:action
                                           params:params];
    
    NSString *msgLength = [NSString stringWithFormat:@"%lx", [soapMsg length]];
    
    // 创建URL，内容是前面的请求报文报文中第二行主机地址加上第一行URL字段
    NSURL *nsurl = [NSURL URLWithString:url];
    
    // 根据上面的URL创建一个请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeout];
    
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    
    // 设置请求行方法为POST，与请求报文第一行对应
    [request setHTTPMethod:@"POST"];
    
    // 将SOAP消息加到请求中
    [request setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 创建连接
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (!connectionError) {
                                   NSError *error = nil;
                                   NSDictionary *dataDictionary = [XMLReader dictionaryForXMLData:data error:&error];
                                   
                                   if (!error) {
                                       success((NSHTTPURLResponse *)response, dataDictionary);
                                   }
                                   else {
                                       failure((NSHTTPURLResponse *)response, error);
                                   }
                               }
                               else {
                                   failure((NSHTTPURLResponse *)response, connectionError);
                               }
                           }];
}

@end

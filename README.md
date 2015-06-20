# EWSoapRequest

### Usage
    EWSoapRequest *soapRequest = [EWSoapRequest shareInstance];
    soapRequest.nameSpace = nameSpace;  //namespace value
    soapRequest.timeout = 10; //default is 60s
    
    [soapRequest requestUrl:[EWAPI API_HOST]
                     action:action
                     params:params
                    success:successBlock
                    failure:failureBlock

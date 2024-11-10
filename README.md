Client Side                                Server Side (AWS)
-----------                                ----------------

                    Client Authentication
Your RootCA ----signs----> Client Cert ----presents----> API Gateway
                                                            |
                                                        Verifies using
                                                        your RootCA
                                                        (from S3 truststore)

                    Server Authentication
System CAs  ----signs----> AWS Cert <----presents---- API Gateway
(including     |
Server's CA)      |
               |
Client ----verifies---- AWS Cert
using system CAs
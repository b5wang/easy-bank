package com.b5wang.easybank.mockservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

@SpringBootApplication
@EnableEurekaClient
public class MockServiceStarter {

    public static void main(String[] args){
        SpringApplication.run(MockServiceStarter.class,args);
    }

}

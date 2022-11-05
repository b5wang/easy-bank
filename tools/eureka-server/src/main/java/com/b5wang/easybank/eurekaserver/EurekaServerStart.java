package com.b5wang.easybank.eurekaserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@SpringBootApplication
@EnableEurekaServer
public class EurekaServerStart {

    public static void main(String[] args){
        SpringApplication.run(EurekaServerStart.class,args);
    }

}

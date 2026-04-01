package com.eb.ops;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class EbOpsApplication {

    public static void main(String[] args) {
        SpringApplication.run(EbOpsApplication.class, args);
    }
}


package com.eb.transfer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class EbTransferApplication {

    public static void main(String[] args) {
        SpringApplication.run(EbTransferApplication.class, args);
    }
}


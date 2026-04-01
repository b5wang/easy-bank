package com.eb.channel;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class EbChannelApplication {

    public static void main(String[] args) {
        SpringApplication.run(EbChannelApplication.class, args);
    }
}


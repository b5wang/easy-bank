package com.b5wang.easybank.mockservice.rest;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import javax.websocket.server.PathParam;

@Slf4j
@RestController
public class HelloRestController {

    @GetMapping("/hello")
    @ResponseBody
    public String hello(@RequestParam(name="name") String name) throws InterruptedException {
        log.info("hello service start");
        // simulate the processing time 5 sec
        Thread.sleep(5000);

        String msg = null;
        if(name == null){
            msg = "Hello!";
        }else{
            msg = "Hello, " + name + "!";
        }
        log.info("hello service end! message={}",msg);
        return msg;
    }

}

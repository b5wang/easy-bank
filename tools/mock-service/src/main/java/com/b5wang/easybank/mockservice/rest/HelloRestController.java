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
    public String hello(@RequestParam(name="name") String name){
        String msg = null;
        if(name == null){
            msg = "Hello!";
        }else{
            msg = "Hello, " + name + "!";
        }
        log.info(msg);
        return msg;
    }

}

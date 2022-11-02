package com.b5wang.easybank.tellerui.controller;


import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
public class MonitorController {

    public MonitorController(){
        log.error("----->MonitorController started");
    }

    @GetMapping("/teller-ui/status")
    public String getStatus(){
        log.info("Monitor the status!");
        return "Running";
    }


}

package com.b5wang.easybank.mockservice.rest;

import com.b5wang.easybank.mockservice.dto.Stat;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.atomic.AtomicLong;

@Slf4j
@RestController
public class HelloRestController {


    private static final AtomicLong COUNTER_TOTAL =  new AtomicLong(0);


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

    @GetMapping("/processing")
    @ResponseBody
    public ResponseEntity<String> processing(@RequestParam(name="time") int time,@RequestParam(name="txId") String txId){
        COUNTER_TOTAL.getAndIncrement();
        log.info("[{}] Processing start time={} seconds.",txId,time);
        try {
            Thread.sleep(1000 * time);
        } catch (InterruptedException e) {
            log.error("[" + txId + "] sleep failed",e);
        }
        log.info("[{}] Processing end!",txId);
        return ResponseEntity.ok("[" + txId + "] done!");
    }

    @RequestMapping(method = RequestMethod.GET, path = "/stat")
    @ResponseBody
    public ResponseEntity<Stat> stat(){
        Stat stat = new Stat();
        stat.setTotal(COUNTER_TOTAL.get());

        return ResponseEntity.ok(stat);
    }

    @RequestMapping(method = RequestMethod.GET, path = "/reset")
    @ResponseBody
    public ResponseEntity<Stat> reset(){
        COUNTER_TOTAL.set(0);

        Stat stat = new Stat();
        stat.setTotal(COUNTER_TOTAL.get());

        return ResponseEntity.ok(stat);
    }

}

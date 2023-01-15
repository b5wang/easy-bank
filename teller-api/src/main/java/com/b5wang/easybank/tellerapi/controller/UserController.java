package com.b5wang.easybank.tellerapi.controller;

import com.b5wang.easybank.tellerapi.model.User;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Slf4j
@RestController
public class UserController {

    @RequestMapping(method = RequestMethod.GET, value = "/users/status")
    @ResponseBody
    public String status(){
        log.info("Status request");
        return "OK";
    }

    @RequestMapping(method = RequestMethod.GET, value = "/users/list")
    @ResponseBody
    public ResponseEntity<List<User>> list(){
        User u1 = new User();
        u1.setId("1");
        u1.setUsername("Tom");
        User u2 = new User();
        u2.setId("2");
        u2.setUsername("Peter");
        User u3 = new User();
        u3.setId("3");
        u3.setUsername("ddT");

        List list = new ArrayList<User>();
        list.add(u1);
        list.add(u2);
        list.add(u3);

        return ResponseEntity.ok(list);
    }

    @RequestMapping(method = RequestMethod.POST, value = "/users/login")
    @ResponseBody
    public String login(@RequestParam String username, @RequestParam String password){
        log.info("login, username: {}, password: {}", username, password);
        return "OK";
    }

    @RequestMapping(method = RequestMethod.POST, value = "/users")
    @ResponseBody
    public String create(@RequestBody User user){
        String id = UUID.randomUUID().toString();
        log.info("User name: {}, id: {}", user.getUsername(),id);
        return id;
    }




}

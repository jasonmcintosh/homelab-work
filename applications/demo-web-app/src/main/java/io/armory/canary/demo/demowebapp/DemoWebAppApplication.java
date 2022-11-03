package io.armory.canary.demo.demowebapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.Properties;

@SpringBootApplication
public class DemoWebAppApplication {

	public static void main(String[] args) {
		SpringApplication app = new SpringApplication(DemoWebAppApplication.class);
		Properties props = new Properties();
		props.put("management.endpoints.web.exposure.include","health,info,prometheus");
		app.setDefaultProperties(props);
		app.run(args);
	}

}

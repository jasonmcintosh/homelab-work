package io.armory.canary.demo.demowebapp;


import org.apache.tomcat.util.http.fileupload.util.Streams;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@RestController
@Component
public class QuoteSchlock {

    private static List<String> quotes;

    static {
        try {
            InputStream stream = QuoteSchlock.class.getResourceAsStream("/quotes.txt");
            String[] fileQuotes = new String(stream.readAllBytes(), StandardCharsets.UTF_8).split("\n");
            quotes = new ArrayList(List.of(fileQuotes));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Value("${latencyToInject:0}")
    private long latencyTOInject = 0;

    @GetMapping(produces = "text/plain", path = "/")
    public String getAQuote() {
        try {
            Thread.sleep(latencyTOInject);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
        return "https://www.schlockmercenary.com/ Quote: " + quotes.get(new Random().nextInt(quotes.size()));
    }
}

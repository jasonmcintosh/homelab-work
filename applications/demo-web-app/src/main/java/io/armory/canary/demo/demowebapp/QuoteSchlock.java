package io.armory.canary.demo.demowebapp;


import jakarta.servlet.http.HttpServletRequest;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
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

    @GetMapping(produces = "application/json", path = "/")
    public SchlockQuote getAQuote(final HttpServletRequest request) {
        try {
            Thread.sleep(latencyTOInject + Integer.parseInt(Optional.ofNullable(request.getHeader("latencyToInject")).orElse("0")));
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
        return new SchlockQuote().setQuote(quotes.get(new Random().nextInt(quotes.size())));
    }

    @Data
    @NoArgsConstructor
    @Accessors(chain=true)
    public static class SchlockQuote {
        private String quote;
        private String url = "https://www.schlockmercenary.com/";

    }
}

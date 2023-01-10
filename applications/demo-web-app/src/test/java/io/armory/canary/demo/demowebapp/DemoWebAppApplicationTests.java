package io.armory.canary.demo.demowebapp;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.util.StopWatch;

import static org.hamcrest.Matchers.containsString;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class DemoWebAppApplicationTests {

	@Autowired
	private MockMvc mockMvc;

	@Test
	void makeSureUrlIsIncluded() throws Exception {
		this.mockMvc.perform(get("/"))
				.andDo(print())
				.andExpect(status().isOk())
				.andExpect(content().contentType("application/json"))
				.andExpect(content().string(containsString("https://www.schlockmercenary.com/")));
	}
	@Test
	void expectLatencyIfHeaderSet() throws Exception {
		StopWatch timer = new StopWatch();
		timer.start();
		this.mockMvc.perform(get("/").header("latencyToInject", "5000"))
				.andDo(print())
				.andExpect(status().isOk())
				.andExpect(content().contentType("application/json"))
				.andExpect(content().string(containsString("https://www.schlockmercenary.com/")));
		timer.stop();
		assertTrue(timer.getTotalTimeSeconds() > 5);
	}
}

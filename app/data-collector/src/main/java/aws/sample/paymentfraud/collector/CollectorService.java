package aws.sample.paymentfraud.collector;

import java.util.logging.Logger;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CollectorService {

    private final static Logger LOGGER = Logger.getLogger(CollectorService.class.getName());

    @Autowired
    DynamoDBDataCollector collector;

    @GetMapping(CollectorConstants.COLLECTOR_API)
    @ResponseBody
    public String processData(@RequestParam String param) {
        JSONObject responseObject = new JSONObject();
        try {
            String response = getCollector().collect();
            responseObject.put("processedUnderName", response);
        } catch (Exception e) {
            LOGGER.severe(e.getMessage());
            responseObject.put("error", e.getMessage());
        }
        return responseObject.toString();
    }

    private DynamoDBDataCollector getCollector() {
        return collector;
    }
}

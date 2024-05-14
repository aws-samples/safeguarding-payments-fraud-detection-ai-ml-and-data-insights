package aws.sample.paymentfraud.collector;

import java.util.logging.Logger;

import org.json.JSONObject;

public class CollectorService {

    private final static Logger LOGGER = Logger.getLogger(CollectorService.class.getName());

    DynamoDBDataCollector collector;

    public String processData( String param) {
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

package aws.sample.paymentfraud.collector;

import java.util.logging.Logger;

public class ConfigMapCollectorConfig {

    public enum Configs {
        FILE_DATA_EXTRACT_FOLDER_IN_S3,
        FILE_LINE_NUMBER_TO_READ_FROM,
        FILES_LOCATION_IN_S3,
        MAX_LINES_TO_READ,
        PAYMENT_DATA_FILE,
        S3_BUCKET
    }

    private final static Logger LOGGER = Logger.getLogger(ConfigMapCollectorConfig.class.getName());

    public boolean updateParameter(String parameterName, String parameterValue) {
        return false;
    }

    public ConfigMapCollectorConfig() {
        LOGGER.info("FILE_DATA_EXTRACT_FOLDER_IN_S3 - " + System.getenv("FILE_DATA_EXTRACT_FOLDER_IN_S3"));
        LOGGER.info("FILE_LINE_NUMBER_TO_READ_FROM - " + System.getenv("FILE_LINE_NUMBER_TO_READ_FROM"));
        LOGGER.info("FILES_LOCATION_IN_S3 - " + System.getenv("FILES_LOCATION_IN_S3"));
        LOGGER.info("MAX_LINES_TO_READ - " + System.getenv("MAX_LINES_TO_READ"));
        LOGGER.info("PAYMENT_DATA_FILE - " + System.getenv("PAYMENT_DATA_FILE"));
        LOGGER.info("S3_BUCKET - " + System.getenv("S3_BUCKET"));
    }

    public String getConfig(ConfigMapCollectorConfig.Configs key) {
        return System.getenv(key.toString());
    }

    /* public static void main(String[] args) {
        ConfigMapCollectorConfig config = new ConfigMapCollectorConfig();
        
        LocalDateTime currentDateTime = LocalDateTime.now();

        // Print the timestamp
        System.out.println("Timestamp: " + currentDateTime);
        //config.updateParameter("/fraud-detection-app/collector/config/scan_timestamp",currentDateTime.toString());
    } */

}

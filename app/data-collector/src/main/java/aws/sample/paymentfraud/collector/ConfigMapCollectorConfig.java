package aws.sample.paymentfraud.collector;

import java.util.logging.Logger;

public class ConfigMapCollectorConfig {

    public enum Configs {
        FILE_DATA_EXTRACT_FOLDER_IN_S3,
        FILE_LINE_NUMBER_TO_READ_FROM,
        FILES_LOCATION_IN_S3,
        MAX_LINES_TO_READ,
        PAYMENT_DATA_FILE,
        REGION,
        S3_BUCKET,
        S3_FOLDER_COLLECTOR,
        MINIO_HOST,
        MINIO_USERNAME,
        MINIO_PASSWORD
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
        LOGGER.info("REGION - " + System.getenv("REGION"));
        LOGGER.info("S3_BUCKET - " + System.getenv("S3_BUCKET"));
        LOGGER.info("S3_FOLDER_COLLECTOR - " + System.getenv("S3_FOLDER_COLLECTOR"));
        LOGGER.info("MINIO_HOST - " + System.getenv("MINIO_HOST"));
        LOGGER.info("MINIO_USERNAME - " + System.getenv("MINIO_USERNAME"));
        LOGGER.info("MINIO_PASSWORD - " + System.getenv("MINIO_PASSWORD"));
    }

    public String getConfig(ConfigMapCollectorConfig.Configs key) {
        /* if(key.equals(Configs.FILE_DATA_EXTRACT_FOLDER_IN_S3)) return "file_extract";
        else if(key.equals(Configs.FILE_LINE_NUMBER_TO_READ_FROM)) return "1";
        else if (key.equals(Configs.FILES_LOCATION_IN_S3)) return "raw_payment_request_files";
        else if (key.equals(Configs.MAX_LINES_TO_READ)) return "10000";
        else if (key.equals(Configs.PAYMENT_DATA_FILE)) return "transaction_data_100K_full.csv";
        else if (key.equals(Configs.S3_BUCKET)) return "payment-fraud-detection-app-us-east-1";
        else if (key.equals(Configs.MINIO_HOST)) return "http://k8s-paymentf-minioalb-859512b7f4-d42861e90e314b53.elb.us-east-1.amazonaws.com:9000/";
        else if (key.equals(Configs.MINIO_USERNAME)) return "minioadmin";
        else if (key.equals(Configs.MINIO_PASSWORD)) return "minioadmin";
        return null; */
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

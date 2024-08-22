package aws.sample.paymentfraud.collector;

import java.net.URI;
import java.text.DecimalFormat;
import java.util.Calendar;
import java.util.Set;
import java.util.TimeZone;
import java.util.logging.Logger;

import com.amazonaws.util.StringUtils;

import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

public class StorageService {

    private final static Logger LOGGER = Logger.getLogger(StorageService.class.getName());

    ConfigMapCollectorConfig collectorConfig = new ConfigMapCollectorConfig();

    private S3Client s3 = null; // S3Client.builder().region(Region.US_EAST_1).build();

    public StorageService() throws Exception {
        String minioHost = getCollectorConfig().getConfig(ConfigMapCollectorConfig.Configs.MINIO_HOST);//System.getenv("MINIO_HOST");
        LOGGER.info("MINIO HOST is - " + minioHost);
        if (StringUtils.isNullOrEmpty(minioHost)) {
            s3 = S3Client.builder().region(Region.US_EAST_1).build();
        } else {
            LOGGER.info("MINIO USERNAME is - " + getCollectorConfig().getConfig(ConfigMapCollectorConfig.Configs.MINIO_USERNAME));
            LOGGER.info("MINIO PASSWORD is - " + getCollectorConfig().getConfig(ConfigMapCollectorConfig.Configs.MINIO_PASSWORD));
            s3 = S3Client.builder()
                    .forcePathStyle(true)
                    .endpointOverride(URI.create(minioHost))
                    .credentialsProvider(
                            StaticCredentialsProvider.create(AwsBasicCredentials.create(
                                getCollectorConfig().getConfig(ConfigMapCollectorConfig.Configs.MINIO_USERNAME),
                                getCollectorConfig().getConfig(ConfigMapCollectorConfig.Configs.MINIO_PASSWORD))))
                    .region(Region.US_EAST_1) // You can use any region here
                    .build();
        }

    }

    public String storeObjects(String data, Set<String> files) {
        String dateString = Utils.now();
        LOGGER.info("Stored data to S3 for " + dateString);
        return dateString;
    }

    public String storeFile(String data) {
        Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        DecimalFormat mFormat = new DecimalFormat("00");
        String date = mFormat.format(calendar.get(Calendar.DATE));
        String month = mFormat.format(calendar.get(Calendar.MONTH) + 1);
        String year = mFormat.format(calendar.get(Calendar.YEAR));
        String hour = mFormat.format(calendar.get(Calendar.HOUR));
        String minute = mFormat.format(calendar.get(Calendar.MINUTE));
        String second = mFormat.format(calendar.get(Calendar.SECOND));

        String objectKey = new StringBuilder()
                .append("data-collector/")
                .append(year).append("/")
                .append(month).append("/")
                .append(date).append("/")
                .append(hour).append("/")
                .append(minute).append("/")
                .append(second).append("/").toString();

        String location = store(data, objectKey + "file.csv");
        return location;
    }

    public String store(String data, String objectName) {
        if (StringUtils.isNullOrEmpty(data)) {
            LOGGER.info("No data to store for name " + objectName);
            return null;
        }

        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(getCollectorConfig().getConfig(ConfigMapCollectorConfig.Configs.S3_BUCKET))
                .key(objectName)
                .build();
        s3.putObject(request, RequestBody.fromBytes(data.getBytes()));
        return getCollectorConfig().getConfig(ConfigMapCollectorConfig.Configs.S3_BUCKET) + "/" + objectName;
    }

    private ConfigMapCollectorConfig getCollectorConfig() {
        return collectorConfig;
    }

    /*
     * public static void main(String[] args) {
     * try {
     * StorageService storageService = new StorageService();
     * } catch (Exception e) {
     * e.printStackTrace();
     * }
     * }
     */

}

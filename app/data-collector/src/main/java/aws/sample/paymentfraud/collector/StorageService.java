package aws.sample.paymentfraud.collector;

import java.io.IOException;
import java.net.URI;
import java.text.DecimalFormat;
import java.util.Calendar;
import java.util.TimeZone;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.json.JSONObject;

import com.amazonaws.util.StringUtils;

import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.HeadObjectRequest;
import software.amazon.awssdk.services.s3.model.HeadObjectResponse;
import software.amazon.awssdk.services.s3.model.NoSuchKeyException;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

public class StorageService {

    private final static Logger LOGGER = Logger.getLogger(StorageService.class.getName());

    CollectorConfig collectorConfig = new CollectorConfig();

    private S3Client s3 = null;

    public StorageService() throws Exception {
        String minioHost = getCollectorConfig().getConfig(CollectorConfig.Configs.MINIO_HOST);//System.getenv("MINIO_HOST");
        LOGGER.info("MINIO HOST is - " + minioHost);
        if (StringUtils.isNullOrEmpty(minioHost)) {
            s3 = S3Client.builder().region(Region.of(getCollectorConfig().getConfig(CollectorConfig.Configs.REGION))).build();
            LOGGER.info("Initialized S3 for storage");
        } else {
            s3 = S3Client.builder()
                    .forcePathStyle(true)
                    .endpointOverride(URI.create(minioHost))
                    .credentialsProvider(
                            StaticCredentialsProvider.create(AwsBasicCredentials.create(
                                getCollectorConfig().getConfig(CollectorConfig.Configs.MINIO_USERNAME),
                                getCollectorConfig().getConfig(CollectorConfig.Configs.MINIO_PASSWORD))))
                    .region(Region.of(CollectorConfig.Configs.REGION.name())) // You can use any region here
                    .build();
            LOGGER.info("Initialized MinIO for storage");
        }
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
                .append(getCollectorConfig().getConfig(CollectorConfig.Configs.COLLECTOR_FOLDER))
                .append("/")
                .append(year).append("/")
                .append(month).append("/")
                .append(date).append("/")
                .append(hour).append("/")
                .append(minute).append("/")
                .append(second).append("/").toString();

        String location = store(data, objectKey + "file.csv");
        return location;
    }

    private byte[] readStateFileFromStorage(String stateFileName) throws IOException {

        HeadObjectRequest headObjectRequest = HeadObjectRequest.builder()
                .bucket(getCollectorConfig().getConfig(CollectorConfig.Configs.S3_BUCKET))
                .key(stateFileName)
                .build();
        LOGGER.info("Head Object Request - " + headObjectRequest);
        try {
            HeadObjectResponse response = s3.headObject(headObjectRequest); // if no exception is thrown that means the file exists
            GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                    .bucket(getCollectorConfig().getConfig(CollectorConfig.Configs.S3_BUCKET))
                    .key(stateFileName)
                    .build();

            ResponseInputStream<GetObjectResponse> stateResponse = s3.getObject(getObjectRequest);
            return stateResponse.readAllBytes();
        } catch (NoSuchKeyException e) {
            LOGGER.info("State file " + stateFileName + " does not exist");
            return null; // Object does not exist
        }
        catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error occurred while retrieving state file", e);
            return null; // Object does not exist
        }
    }

    public JSONObject getCollectorState() throws IOException {
        byte[] responseBytes = readStateFileFromStorage(getCollectorConfig().getConfig(CollectorConfig.Configs.COLLECTOR_STATE));
        if (responseBytes == null) return null;

        String fileContent = new String(responseBytes);
        return new JSONObject(fileContent);
    }

    public String store(String data, String objectName) {
        if (StringUtils.isNullOrEmpty(data)) {
            LOGGER.info("No data to store for name " + objectName);
            return null;
        }

        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(getCollectorConfig().getConfig(CollectorConfig.Configs.S3_BUCKET))
                .key(objectName)
                .build();
        s3.putObject(request, RequestBody.fromBytes(data.getBytes()));
        return getCollectorConfig().getConfig(CollectorConfig.Configs.S3_BUCKET) + "/" + objectName;
    }

    private CollectorConfig getCollectorConfig() {
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

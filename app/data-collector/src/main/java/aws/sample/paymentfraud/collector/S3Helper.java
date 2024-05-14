package aws.sample.paymentfraud.collector;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.json.JSONObject;
import org.json.XML;

import com.amazonaws.util.StringUtils;

import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.CopyObjectResponse;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.HeadObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectResponse;
import software.amazon.awssdk.services.s3.model.S3Exception;

public class S3Helper {

    private final static Logger LOGGER = Logger.getLogger(S3Helper.class.getName());

    CollectorConfig collectorConfig = new CollectorConfig();
    public static final String DATE_FORMAT_NOW = "yyyy-MM-dd HH-mm-ss";

    S3Client s3 = S3Client.builder().region(Region.US_EAST_1).build();

    public String storeObjects(String data, Set<String> files) {
        String dateString = now();
        store(data, dateString);
        // savePaymentInfoInXMLASJson(files);
        processFiles(files, dateString);
        LOGGER.info("Stored data to S3 for " + dateString);
        return dateString;
    }

    public PutObjectResponse store(String data, String objectName) {
        if (StringUtils.isNullOrEmpty(data)) {
            LOGGER.info("No data to store for name " + objectName);
            return null;
        }

        String objectKey = collectorConfig.getConfig(CollectorConstants.SSM_KEY_SCAN_DATA_LOCATION) + "/" + objectName;
        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(collectorConfig.getConfig(CollectorConstants.SSM_KEY_S3_BUCKET))
                .key(objectKey)
                .build();
        return s3.putObject(request, RequestBody.fromBytes(data.getBytes()));
    }

    public void processFiles(Set<String> files, String folderName) {
        if (files == null || files.isEmpty()) {
            LOGGER.info("No files to copy for folder " + folderName);
            return;
        }

        for (String s3Object : files) {
            if (!objectExists(getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_SOURCE_S3_BUCKET_FOR_RP2), s3Object)) {
                LOGGER.log(Level.SEVERE, "Object {0} doesn't exist", s3Object);
                continue;
            }
            String fileName = s3Object.substring(s3Object.lastIndexOf("/") + 1);
            try {
                copyFile(getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_SOURCE_S3_BUCKET_FOR_RP2), s3Object,
                        getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_S3_BUCKET),
                        getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_FILES_LOCATION_IN_S3) + "/" + folderName + "/" + fileName + ".csv");

                savePaymentInfoInXMLASJson(
                        getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_SOURCE_S3_BUCKET_FOR_RP2), s3Object,
                        getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_S3_BUCKET),
                        getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_FILE_DATA_EXTRACT_FOLDER_IN_S3) + "/" + folderName + "/" + fileName + ".json");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public CopyObjectResponse copyFile(String sourceBucket, String sourceKey, String destinationBucket,
            String destinationKey) throws Exception {
        try {
            /* CopyObjectRequest copyObjRequest = CopyObjectRequest.builder()
                    .sourceBucket(sourceBucket)
                    .sourceKey(sourceKey)
                    .destinationBucket(destinationBucket)
                    .destinationKey(destinationKey)
                    .build(); */

            //s3.copyObject(copyObjRequest);
            LOGGER.info("Attempting to copy " + sourceBucket + "/" + sourceKey + " --> " + destinationBucket + "/"
                    + destinationKey);
            return s3.copyObject(builder -> builder.sourceBucket(sourceBucket).sourceKey(sourceKey)
                    .destinationBucket(destinationBucket).destinationKey(destinationKey));
        } catch (Exception e) {
            throw new Exception("Unable to copy " + sourceBucket + "/" + sourceKey + " --> " + destinationBucket + "/"
                    + destinationKey, e);
        }
    };

    private boolean objectExists(String bucketName, String objectKey) {
        try {
            return s3.headObject(HeadObjectRequest.builder()
                    .bucket(bucketName)
                    .key(objectKey)
                    .build()) != null;

        } catch (S3Exception e) {
            return false;
        }
    }

    public void savePaymentInfoInXMLASJson(String sourceBucket, String sourceKey, String destinationBucket, String destinationKey) {
        ResponseInputStream<GetObjectResponse> objectStream = s3.getObject(GetObjectRequest.builder()
                .bucket(sourceBucket)
                .key(sourceKey)
                .build());

        JSONObject xmlJSONObj = XML.toJSONObject(new BufferedReader(new InputStreamReader(objectStream)));
        String jsonData = xmlJSONObj.toString();

        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(destinationBucket)
                .key(destinationKey)
                .build();

        RequestBody body = RequestBody.fromBytes(jsonData.getBytes());
        s3.putObject(request, body);
        Object params[] = {destinationBucket,destinationKey};
        LOGGER.log(Level.INFO, "Successfully saved data in JSON format to S3 for {0}/{1} ", params);
    }

    private static String now() {
        Calendar cal = Calendar.getInstance();
        SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
        return sdf.format(cal.getTime());
    }

    private CollectorConfig getCollectorConfig() {
        return collectorConfig;
    }

    public static void main(String[] args) {
        S3Helper storageService = new S3Helper();
    }
}

package aws.sample.paymentfraud.collector;

import java.text.DecimalFormat;
import java.util.Calendar;
import java.util.Set;
import java.util.TimeZone;
import java.util.logging.Logger;

import com.amazonaws.util.StringUtils;

import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

public class StorageService {

    private final static Logger LOGGER = Logger.getLogger(StorageService.class.getName());

    ConfigMapCollectorConfig collectorConfig = new ConfigMapCollectorConfig();

    S3Client s3 = S3Client.builder().region(Region.US_EAST_1).build();

    //Pac008Processor pac008Processor = new Pac008Processor();

    public String storeObjects(String data, Set<String> files) {
        String dateString = Utils.now();
        //store(data, getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_SCAN_DATA_LOCATION) + "/" + dateString+".csv");
        // savePaymentInfoInXMLASJson(files);
        //processFilesAndStore(files, dateString);
        LOGGER.info("Stored data to S3 for " + dateString);
        return dateString;
    }

    public String storeFile(String data) {
        Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        DecimalFormat mFormat= new DecimalFormat("00");
        String date = mFormat.format(calendar.get(Calendar.DATE));
        String month = mFormat.format(calendar.get(Calendar.MONTH)+1);
        String year = mFormat.format(calendar.get(Calendar.YEAR));
        String hour = mFormat.format(calendar.get(Calendar.HOUR));
        String minute = mFormat.format(calendar.get(Calendar.MINUTE));
        String second = mFormat.format(calendar.get(Calendar.SECOND));

        String objectKey = new StringBuilder()
                    .append("payment/")
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

        //collectorConfig.getConfig(CollectorConstants.SSM_KEY_SCAN_DATA_LOCATION) + "/" + objectName;
        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(getCollectorConfig().getConfig(ConfigMapCollectorConfig.Configs.S3_BUCKET))
                .key(objectName)
                .build();
        s3.putObject(request, RequestBody.fromBytes(data.getBytes()));
        return getCollectorConfig().getConfig(ConfigMapCollectorConfig.Configs.S3_BUCKET)+"/"+objectName;
    }

    /* public void processFilesAndStore(Set<String> files, String folderName) {
        if (files == null || files.isEmpty()) {
            LOGGER.info("No files to copy for folder " + folderName);
            return;
        }

        StringBuffer buffer = new StringBuffer();
        buffer.append(getPac008Processor().getHeader()).append("\n");
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

                buffer.append(getPaymentInfoInXMLASCSV(
                    getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_SOURCE_S3_BUCKET_FOR_RP2), s3Object));
                    buffer.append("\n");

                //savePaymentInfoInXMLASJson(
                  //      getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_SOURCE_S3_BUCKET_FOR_RP2), s3Object,
                    //    getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_S3_BUCKET),
                      //  getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_FILE_DATA_EXTRACT_FOLDER_IN_S3) + "/" + folderName + "/" + fileName + ".json");
                       // System.out.println(buffer);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        store(buffer.toString(), 
        getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_FILE_DATA_EXTRACT_FOLDER_IN_S3) + "/" + folderName + ".csv"); // Save all pac008 files in one CSV
        LOGGER.log(Level.INFO,buffer.toString());
    } */

/*     public CopyObjectResponse copyFile(String sourceBucket, String sourceKey, String destinationBucket,
            String destinationKey) throws Exception {
        try {
            //s3.copyObject(copyObjRequest);
            LOGGER.info("Attempting to copy " + sourceBucket + "/" + sourceKey + " --> " + destinationBucket + "/"
                    + destinationKey);
            return s3.copyObject(builder -> builder.sourceBucket(sourceBucket).sourceKey(sourceKey)
                    .destinationBucket(destinationBucket).destinationKey(destinationKey));
        } catch (Exception e) {
            throw new Exception("Unable to copy " + sourceBucket + "/" + sourceKey + " --> " + destinationBucket + "/"
                    + destinationKey, e);
        }
    }; */

    /* private boolean objectExists(String bucketName, String objectKey) {
        try {
            return s3.headObject(HeadObjectRequest.builder()
                    .bucket(bucketName)
                    .key(objectKey)
                    .build()) != null;

        } catch (S3Exception e) {
            return false;
        }
    } */

    /* private String getPaymentInfoInXMLASCSV(String sourceBucket, String sourceKey) throws Exception {
        ResponseInputStream<GetObjectResponse> objectStream = s3.getObject(GetObjectRequest.builder()
                .bucket(sourceBucket)
                .key(sourceKey)
                .build());

        Object[] params = {sourceBucket,sourceKey};
        LOGGER.log(Level.INFO, "Processing for CSV of {0}/{1}", params);
        
        String csv = getPac008Processor().process(objectStream);
        LOGGER.log(Level.INFO, "Successfully converted data in CSV format {0}/{1} ", params);
        return csv;
    }

    private void savePaymentInfoInXMLASJson(String sourceBucket, String sourceKey, String destinationBucket, String destinationKey) {
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
    } */

    private ConfigMapCollectorConfig getCollectorConfig() {
        return collectorConfig;
    }

    /* public static void main(String[] args) {
        try {
            StorageService storageService = new StorageService();
        } catch (Exception e) {
            e.printStackTrace();
        }
    } */

    /* private Pac008Processor getPac008Processor() {
        throw new UnsupportedOperationException();
        //return pac008Processor;
    }
 */
}

package aws.sample.paymentfraud.collector;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.ScanRequest;
import software.amazon.awssdk.services.dynamodb.model.ScanResponse;

public class DynamoDBDataCollector implements DataCollector {

  private final static Logger LOGGER = Logger.getLogger(DynamoDBDataCollector.class.getName());

  private static final String KEYS[] = { "transaction_status", "request_resource", "request_account", "created_at",
      "message_id", "created_by",
      "request_service", "request_timestamp", "request_partition", "sk", "request_region", "pk", "storage_type",
      "storage_path" };

  private static final DynamoDbClient ddb = DynamoDbClient.builder()
      .region(Region.US_EAST_1)
      .build();

  private CollectorConfig collectorConfig = new CollectorConfig();

  private StorageService storageService = new StorageService();

  @Override
  public String collect() {
      String tableName = getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_DYNAMO_DB_TABLE);
      String scanTimestamp = getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_SCAN_TIMESTAMP);
      List<Map<String, AttributeValue>> items = scanTableByDate(tableName, scanTimestamp);
      return process(items);
  }

  public List<Map<String, AttributeValue>> scanTableByDate(String tableName, String date) {
    LOGGER.log(Level.INFO, "Starting scan with timestamp " + date);

    ScanRequest scanRequest = ScanRequest.builder()
        .tableName(tableName)
        .filterExpression("created_at >= :val")
        .expressionAttributeValues(Map.of(":val", AttributeValue.builder().s(date).build()))
        .build();
    LOGGER.info("before scan");
    ScanResponse response = getDdb().scan(scanRequest);
    if (response.items() != null && response.items().size() > 0) {
      // writeToCSV(response.items());
      return response.items();
    }
    return null;
  }

  private String process(List<Map<String, AttributeValue>> items) {
    if(items == null || items.size() == 0){
      LOGGER.log(Level.INFO, "No items to process");
      return null;
    }
    StringBuilder sb = new StringBuilder();
    Set<String> incomingFiles = new HashSet<String>();

    for (String key : KEYS) {
      sb.append(key).append(",");
    }
    sb.append("\n");
    items.forEach(item -> {
      for (String key : KEYS) {
        AttributeValue attributeValue = (item.get(key));
        if (attributeValue == null) {
          sb.append("\"\"").append(",");
          continue;
        } else {
          sb.append("\"").append(attributeValue.s()).append("\"").append(",");
        }
        if (key.equals("transaction_status") &&
            item.get(key).s().equals(CollectorConstants.INCOMING_FILE_TRANSACTION_STATUS)) {
          incomingFiles.add(item.get("storage_path").s());
        }
      }
      sb.append("\n");
    });

    String processedUnderName = getStorageService().storeObjects(sb.toString(), incomingFiles);
    return processedUnderName;
  }

  public DynamoDbClient getDdb() {
    return ddb;
  }

  private CollectorConfig getCollectorConfig() {
    return collectorConfig;
  }

  private StorageService getStorageService() {
    return storageService;
  }

  public static void main(String[] args) {
    DynamoDBDataCollector collector = new DynamoDBDataCollector();
    String tableName = collector.getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_DYNAMO_DB_TABLE);
    String scanTimestamp = collector.getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_SCAN_TIMESTAMP);
    LocalDateTime currentDateTime = LocalDateTime.now();

    List<Map<String, AttributeValue>> items = collector.scanTableByDate(tableName, scanTimestamp);
    collector.process(items);
    collector.getCollectorConfig().updateParameter(CollectorConstants.SSM_KEY_SCAN_TIMESTAMP,currentDateTime.toString());
  }

}

package aws.sample.paymentfraud.collector;

public interface CollectorConstants {
    
    public static final String SSM_KEY_COLLECTOR_CONFIG_NAMESPACE="/fraud-detection-app/collector/config";
    public static final String SSM_KEY_SCAN_DATA_LOCATION="/fraud-detection-app/collector/config/table_scan_data_folder_in_s3";
    public static final String SSM_KEY_LINE_NUMBER_TO_READ_FROM="/fraud-detection-app/collector/config/file_line_number_to_read_from";
    public static final String SSM_KEY_MAX_LINES_TO_READ="/fraud-detection-app/collector/config/max_lines_to_read";
    public static final String SSM_KEY_SOURCE_PAYMENT_FILE_LOCATION="/fraud-detection-app/collector/config/source_payment_file_location";
    public static final String SSM_KEY_DYNAMO_DB_TABLE="/fraud-detection-app/collector/config/dynamo-db-table";
    public static final String SSM_KEY_FILE_DATA_EXTRACT_FOLDER_IN_S3="/fraud-detection-app/collector/config/file_data_extract_folder_in_s3";
    public static final String SSM_KEY_FILES_LOCATION_IN_S3="/fraud-detection-app/collector/config/files_location_in_s3";
    public static final String SSM_KEY_S3_BUCKET="/fraud-detection-app/collector/config/s3_bucket";
    public static final String SSM_KEY_SCAN_TIMESTAMP="/fraud-detection-app/collector/config/scan_timestamp";
    //public static final String SSM_KEY_PAYMENT_DATA_EXTRACT_LOCATION="/fraud-detection-app/collector/config/payment_data_extract_location";
    //public static final String PAYMENT_DATA_EXTRACT_LOCATION="transaction_data_100K_full.csv";
    public static final String SSM_KEY_SOURCE_S3_BUCKET_FOR_RP2="/fraud-detection-app/collector/config/source_s3_bucket_for_rp2";
    public static final String INCOMING_FILE_TRANSACTION_STATUS="ACTC";
    public static final String COLLECTOR_API="/collect";

}
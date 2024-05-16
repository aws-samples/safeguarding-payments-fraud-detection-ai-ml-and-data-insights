package aws.sample.paymentfraud.collector;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Calendar;
import java.util.TimeZone;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PaymentDataCollector implements DataCollector {

    private CollectorConfig collectorConfig = new CollectorConfig();

    private StorageService storageService = new StorageService();

    private final static Logger LOGGER = Logger.getLogger(PaymentDataCollector.class.getName());

    @Override
    public String collect() throws Exception {
        int startLineNumber = Integer.parseInt(collectorConfig.getConfig(CollectorConstants.SSM_KEY_LINE_NUMBER_TO_READ_FROM));
        
        int endLineNumber = startLineNumber + 
            Integer.parseInt(getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_MAX_LINES_TO_READ));

        String lines = readFileFromUrl(getCollectorConfig().getConfig(CollectorConstants.SSM_KEY_PAYMENT_DATA_EXTRACT_LOCATION), 
        startLineNumber, endLineNumber
        );
        if(!lines.isBlank()) {
            String dataToReturn = getStorageService().storeFile(lines);
            getCollectorConfig().updateParameter(CollectorConstants.SSM_KEY_LINE_NUMBER_TO_READ_FROM, (endLineNumber+1)+"");
            Object[] params = {endLineNumber-startLineNumber, startLineNumber,endLineNumber,dataToReturn};
            LOGGER.log(Level.INFO, "Read total of {0} lines starting at line number {1} and ending at line number {2}. Stored at S3 folder {3}", params);
            return dataToReturn;
        }else {
            Object[] params = {startLineNumber,endLineNumber};
            LOGGER.log(Level.INFO, "NO_DATA_READ -> Start line number = {0}, End Line Number = {1}", params);
            return "There was no data to collect. -> Start line number = " + startLineNumber + " , EndLineNumber = " + endLineNumber;
        }
    }
    
     public String readFileFromUrl(String fileUrl, int startLineNumber, int endLineNumber) throws URISyntaxException, InterruptedException {
        StringBuilder content = new StringBuilder();
        try {
            URL url = new URI(fileUrl).toURL();
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");

            int responseCode = connection.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                try (InputStream inputStream = connection.getInputStream();
                     BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
                    String line;
                    int currentLineNumber = 1;
                    int secondCounter = 1;
                    String firstLine = null;
                    Object[] params = {fileUrl,startLineNumber,endLineNumber};
                    LOGGER.log(Level.INFO, "Reading {0} from line {1} to {2}", params);
                    while ((line = reader.readLine()) != null && currentLineNumber <= endLineNumber) {
                        if (currentLineNumber == 1) {
                            firstLine = line;
                        }
                        else if (currentLineNumber >= startLineNumber) {
                            Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
                            calendar.add(Calendar.SECOND, secondCounter);
                            String dateString = Utils.getDateString(calendar);
                            Object[] fields = line.split(",");
                            fields[1] = dateString;
                            fields[2] = dateString;
                            //String finalData = Arrays.toString(fields);
                            StringBuilder row = new StringBuilder();
                            for(int i=0; i<fields.length; i++){
                                row.append(fields[i]);
                                if(i < fields.length-1) {
                                    row.append(",");
                                }
                            }
                            content.append(row).append(System.lineSeparator());
                            secondCounter++;
                        }
                        currentLineNumber++;
                    }
                    if(content.length()>0){
                        content.insert(0,System.lineSeparator())
                            .insert(0, firstLine);
                        //append(System.lineSeparator());
                    }
                }
            } else {
                System.out.println("Error reading file from URL: " + responseCode);
            }
        } catch (IOException e) {
            System.out.println("Error reading file from URL: " + e.getMessage());
            
        }
        return content.toString();
    }

    public static void main(String[] args) {
        PaymentDataCollector collector = new PaymentDataCollector();
        try {
            String objectKey = collector.collect();
            LOGGER.log(Level.INFO, objectKey);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public CollectorConfig getCollectorConfig() {
        return collectorConfig;
    }

    public StorageService getStorageService() {
        return storageService;
    }
}


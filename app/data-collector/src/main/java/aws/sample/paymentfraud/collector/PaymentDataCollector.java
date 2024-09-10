package aws.sample.paymentfraud.collector;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLDecoder;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.json.JSONObject;

public class PaymentDataCollector implements DataCollector {
    
    private final static Logger LOGGER = Logger.getLogger(PaymentDataCollector.class.getName());
    private CollectorConfig collectorConfig = new CollectorConfig();
    private StorageService storageService;

    public PaymentDataCollector() throws Exception {
        storageService = new StorageService();
    }

    @Override
    public String collect() throws Exception {
        int startLineNumber = getStartLineNumber();

        int endLineNumber = startLineNumber +
                Integer.parseInt(getCollectorConfig().getConfig(CollectorConfig.Configs.MAX_LINES_TO_READ));

        String lines = readDataFile(getCollectorConfig().getConfig(CollectorConfig.Configs.PAYMENT_DATA_FILE),
                startLineNumber, endLineNumber);
        if (!lines.isBlank()) {
            String dataToReturn = getStorageService().storeFile(lines);
            Object[] params = { endLineNumber - startLineNumber, startLineNumber, endLineNumber, dataToReturn };
            LOGGER.log(Level.INFO,
                    "Read total of {0} lines starting at line number {1} and ending at line number {2}. Stored at S3 folder {3}",
                    params);
            saveState(endLineNumber + 1 + "");
            return dataToReturn;
        } else {
            Object[] params = { startLineNumber, endLineNumber };
            LOGGER.log(Level.INFO, "NO_DATA_READ -> Start line number = {0}, End Line Number = {1}", params);
            return "There was no data to collect. -> Start line number = " + startLineNumber + " , EndLineNumber = "
                    + endLineNumber;
        }
    }

    public String readDataFile(String fileUrl, int startLineNumber, int endLineNumber)
            throws IOException, ParseException {
        StringBuilder content = new StringBuilder();
        LOGGER.log(Level.INFO, "Attempting to read from url {0} directly", fileUrl);

        ClassLoader classLoader = this.getClass().getClassLoader();
        URL url = classLoader.getResource(fileUrl);
        String path = URLDecoder.decode(url.getPath(), "utf-8");
        System.out.println("Path: " + path);
            BufferedReader reader = new BufferedReader(
                new InputStreamReader(url.openStream()));

            String line;
            int currentLineNumber = 1;
            int secondCounter = 1;
            String headerLine = null;
            Object[] params = { fileUrl, startLineNumber, endLineNumber };
            LOGGER.log(Level.INFO, "Reading {0} from line {1} to {2}", params);
            while ((line = reader.readLine()) != null && currentLineNumber <= endLineNumber) {
                if (currentLineNumber == 1) {
                    headerLine = line;
                } else if (currentLineNumber >= startLineNumber) {
                    Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
                    calendar.add(Calendar.SECOND, secondCounter);

                    Object[] fields = line.split(",");
                    String dateField = (String) fields[1];
                    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
                    Date tempDate = dateFormat.parse(dateField);
                    Calendar tempCalendar = Calendar.getInstance();
                    tempCalendar.setTime(tempDate);
                    int month = tempCalendar.get(Calendar.MONTH);
                    if (month < calendar.get(Calendar.MONTH)) {
                        calendar.set(Calendar.MONTH, month);
                    }
                    String dateString = Utils.getDateString(calendar);
                    fields[1] = dateString;
                    fields[2] = dateString;
                    StringBuilder row = new StringBuilder();
                    for (int i = 0; i < fields.length; i++) {
                        row.append(fields[i]);
                        if (i < fields.length - 1) {
                            row.append(",");
                        }
                    }
                    content.append(row).append(System.lineSeparator());
                    secondCounter++;
                }
                currentLineNumber++;
            }
            if (content.length() > 0) {
                content.insert(0, System.lineSeparator())
                        .insert(0, headerLine);
            }
        return content.toString();
    }

    private void saveState(String parameterValue) {
        JSONObject state = new JSONObject();
        state.put(CollectorConfig.COLLECTOR_STATE_START_LINE_NUMBER, parameterValue);
        getStorageService().store(state.toString(), getCollectorConfig().getConfig(CollectorConfig.Configs.COLLECTOR_STATE));
        Object[] params = { getCollectorConfig().getConfig(CollectorConfig.Configs.COLLECTOR_STATE), parameterValue};
        LOGGER.log(Level.INFO, "State saved parameter - {0},. For next run reading line from - {1}", params);
    }

    private int getStartLineNumber() throws IOException {
        JSONObject state = getStorageService().getCollectorState();
        if (state == null) {
            return 0; // first line
        }

        if (state.has(CollectorConfig.COLLECTOR_STATE_START_LINE_NUMBER)) {
            return state.getInt(CollectorConfig.COLLECTOR_STATE_START_LINE_NUMBER);
        }

        return 0; // first line
    }

    public static void main(String[] args) {
        try {
            PaymentDataCollector collector = new PaymentDataCollector();
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

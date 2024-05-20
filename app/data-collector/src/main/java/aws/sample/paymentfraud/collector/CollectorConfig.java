package aws.sample.paymentfraud.collector;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.amazonaws.util.StringUtils;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.ssm.SsmClient;
import software.amazon.awssdk.services.ssm.model.GetParametersByPathRequest;
import software.amazon.awssdk.services.ssm.model.GetParametersByPathResponse;
import software.amazon.awssdk.services.ssm.model.Parameter;
import software.amazon.awssdk.services.ssm.model.ParameterType;
import software.amazon.awssdk.services.ssm.model.PutParameterRequest;
import software.amazon.awssdk.services.ssm.model.PutParameterResponse;

public class CollectorConfig {

    private static final SsmClient ssmClient = SsmClient.builder().region(Region.US_EAST_1).build();

    private static Map<String, String> configurations = new HashMap<String, String>();

    private final static Logger LOGGER = Logger.getLogger(CollectorConfig.class.getName());

    public CollectorConfig() {
        loadParametersFromSSM(CollectorConstants.SSM_KEY_COLLECTOR_CONFIG_NAMESPACE);
    }

    private void loadParametersFromSSM(String path) {
        // Create the request builder
        GetParametersByPathRequest.Builder requestBuilder = GetParametersByPathRequest.builder();

        // Set the path to retrieve parameters from
        requestBuilder.path(path).recursive(true);

        // Set a filter to limit results
        /*
         * requestBuilder.parameterFilters(
         * ParameterStringFilter.builder()
         * .key("tag:Name")
         * .option("Example")
         * .build()
         * );
         */

        // Set pagination configuration
        // requestBuilder.maxResults(10);

        GetParametersByPathRequest request = requestBuilder.build();
        GetParametersByPathResponse response = getSSMClient().getParametersByPath(request);

        if (response.parameters().size() > 0) {

            for (Parameter parameter : response.parameters()) {
                getConfiguration().put(parameter.name(), parameter.value());
            }
            // Parameter parameter = response.parameters().get(0);
            /*
             * System.out.println("value " + parameter.value());
             * return parameter.value();
             */
        }
    }

    public boolean updateParameter(String parameterName, String parameterValue) {
        ParameterType parameterType = ParameterType.STRING;

        // Create the PutParameterRequest
        PutParameterRequest request = PutParameterRequest.builder()
                //.name(CollectorConstants.SSM_KEY_SCAN_TIMESTAMP)
                .name(parameterName)
                .value(parameterValue)
                .type(parameterType)
                .overwrite(true)
                .build();

        // Update the parameter
        PutParameterResponse response = ssmClient.putParameter(request);
        Object[] params = {parameterName,parameterValue,response.version()};
        LOGGER.log(Level.INFO,"Parameter {0} updated to {1} with version {2} " , params);
        return response.sdkHttpResponse().isSuccessful();
    }

    private static SsmClient getSSMClient() {
        return ssmClient;
    }

    public String getConfig(String key) {
        return getConfiguration().get(StringUtils.trim(key));
    }

    public static void main(String[] args) {
        CollectorConfig config = new CollectorConfig();
        //config.loadParametersFromSSM(CollectorConstants.SSM_KEY_COLLECTOR_CONFIG_NAMESPACE);
        
        LocalDateTime currentDateTime = LocalDateTime.now();

        // Print the timestamp
        System.out.println("Timestamp: " + currentDateTime);
        //config.updateParameter("/fraud-detection-app/collector/config/scan_timestamp",currentDateTime.toString());
    }

    private Map<String, String> getConfiguration() {
        return configurations;
    }
}

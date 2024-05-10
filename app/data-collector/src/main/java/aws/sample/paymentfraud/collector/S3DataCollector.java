package aws.sample.paymentfraud.collector;

import java.util.List;

import org.springframework.stereotype.Component;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.S3Object;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.Message;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;

@Component
public class S3DataCollector implements DataCollector {
    Region region = Region.US_EAST_1;
    SqsClient sqsClient = SqsClient.builder()
            .region(Region.US_EAST_1)
            // .credentialsProvider(ProfileCredentialsProvider.create())
            .build();

    // Create an S3 client
    final AmazonS3 s3 = AmazonS3ClientBuilder.standard().withRegion(Regions.DEFAULT_REGION).build();

    @Override
    public String collect() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void processMessagesFromSQS(String queueUrl) {
        // List<Message> messages = new ArrayList<>();
        ReceiveMessageRequest receiveMessageRequest = ReceiveMessageRequest.builder()
                .queueUrl((String) queueUrl)
                .waitTimeSeconds(10)
                .maxNumberOfMessages(10)
                .build();

        List<Message> sqsMessages = sqsClient.receiveMessage(receiveMessageRequest)
                .messages();

        for (Message message : sqsMessages) {
            System.out.println(message.body());
            getObjectFromS3(message.body());
        }
    }

    private void getObjectFromS3(String path) {
        // Specify the bucket name and object key
        String bucketName = "my-bucket";
        String objectKey = "my-object";

        try {
            S3Object s3Object = s3.getObject(bucketName, objectKey);
            System.out.println("Retried S3 object - " + s3Object);
            /* S3ObjectInputStream s3is = o.getObjectContent();
            FileOutputStream fos = new FileOutputStream(new File(objectKey));
            byte[] read_buf = new byte[1024];
            int read_len = 0;
            while ((read_len = s3is.read(read_buf)) > 0) {
                fos.write(read_buf, 0, read_len);
            }
            s3is.close();
            fos.close(); */
        } catch (AmazonServiceException e) {
            System.err.println(e.getErrorMessage());
            System.exit(1);
        }
        System.out.println("Done!");

    }

}

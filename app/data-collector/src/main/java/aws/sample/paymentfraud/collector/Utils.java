package aws.sample.paymentfraud.collector;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.TimeZone;

public class Utils {

    public static final String DATE_FORMAT_NOW = "yyyy-MM-dd HH:mm:ss";

    public  static String now() {
        Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        return getDateString(calendar);
    }

    public static String getDateString(Calendar cal) {
        SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
        return sdf.format(cal.getTime());
    }
}

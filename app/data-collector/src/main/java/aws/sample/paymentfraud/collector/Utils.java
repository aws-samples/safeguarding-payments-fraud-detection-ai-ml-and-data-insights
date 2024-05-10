package aws.sample.paymentfraud.collector;

import java.text.SimpleDateFormat;
import java.util.Calendar;

public class Utils {

    public static final String DATE_FORMAT_NOW = "yyyy-MM-dd HH-mm-ss";

    public  static String now() {
        Calendar cal = Calendar.getInstance();
        return getDateString(cal);
    }

    public static String getDateString(Calendar cal) {
        SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
        return sdf.format(cal.getTime());
    }
}

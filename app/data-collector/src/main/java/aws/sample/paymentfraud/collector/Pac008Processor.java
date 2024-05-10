package aws.sample.paymentfraud.collector;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class Pac008Processor {

    private final static Logger LOGGER = Logger.getLogger(Pac008Processor.class.getName());

    private final static String xPathFile = "/aws/sample/paymentfraud/collector/config/pac_008_xpath.properties";
    private List<String> xPaths = null;
    private String header;

    public Pac008Processor() {
        try {
            InputStream in = Pac008Processor.class.getResourceAsStream(xPathFile);
            InputStreamReader streamReader = new InputStreamReader(in, StandardCharsets.UTF_8);
            BufferedReader reader = new BufferedReader(streamReader);
            StringBuffer headerBuffer = new StringBuffer();
            xPaths = new ArrayList<String>();
            for (String line; (line = reader.readLine()) != null;) {
                getxPaths().add(line.substring(0, line.indexOf("=")));
                headerBuffer.append("\"")
                        .append(line.substring(line.indexOf("=") + 1, line.length()))
                        .append("\",");
            }
            setHeader(headerBuffer.toString());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, e.getMessage(), e);
            e.printStackTrace();
        }
    }

    public String process(InputStream in) throws Exception {
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder db = dbf.newDocumentBuilder();
        Document doc = db.parse(in);
        doc.getDocumentElement().normalize();

        XPathFactory xpathfactory = XPathFactory.newInstance();
        XPath xpath = xpathfactory.newXPath();

        StringBuffer buffer = new StringBuffer();

        for (String xPath : xPaths) {
            XPathExpression expr = xpath.compile(xPath);
            Object result = expr.evaluate(doc, XPathConstants.NODESET);
            NodeList nodes = (NodeList) result;
            if (nodes.getLength() > 1) {
                Object[] params = { xpath };
                LOGGER.log(Level.SEVERE, "Found more than one text node for ", params);
                throw new Exception("Found more than one text node for " + xPath);
            }

            buffer.append("\"");
            Node node = nodes.item(0);
            if (node == null) {
                buffer.append("");
                buffer.append("\",");
                Object param[] = { xPath };
                LOGGER.log(Level.INFO, "Null value for node {0}", param);
                continue;
            }
            buffer.append(nodes.item(0).getNodeValue()); // Since this should be a leaf text node, We're only getting
                                                         // the first node here and don't expect other nodes to exist.
            buffer.append("\",");
        }
        return buffer.toString();
    }

    public static void main(String[] args) throws Exception {
        Pac008Processor pac008Processor = new Pac008Processor();
        String sampleInputXMLFile = "/data/pacs.008.xml";
        File inputXml = new File(sampleInputXMLFile);
        FileInputStream inputStream = new FileInputStream(inputXml);
        pac008Processor.process(inputStream);
    }

    private List<String> getxPaths() {
        return xPaths;
    }

    private void setHeader(String header) {
        this.header = header;
    }

    public String getHeader() {
        return header;
    }
}
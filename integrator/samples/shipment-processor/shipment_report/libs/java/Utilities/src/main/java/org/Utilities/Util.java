package org.Utilities;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jcraft.jsch.*;
import com.lowagie.text.*;
import com.lowagie.text.Font;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.*;
import com.lowagie.text.pdf.draw.LineSeparator;

import java.awt.*;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Util {

    private static final Color HEADER_COLOR = new Color(41, 128, 185);  // Professional blue
    private static final Color ACCENT_COLOR = new Color(52, 152, 219);  // Lighter blue
    private static final Color TABLE_HEADER_COLOR = new Color(236, 240, 241); // Light gray
    private static final Color ALTERNATE_ROW_COLOR = new Color(248, 249, 250); // Very light gray

    public static void main(String[] args) {
        aggregateShipments();
    }

    public static Map<String, String> aggregateShipments() {

        // Initialize database connection for local MySQL
        String url = "jdbc:mysql://mysql-com:24547/DEMO"; // Replace 'yourdb' with your database name
        String user = "user"; // Replace with your MySQL username if different
        String password = "password"; // Replace with your MySQL password
        String pdfFileName = "customer_shipments_" + System.currentTimeMillis() + ".pdf";

        try {
            java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, password);
            System.out.println("Database connected successfully.");

            String query = "SELECT\n" +
                    "  customer_id,\n" +
                    "  customer_name,\n" +
                    "  GROUP_CONCAT(DISTINCT shipment_id ORDER BY shipment_id ASC) AS shipment_ids,\n" +
                    "  GROUP_CONCAT(DISTINCT products_json ORDER BY shipment_id ASC) AS products_json\n" +
                    "FROM shipment_products\n" +
                    "GROUP BY customer_id, customer_name;";
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(query);

            Document document = new Document(PageSize.A4, 50, 50, 50, 50); // Better margins
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            PdfWriter writer = PdfWriter.getInstance(document, outputStream);
            // Add metadata
            document.addTitle("Customer Shipments Report");
            document.addSubject("Aggregated Shipment Information");
            document.addKeywords("shipments, customers, products");
            document.addAuthor("Your Company Name");
            document.addCreator("Shipment Management System");

            document.open();

            // Add document header with logo area and title
            addDocumentHeader(document);

            // JSON Parser
            ObjectMapper mapper = new ObjectMapper();

            // Track if this is the first customer (for spacing)
            boolean firstCustomer = true;

            Map<String, String> customerShipmentMap = new java.util.HashMap<>();
            // --- Loop through query results ---
            while (rs.next()) {
                String customerId = rs.getString("customer_id");
                String customerName = rs.getString("customer_name");
                String shipmentIds = rs.getString("shipment_ids");
                String productsJsonGroup = rs.getString("products_json");

                customerShipmentMap.put(customerId, customerName);

                // Add page break for subsequent customers (except the first)
                if (!firstCustomer) {
                    document.newPage();
                }
                firstCustomer = false;

                // Add customer section
                addCustomerSection(document, customerId, customerName, shipmentIds);

                // Add products table
                if (productsJsonGroup != null && !productsJsonGroup.trim().isEmpty()) {
                    addProductsTable(document, productsJsonGroup, mapper);
                }

                // Add summary section
                addCustomerSummary(document, productsJsonGroup, mapper);
            }

            // Add footer with generation date and page numbers
            addDocumentFooter(writer, document);

            // --- Close everything ---
            document.close();
            rs.close();
            stmt.close();
            conn.close();

            System.out.println("PDF generated: " + pdfFileName);

            // Upload to SFTP server
            uploadPdfToSFTP(document, outputStream);
            return customerShipmentMap;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private static void addDocumentHeader(Document document) throws DocumentException {
        // Main title
        Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 24, HEADER_COLOR);
        Paragraph title = new Paragraph("CUSTOMER SHIPMENTS REPORT", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        title.setSpacingAfter(10f);
        document.add(title);

        // Subtitle with date
        Font subtitleFont = FontFactory.getFont(FontFactory.HELVETICA, 12, Color.GRAY);
        Paragraph subtitle = new Paragraph("Generated on: " + new java.util.Date(), subtitleFont);
        subtitle.setAlignment(Element.ALIGN_CENTER);
        subtitle.setSpacingAfter(20f);
        document.add(subtitle);

        // Add a horizontal line
        LineSeparator line = new LineSeparator();
        line.setLineColor(HEADER_COLOR);
        line.setLineWidth(2);
        document.add(new Chunk(line));
        document.add(Chunk.NEWLINE);
    }

    private static void addCustomerSection(Document document, String customerId, String customerName, String shipmentIds)
            throws DocumentException {

        // Customer header with background
        Font customerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16, Color.WHITE);

        // Create a table for the customer header background
        PdfPTable headerTable = new PdfPTable(1);
        headerTable.setWidthPercentage(100);
        headerTable.setSpacingBefore(15f);
        headerTable.setSpacingAfter(10f);

        PdfPCell headerCell = new PdfPCell(new Phrase("Customer: " + customerName + " (ID: " + customerId + ")", customerFont));
        headerCell.setBackgroundColor(HEADER_COLOR);
        headerCell.setPadding(12f);
        headerCell.setBorder(Rectangle.NO_BORDER);
        headerTable.addCell(headerCell);

        document.add(headerTable);

        // Shipment information
        Font infoFont = FontFactory.getFont(FontFactory.HELVETICA, 11, Color.DARK_GRAY);
        Paragraph shipmentInfo = new Paragraph();
        shipmentInfo.add(new Chunk("Shipment IDs: ", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11)));
        shipmentInfo.add(new Chunk(shipmentIds, infoFont));
        shipmentInfo.setSpacingAfter(15f);
        document.add(shipmentInfo);
    }

    private static void addProductsTable(Document document, String productsJsonGroup, ObjectMapper mapper)
            throws DocumentException, IOException {

        // Products section header
        Font sectionFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, ACCENT_COLOR);
        Paragraph productsHeader = new Paragraph("PRODUCTS SUMMARY", sectionFont);
        productsHeader.setSpacingBefore(10f);
        productsHeader.setSpacingAfter(10f);
        document.add(productsHeader);

        // Create enhanced table
        PdfPTable table = new PdfPTable(3); // 3 columns: Product Code, Quantity, Subtotal
        table.setWidthPercentage(100);
        table.setSpacingBefore(5f);
        table.setSpacingAfter(15f);

        // Set column widths
        float[] columnWidths = {3f, 2f, 2f};
        table.setWidths(columnWidths);

        // Table headers with styling
        Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, Color.DARK_GRAY);

        addTableHeader(table, "Product Code", headerFont);
        addTableHeader(table, "Quantity", headerFont);
        addTableHeader(table, "Status", headerFont);

        // Parse and add product data
        List<Product> products = parseProducts(productsJsonGroup, mapper);
        boolean alternate = false;
        int totalQuantity = 0;

        Font cellFont = FontFactory.getFont(FontFactory.HELVETICA, 10);

        for (Product product : products) {
            Color rowColor = alternate ? ALTERNATE_ROW_COLOR : Color.WHITE;

            addTableCell(table, product.productCode, cellFont, rowColor, Element.ALIGN_LEFT);
            addTableCell(table, String.valueOf(product.qty), cellFont, rowColor, Element.ALIGN_CENTER);
            addTableCell(table, "✓ Shipped", cellFont, rowColor, Element.ALIGN_CENTER);

            totalQuantity += product.qty;
            alternate = !alternate;
        }

        // Add total row
        Font totalFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11);
        addTableCell(table, "TOTAL", totalFont, TABLE_HEADER_COLOR, Element.ALIGN_RIGHT);
        addTableCell(table, String.valueOf(totalQuantity), totalFont, TABLE_HEADER_COLOR, Element.ALIGN_CENTER);
        addTableCell(table, products.size() + " items", totalFont, TABLE_HEADER_COLOR, Element.ALIGN_CENTER);

        document.add(table);
    }

    private static void addTableHeader(PdfPTable table, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(TABLE_HEADER_COLOR);
        cell.setPadding(8f);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setBorder(Rectangle.BOTTOM);
        cell.setBorderWidth(1f);
        cell.setBorderColor(Color.GRAY);
        table.addCell(cell);
    }

    private static void addTableCell(PdfPTable table, String text, Font font, Color backgroundColor, int alignment) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(backgroundColor);
        cell.setPadding(6f);
        cell.setHorizontalAlignment(alignment);
        cell.setBorder(Rectangle.NO_BORDER);
        table.addCell(cell);
    }

    private static List<Product> parseProducts(String productsJsonGroup, ObjectMapper mapper) throws IOException {
        List<Product> allProducts = new ArrayList<>();

        if (productsJsonGroup == null || productsJsonGroup.trim().isEmpty()) {
            return allProducts;
        }

        String trimmed = productsJsonGroup.trim();

        // Handle multiple JSON arrays concatenated with commas
        if (trimmed.contains("],[")) {
            // Split by ],[ and reconstruct each JSON array
            String[] jsonArrays = trimmed.split("\\],\\[");

            for (int i = 0; i < jsonArrays.length; i++) {
                String jsonArray = jsonArrays[i];

                // Add missing brackets
                if (i == 0) {
                    // First element: add closing bracket
                    jsonArray += "]";
                } else if (i == jsonArrays.length - 1) {
                    // Last element: add opening bracket
                    jsonArray = "[" + jsonArray;
                } else {
                    // Middle elements: add both brackets
                    jsonArray = "[" + jsonArray + "]";
                }

                // Parse this JSON array
                List<Product> products = mapper.readValue(jsonArray, new TypeReference<List<Product>>() {
                });
                allProducts.addAll(products);
            }
        } else if (trimmed.startsWith("[")) {
            // Single JSON array
            allProducts = mapper.readValue(trimmed, new TypeReference<List<Product>>() {
            });
        } else {
            // Single JSON object
            Product product = mapper.readValue(trimmed, Product.class);
            allProducts.add(product);
        }

        return allProducts;
    }

    private static void addCustomerSummary(Document document, String productsJsonGroup, ObjectMapper mapper)
            throws DocumentException, IOException {

        if (productsJsonGroup == null || productsJsonGroup.trim().isEmpty()) {
            return;
        }

        List<Product> products = parseProducts(productsJsonGroup, mapper);

        // Summary box
        PdfPTable summaryTable = new PdfPTable(2);
        summaryTable.setWidthPercentage(50);
        summaryTable.setHorizontalAlignment(Element.ALIGN_RIGHT);
        summaryTable.setSpacingBefore(10f);

        Font summaryFont = FontFactory.getFont(FontFactory.HELVETICA, 10);
        Font summaryBoldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);

        // Total products
        addSummaryRow(summaryTable, "Total Products:", String.valueOf(products.size()), summaryFont, summaryBoldFont);

        // Total quantity
        int totalQty = products.stream().mapToInt(p -> p.qty).sum();
        addSummaryRow(summaryTable, "Total Quantity:", String.valueOf(totalQty), summaryFont, summaryBoldFont);

        // Unique product codes
        long uniqueProducts = products.stream().map(p -> p.productCode).distinct().count();
        addSummaryRow(summaryTable, "Unique Items:", String.valueOf(uniqueProducts), summaryFont, summaryBoldFont);

        document.add(summaryTable);
    }

    private static void addSummaryRow(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        PdfPCell labelCell = new PdfPCell(new Phrase(label, labelFont));
        labelCell.setBorder(Rectangle.NO_BORDER);
        labelCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        labelCell.setPadding(3f);

        PdfPCell valueCell = new PdfPCell(new Phrase(value, valueFont));
        valueCell.setBorder(Rectangle.NO_BORDER);
        valueCell.setHorizontalAlignment(Element.ALIGN_LEFT);
        valueCell.setPadding(3f);

        table.addCell(labelCell);
        table.addCell(valueCell);
    }

    private static void addDocumentFooter(PdfWriter writer, Document document) throws DocumentException {
        // This would typically be done with page events for proper footer placement
        // For simplicity, adding a final section
        document.add(Chunk.NEWLINE);

        LineSeparator line = new LineSeparator();
        line.setLineColor(Color.LIGHT_GRAY);
        document.add(new Chunk(line));

        Font footerFont = FontFactory.getFont(FontFactory.HELVETICA, 8, Color.GRAY);
        Paragraph footer = new Paragraph("This report was generated automatically by the Shipment Management System", footerFont);
        footer.setAlignment(Element.ALIGN_CENTER);
        footer.setSpacingBefore(10f);
        document.add(footer);
    }

    private static void uploadPdfToSFTP(Document document, ByteArrayOutputStream outputStream) throws Exception {
        String sftpHost = "ftp.com";
        String sftpUser = "user";
        String sftpPassword = "password123";
        int sftpPort = 22;
        String remoteFolderPath = "/reports";
        String remoteFileName = "customer_shipments_" + System.currentTimeMillis() + ".pdf";

        JSch jsch = new JSch();
        Session session = null;
        ChannelSftp channelSftp = null;

        try {
            session = jsch.getSession(sftpUser, sftpHost, sftpPort);
            session.setPassword(sftpPassword);

            java.util.Properties config = new java.util.Properties();
            config.put("StrictHostKeyChecking", "no");
            session.setConfig(config);

            session.connect();
            System.out.println("SFTP Session connected.");

            channelSftp = (ChannelSftp) session.openChannel("sftp");
            channelSftp.connect();
            System.out.println("SFTP Channel connected.");

            // Create/navigate to remote directory
            try {
                channelSftp.cd(remoteFolderPath);
            } catch (Exception e) {
                System.out.println("Remote folder doesn't exist, creating: " + remoteFolderPath);
                channelSftp.mkdir(remoteFolderPath);
                channelSftp.cd(remoteFolderPath);
            }

            // Ensure document is closed before getting bytes
            if (document.isOpen()) {
                document.close();
            }

            // Get the PDF content as byte array from the outputStream
            byte[] pdfBytes = outputStream.toByteArray();

            // Upload using InputStream
            ByteArrayInputStream inputStream = new ByteArrayInputStream(pdfBytes);
            channelSftp.put(inputStream, remoteFileName);

            System.out.println("PDF uploaded directly to: " + remoteFolderPath + "/" + remoteFileName);

        } catch (Exception e) {
            System.err.println("Direct SFTP upload failed: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (channelSftp != null && channelSftp.isConnected()) {
                channelSftp.disconnect();
            }
            if (session != null && session.isConnected()) {
                session.disconnect();
            }
        }
    }
}
// --- Data Models ---
class Product {
    public String productCode;
    public int qty;
}
// server.js - Updated with Dashboard Stats and Missing APIs
const express = require("express");
const mysql = require("mysql2/promise");
const cors = require("cors");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Database configuration
const dbConfig = {
  host: process.env.DB_HOST || "localhost",
  port: process.env.DB_PORT || 3300,
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "2045",
  database: process.env.DB_NAME || "pharmacy_database",
  connectionLimit: 10,
  acquireTimeout: 60000,
  timeout: 60000,
};

// Create connection pool
const pool = mysql.createPool(dbConfig);

// Test database connection
async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log("✅ Connected to MySQL database successfully on port 3300");
    connection.release();
  } catch (error) {
    console.error("❌ Database connection failed:", error.message);
  }
}

testConnection();

// Helper function to execute queries
async function executeQuery(query, params = []) {
  let connection;
  try {
    connection = await pool.getConnection();
    const [results] = await connection.execute(query, params);
    return results;
  } catch (error) {
    console.error("Database query error:", error.message);
    throw error;
  } finally {
    if (connection) connection.release();
  }
}

// Health check endpoint
app.get("/api/health", async (req, res) => {
  try {
    await executeQuery("SELECT 1");
    res.json({
      success: true,
      message: "Server and database are healthy",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: "Database connection failed",
      details: error.message,
    });
  }
});

// DASHBOARD STATS ROUTE
// DASHBOARD STATS ROUTE
app.get("/api/dashboard/stats", async (req, res) => {
  try {
    // Get total medicines
    const [totalMedicines] = await executeQuery(
      "SELECT COUNT(*) as count FROM product"
    );

    // Get medicines available (quantity > 0)
    const [medicinesAvailable] = await executeQuery(
      "SELECT COUNT(*) as count FROM product WHERE prod_quantity > 0"
    );

    // Get medicine shortage (quantity <= 10)
    const [medicineShortage] = await executeQuery(
      "SELECT COUNT(*) as count FROM product WHERE prod_quantity <= 10"
    );

    // Get total revenue from sales
    const [totalRevenue] = await executeQuery(
      "SELECT COALESCE(SUM(total_cost), 0) as revenue FROM sale"
    );

    // Get medicine groups (count of suppliers as proxy)
    const [medicineGroups] = await executeQuery(
      "SELECT COUNT(*) as count FROM supplier"
    );

    // Get total quantity of medicines sold
    const [qtyMedicinesSold] = await executeQuery(
      "SELECT COALESCE(SUM(prod_quantity), 0) as quantity FROM sale"
    );

    // Get invoices generated (total sales count)
    const [invoicesGenerated] = await executeQuery(
      "SELECT COUNT(*) as count FROM sale"
    );

    // Get total suppliers
    const [totalSuppliers] = await executeQuery(
      "SELECT COUNT(*) as count FROM supplier"
    );

    // Get total users (employees)
    const [totalUsers] = await executeQuery(
      "SELECT COUNT(*) as count FROM employee"
    );

    // Get total customers
    const [totalCustomers] = await executeQuery(
      "SELECT COUNT(*) as count FROM customer"
    );

    // Get most frequent item (most sold product)
    const [frequentItem] = await executeQuery(`
      SELECT p.prod_name, SUM(s.prod_quantity) as total_sold
      FROM sale s
      JOIN product p ON s.prod_id = p.prod_id
      GROUP BY s.prod_id, p.prod_name
      ORDER BY total_sold DESC
      LIMIT 1
    `);

    const stats = {
      inventoryStatus:
        medicineShortage.count > 5
          ? "Critical"
          : medicineShortage.count > 2
          ? "Warning"
          : "Good",
      revenue: totalRevenue.revenue || 0,
      medicinesAvailable: medicinesAvailable.count || 0,
      medicineShortage: medicineShortage.count || 0,
      totalMedicines: totalMedicines.count || 0,
      medicineGroups: medicineGroups.count || 0,
      qtyMedicinesSold: qtyMedicinesSold.quantity || 0,
      invoicesGenerated: invoicesGenerated.count || 0,
      totalSuppliers: totalSuppliers.count || 0,
      totalUsers: totalUsers.count || 0,
      totalCustomers: totalCustomers.count || 0,
      frequentItem: frequentItem ? frequentItem.prod_name : "None",
    };

    res.json({
      success: true,
      data: stats,
    });
  } catch (error) {
    console.error("Error fetching dashboard stats:", error);
    res.status(500).json({
      success: false,
      error: error.message,
      data: {
        inventoryStatus: "Unknown",
        revenue: 0,
        medicinesAvailable: 0,
        medicineShortage: 0,
        totalMedicines: 0,
        medicineGroups: 0,
        qtyMedicinesSold: 0,
        invoicesGenerated: 0,
        totalSuppliers: 0,
        totalUsers: 0,
        totalCustomers: 0,
        frequentItem: "Unknown",
      },
    });
  }
});

// PHARMACY ROUTES
app.get("/api/pharmacies", async (req, res) => {
  try {
    const pharmacies = await executeQuery(
      "SELECT * FROM pharmacy ORDER BY pharm_id"
    );
    const mappedPharmacies = pharmacies.map((p) => ({
      pharmacy_id: p.pharm_id,
      name: p.pharm_name,
      address: p.pharm_address,
      contact: p.pharm_contact,
    }));
    res.json(mappedPharmacies);
  } catch (error) {
    console.error("Error fetching pharmacies:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post("/api/pharmacies", async (req, res) => {
  try {
    const { name, address, contact } = req.body;
    if (!name) {
      return res
        .status(400)
        .json({ success: false, error: "Name is required" });
    }
    await executeQuery(
      "INSERT INTO pharmacy (pharm_name, pharm_address, pharm_contact) VALUES (?, ?, ?)",
      [name, address, contact]
    );
    res.json({ success: true, message: "Pharmacy added successfully" });
  } catch (error) {
    console.error("Error adding pharmacy:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put("/api/pharmacies/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { name, address, contact } = req.body;
    if (!name) {
      return res
        .status(400)
        .json({ success: false, error: "Name is required" });
    }
    await executeQuery(
      "UPDATE pharmacy SET pharm_name = ?, pharm_address = ?, pharm_contact = ? WHERE pharm_id = ?",
      [name, address, contact, id]
    );
    res.json({ success: true, message: "Pharmacy updated successfully" });
  } catch (error) {
    console.error("Error updating pharmacy:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete("/api/pharmacies/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await executeQuery("DELETE FROM pharmacy WHERE pharm_id = ?", [id]);
    res.json({ success: true, message: "Pharmacy deleted successfully" });
  } catch (error) {
    console.error("Error deleting pharmacy:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// BRANCH ROUTES
app.get("/api/branches", async (req, res) => {
  try {
    const branches = await executeQuery(`
      SELECT b.*, p.pharm_name as pharmacy_name 
      FROM branch b 
      LEFT JOIN pharmacy p ON b.pharm_id = p.pharm_id 
      ORDER BY b.brch_id
    `);
    const mappedBranches = branches.map((b) => ({
      branch_id: b.brch_id,
      pharmacy_id: b.pharm_id,
      name: b.brch_name,
      address: b.brch_address,
      contact: b.brch_contact,
      pharmacy_name: b.pharmacy_name,
    }));
    res.json(mappedBranches);
  } catch (error) {
    console.error("Error fetching branches:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post("/api/branches", async (req, res) => {
  try {
    const { pharmacy_id, name, address, contact } = req.body;
    if (!name || !pharmacy_id) {
      return res.status(400).json({
        success: false,
        error: "Name and pharmacy_id are required",
      });
    }
    await executeQuery(
      "INSERT INTO branch (pharm_id, brch_name, brch_address, brch_contact) VALUES (?, ?, ?, ?)",
      [pharmacy_id, name, address, contact]
    );
    res.json({ success: true, message: "Branch added successfully" });
  } catch (error) {
    console.error("Error adding branch:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put("/api/branches/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { pharmacy_id, name, address, contact } = req.body;
    await executeQuery(
      "UPDATE branch SET pharm_id = ?, brch_name = ?, brch_address = ?, brch_contact = ? WHERE brch_id = ?",
      [pharmacy_id, name, address, contact, id]
    );
    res.json({ success: true, message: "Branch updated successfully" });
  } catch (error) {
    console.error("Error updating branch:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete("/api/branches/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await executeQuery("DELETE FROM branch WHERE brch_id = ?", [id]);
    res.json({ success: true, message: "Branch deleted successfully" });
  } catch (error) {
    console.error("Error deleting branch:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// EMPLOYEE ROUTES
app.get("/api/employees", async (req, res) => {
  try {
    const employees = await executeQuery(`
      SELECT e.*, b.brch_name as branch_name 
      FROM employee e 
      LEFT JOIN branch b ON e.brch_id = b.brch_id 
      ORDER BY e.emp_id
    `);
    const mappedEmployees = employees.map((e) => ({
      employee_id: e.emp_id,
      branch_id: e.brch_id,
      name: e.emp_name,
      position: e.emp_position,
      email: e.emp_email,
      contact: e.emp_contact,
      address: e.emp_address,
      branch_name: e.branch_name,
    }));
    res.json(mappedEmployees);
  } catch (error) {
    console.error("Error fetching employees:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post("/api/employees", async (req, res) => {
  try {
    const { branch_id, name, position, email, contact, address, password } =
      req.body;
    if (!name || !branch_id) {
      return res.status(400).json({
        success: false,
        error: "Name and branch_id are required",
      });
    }
    await executeQuery(
      "INSERT INTO employee (brch_id, emp_name, emp_position, emp_email, emp_contact, emp_address, emp_password) VALUES (?, ?, ?, ?, ?, ?, ?)",
      [branch_id, name, position, email, contact, address, password]
    );
    res.json({ success: true, message: "Employee added successfully" });
  } catch (error) {
    console.error("Error adding employee:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put("/api/employees/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { branch_id, name, position, email, contact, address } = req.body;
    await executeQuery(
      "UPDATE employee SET brch_id = ?, emp_name = ?, emp_position = ?, emp_email = ?, emp_contact = ?, emp_address = ? WHERE emp_id = ?",
      [branch_id, name, position, email, contact, address, id]
    );
    res.json({ success: true, message: "Employee updated successfully" });
  } catch (error) {
    console.error("Error updating employee:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete("/api/employees/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await executeQuery("DELETE FROM employee WHERE emp_id = ?", [id]);
    res.json({ success: true, message: "Employee deleted successfully" });
  } catch (error) {
    console.error("Error deleting employee:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// PRODUCT ROUTES
app.get("/api/products", async (req, res) => {
  try {
    const products = await executeQuery(`
      SELECT p.*, s.supp_name as supplier_name 
      FROM product p 
      LEFT JOIN supplier s ON p.supp_id = s.supp_id 
      ORDER BY p.prod_id
    `);
    const mappedProducts = products.map((p) => ({
      product_id: p.prod_id,
      supplier_id: p.supp_id,
      name: p.prod_name,
      unit_price: p.prod_unit_price,
      quantity: p.prod_quantity,
      latest_expiry_date: p.prod_latest_expiry_date,
      supplier_name: p.supplier_name,
    }));
    res.json(mappedProducts);
  } catch (error) {
    console.error("Error fetching products:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post("/api/products", async (req, res) => {
  try {
    const { supplier_id, name, unit_price, quantity, latest_expiry_date } =
      req.body;
    if (!name) {
      return res
        .status(400)
        .json({ success: false, error: "Name is required" });
    }
    await executeQuery(
      "INSERT INTO product (supp_id, prod_name, prod_unit_price, prod_quantity, prod_latest_expiry_date) VALUES (?, ?, ?, ?, ?)",
      [supplier_id, name, unit_price, quantity, latest_expiry_date]
    );
    res.json({ success: true, message: "Product added successfully" });
  } catch (error) {
    console.error("Error adding product:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put("/api/products/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { supplier_id, name, unit_price, quantity, latest_expiry_date } =
      req.body;
    await executeQuery(
      "UPDATE product SET supp_id = ?, prod_name = ?, prod_unit_price = ?, prod_quantity = ?, prod_latest_expiry_date = ? WHERE prod_id = ?",
      [supplier_id, name, unit_price, quantity, latest_expiry_date, id]
    );
    res.json({ success: true, message: "Product updated successfully" });
  } catch (error) {
    console.error("Error updating product:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete("/api/products/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await executeQuery("DELETE FROM product WHERE prod_id = ?", [id]);
    res.json({ success: true, message: "Product deleted successfully" });
  } catch (error) {
    console.error("Error deleting product:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// SUPPLIER ROUTES
app.get("/api/suppliers", async (req, res) => {
  try {
    const suppliers = await executeQuery(
      "SELECT * FROM supplier ORDER BY supp_id"
    );
    const mappedSuppliers = suppliers.map((s) => ({
      supplier_id: s.supp_id,
      name: s.supp_name,
      contact: s.supp_contact,
      product_type: s.supp_product_type,
    }));
    res.json(mappedSuppliers);
  } catch (error) {
    console.error("Error fetching suppliers:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post("/api/suppliers", async (req, res) => {
  try {
    const { name, contact, product_type } = req.body;
    if (!name) {
      return res
        .status(400)
        .json({ success: false, error: "Name is required" });
    }
    await executeQuery(
      "INSERT INTO supplier (supp_name, supp_contact, supp_product_type) VALUES (?, ?, ?)",
      [name, contact, product_type]
    );
    res.json({ success: true, message: "Supplier added successfully" });
  } catch (error) {
    console.error("Error adding supplier:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put("/api/suppliers/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { name, contact, product_type } = req.body;
    await executeQuery(
      "UPDATE supplier SET supp_name = ?, supp_contact = ?, supp_product_type = ? WHERE supp_id = ?",
      [name, contact, product_type, id]
    );
    res.json({ success: true, message: "Supplier updated successfully" });
  } catch (error) {
    console.error("Error updating supplier:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete("/api/suppliers/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await executeQuery("DELETE FROM supplier WHERE supp_id = ?", [id]);
    res.json({ success: true, message: "Supplier deleted successfully" });
  } catch (error) {
    console.error("Error deleting supplier:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// CUSTOMER ROUTES
app.get("/api/customers", async (req, res) => {
  try {
    const customers = await executeQuery(
      "SELECT * FROM customer ORDER BY cust_id"
    );
    const mappedCustomers = customers.map((c) => ({
      customer_id: c.cust_id,
      name: c.cust_name,
      contact: c.cust_contact,
    }));
    res.json(mappedCustomers);
  } catch (error) {
    console.error("Error fetching customers:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post("/api/customers", async (req, res) => {
  try {
    const { name, contact } = req.body;
    if (!name) {
      return res
        .status(400)
        .json({ success: false, error: "Name is required" });
    }
    await executeQuery(
      "INSERT INTO customer (cust_name, cust_contact) VALUES (?, ?)",
      [name, contact]
    );
    res.json({ success: true, message: "Customer added successfully" });
  } catch (error) {
    console.error("Error adding customer:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put("/api/customers/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { name, contact } = req.body;
    await executeQuery(
      "UPDATE customer SET cust_name = ?, cust_contact = ? WHERE cust_id = ?",
      [name, contact, id]
    );
    res.json({ success: true, message: "Customer updated successfully" });
  } catch (error) {
    console.error("Error updating customer:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete("/api/customers/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await executeQuery("DELETE FROM customer WHERE cust_id = ?", [id]);
    res.json({ success: true, message: "Customer deleted successfully" });
  } catch (error) {
    console.error("Error deleting customer:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// SALES ROUTES
app.get("/api/sales", async (req, res) => {
  try {
    const sales = await executeQuery(`
      SELECT s.*, e.emp_name, c.cust_name as customer_name, p.prod_name as product_name 
      FROM sale s 
      LEFT JOIN employee e ON s.emp_id = e.emp_id 
      LEFT JOIN customer c ON s.cust_id = c.cust_id 
      LEFT JOIN product p ON s.prod_id = p.prod_id 
      ORDER BY s.sale_id DESC
    `);
    const mappedSales = sales.map((s) => ({
      sale_id: s.sale_id,
      employee_id: s.emp_id,
      customer_id: s.cust_id,
      product_id: s.prod_id,
      quantity: s.prod_quantity,
      total_cost: s.total_cost,
      status: s.status,
      payment_method: s.payment_method,
      receipt_num: s.recpt_number,
      emp_name: s.emp_name,
      customer_name: s.customer_name,
      product_name: s.product_name,
    }));
    res.json(mappedSales);
  } catch (error) {
    console.error("Error fetching sales:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post("/api/sales", async (req, res) => {
  try {
    const {
      employee_id,
      customer_id,
      product_id,
      quantity,
      total_cost,
      status,
      payment_method,
      receipt_num,
    } = req.body;

    if (!employee_id || !product_id || !quantity) {
      return res.status(400).json({
        success: false,
        error: "Employee ID, Product ID, and Quantity are required",
      });
    }

    await executeQuery(
      "INSERT INTO sale (emp_id, cust_id, prod_id, prod_quantity, total_cost, status, payment_method, recpt_number) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
      [
        employee_id,
        customer_id,
        product_id,
        quantity,
        total_cost,
        status || "completed",
        payment_method,
        receipt_num,
      ]
    );
    res.json({ success: true, message: "Sale added successfully" });
  } catch (error) {
    console.error("Error adding sale:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// RECEIPT ROUTES
app.get("/api/receipts", async (req, res) => {
  try {
    const receipts = await executeQuery(
      "SELECT * FROM receipt ORDER BY recpt_number"
    );
    const mappedReceipts = receipts.map((r) => ({
      receipt_number: r.recpt_number,
      pharm_name: r.pharm_name,
      sale_id: r.sale_id,
      prod_name: r.prod_name,
      prod_quantity: r.prod_quantity,
      total_amount: r.total_amount,
    }));
    res.json(mappedReceipts);
  } catch (error) {
    console.error("Error fetching receipts:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post("/api/receipts", async (req, res) => {
  try {
    const {
      receipt_number,
      pharm_name,
      sale_id,
      prod_name,
      prod_quantity,
      total_amount,
    } = req.body;
    if (!receipt_number) {
      return res
        .status(400)
        .json({ success: false, error: "Receipt number is required" });
    }
    await executeQuery(
      "INSERT INTO receipt (recpt_number, pharm_name, sale_id, prod_name, prod_quantity, total_amount) VALUES (?, ?, ?, ?, ?, ?)",
      [
        receipt_number,
        pharm_name,
        sale_id,
        prod_name,
        prod_quantity,
        total_amount,
      ]
    );
    res.json({ success: true, message: "Receipt added successfully" });
  } catch (error) {
    console.error("Error adding receipt:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put("/api/receipts/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { pharm_name, sale_id, prod_name, prod_quantity, total_amount } =
      req.body;
    await executeQuery(
      "UPDATE receipt SET pharm_name = ?, sale_id = ?, prod_name = ?, prod_quantity = ?, total_amount = ? WHERE recpt_number = ?",
      [pharm_name, sale_id, prod_name, prod_quantity, total_amount, id]
    );
    res.json({ success: true, message: "Receipt updated successfully" });
  } catch (error) {
    console.error("Error updating receipt:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete("/api/receipts/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await executeQuery("DELETE FROM receipt WHERE recpt_number = ?", [id]);
    res.json({ success: true, message: "Receipt deleted successfully" });
  } catch (error) {
    console.error("Error deleting receipt:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// ATTENDANCE ROUTES
app.get("/api/attendance", async (req, res) => {
  try {
    const attendance = await executeQuery(`
      SELECT a.*, e.emp_name 
      FROM attendance a 
      LEFT JOIN employee e ON a.emp_id = e.emp_id 
      ORDER BY a.attnd_id DESC
    `);
    const mappedAttendance = attendance.map((a) => ({
      attnd_id: a.attnd_id,
      emp_id: a.emp_id,
      date: a.date,
      check_in_time: a.check_in_time,
      check_out_time: a.check_out_time,
      emp_name: a.emp_name,
    }));
    res.json(mappedAttendance);
  } catch (error) {
    console.error("Error fetching attendance:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post("/api/attendance", async (req, res) => {
  try {
    const { emp_id, date, check_in_time, check_out_time } = req.body;
    if (!emp_id || !date) {
      return res.status(400).json({
        success: false,
        error: "Employee ID and date are required",
      });
    }
    await executeQuery(
      "INSERT INTO attendance (emp_id, date, check_in_time, check_out_time) VALUES (?, ?, ?, ?)",
      [emp_id, date, check_in_time, check_out_time]
    );
    res.json({ success: true, message: "Attendance added successfully" });
  } catch (error) {
    console.error("Error adding attendance:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put("/api/attendance/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { emp_id, date, check_in_time, check_out_time } = req.body;
    await executeQuery(
      "UPDATE attendance SET emp_id = ?, date = ?, check_in_time = ?, check_out_time = ? WHERE attnd_id = ?",
      [emp_id, date, check_in_time, check_out_time, id]
    );
    res.json({ success: true, message: "Attendance updated successfully" });
  } catch (error) {
    console.error("Error updating attendance:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete("/api/attendance/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await executeQuery("DELETE FROM attendance WHERE attnd_id = ?", [id]);
    res.json({ success: true, message: "Attendance deleted successfully" });
  } catch (error) {
    console.error("Error deleting attendance:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// SUPPLIER PRODUCT ROUTES
app.get("/api/supplier-products", async (req, res) => {
  try {
    const supplierProducts = await executeQuery(`
      SELECT sp.*, s.supp_name 
      FROM supplier_product sp 
      LEFT JOIN supplier s ON sp.supp_id = s.supp_id 
      ORDER BY sp.supp_pro_id
    `);
    const mappedSupplierProducts = supplierProducts.map((sp) => ({
      supp_pro_id: sp.supp_pro_id,
      supp_id: sp.supp_id,
      supp_prod_price: sp.supp_prod_price,
      updated_at: sp.updated_at,
      supp_name: sp.supp_name,
    }));
    res.json(mappedSupplierProducts);
  } catch (error) {
    console.error("Error fetching supplier products:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post("/api/supplier-products", async (req, res) => {
  try {
    const { supp_id, supp_prod_price } = req.body;
    if (!supp_id) {
      return res.status(400).json({
        success: false,
        error: "Supplier ID is required",
      });
    }
    await executeQuery(
      "INSERT INTO supplier_product (supp_id, supp_prod_price) VALUES (?, ?)",
      [supp_id, supp_prod_price]
    );
    res.json({ success: true, message: "Supplier product added successfully" });
  } catch (error) {
    console.error("Error adding supplier product:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put("/api/supplier-products/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { supp_id, supp_prod_price } = req.body;
    await executeQuery(
      "UPDATE supplier_product SET supp_id = ?, supp_prod_price = ?, updated_at = CURRENT_TIMESTAMP WHERE supp_pro_id = ?",
      [supp_id, supp_prod_price, id]
    );
    res.json({
      success: true,
      message: "Supplier product updated successfully",
    });
  } catch (error) {
    console.error("Error updating supplier product:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete("/api/supplier-products/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await executeQuery("DELETE FROM supplier_product WHERE supp_pro_id = ?", [
      id,
    ]);
    res.json({
      success: true,
      message: "Supplier product deleted successfully",
    });
  } catch (error) {
    console.error("Error deleting supplier product:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error(error.stack);
  res.status(500).json({ success: false, error: "Something went wrong!" });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, error: "Endpoint not found" });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 API available at http://localhost:${PORT}/api`);
  console.log(`🏥 Health check: http://localhost:${PORT}/api/health`);
});

module.exports = app;

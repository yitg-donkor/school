// server.js - Fixed with correct column names and response formats
const express = require("express");
const mysql = require("mysql2/promise");
const cors = require("cors");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 3000; // Node.js HTTP server port

// Middleware
app.use(cors());
app.use(express.json());

// Database configuration - UPDATED FOR YOUR MYSQL PORT
const dbConfig = {
  host: process.env.DB_HOST || "localhost",
  port: process.env.DB_PORT || 3300, // YOUR MySQL port
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "2045", // Add your MySQL password
  database: process.env.DB_NAME || "pharmacy_database", // Add your MySQL database name
  connectionLimit: 10, // Connection pool limit
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
    console.error("Check your MySQL server, credentials, and database name");
  }
}

// Test connection on startup
testConnection();

// Helper function to execute queries with better error handling
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

// Add a health check endpoint
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

// PHARMACY ROUTES
app.get("/api/pharmacies", async (req, res) => {
  try {
    const pharmacies = await executeQuery(
      "SELECT * FROM pharmacy ORDER BY pharm_id"
    );
    // Map to match Flutter column expectations
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

    // Validate required fields
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
    // Map to match Flutter column expectations
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
    // Map to match Flutter column expectations
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
    // Map to match Flutter column expectations
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
    // Map to match Flutter column expectations
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
    // Map to match Flutter column expectations
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
    // Map to match Flutter column expectations
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

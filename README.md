# Hospital Database Design (Excel → MySQL)

## 📌 Project Overview
This project focuses on **database design and data modeling** for a hospital management system.

The original dataset was provided in **Excel format**, which contained:
- Redundant records
- Repeated information
- Poor structure for scalable querying

To solve this, the data was redesigned into a **normalized MySQL relational database** using **ER modeling principles**.

---

## 📐 ER Diagram
The ER diagram represents:
- Logical entity separation
- Primary Key – Foreign Key relationships
- One-to-many relationships
- Normalized schema to remove redundancy

![hospital_er_daigram](https://github.com/user-attachments/assets/0dcea397-6412-42bd-a4de-f090d0d10b49)


---

## 🏗 Database 

### Entities Included
- **Departments**
- **Doctors**
- **Patients**
- **Appointments**
- **Prescriptions**
- **Bills**
- **Lab Reports**

Each entity is connected using **foreign keys**, ensuring data consistency and integrity.

---

## 🔐 Data Integrity & Business Rules

### Constraints
- CHECK constraints for gender and appointment status
- Foreign key constraints across all related tables

### Trigger
- Prevents appointments from being scheduled in the past
- Prevents doctors from being double-booked at the same time

### Stored Procedures
- Role-based patient data access (senior vs junior doctors)
- Monthly department-wise revenue reporting

---

## 🔄 Data Migration Process
1. Load Excel data into a staging table
2. Identify redundant and unnecessary columns
3. Split data into normalized entities
4. Insert cleaned data into relational tables
5. Enforce constraints and relationships

---

## ✅ Key Benefits
- Eliminates data redundancy
- Improves query performance
- Ensures data integrity
- Scalable and analytics-ready design
- Real-world hospital workflow modeling

---

## 🧠 Concepts Used
- ER Modeling
- Normalization
- Primary & Foreign Keys
- Constraints
- Triggers
- Stored Procedures
- Relational Database Design

---

##  Author
**Rahul Patel**  
B.Tech Student | Aspiring Data Analyst / Data Engineer  

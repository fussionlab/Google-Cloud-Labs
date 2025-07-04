# 🚀 **Migrate MySQL Data to Cloud SQL using Database Migration Service: Challenge Lab || GSP351**  
[![Open Lab](https://img.shields.io/badge/Open-Lab-brown?style=for-the-badge&logo=google-cloud&logoColor=white)](https://www.cloudskillsboost.google/focuses/20393?parent=catalog)  

---

## ⚠️ **Important Notice**  
This guide is crafted to elevate your learning experience during this lab. Carefully follow each step to grasp the concepts fully. Ensure compliance with **Qwiklabs** and **YouTube** policies while using this guide.  

---

## **1️⃣ Enable APIs** 
1. **Database Migration API**
2. **Service Networking API**

## **2️⃣ Connect to the MySQL Interactive Console**  

To connect to the MySQL interactive console, follow these steps:  

1. Open your terminal and execute the following command:  
   ```bash
   mysql -u admin -p
   ```  

2. When prompted for the password, enter:  
   ```bash
   changeme
   ```  

---

## **🛠3️⃣ Update Records in the Database**  

Once connected to the MySQL console:  

1. Switch to the `customers_data` database:  
   ```sql
   use customers_data;
   ```  

2. Update the `gender` field for a specific record using the following SQL command:  
   ```sql
   update customers set gender = 'FEMALE' where addressKey = 934;
   ```  

---

## 🎉 **Congratulations! You've Successfully Completed the Lab!** 🏆  

---

<div align="center" style="padding: 5px;">
  <h3>📱 Join the Arcade Crew Community</h3>
  
  <a href="https://t.me/arcadecrewupdates">
    <img src="https://img.shields.io/badge/Join-Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram">
  </a>
  &nbsp;
  <a href="https://www.instagram.com/arcade_crew/">
    <img src="https://img.shields.io/badge/Follow-Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white" alt="Instagram">
  </a>
  &nbsp;
  <a href="https://www.youtube.com/@arcade_creww?sub_confirmation=1">
    <img src="https://img.shields.io/badge/Subscribe-Arcade%20Crew-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="YouTube Channel">
  </a>
  &nbsp;
  <a href="https://www.linkedin.com/in/arcadecrew/">
    <img src="https://img.shields.io/badge/LINKEDIN-Arcade%20Crew-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn">
  </a>
</div>

---

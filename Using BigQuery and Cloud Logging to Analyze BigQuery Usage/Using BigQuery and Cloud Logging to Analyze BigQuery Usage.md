# 🌐 [Using BigQuery and Cloud Logging to Analyze BigQuery Usage || GSP617](https://www.cloudskillsboost.google/focuses/6100?parent=catalog)

--- 

🎥 Watch the full video walkthrough for this lab:  
[![YouTube Solution](https://img.shields.io/badge/YouTube-Watch%20Solution-red?style=flat&logo=youtube)](https://youtu.be/55LqL1oEYrY)

---
## ⚠️ **Important Note:**
This guide is provided to support your educational journey in this lab. Please open and review each step of the script to gain full understanding. Be sure to follow the terms of Qwiklabs and YouTube’s guidelines as you proceed.

---

## 🚀 Steps to Perform

Run in Cloudshell:  

```
bq mk bq_logs
bq query --use_legacy_sql=false "SELECT current_date()"
```
```
resource.type="bigquery_resource"
protoPayload.methodName="jobservice.jobcompleted"
```
### Sink name: `JobComplete`

```bash
curl -LO raw.githubusercontent.com/ArcadeCrew/Google-Cloud-Labs/refs/heads/main/Using%20BigQuery%20and%20Cloud%20Logging%20to%20Analyze%20BigQuery%20Usage/arcadecrew.sh

sudo chmod +x arcadecrew.sh

./arcadecrew.sh
```
---

### 🏆 Congratulations! You've completed the Lab! 🎉

---

<div align="center" style="padding: 5px;">
  <h3>📱 Join the Arcade Crew Community</h3>

  <a href="https://whatsapp.com/channel/0029VbAiEFzAe5VikdanX42e">
    <img src="https://img.shields.io/badge/Join-WhatsApp-25D366?style=for-the-badge&logo=whatsapp&logoColor=white" alt="WhatsApp Channel">
  </a>
  &nbsp;
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

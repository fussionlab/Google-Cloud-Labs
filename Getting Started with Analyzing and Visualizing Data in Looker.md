# 🚀 **Getting Started with Analyzing and Visualizing Data in Looker**  
[![Open Lab](https://img.shields.io/badge/Open-Lab-brown?style=for-the-badge&logo=google-cloud&logoColor=blue)](https://www.cloudskillsboost.google/focuses/25305?parent=catalog) 
---

## ⚠️ **Important Notice**  
This guide is designed to enhance your learning experience during this lab. Please review each step carefully to fully understand the concepts. Ensure you adhere to **Qwiklabs** and **YouTube** policies while following this guide.  

---

## Task 1: Single Value Visualization (`Average Elevation`)
```
explore: +airports { 
    query: ArcadeCrew_Task1 {
      measures: [average_elevation]
    }
  }
```

- **Explore** → **FAA** → **Airports**
- Customize Visualization:
  - Select **Single Value**
  - Set **Value Format**: `0.00`
  - Modify **Value Color** and **Title**
- Save to **New Dashboard** → **"Airports"**

## Task 2: Bar Chart (`Average Elevation by Facility Type`)
```
explore: +airports {
    query: ArcadeCrew_Task2 {
      dimensions: [facility_type]
      measures: [average_elevation, count]
  }
}
```

- **Explore** → **FAA** → **Airports**
- Set **Row Limit**: `5`
- Customize Visualization:
  - Select **Bar Chart**
  - Enable **Value Labels**
  - Rename **Axes** and set **Value Format**: `0.00`
- Save to **Existing Dashboard** → **"Airports"**

## Task 3: Line Chart (`Number of Flights Cancelled Each Week in 2004`)
```
explore: +flights {
    query: ArcadeCrew_Task3 {
      dimensions: [depart_week]
      measures: [cancelled_count]
      filters: [flights.depart_date: "2004"]
  }
}
```

- **Explore** → **FAA** → **Flights**
- Customize Visualization:
  - Select **Line Chart**
  - Set **Filled Point Style**
  - Add **Reference Line**
- Save to **New Dashboard** → **"Airports and Flights"**

## Task 4: Line Chart (`Number of Flights by Distance Tier in 2003`)
```
explore: +flights {
    query: ArcadeCrew_Task4 {
      dimensions: [depart_week, distance_tiered]
      measures: [count]
      filters: [flights.depart_date: "2003"]
  }
}
```

- **Explore** → **FAA** → **Flights**
- Customize Visualization:
  - Select **Stacked Line Chart**
  - Enable **Overlay Series Positioning**
- Save to **Existing Dashboard** → **"Airports and Flights"**
  
---

## 🎉 **Congratulations! Lab Completed Successfully!** 🏆  

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

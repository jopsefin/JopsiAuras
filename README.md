# JopsiAuras

**JopsiAuras** is a lightweight World of Warcraft addon designed primarily for Warlocks to track essential combat and raid readiness warnings, alongside handy quality-of-life utilities for all classes.

---

## ✨ Features

### 🔮 Warlock Warnings
Never get caught unprepared before a pull again. Each warning features a subtle pulsing animation and can be individually toggled and customized:

* **Summon Pet Warning**: Alerts you when your demon is missing or dead (automatically hides while mounted, on a flight path, in a vehicle, or dead). Dynamically uses the Felguard icon when playing Demonology.
* **Passive Pet Warning**: Alerts you if your summoned pet is sitting in Passive stance.
* **Soulstone Warning**: Alerts you out of combat when you are in a Raid and your Soulstone is off cooldown so you remember to Soulstone a healer.
  * *Optional:* Can be toggled to also show outside of raids.
* **Healthstone Warning**: Alerts you when you are out of Healthstones (supports both standard **Healthstone** and **Demonic Healthstone** from Pact of Gluttony).
  * *Optional:* Can be configured to show only out of combat (default) or during combat as well.

### 🎨 Customization & Layout
* **Drag-and-Drop Positioning**: While the `/ja` options menu is open, all active warning frames are highlighted and unlocked so you can drag them anywhere on your screen.
* **Display Modes**: Show the icon, the warning text, or both for each individual alert (auto-centers dynamically).
* **Custom Alert Text**: Edit the warning message for every alert to say whatever you want.
* **Typography & Scaling**: Choose from built-in WoW fonts (*Friz Quadrata*, *Arial*, *Morpheus*, *Skurri*) or any custom font registered via **LibSharedMedia-3.0**. Adjust the font size (`10`-`100`), and warning icons will automatically scale to match.

### 🛠️ Quality-of-Life Utilities
* **Auto-Repair**: Automatically repairs all gear when visiting a repair vendor and prints the total repair cost in chat.
* **Auto-Sell Junk**: Automatically sells all poor-quality (grey) items when opening a merchant window and prints the gold earned.
* **Auction House Filter**: Option to automatically enable the *"Current Expansion Only"* filter whenever you open the Auction House.

---

## 💬 Commands & Configuration

Type the following slash command in-game to open the configuration menu and unlock frames for moving:

```text
/ja
```

* Closing the options window (via the `X` button, pressing `ESC`, or typing `/ja` again) automatically locks the warning frames in place.
* Click **Reset Defaults** at the bottom of the options window at any time to restore default warning texts, fonts, and screen positions.

---

## 📦 Installation

1. Download the latest release or clone this repository.
2. Extract the `JopsiAuras` folder into your World of Warcraft addons directory:
   ```text
   World of Warcraft\_retail_\Interface\AddOns\JopsiAuras
   ```
3. Ensure the folder is named `JopsiAuras` and contains `JopsiAuras.toc` and `JopsiAuras.lua` directly inside it.
4. Restart World of Warcraft or type `/reload` in-game.

---

## 👤 Author

* **Jopsi**


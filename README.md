# Calculator App in Flutter

### Overview

This is a basic calculator application built using Flutter. It features a modern user interface with animated splash screen, basic arithmetic operations, and a history feature for tracking previous calculations. The app stores calculation history using the Hive database, allowing users to revisit their past calculations.

### Features

* **Splash Screen with Animated Text** : The app starts with a splash screen that features a unique character-wise animated text effect. The screen displays the app name "Calculator" followed by "Made by Rahul Gupta," adding a personal touch and a polished introduction to the app.
* **Basic Arithmetic Operations:** Perform basic arithmetic operations like addition, subtraction, multiplication, and division.
* **Calculation History:** Saves up to 10 previous calculations in local storage using Hive, allowing users to view or clear their history.
* **Responsive UI:** Scrollable result display that adjusts based on the length of the expression and result.

### Project Structure

* **main.dart:** The entry point of the app that initializes Hive for local storage and sets up the splash screen and home screen.
* **calculate.dart:** Contains the logic for performing arithmetic operations following the BODMAS rules.
* **colors.dart:** Defines the color scheme used throughout the app for a consistent and visually appealing interface.

### Dependenices

* **Flutter:** The framework used to build the application.
* **Hive:** A lightweight and fast key-value database used for storing the calculation history.
* **animated_text_kit:** Provides the animated text effects for the splash screen.
* **path_provider:** Used to find the correct directory for storing the Hive database files.

### Installation

1. Clone the Repository

   ```
   git clone https://github.com/rahul-gupta-2004/calculator-app
   ```
2. Install Dependencies

   ```
   flutter pub get
   ```
3. Run the App

   ```
   flutter run
   ```

### Usage

* **Clear (C):** Clears the current input and resets the calculator for a new calculation.
* **Backspace (⌫):** Deletes the last character in the current input.
* **History:** View previous calculations by tapping the history icon in the top right corner. You can clear all history from this screen as well.
* **Arithmetic Operations:** Supports addition (+), subtraction (-), multiplication (×), and division (÷).

### UI Design

For a preview of the UI design, check out the [design on Figma].(https://www.figma.com/proto/EMtNs3em3xoi6XJ83ZaChl/ios-calculator-design?node-id=0-1&t=81uuAFmhPQnz6EHL-1)

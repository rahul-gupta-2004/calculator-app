// Function to perform the BODMAS calculation with error handling
double? bodmasCalculation(String expression) {
  // Return null if the expression is empty
  if (expression.isEmpty) return null;

  // Remove commas from the expression for calculation purposes
  expression = expression.replaceAll(',', '');

  // List to store individual tokens (numbers and operators)
  List<String> tokens = [];
  String number = '';

  // Loop through the expression to separate numbers and operators
  for (int i = 0; i < expression.length; i++) {
    // If the current character is an operator, add the number and operator to tokens
    if ('+-×÷'.contains(expression[i])) {
      tokens.add(number);
      tokens.add(expression[i]);
      number = ''; // Reset the number string
    } else {
      // Accumulate the digits for the current number
      number += expression[i];
    }
  }
  // Add the last number to the tokens list
  tokens.add(number);

  // Handle multiplication and division first according to BODMAS rules
  for (int i = 0; i < tokens.length; i++) {
    // Check for multiplication or division operators
    if (tokens[i] == '×' || tokens[i] == '÷') {
      // Parse the numbers around the operator
      double left = double.tryParse(tokens[i - 1]) ?? 0;
      double right = double.tryParse(tokens[i + 1]) ?? 0;
      double result;

      // Perform multiplication or division based on the operator
      if (tokens[i] == '×') {
        result = left * right;
      } else {
        // Handle division by zero error by returning null
        if (right == 0) return null;
        result = left / right;
      }

      // Replace the operator and the numbers with the result in the tokens list
      tokens[i - 1] = result.toString();
      tokens.removeAt(i); // Remove the operator
      tokens.removeAt(i); // Remove the right operand
      i--; // Adjust index after removal
    }
  }

  // Handle addition and subtraction after multiplication and division
  double result = double.tryParse(tokens[0]) ?? 0;
  for (int i = 1; i < tokens.length; i += 2) {
    // Operator is expected at odd indices
    String operator = tokens[i];
    // The number following the operator
    double nextValue = double.tryParse(tokens[i + 1]) ?? 0;

    // Perform addition or subtraction based on the operator
    if (operator == '+') {
      result += nextValue;
    } else if (operator == '-') {
      result -= nextValue;
    }
  }

  // Return the final result of the calculation
  return result;
}

// Function to format the result to include commas in Indian number format
String formatResult(double result) {
  // Check if the result is an integer
  if (result % 1 == 0) {
    // Convert the integer result to a string
    String integerPart = result.toInt().toString();
    String numberWithCommas = '';
    int commaCount = 0;

    // Loop to insert commas according to Indian numbering format
    for (int i = integerPart.length - 1; i >= 0; i--) {
      numberWithCommas = integerPart[i] + numberWithCommas;
      commaCount++;
      // Insert a comma after every three digits
      if (commaCount == 3 && i > 0) {
        numberWithCommas = ',$numberWithCommas';
        commaCount = 0;
      }
    }
    return numberWithCommas; // Return the formatted string
  } else {
    // Return the result as a string with up to four decimal places
    return result.toStringAsFixed(4);
  }
}

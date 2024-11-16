# FormulaBuilder

Takes a string input and converts it into a function that can be safely run. The function takes just one parameter: a map of variables.

## Variables

The map of variables allows a user to define unknowns in their provided formula. This means the function is reusable for a changing state without reinterpreting the original string.

## Safety

We can ensure that no mailicous functions are run, as only the functions provided by this dependency, and any functions provided by the developer are permitted in the formula. Any other attempts at calling functions will not work.

## Extensibility

By setting the config for this dependency, a developer may provide additional functions and operations for a user to include in their formula. If there is going to be a lot of common formulae or repeatedly use parts of a formula, then a developer may see fit to add a function that handles this for a user to simplify their input.

## Example usage

This dependency was originally made to interpret formulae for a trading system. A trader would provide a collection of formulae to act together as a strategy, and the system would provide a list of expected variables to the formulae that allowed the trader access to information which would inform their next submission. There were several additional functions that were able to do more complex mathematical equations and return them within a formula, to simplify the work the traders had to do in each formula.

# Application Setup Notes

The project's root directory is located at `/Users/tam0013/Documents/git/galaxyGame/galaxy_game`. This directory contains the application's source code.

To run the application, follow these steps:

1. Navigate to the project's root directory:
```
cd /Users/tam0013/Documents/git/galaxyGame/galaxy_game
```

2. Install the required dependencies by running the following command:
```
bundle install
```

3. To run the test suite, use the following command:
```
rspec
```

This will execute all the tests within the project.

Note that the test `expect(atmosphere.co2_percentage).to be < initial_co2` in the `terraforming_integration_spec.rb` file is failing. The issue might be related to the initial CO2 percentage not being updated correctly during the simulation or the atmospheric contribution of the life forms not being calculated correctly. To investigate further, logging or print statements could be added to track the CO2 percentage and the atmospheric contribution of the life forms before and after the simulation.
# galaxyGame
Rails Game similar to SimEarth

## Versions
- Rails 7.0.8.4
- Ruby 3.2
- Postgress 16

## Testing and Quality Control 
The test suite includes rspec, capybara, selnium, simplecov, CircleCI, and code climate. 
Javascript is difficult to test by iteself.  To run tests locally uncomment the selenium docker container and adjust capybara setups. 
`RAILS_ENV=test bundle exec rspec` this helps to ensure that all gems are loaded appropriately and you do not get the `shoulda error`.  

### Troubleshooting
Using Chatgpt to generate some of this code based on the original java version. 
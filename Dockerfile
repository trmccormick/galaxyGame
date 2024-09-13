# Use the official Ruby image
FROM ruby:3.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Set the working directory
WORKDIR /home/galaxy_game

# Install Bundler
RUN gem install bundler

# Copy the Gemfile and Gemfile.lock into the container
COPY ./galaxy_game/Gemfile ./galaxy_game/Gemfile.lock /home/galaxy_game/

# Install gems
RUN bundle install

# Copy the rest of the application code into the container
ADD ./galaxy_game /home/galaxy_game

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn
RUN yarn install --check-files

# Expose port 3000 to the Docker host
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]

# Overview

  SAM is a an application that uses social identity to provide access to physical spaces.  Through a simple RESTful API, SAM provides CRUD access on a  generic set of objects that represent both physical devices, social identities, and information about granting access to one from the other.

  This application is a complement to the main SAM application. It demoes an OAuth Client that interacts with the SAM's OAuth server to obtain a bearer token.
Same with SAM API, it is written primarily in [CoffeeScript](http://coffeescript.org/), a language that compiles into Javascript. It runs on [node.js](http://nodejs.org/) using several supporting open-source modules.  

  The application is intended to run locally for testing purposes.

# Configuration
  All Configuration is bundled in a single file, namely src/config.coffee.
  This list will explain the various options.  Most things will __not__ need to be modified during development.

*   **use_ssl** creates a secure server if true. Note that in heroku this is NOT needed.
*   **pi** all setting related to the brivo pi interaction
    *   **api_url** the BrivoPi root endpoint
   
# Local Deployment
1. Ensure you have coffescript installed.  If you do not, run command: sudo npm install -g coffee-script
2. Install node dependencies:

```
  npm install
```

3. Update the config.coffee file pointing to your host and port (defaults are 'localhost' and 3000)
   You can also add a custom server by uncommenting the custom environment section, and setting the host for the samUrl.
   Then add the custom environment to the list of available environments.
4. Run the application using

```
  npm start
```

5. If you want the app to open your browser and point it to the OAuth Client page, just pass the -o option to the command line

```
  coffee app.coffee -o
```
 
6. Done!

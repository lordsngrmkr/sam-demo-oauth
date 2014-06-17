# Overview

  SAM is a an application that uses social identity to provide access to physical spaces.  Through a simple RESTful API, SAM provides CRUD access on a  generic set of objects that represent both physical devices, social identities, and information about granting access to one from the other.

  This application is a complement to the main SAM application. It demoes an OAuth Client that interacts with the SAM's OAuth server to obtain a bearer token.
Same with SAM API, it is written primarily in [CoffeeScript](http://coffeescript.org/), a language that compiles into Javascript. It runs on [node.js](http://nodejs.org/) using several supporting open-source modules.  

  The application is intended to run locally for testing purposes.

# Configuration
  All Configuration is bundled in a single file, namely src/config.coffee.
  This list will explain the various options.  Most things will __not__ need to be modified during development.
  The only things that you may need to change are related to the oauth demo client, at the module.exports section:

* **environment** set current environment to either development or production.
* **host** the host where the oauth demo app will run. Usually the default value 'localhost' is OK.
* **port** the port number used by the oauth demo app.

  If you want to add a custom environment for testing, then please modify the custom section (and uncomment its block).
  Do not modify existing ones since they are standard.
  That section contains the following properties:

* **commonName** the name of the environment. Leave the default value ('custom') unless multiple custom environments are required.
* **samUrl** the URL of the brivo API host in the form of 'https://<HOST>:<PORT>'
* **type** the environment type. Usually the default ('testing') is OK.

  Then add the 'custom' string in the list of environments (list method on module.exports)
   
# Local Deployment
1. Ensure you have coffescript installed.  If you do not, run command: sudo npm install -g coffee-script
2. Install node dependencies:

```
  npm install
```

3. Update the config.coffee file pointing to your host and port (defaults are 'localhost' and 3003)
   You can also add a custom server by uncommenting the custom environment section, and setting the host for the samUrl. See configuration for details.
4. Run the application using

```
  npm start
```

5. If you want the app to open your browser and point it to the OAuth Client page, just pass the -o option to the command line

```
  coffee app.coffee -o
```
 
6. Done!

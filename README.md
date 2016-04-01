madura-dbloader
===============

This is an ant task that will run multiple sql files using potentially multiple schemas. It is intended for use during development rather than production for those times when DBAs release a new load of database scripts and you need to update your local database. Normally you would use the <courier>sql</courier> task but that does not handle multiple schemas as well as this.

So, if you have a database that spans multiple schemas and you need to run multiple scripts against them all then MaduraDBLoad will help.

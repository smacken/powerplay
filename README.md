powerplay
=========

Psake based build automation scaffolding

Build steps are created with a series of 'Tasks'. Each task represents a step in the deployment process and can be chained together to represent complex processes.
Tasks can be dependent upon one another.

Powerplay creates a starting point and scaffolding in setting up build automation for a project.
A project will have a set of properties relating to tasks which can allow for an abstracted configuration on a project by project basis. Different configurations could be used per different environments.

Client-side (JavaScript) build automation leveages Grunt. See grunt.js.
This allows for concat, minification, test etc of client-side scripts.

- [x] web page for seeing status


- [x] api to set desired capacity
- [x] command to scale
- [x] save tf state somewhere
- [x] run minecraft as a service
- [x] save game to s3 on exit
- [x] scale down when nobody connected
- [x] spot instances

# near future

- api service to see status and activate server
  + token validation
  + get server status
  + activate server

- web page to view status and enable server
  + hosting via S3 and cloud-front
  + implicit flow log-in
  + page to view status
  + button / input to modify server status

# Longer

- how to have multiple server configurations
  + different mods
  + snapshots

- Multiple different servers running in parallel

- keep track of hosting costs via UI
- allow donations towards hosting costs


# Strategy

- setup a boilerplate react SPA with Auth0 to just generate a token
- setup a simple serverless API and implement token validation
- setup SPA hosting
- implement apis for status and scaling
- implement UI for status and scaling

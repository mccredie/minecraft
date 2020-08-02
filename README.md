
This project contains an application for hosting minecraft servers on AWS. It
has the following features.

0. All infrastructure is defined in code using terraform. So it is relatively
   easy to reproduce.
1. Hosting is done using an EC2 auto-scaling group, which will automatically
   shut-down the server after a period of non-use.  The world is automatically
   saved.
2. There is a website, which an authorized user can use to enable or disable
   the server.

This enables me to host a minecraft server relatively cheaply, depending on
usage.  In practice I pay $12 / year for a domain, $0.50 / month for a hosted
zone in route 53, and about $0.04 per hour for server usage.  Taking into
account the cost of the domain, I pay less than $2 per month for a very capable
server.

World - This refers to a world save, and the server version that it is tied to.  A world can be copied or upgraded.
Server - refers to the server program including version. For example 'Vanilla Minecraft 1.15.2' is a server
Domain - The name that is used to host a unique instance of a minecraft server.  Assuming this service is hosted at 'myminecraft.com' and you launch a server using the domain 'mysurvival' then you can access the server using the domain name 'mysurvival.myminecraft.com'.  This also the endpoint used to get information about the currently running instances.




/api/domains/ - list domains
/api/domains/{name} - information (status) of an individual domain
/api/worlds/ - list worlds
/api/worlds/{name} - details of a world, including server version and configuration
/api/servers/ - list available servers
/api/servers/{name} - information about an individual server



  DomainOwner
   - Can launch world instances on a domain
   - Can stop world instances on a domain
   - Modify their worlds
    - Update server version
   - List their worlds
   - List public worlds
   - Copy public worlds
   - Delete their worlds
  Administrator -
   - Start stop running instances
   - Modify all worlds
   - List all worlds
   - Copy all worlds
   - Delete all worlds

Domain
 + Name / Id - 'Domain/{id}'
 + Owner - user Id 'User/{id}'
 + World - 'World/{id}'

World
 + Id - 'World/{id}'
 + Owner - user Id 'User/{id}'
 + Location (path in S3)
 + Server

Server
 + Id - 'Server/{id}/{version}'
 + Location  (path in S3)
 + verified - True if the file exists (false between posting for upload and actually uploading the server file).


Upload a new server:
  + POST '/api/servers' with body for name and vesion -> generate a new storage location and creates a signed URL - response is a signed upload URL
  + PUT server binary on {upload URL} -> triggers lambda to set 'exists = True'



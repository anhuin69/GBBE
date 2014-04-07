#Gatherbox - Backend
### A generic API to connect to any kind of online storage.
#### [Gatherbox - Frontend](https://github.com/Ephismen/GBFE)

######List of online storages: 
- Google Drive (90%)
- Dropbox (20%)
- Mega (todo)
- FTP (todo)
- More... (todo)

### Documentation
#### Routes

<table>
<tr>
  <th>HTTP Verb</th> 
  <th>Path</th>
  <th>Controller#Action</th>
  <th>Description</th>
</tr>
<tbody>
<tr>
  <td>
POST
  </td>
  <td>
/account/create(.:format)
  </td>
  <td data-route-reqs="users#create">
users#create
  </td>
  <td>Account creation</td>
</tr>
<tr>
  <td>
GET
  </td>
  <td>
/account/info(.:format)
  </td>
  <td data-route-reqs="users#show">
users#show
  </td>
  <td>Account informations</td>
</tr>
<tr>
  <td>
PUT
  </td>
  <td>
/account/update(.:format)
  </td>
  <td data-route-reqs="users#update">
users#update
  </td>
  <td>Account edit</td>
</tr>
<tr>
  <td>
POST
  </td>
  <td>
/account/token(.:format)
  </td>
  <td data-route-reqs="users#token">
users#token
  </td>
  <td>Login - auth token</td>
</tr>
<tr>
  <td>
GET
  </td>
  <td>
/storages(.:format)
  </td>
  <td data-route-reqs="storages#index">
storages#index
  </td>
  <td>Get all storages</td>
</tr>
<tr>
  <td>
POST
  </td>
  <td>
/storages(.:format)
  </td>
  <td data-route-reqs="storages#create">
storages#create
  </td>
  <td>Add new storage</td>
</tr>
<tr>
  <td>
GET
  </td>
  <td>
/storages/:id(.:format)
  </td>
  <td data-route-reqs="storages#show">
storages#show
  </td>
  <td>Storage informations</td>
</tr>
<tr>
  <td>
PATCH
  </td>
  <td>
/storages/:id(.:format)
  </td>
  <td data-route-reqs="storages#update">
storages#update
  </td>
  <td>Edit storage informations</td>
</tr>
<tr>
  <td>
PUT
  </td>
  <td>
/storages/:id(.:format)
  </td>
  <td data-route-reqs="storages#update">
storages#update
  </td>
  <td>Edit storage informations</td>
</tr>
<tr>
  <td>
DELETE
  </td>
  <td>
/storages/:id(.:format)
  </td>
  <td data-route-reqs="storages#destroy">
storages#destroy
  </td>
  <td>Delete storage</td>
</tr>
<tr>
  <td>
GET
  </td>
  <td>
/storages/:id/changes(.:format)
  </td>
  <td data-route-reqs="storages#changes">
storages#changes
  </td>
  <td>Update remote storage informations</td>
</tr>
<tr>
  <td>
GET
  </td>
  <td>
/storages/:storage_id/files(.:format)
  </td>
  <td data-route-reqs="items#index">
items#index
  </td>
  <td>Storage root files</td>
</tr>
<tr>
  <td>
POST
  </td>
  <td>
/storages/:storage_id/files(.:format)
  </td>
  <td data-route-reqs="items#create">
items#create
  </td>
  <td>Add file/folder to storage</td>
</tr>
<tr>
  <td>
GET
  </td>
  <td>
/storages/:storage_id/files/:id(.:format)
  </td>
  <td data-route-reqs="items#show">
items#show
  </td>
  <td>File informations</td>
</tr>
<tr>
  <td>
PATCH
  </td>
  <td>
/storages/:storage_id/files/:id(.:format)
  </td>
  <td data-route-reqs="items#update">
items#update
  </td>
  <td>Edit file informations</td>
</tr>
<tr>
  <td>
PUT
  </td>
  <td>
/storages/:storage_id/files/:id(.:format)
  </td>
  <td data-route-reqs="items#update">
items#update
  </td>
  <td>Edit file informations</td>
</tr>
<tr>
  <td>
DELETE
  </td>
  <td>
/storages/:storage_id/files/:id(.:format)
  </td>
  <td data-route-reqs="items#destroy">
items#destroy
  </td>
  <td>Delete file</td>
</tr>
<tr>
  <td>
GET
  </td>
  <td>
/storages/:storage_id/files/:id/changes(.:format)
  </td>
  <td data-route-reqs="items#changes">
items#changes
  </td>
  <td>Update remote file informations</td>
</tr>
</tbody>
</table>

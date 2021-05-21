## General Principles about Objects

DocNet data is either binary blobs or JSON objects. The generic form of a DocNet JSON object is

```
{
	"objectClass" : String
	"objectId"    : String
	"mutationId"  : String
	"timeVersion" : Float
	----------------------
    (other key/value pairs...)
}
```

Objects are immutable, once created they never change. This is true to the point that they are stored with a file name that is the named hash of the JSON serialization of the object.  

The `objectClass` attribute indicates the class or type of the object. 

`objectId` is what remain invariant from one version of an object to another. All versions of the same object carry the same `objectId`. 

`mutationId` is a unique id. No two objects of the DocNet universe have the same `mutationId`.

The reason why we have a `objectId` and an `mutationId` is because in addition of being immutable, objects are never deleted from the object repository. The id maniplated by the logic layer of DocNet is the `objectId`, but a `objectId` maps to one or more `mutationId`s which represent the various mutations of the `objectId`, all immutable files and all stored indefinitely.

Having all those versions of the same logical object around poses the immediate problem of knowing which version is the current one ? The answer is simple, the one with the highest `timeVersion`. 

`timeVersion` is a decimal number, the unixtime with decimals of the time the object is issued.

## Data Carriers

The Data Carrier is one of the most important objects of the DocNet universe. They represent the information that make the documentation. Their class is "DataCarrier".

Data carriers existing in various flavours. Each data carrier has a **payload type**. 

The payload type is one of the following

- text 
- url
- aion-point

If the type is "Text" then the payload is a named hash, the hash of the blob of text. (This implies that the object itself mutates everytime the text is updated.)

If the Type is "Url" then the payload is a named hash, the hash of the data blob that contains the url. 

If the type is "AionPoint" then the payload is the named hash of an Aion Point. See the documentation for [Aion Points](Aion-Points.md).

Some readers will notice that DocNet has less payload types than Pascal's Catalyst or Nyx. This is on purpose, as we aim to reduce the list of payload type in DocNet, to help user's mental models. 

### Transmutation

Transmutation is the process by which a data carrier changes payload from one mutationId to another. This process and the reasons for its existence are explained in [Transmutation](Transmutation.md).

### Text Schema

```
DataCarrier {
	"objectClass" : "DataCarrier"
	"objectId"    : String # UUID
	"mutationId"  : String # UUID
	"timeVersion" : Float  # Unixtime with decimal part
	----------------------
	"description" : String
	"payloadType" : "text"
	"payload"     : NamedHash
}
```

The schema for Text nodes, is simple. They are Data Carriers therefore the `objectClass` is set to `"DataCarrier"` and the `payloadType` is set to `"text"`. The Text specific attributes are the description, which is carried by the object itself and the NamedHash of the blob of text.  

### Url Schema

```
DataCarrier {
	"objectClass" : "DataCarrier"
	"objectId"    : String # UUID
	"mutationId"  : String # UUID
	"timeVersion" : Float  # Unixtime with decimal part
	----------------------
	"description" : String
	"payloadType" : "url"
	"payload"     : NamedHash
}
```

Follows the same logic as the text version. Note that the URL is not embedded into the object itself, but commited to disk as a blob and the DataCarrier carries the NamedHash.

### Aion Point Schema

```
DataCarrier {
	"objectClass" : "DataCarrier"
	"objectId"    : String # UUID
	"mutationId"  : String # UUID
	"timeVersion" : Float  # Unixtime with decimal part
	----------------------
	"description" : String
	"payloadType" : "aion-point"
	"payload"     : NamedHash
}
```

## User Identifiers

DocNet is multi-user, but unlike multi users systems such as Wikipedia, Reddit ot 4chan, where membership is a fuzzy concept, with the possibility to remain amonymous, in Docnet we want to have a finer control of who the users are, and notably who can update the data repository (either by creating new data nodes or by editing existing ones). 

A User Identifier is an object of the form

```
UserIdentifier {
	"objectClass" : "UserIdentifier"
	"objectId"    : String
	"mutationId"  : String
	"timeVersion" : Float
	----------------------
	"docNetMembership" : DocNetUserMembershipCard
}

DocNetUserMembershipCard { 
	"version"       : 1
	"name"          : String
	"accessLevel"   : String # "ReadOnly" / "ReadWrite" / "Curator"
	"declaration"   : String
	"challenge"     : String
	"authorization" : String
}
```

In addition of the standard general object attributes, and an `objectClass` set to `"UserIdentifier"`, 

- `name` 
- `docnetMembership` which is an instance of a `DocNetUserMembershipCard`

For the full details of how `DocNetUserMembershipCard.md` work see [DocNetUserMembershipCard.md](DocNetUserMembershipCard.md)

## (Authorship) Claims

Having defined User Identifiers we can introduce a general object that is used to link a particular user to particular objects, called an Authorship Claim. In this current version used to link users to particular Data Carriers, and more exactly users to particular mutations of a Data Carrier.

```
AuthorshipClaim {
	"objectClass" : "AuthorshipClaim"
	"objectId"    : String
	"mutationId"  : String
	"timeVersion" : Float
	----------------------
	"type"        : "User->DataCarrier"
	"source"      : UserIdentifier's objectId
	"target"      : DataCarrier's mutationId 
}
```